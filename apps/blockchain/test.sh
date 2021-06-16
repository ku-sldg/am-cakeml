cd ../tests/
echo -n "Starting the server..."
../../build/apps/blockchain/blockchainServer 5000 5 &
if [ $? -eq 0 ]
then
	export SERVER_PID=$!
	echo "done."
	cd ../../build/apps/blockchain/
	./blockchainSetHash $1 7BE9FDA48F4179E611C698A73CFF09FAF72869431EFEE6EAAD14DE0CB44BBF66503F752B7A8EB17083355F3CE6EB7D2806F236B25AF96A24E22B887405C20081
	read -p "Press enter to launch the client" dummy
	./blockchainClient 127.0.0.1 $1
	kill ${SERVER_PID}
else
	echo "Error starting the server."
fi
