./setHash $1 7BE9FDA48F4179E611C698A73CFF09FAF72869431EFEE6EAAD14DE0CB44BBF66503F752B7A8EB17083355F3CE6EB7D2806F236B25AF96A24E22B887405C20081
read -p "Press Enter to continue."
./server 5000 5 &
export SERVER_PID=$!
echo "Server started (hopefully) at pid ${SERVER_PID}."
./client 127.0.0.1 $1
echo "Test completed."
read -p "Press Enter to terminate server and complete program."
kill $SERVER_PID