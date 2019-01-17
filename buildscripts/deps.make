# A representation of the dependencies in our CakeML source code, inspired by
# Makefile syntax (hence the `.make` extension to get syntax highlighting).
# topOrd.py can derive a topological ordering from this to be used as an
# appension ordering

# Syntax:
# Each line should either
#     a) start with a `#`, denoting a comment
#     b) be empty (the line is ignored)
#     c) consist of a filename, followed by a colon, then a space-separated
#        list of file dependencies
# If the dependencies list is long, you may use a backslash to continue on to
# the next line without it being considered a new dependency description thing

CoplandLang.sml: ByteString.sml CoqDefaults.sml

Measurements.sml: CoplandLang.sml ByteString.sml crypto/Random.sml \
                  crypto/CryptoFFI.sml

crypto/Aes256.sml: ByteString.sml crypto/CryptoFFI.sml

crypto/Random.sml: crypto/Aes256.sml crypto/CryptoFFI.sml

crypto/CryptoFFI.sml: ByteString.sml

sockets/SocketFFI.sml: ByteString.sml

Eval.sml: CoplandLang.sml CoqDefaults.sml ByteString.sml Measurements.sml

Main.sml: Eval.sml ByteString.sml CoplandLang.sml Measurements.sml \
          crypto/Aes256.sml
