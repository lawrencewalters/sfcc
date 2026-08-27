# expects a tmp/dwjson/dw.(site id).json and tmp/gulpconfigs/config.(site id).json to exist
# also expects dw.credentials.json with username, password, client-id and client-secret, will get injected into dw.json so that the credentials don't matter in the tmp/dwjson/dw.(site id).json file

param(
    [Parameter(Mandatory=$true)]
    [string]$SiteId
)

fnm use 20

Copy-Item "tmp\dwjson\dw.$SiteId.json" "dw.json"

# Update dw.json with credentials from dw.credentials.json... so creds don't matter in tmp/dwjson/dw.$SiteId.json
$pythonScript = @'
import json
from pathlib import Path

dw_path = Path('dw.json')
credentials_path = Path('dw.credentials.json')

with dw_path.open() as f:
    dw = json.load(f)

with credentials_path.open() as f:
    credentials = json.load(f)

for key, value in credentials.items():
    dw[key] = value

with dw_path.open('w') as f:
    json.dump(dw, f, indent=4)
    f.write('\n')
'@
$pythonScript | python3 -

Copy-Item "tmp\gulpconfigs\config.$SiteId.json" "gulp_builder\config.$SiteId.json"

Write-Host "Switched SFCC environment to $SiteId"
Write-Host "Cleaning js and css"

Get-ChildItem -Path "app_*\cartridge\static\default\css" -Recurse -Include "*.css","*.map" -ErrorAction SilentlyContinue | Remove-Item -Force

Get-ChildItem -Path "app_*\cartridge\static\default\js" -Recurse -Include "app.js","app.min.js" -ErrorAction SilentlyContinue | Remove-Item -Force

fnm use 10

Set-Location "gulp_builder"

gulp delete styles js --config "config.$SiteId.json"

Set-Location ".."

fnm use 20

npx b2c-tools code deploy --log-level info

npx b2c-tools code watch --log-level info
