Set objShell = WScript.CreateObject("WScript.Shell")

' WScript.Echo TypeName(objShell.Environment("PROCESS").Item("specMatch"))

specMatch = objShell.Environment("PROCESS").Item("specMatch")
specsString = objShell.Environment("PROCESS").Item("specsString")
specsFile = objShell.Environment("PROCESS").Item("specsFile")
outputFormat = objShell.Environment("PROCESS").Item("outputFormat")
output = objShell.Environment("PROCESS").Item("output")
bestMatch = objShell.Environment("PROCESS").Item("bestMatch")


Function ParseVersion(versions)
	t = Split(versions, ".")
	major = t(0)
	minor = "x"
	patch = "x"
	If UBound(t) > 0 Then minor = t(1) End If
	If UBound(t) > 1 Then patch = t(2) End If
	set dict = CreateObject("Scripting.Dictionary")
	dict.Add "major", major
	dict.Add "minor", minor
	dict.Add "patch", patch
	set ParseVersion = dict
End Function

Function SplitInplace(ByRef arr, idx, sed)
	s = arr(0)
    ReDim arr(-1)
    arr = Split(s, sed)
End Function

Function ParseSpec(verSpec)
	Dim t
	verSpec = Replace(verSpec, vbCrLf, "")


	state = "ok"
	comparator = "="
	version = "x"
	arch = "any"
	patches = "."
	carry = ""

	If InStr(verSpec, "$") <> 0 Then
		t = Split(verSpec, "$", 2)
		verSpec = t(0)
		carry = t(1)
		verSpec = Replace(verSpec, " ", "")
	End If

	ReDim t(-1)
	t = Array(verSpec)

	If InStr(t(0), "[") <> 0 Then
  		SplitInplace t, 0, "["
        if Right(t(1), 1) = "]" Then
        	patches = Left(t(1), Len(t(1)) - 1)
        End If
	End If
	' if ($t[0].Contains('[')) { $state = 'error' }

	If InStr(t(0), "@") <> 0 Then
		SplitInplace t, 0, "@"
		arch = t(1)
	End If
	' if ($t[0].Contains('@')) { $state = 'error' }

	If InStr(t(0), "=") <> 0 Then
		SplitInplace t, 0, "="
		version = t(1)
	End If
	' if ($t[0].Contains('=')) { $state = 'error' }
	name = t(0)

	set dict = ParseVersion(version)
	dict.Add "name", name
	dict.Add "arch", arch
	dict.Add "patches", patches
	dict.Add "carry", carry


	set ParseSpec = dict
End Function


' set dict = ParseSpec("a=1.2[c]$b")
' arr = dict.Items
' For i = 0 To UBound(dict.Items)
'     WScript.Echo arr(i)
' Next



Function Match(R, T)
	If R.Item("name") <> "" And R.Item("name") <> T.Item("name") Then
		Match = 0
		Exit Function
	End If
    If R.Item("arch") <> "any" And T.Item("arch") <> "any" And R.Item("arch") <> T.Item("arch") Then
		Match = 0
		Exit Function
	End If
	If R.Item("major") <> "x" And T.Item("major") <> "x" And R.Item("major") <> T.Item("major") Then
		Match = 0
		Exit Function
	End If
	If R.Item("minor") <> "x" And T.Item("minor") <> "x" And R.Item("minor") <> T.Item("minor") Then
		Match = 0
		Exit Function
	End If
	If R.Item("patch") <> "x" And T.Item("patch") <> "x" And R.Item("patch") <> T.Item("patch") Then
		Match = 0
		Exit Function
	End If
	' If R.Item("patches") <> "." And T.Item("patch") <> "x" And R.Item("patch") <> T.Item("patch")
	' 	Then set Match = 0 Exit Function End If
	Match = -1
End Function

' WScript.Echo Match(ParseSpec("a=1.x[c]$b"), ParseSpec("b=1.2[c]$b"))


Class cFormat
	Private m_oSB
	Private Sub Class_Initialize()
		Set m_oSB = CreateObject("System.Text.StringBuilder")
	End Sub ' Class_Initialize
	Public Function formatArray(sFmt, aElms)
		m_oSB.AppendFormat_4 sFmt, (aElms)
		formatArray = m_oSB.ToString()
		m_oSB.Length = 0
	End Function ' formatArray
End Class ' cFormat

Set oFormat = New cFormat


Function SpecToArray(spec)
	arr = Array(spec.Item("name"), spec.Item("major"), _
	            spec.Item("minor"), spec.Item("patch"), _
	            spec.Item("arch"), spec.Item("patches"), _
	            spec.Item("carry"), """")
	SpecToArray = arr
End Function

Function FormatSpec(spec)
	If spec.Item("carry") <> "" Then
		FormatSpec = oFormat.formatArray("{0}={1}.{2}.{3}@{4}[{5}]${6}", SpecToArray(spec))
	Else
		FormatSpec = oFormat.formatArray("{0}={1}.{2}.{3}@{4}[{5}]", SpecToArray(spec))
	End If
End Function

Function FormatSpecForSort(spec)
	FormatSpecForSort = oFormat.formatArray( _
    	"{0,-15}={1,10}.{2,10}.{3,10}@{4,8}[{5}]${6}", SpecToArray(spec))
End Function

Function FormatSpecForCmd(spec)
	If spec.Item("carry") <> "" Then
		FormatSpecForCmd = oFormat.formatArray("{0} {1} {2} {3} {4} {5} {7}{6}{7}", SpecToArray(spec))
	Else
		FormatSpecForCmd = oFormat.formatArray("{0} {1} {2} {3} {4} {5}", SpecToArray(spec))
	End If
End Function


' WScript.Echo FormatSpecForCmd(ParseSpec("a=1.x[c]$b"))

Function SortArray(ByRef arrShort)
Dim i, j, temp
    For i = UBound(arrShort) - 1 To 0 Step -1
        For j = 0 To i
            If Split(arrShort(j), "_")(2) > Split(arrShort(j + 1), "_")(2) Then
                temp = arrShort(j + 1)
                arrShort(j + 1) = arrShort(j)
                arrShort(j) = temp
            End If
        Next
    Next
    SortArray = arrShort
End Function

Sub Reverse( ByRef myArray )
	Dim i, j, idxLast, idxHalf, strHolder

	idxLast = UBound( myArray )
	idxHalf = Int( idxLast / 2 )

	For i = 0 To idxHalf
		strHolder              = myArray( i )
		myArray( i )           = myArray( idxLast - i )
		myArray( idxLast - i ) = strHolder
	Next
End Sub

Function SelectVersion()
	Dim specsStrings
    If specsString <> "" Then
    	specsStrings = Split(specsString, " ")
    End If
    If specsFile <> "" Then
    	Set fso = CreateObject("Scripting.FileSystemObject")
    	Set objFile = fso.GetFile(specsFile)
    	if objFile.Size > 0 Then
	    	fileCtx = fso.OpenTextFile(specsFile).ReadAll
			specsStrings = Split(fileCtx, vbCrLf)
			ReDim Preserve specsStrings(UBound(specsStrings) - 1)
		End If
    End If
    If IsEmpty(specsStrings) Then
    	Exit Function
	End If
	' if ($specsString) { $specsStrings = $specsString.Split(' ')}
    ' if ($specsFile) { $specsStrings = Get-Content $specsFile }
    ' if (!$specsStrings) { return }

    Set specs = CreateObject("System.Collections.ArrayList")
    ' specs = Array()
	For i = 0 To UBound(specsStrings)
		' ReDim Preserve specs(UBound(specs) + 1)
		str = specsStrings(i)

		set spec = ParseSpec(Trim(str))
		spec = FormatSpecForSort(spec)
		specs.Add spec
		' WScript.Echo spec
		' specs(UBound(specs)) = spec
	Next
	specs.Sort()
	specs.Reverse()
	' For i = 0 To specs.Count
	' 	specs(i) = ParseSpec(specs(i))
	' Next

	if specMatch <> "" Then
		Set specMatchObj = ParseSpec(specMatch)
	End If

	specsOutput = Array()
	For Each spec in specs
		Set specObj = ParseSpec(spec)
		If specMatch = "" Or Match(specMatchObj, specObj) Then
			If bestMatch = "" Or UBound(specsOutput) < 0 Then
				ReDim Preserve specsOutput(UBound(specsOutput) + 1)
			    specsOutput(UBound(specsOutput)) = GetRef(formatter)(specObj)
		    End If
	    End If
	Next

	if output <> "" Then
		Set objFSO=CreateObject("Scripting.FileSystemObject")
		Set objFile = objFSO.CreateTextFile(output, True)
		For i = 0 To UBound(specsOutput)
		    objFile.Write specsOutput(i) & vbCrLf
		Next
		objFile.Close
    Else
    	Set fso = CreateObject ("Scripting.FileSystemObject")
		Set stdout = fso.GetStandardStream(1)
    	For i = 0 To UBound(specsOutput)
		    stdout.Write specsOutput(i) & vbCrLf
		Next
    End If
End Function

' specsString = "app2=3.1.X@x86[a,b] app2=2.1.X@x86[a,b]"
' specMatch = "app2=3"
' outputFormat = "cmd"
' output = ""
' bestMatch = "1"
formatter = "FormatSpec"
if outputFormat = "cmd" Then
    formatter = "FormatSpecForCmd"
End If

SelectVersion
