echo "C:\Program Files\7-Zip\7z.exe" x -ojdk_dir tools.zip
echo cd jdk_dir
for /r %x in (*.pack) do .\bin\unpack200 -r "%x" "%~dx%~px%~nx.jar"