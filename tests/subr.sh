#!/bin/bash

set -uoe pipefail

BNS_CLI="../bns-cli"
HUB_URL="http://localhost:3000"
STORAGE_ROOT="/tmp/gaia-storage"
TEST_ROOT_PREFIX="/tmp/gaia-storage-test"

function get_bns_cli_path() {
   echo "$BNS_CLI"
}

function get_gaia_hub_url() {
   echo "$HUB_URL"
}

function get_storage_root() {
   echo "$STORAGE_ROOT"
}

function abort() {
   echo >&2 "$1"
   exit 2
}

function setup_test_storage() {
   local test_name="$1"
   if [ -z "$test_name" ]; then 
      abort "Missing \$test_name in setup_test_storage"
   fi

   local dir="$TEST_ROOT_PREFIX/$test_name";
   if [ -d "$dir" ]; then 
      rm -rf "$dir"
   fi

   mkdir -p "$dir"
   echo "$dir"
}
