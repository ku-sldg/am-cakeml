Build with `make am` (or `make server` and `make client` to build the two separately).

To run the server, you must give it a port number and a queue length as arguments,
e.g. `./server 50000 5`. The queue length sets the maximum backlog for incoming
connections. Run under the same directory as `tests/hashTest.txt`.

The client takes no arguments, just run it with `./client` after the corresponding server has started.

Note that many values are currently hard-coded. At-dispatching attempts to connect at port 50000. In the client test, the remote ip address is hard-coded to loopback and the copland term is a nonce.
