#!/bin/bash

# Start the server process in the background
(../../build/apps/demo/serverdemo ../../apps/demo/server/example_server_three.json > /dev/null 2> s3.err) &
server3_pid=$!

sleep 1
(../../build/apps/demo/serverdemo ../../apps/demo/server/example_server_two.json > /dev/null 2> s2.err) &
server2_pid=$!

sleep 1
(../../build/apps/demo/serverdemo ../../apps/demo/server/example_server.json > /dev/null 2> s1.err) &
server1_pid=$!

sleep 1
# Start the client process in the background
(../../build/apps/demo/clientdemo ../../apps/demo/server/example_client.json > /dev/null 2> client.err) &
client_pid=$!

# Kill the processes using after a delay
sleep 1
kill $server3_pid
kill $server2_pid
kill $server1_pid

cat s1.err s2.err s3.err client.err > combined.err
rm s1.err s2.err s3.err client.err

if [ ! -s "combined.err" ]; then
  rm combined.err
  echo "SUCCESS"
else
  echo "ERROR - Check combined.err for more info"
fi

