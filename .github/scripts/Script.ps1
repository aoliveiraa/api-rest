param (
    [Parameter()]
    [string]$BasePath
)

$ErrorActionPreference = "Stop"

& npm install -g webdriver-manager

Start-Sleep -Seconds 10

& webdriver-manager update

Start-Sleep -Seconds 10

#start dotnet application
$dotnet = Start-Job -ScriptBlock {
    Get-ChildItem $using:BasePath\publish\*.exe | ForEach { & $_.FullName }
}

Start-Sleep -Seconds 10

Receive-Job $dotnet

#start server 
$server = Start-Job -ScriptBlock {
    cd $using:BasePath\opentest\server
    opentest server
}

Start-Sleep -Seconds 15

Receive-Job $server

#start actor 
$actor = Start-Job -ScriptBlock {
    cd $using:BasePath\opentest\actor-web
    opentest actor
}

Start-Sleep -Seconds 15

Receive-Job $actor

New-Item "$BasePath\test-results" -ItemType Directory
& opentest session create --template "Go to test" --wait --out $BasePath\test-results\junit.xml

exit 0
