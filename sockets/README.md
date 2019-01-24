# Status
The CakeML basis library has recently been changed such that the Client and Server tests will not compile. They should still work properly on older versions of the compiler (I believe [this](https://cakeml.org/regression.cgi/job/690) is the most recent compatible version).

Aside from the tests, the socket code still compiles and works, but there is currently no way to read/write/close them. This is because I was using the file operations in TextIO, which have since been changed to work exclusively on files opened through the basis library.
