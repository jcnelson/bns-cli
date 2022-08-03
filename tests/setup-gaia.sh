#!/bin/bash

STORAGE_ROOT="$1"
if [ -z "$STORAGE_ROOT" ]; then 
   echo >&2 "Usage: $0 /path/to/storage/root"
   exit 1
fi
   
set -uoe pipefail

if ! [ -d "$STORAGE_ROOT" ]; then
   mkdir -p "$STORAGE_ROOT" || exit 1
fi

REPO="https://github.com/stacks-network/gaia"
REPO_DIR="/tmp/gaia"

HUB_CONFIG="$REPO_DIR/config-hub.json"
READER_CONFIG="$REPO_DIR/config-reader.json"

function setup_repo() {
   if ! [ -d "$REPO_DIR" ]; then
      git clone "$REPO" "$REPO_DIR"
      pushd "$REPO_DIR" >/dev/null
      
      echo "Setting up hub"
      cd ./hub && npm install && npm run build
      cd ..

      echo "Setting up reader"
      cd ./reader && npm install && npm run build
      cd ..

      echo "Setting up admin"
      cd ./admin && npm install && npm run build
      cd ..

      echo "Github repo setup"
      popd >/dev/null
   fi

   return 
}

function run_hub() {
   echo "Setting up hub"

   cat << EOF > "$HUB_CONFIG"
{
  "port": 3000,
  "driver": "disk",
  "readURL": "http://localhost:3001/",
  "serverName": "localhost:3000",
  "diskSettings": {
      "storageRootDirectory": "$STORAGE_ROOT"
  },
  "argsTransport": {
    "level": "debug",
    "handleExceptions": true,
    "timestamp": true,
    "colorize": false,
    "json": true
  }
}
EOF

   echo "Starting hub"
   cd "$REPO_DIR/hub" && node ./lib/index.js "$HUB_CONFIG"
}

function run_reader() {
   echo "Setting up reader"

   cat << EOF > "$READER_CONFIG"
{
   "port": 3001,
   "diskSettings": {
      "storageRootDirectory": "$STORAGE_ROOT"
   }
}
EOF

    echo "Starting reader"
    cd "$REPO_DIR/reader" && node ./lib/index.js "$READER_CONFIG"
}

setup_repo
run_hub &
HUB_PID="$!"

run_reader &
READER_PID="$!"

wait "$HUB_PID"
wait "$READER_PID"
exit 0

