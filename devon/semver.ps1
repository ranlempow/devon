$comment = 'app[=ver][@arch][patches] app=...'
$comment = 'app1=3.1.X@x86 app2=3.1.X@x86'

function ParseVersion {
    $t = $args[0].split('.')
    $major = $minor = $patch = 'x'
    $major = $t[0]
    if ($t.length -gt 1) { $minor = $t[1] }
    if ($t.length -gt 2) { $patch = $t[2] }
    $r = New-Object PSObject
    $r | Add-Member -type NoteProperty -name major -value $major
    $r | Add-Member -type NoteProperty -name minor -value $minor
    $r | Add-Member -type NoteProperty -name patch -value $patch
    $r
}

filter ParseSpec {
    $verSpec = $_
    $verSpec = $verSpec.replace(([String][char]34), '')
    # $verSpec = $verSpec.replace(([String][char]34), '').replace('==', '=')
    # $verSpec = $verSpec.TrimStart(' ')
    $verSpec, $carry = $verSpec.Split('$', 2)
    $verSpec = $verSpec.replace(' ', '').replace('==', '=')

    $state = 'ok'
    $comparator = '='
    $version = 'x.x.x'
    $arch = 'any'
    $patches = '.'

    $t = @($verSpec)

    if ($t[0].Contains('[')) {
        $t = $t[0].Split('[')
        if ($t[1].EndsWith(']')) {
            $patches = $t[1].TrimEnd(']')
        }
    }
    if ($t[0].Contains('[')) { $state = 'error' }

    if ($t[0].Contains('@')) {
        $t = $t[0].split('@')
        $arch = $t[1].ToLower()
    }
    if ($t[0].Contains('@')) { $state = 'error' }

    if ($t[0].Contains('=')) {
        $t = $t[0].split('=')
        $version = $t[1].ToLower()
    }
    if ($t[0].Contains('=')) { $state = 'error' }
    $name = $t[0]

    if ($state -eq 'error') {
        return $null
    }

    $pVersion = ParseVersion $version
    $r = New-Object PSObject
    $r | Add-Member -type NoteProperty -name name -value $name
    $r | Add-Member -type NoteProperty -name version -value $pVersion
    $r | Add-Member -type NoteProperty -name arch -value $arch
    $r | Add-Member -type NoteProperty -name patches -value $patches
    $r | Add-Member -type NoteProperty -name carry -value $carry
    $r
}

filter FormatSpec {
    if ($_.carry) {
        '{0}={1}.{2}.{3}@{4}[{5}]${6}' -f $_.name, $_.version.major, $_.version.minor, $_.version.patch, $_.arch, $_.patches, $_.carry
    } else {
        '{0}={1}.{2}.{3}@{4}[{5}]' -f $_.name, $_.version.major, $_.version.minor, $_.version.patch, $_.arch, $_.patches
    }
}

filter FormatSpecForSort {
    '{0,-15}={1,10}.{2,10}.{3,10}@{4,8}[{5}]${6}' -f $_.name, $_.version.major, $_.version.minor, $_.version.patch, $_.arch, $_.patches, $_.carry
}

filter FormatSpecForCmd {
    if ($_.carry) {
        '{0} {1} {2} {3} {4} {5} {7}{6}{7}' -f $_.name, $_.version.major, $_.version.minor, $_.version.patch, $_.arch, $_.patches, $_.carry, ([String][char]34)
    } else {
        '{0} {1} {2} {3} {4} {5}' -f $_.name, $_.version.major, $_.version.minor, $_.version.patch, $_.arch, $_.patches
    }
}

function Match {
    $R = $args[0]
    $T = $args[1]
    if ($R.name -ne '' -And $R.name -ne $T.name) { return $false }
    if ($R.arch -ne 'any' -And $T.arch -ne 'any' -And $R.arch -ne $T.arch) { return $false }
    if ($R.version.major -ne 'x' -And $T.version.major -ne 'x' -And $R.version.major -ne $T.version.major) { return $false }
    if ($R.version.minor -ne 'x' -And $T.version.minor -ne 'x' -And $R.version.minor -ne $T.version.minor) { return $false }
    if ($R.version.patch -ne 'x' -And $T.version.patch -ne 'x' -And $R.version.patch -ne $T.version.patch) { return $false }
    if ($R.patches -ne '.' -And $R.patches -ne $T.patches) { return $false }
    return $true
}

filter MatchFilter {
    $R = @($args[0]) | ParseSpec
    if (Match $R $_) { return $_ }
    return $null
}

function SelectVersion {
    if ($specsString) { $specsStrings = $specsString.Split(' ')}
    if ($specsFile) { $specsStrings = Get-Content $specsFile }
    if (!$specsStrings) { return }

    $specs = $specsStrings | Where-Object { $_.Trim(' ') }
    if ($specs -isnot [system.array]) { $specs = @($specs) }
    $specs = $specs | ParseSpec | FormatSpecForSort | Sort-Object -descending | ParseSpec
    if ($specMatch) { $specs = $specs | MatchFilter $specMatch | Where-Object { $_ }}
    if ($specs -eq $null) { return }
    if ($specs -isnot [system.array]) { $specs = @($specs) }

    if ($bestMatch) { $specs = @($specs[0]) }
    $specsOutput = $specs | ForEach-Object { $formatter.invoke($_) }
    if ($output) {
        $specsOutput | Set-Content -path $output
    } else {
        # because Write-Output to pipe that breaks lines to fit console
        # instead we use Write-Host to prevent this issue
        # notice:
        #   Write-Host output '\n' new line character rather than '\r\n'
        $specsOutput | ForEach-Object { Write-Host $_ }
    }
}

function Test {
    # $specsString = 'app2=3.1.X@x86[a,b] app2=2.1.X@x86[a,b]'
    # $specsStrings = @(' app1=3.1.X@x86[a, b] ', 'app1=2.1.X@x86[a, b] ', '  ')
    $specsFile = 'C:\Users\ran\Desktop\brickv\var\tmp\spces-git.ver.txt'
    $specMatch = 'git=2.10@any[ssh-stab]'
    $outputFormat = 'cmd'
    $output = ''
    $bestMatch = 1
}


$formatter = ${function:FormatSpec}
if ($outputFormat -eq 'cmd') { $formatter = ${function:FormatSpecForCmd} }

SelectVersion
