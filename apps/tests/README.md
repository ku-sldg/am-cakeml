# Test for Copland #

A series of tests for the interpreter, largely revolving around the crypto functionality. Build with `make test`. Make sure to run in the same directory as `hashTest.txt` for the file hash test to work.

## Contents ##

- `testDir/`&mdash;a test directory to be hashed.
- `hashTest.txt`&mdash;a test file to be hashed.
- `Main.sml`&mdash;the code that checks the hashes with the current
  golden values hard-coded into the file, uses OpenSSL only.
- `Main_tpm.sml`&mdash;same as previous only uses TPM instead of OpenSSL.
- `Main_hacl.sml`&mdash;same as previous only uses Evercrypt instead of OpenSSL.

## How to create 2048-bit RSA Signing Keys ##

```shell
openssl genrsa -out rsa.pem
openssl rsa -in rsa.pem -outform derm | hexdump -v -e '1/1 "%02x"' # private key
openssl rsa -in rsa.pem -RSAPublicKey_out -outform der | hexdump -v -e '1/1 "%02x"' # public key
```

## How to create 2048-bit ##

```shell
openssl dhparam -out dhparam.pem 2048
openssl genpkey -paramfile dhparam.pem -out dhkey1.pem
openssl genpkey -paramfile dhparam.pem -out dhkey2.pem
openssl pkey -in dhkey1.pem -outform der | hexdump -v -e '1/1 "%02x"' # 1st private key
openssl pkey -in dhkey1.pem -pubout -outform der | hexdump -v -e '1/1 "%02x"' # 1st public key
openssl pkey -in dhkey2.pem -outform der | hexdump -v -e '1/1 "%02x"' # 2nd private key
openssl pkey -in dhkey2.pem -pubout -outform der | hexdump -v -e '1/1 "%02x"' # 2nd public key
```
