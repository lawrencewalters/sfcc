#!/bin/bash
# expects a tmp/dwjson/dw.(site id).json and tmp/gulpconfigs/config.(site id).json to exist
# also expects dw.credentials.json with username, password, client-id and client-secret, will get injected into dw.json so that the credentials don't matter in the tmp/dwjson/dw.(site id).json file

source ~/.nvm/nvm.sh

nvm use 20

cp tmp/dwjson/dw.$1.json dw.json

# Update dw.json with credentials from dw.credentials.json... so creds don't matter in tmp/dwjson/dw.$1.json
python3 - <<'PY'
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
PY

cp tmp/gulpconfigs/config.$1.json gulp_builder/config.$1.json

echo "Switched SFCC environment to $1"
echo "Cleaning js and css"

find . -path "./app_*/cartridge/static/default/css/*"  -name "*.css" -o -name "*.map"  -type f -delete

find . -path "./app_*/cartridge/static/default/js/*" -name "app.js" -o -name "app.min.js" -type f -delete

nvm use 10

cd gulp_builder

gulp delete styles js --config config.$1.json

cd ..

nvm use 20

npx b2c-tools code deploy --log-level info

npx b2c-tools code watch --log-level info