#!/usr/bin/bash
# $1 is the address of the `credentialManager` smart contract
# $2 is the address of the `HealthRecord` smart contract
cd ../tests/
echo -n "Starting the server..."
../../build/apps/blockchain/blockchainServer ../blockchain/config.ini &
if [ $? -eq 0 ];
then
	export SERVER_PID=$!
	echo "done."
	cd ../../build/apps/blockchain/
	# '7BE9FDA4...05C20081' is the golden hash value
	./blockchainSetHash ../../../apps/blockchain/config.ini
	read -p "Press enter to launch the client." dummy
	./blockchainClient ../../../apps/blockchain/config.ini
	read -p "Press enter to relaunch client." dummy
	./blockchainClient ../../../apps/blockchain/config.ini
	kill ${SERVER_PID}
	exit $?
else
	echo "Error starting the server."
	exit 1
fi
