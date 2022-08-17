#!/bin/bash

source ./subr.sh

gaia_cli="$(get_gaia_cli_path)"
hub_url="$(get_gaia_hub_url)"
gaia_storage_root="$(get_storage_root)"
test_storage="$(setup_test_storage test_putfile)"

privkey="d3a7e5ca9b4ab15326c1fd084b86045fa7b6a7d7005a422630166530514d6843"
addr="1MndDXXcY6kH6bXz3pKsCBTGJHevUtiKqZ"
gaia_auth="v1:eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJnYWlhQ2hhbGxlbmdlIjoiW1wiZ2FpYWh1YlwiLFwiMFwiLFwibG9jYWxob3N0OjMwMDBcIixcImJsb2Nrc3RhY2tfc3RvcmFnZV9wbGVhc2Vfc2lnblwiXSIsImh1YlVybCI6Imh0dHA6Ly9sb2NhbGhvc3Q6MzAwMCIsImlzcyI6IjAzNTk3OTY3NjJjNWUzYTQxZmRlY2U1MzJjOGQ4M2ExYTI1ZTQxODFjZWE4M2Y1YTlkNmM4NzEyOWQxNjEzNjdjOCIsInNhbHQiOiJiZjIzYmM1NTM5Nzg2YWEyNmI2OTJhZjJmMDNiMTM3YSIsInNjb3BlcyI6W119.BXDFlDTsXKjTVRj4UGV7-n3rWCqGwsGzVICatSSeb5JOL7F_wUyglzDSoU0qTIA__g2nsIDuENbr8b9HWd_abA"
gaia_auth_addr="1J3esDdYub5VGmewsaKoJguK6AB8Ws1b7n"

function init() {
   local gaia_dir="$gaia_storage_root/$addr";
   local gaia_auth_dir="$gaia_storage_root/$gaia_auth_addr";
   if [ -d "$gaia_dir" ]; then
      rm -rf "$gaia_dir"
   fi
   if [ -d "$gaia_auth_dir" ]; then
      rm -rf "$gaia_auth_dir"
   fi
}

function test_plaintext_putfile() {
   echo "plaintext putfile" > "$test_storage/test_plaintext_putfile"

   "$gaia_cli" putfiles -h "$hub_url" -k "$privkey" -p -s a "$test_storage/test_plaintext_putfile"

   test -f "$gaia_storage_root/$addr/a" || \
      abort "test_plaintext_putfile: did not create file '$filename' at $gaia_storage_root/$addr/a"

   # file contents are the same
   cmp "$gaia_storage_root/$addr/a" "$test_storage/test_plaintext_putfile" || \
      abort "test_plaintext_putfile: contents of $gaia_storage_root/$addr/a do not match $test_storage/test_plaintext_putfile"

   return 0
}

function test_plaintext_putfile_gaia_auth() {
   echo "plaintext putfile gaia auth" > "$test_storage/test_plaintext_putfile_gaia_auth"

   "$gaia_cli" putfiles -h "$hub_url" -g "$gaia_auth" -p -s ag "$test_storage/test_plaintext_putfile_gaia_auth"

   test -f "$gaia_storage_root/$gaia_auth_addr/ag" || \
      abort "test_plaintext_putfile_gaia_auth: did not create file '$filename' at $gaia_storage_root/$gaia_auth_addr/a"

   # file contents are the same
   cmp "$gaia_storage_root/$gaia_auth_addr/ag" "$test_storage/test_plaintext_putfile_gaia_auth" || \
      abort "test_plaintext_putfile_gaia_auth: contents of $gaia_storage_root/$gaia_auth_addr/ag do not match $test_storage/test_plaintext_putfile_gaia_auth"

   return 0
}

function test_plaintext_signed_putfile() {
   echo "plaintext signed putfile" > "$test_storage/test_plaintext_signed_putfile"

   "$gaia_cli" putfiles -h "$hub_url" -k "$privkey" -p b "$test_storage/test_plaintext_signed_putfile"

   test -f "$gaia_storage_root/$addr/b" ||
      abort "test_plaintext_signed_putfile: did not create file 'b' at $gaia_storage_root/$addr/b"

   # file contents are the same
   cmp "$gaia_storage_root/$addr/b" "$test_storage/test_plaintext_signed_putfile" ||
      abort "test_plaintext_signed_putfile: contents of $gaia_storage_root/$addr/b do not match $test_storage/test_plaintext_signed_putfile"

   # signature exists
   test -f "$gaia_storage_root/$addr/b.sig" ||
      abort "test_plaintext_signed_putfile: no such file: $gaia_storage_root/$addr/b.sig"

   # signature is valid
   "$gaia_cli" decodefile -k "$privkey" -o "$addr" -p "$gaia_storage_root/$addr/b" "$gaia_storage_root/$addr/b.sig" > "$test_storage/test_plaintext_signed_putfile.decoded"
   cmp "$test_storage/test_plaintext_signed_putfile" "$test_storage/test_plaintext_signed_putfile.decoded" ||
      abort "test_plaintext_signed_putfile: could not verify signature"

   return 0
}

function test_signed_encrypted_putfile() {
   echo "signed encrypted putfile" > "$test_storage/test_signed_encrypted_putfile"

   "$gaia_cli" putfiles -h "$hub_url" -k "$privkey" c "$test_storage/test_signed_encrypted_putfile"

   test -f "$gaia_storage_root/$addr/c" ||
      abort "test_signed_encrypted_putfile: did not create file 'c' at $gaia_storage_root/$addr/c"

   # file exists
   test -f "$gaia_storage_root/$addr/c" ||
      abort "test_signed_encrypted_putfile: no such file: $gaia_storage_root/$addr/c"
   
   # file decodes
   "$gaia_cli" decodefile -k "$privkey" -o "$addr" "$gaia_storage_root/$addr/c" > "$test_storage/test_signed_encrypted_putfile.decoded"
   cmp "$test_storage/test_signed_encrypted_putfile" "$test_storage/test_signed_encrypted_putfile.decoded" ||
      abort "test_signed_encrypted_putfile: could not verify signature and/or decode file"

   return 0
}


echo "initializing"
init

echo "test_plaintext_putfile"
test_plaintext_putfile

echo "test_plaintext_putfile_gaia_auth"
test_plaintext_putfile_gaia_auth

echo "test_plaintext_signed_putfile"
test_plaintext_signed_putfile

echo "test_signed_encrypted_putfile"
test_signed_encrypted_putfile

