if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  
$date = Get-Date -format M-d-yy
$Sources = @( 
"C:\Users\rusty\desktop\"
"C:\Users\rusty\documents\"
"C:\Users\rusty\downloads\"
"C:\Users\rusty\pictures\"
)   
$Target = "d:\backup\$date.7z"
foreach ($source in $sources) {

sz a -mx=9 $Target $Source
}