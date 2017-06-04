Set objShell = WScript.CreateObject("WScript.Shell")

Set env = objShell.Environment("PROCESS")
specMatch = env.Item("specMatch")
specsString = env.Item("specsString")
specsFile = env.Item("specsFile")
outputFormat = env.Item("outputFormat")
output = env.Item("output")
bestMatch = env.Item("bestMatch")

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
	s = arr(idx)
	ReDim arr(-1)
	arr = Split(s, sed)
End Function

Function Slice(arr, starting, ending)
	out_array = Array()
	ReDim Preserve out_array(ending - starting)
	For index = starting To ending
		out_array(index - starting) = arr(index)
	Next
	Slice = out_array
End Function



Function ParseSpec(verSpec)
	' name:host-venv=3.1.X_x64[default]@local@no-select
	Dim t
	verSpec = Replace(verSpec, vbCrLf, "")

	state = "ok"
	comparator = "="
	version = "x"
	name = "none"
	arch = "any"
	patches = "."
	options = ""
	carry = ""


	If InStr(verSpec, "$") <> 0 Then
		t = Split(verSpec, "$", 2)
		verSpec = t(0)
		carry = t(1)
		verSpec = Replace(verSpec, " ", "")
	End If

	ReDim t(-1)
	t = Array(verSpec)


	If InStr(t(0), "@") <> 0 Then
		SplitInplace t, 0, "@"
		options = Join(Slice(t, 1, UBound(t)), ",")
	End If

	If InStr(t(0), "[") <> 0 Then
		SplitInplace t, 0, "["
		if Right(t(1), 1) = "]" Then
			patches = Left(t(1), Len(t(1)) - 1)
		End If
	End If
	' if ($t[0].Contains('[')) { $state = 'error' }

	If InStr(t(0), ":") <> 0 Then
		SplitInplace t, 0, ":"
		name = t(0)
		t(0) = t(1)
	End If

	If InStr(t(0), "_") <> 0 Then
		SplitInplace t, 0, "_"
		arch = t(1)
	End If


	If InStr(t(0), "=") <> 0 Then
		SplitInplace t, 0, "="
		app = t(0)
		version = t(1)
	Else
		app = t(0)
	End If


	set dict = ParseVersion(version)
	dict.Add "name", name
	dict.Add "app", app
	dict.Add "arch", arch
	dict.Add "patches", patches
	dict.Add "options", options
	dict.Add "carry", carry

	set ParseSpec = dict
End Function


' set dict = ParseSpec("a=1.2[c]$b")
' set dict = ParseSpec("name:host-venv=3.1.X_x64[p1,p2]@local@no-select$data")
' arr = dict.Items
' For i = 0 To UBound(dict.Items)
' 	WScript.Echo arr(i)
' Next



Function Match(R, T)
	If R.Item("app") <> "" And R.Item("app") <> T.Item("app") Then
		Match = 0
		Exit Function
	End If
	If R.Item("name") <> "none" And R.Item("name") <> T.Item("name") Then
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
	arr = Array(spec.Item("name"), spec.Item("app"), _
				spec.Item("major"), spec.Item("minor"), spec.Item("patch"), _
				spec.Item("arch"), _
				spec.Item("patches"), _
				Join(Split(spec.Item("options"), ","), "@"), _
				spec.Item("carry"), """")
	SpecToArray = arr
End Function

Function FormatSpec(spec)
	specarr = SpecToArray(spec)
	FormatSpec = oFormat.formatArray("{0}:{1}={2}.{3}.{4}_{5}[{6}]", specarr)
	if spec.Item("options") <> "" Then
		FormatSpec = FormatSpec & "@" & specarr(7)
	End If
	if spec.Item("carry") <> "" Then
		FormatSpec = FormatSpec & "$" & specarr(8)
	End If
End Function

Function FormatSpecForSort(spec)
	FormatSpecForSort = oFormat.formatArray( _
		"{0,-20}:{1,-15}={2,10}.{3,10}.{4,10}_{5,8}[{6}]@{7}${8}", SpecToArray(spec))
End Function

Function FormatSpecForCmd(spec)
	specarr = SpecToArray(spec)
	specarr(6) = spec.Item("patches")
	specarr(7) = spec.Item("options")
	FormatSpecForCmd = oFormat.formatArray( _
		"{0} {1} {2} {3} {4} {5} {9}{6}{9} {9}{7}{9} {9}{8}{9}", _
		specarr)
End Function


' WScript.Echo FormatSpecForCmd(ParseSpec("a=1.x[c]$b"))
' WScript.Echo FormatSpecForCmd(ParseSpec("name:host-venv=3.1.X_x64[p1,p2]@local@no-select$data"))

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
		If Replace(str, " ", "") <> "" Then
			set spec = ParseSpec(Trim(str))
			spec = FormatSpecForSort(spec)
			specs.Add spec
		End If
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


formatter = "FormatSpec"
if outputFormat = "cmd" Then
	formatter = "FormatSpecForCmd"
End If
SelectVersion
