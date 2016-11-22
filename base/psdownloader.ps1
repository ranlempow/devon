$scriptHome = $env:VA_HOME + '\base'
$errorFile = '{0}\download_error' -f $env:Temp

if (!$url -or !$output) {
    Set-Content $errorFile ('[download] Arguments Broken {0}, {1}' -f $url, $output)
    Exit 1
}
if ($SkipExists) {
    if (Test-Path $output){
        pushd $scriptHome
        .\print.cmd normal message cached $output
        popd
        Exit 0
    }
}
pushd $scriptHome
.\print.cmd normal message fetch $url
popd

$request = [System.Net.WebRequest]::Create($url)
$request.UserAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:46.0) Gecko/20100101 Firefox/46.0'

$request.headers.Set('Cookie', $Cookie)
try {
    $response = $request.GetResponse()
    $remoteHost = $request.headers.Get('Host')
} catch {
    $remoteHost = $request.headers.Get('Host')
    $response = $null
}
if (!$response) {
    Set-Content $errorFile ('[download] Unable connect to {0}' -f $remoteHost)
    Exit 1
}
$responseStream = $response.GetResponseStream()
if ($response.StatusDescription -eq 'OK') {
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $output, Create
} else {
    Set-Content $errorFile ('[download] Remote server reject, code: {0}' -f $response.StatusDescription)
    Exit 1
}
if (!$targetStream) {
    Set-Content $errorFile ('[download] Unable Create File: {0}' -f $output)
    Exit 1
}
$totalLength = [System.Math]::Floor($response.ContentLength/1024)
if ($totalLength -eq -1) { $totalLength = '?'; }


$buffer = new-object byte[] 8KB
$count = $responseStream.Read($buffer, 0, $buffer.length)
$downloadedBytes = $count
while ($count -gt 0) {
    [System.Console]::CursorLeft = 0
    [System.Console]::Write('Downloaded {0}K / {1}K', [System.Math]::Floor($downloadedBytes/1024), $totalLength)

    $targetStream.Write($buffer, 0, $count)
    $count = $responseStream.Read($buffer, 0, $buffer.length)
    $downloadedBytes = $downloadedBytes + $count 
}
[System.Console]::CursorLeft = 0
[System.Console]::Write('                                          ')
[System.Console]::CursorLeft = 0
pushd $scriptHome
.\print.cmd info message write $output
popd

$targetStream.Flush()
$targetStream.Close()
$targetStream.Dispose()
$responseStream.Dispose()
