#!/bin/bash

# Access UI from localhost:5705
echo "Creating a tunnel for the UI as a background process"
kubectl -n storageos port-forward svc/storageos 5705:5705 &>/dev/null &

echo -e "Access the Storageos UI at \033[0;32m http://localhost:5705\033[0m"
echo "You can use localhost to send cli requests by running export STORAGEOS_HOST=127.0.0.1"
echo "To kill the tunnel you can run pkill --full \"kubectl -n storageos port-forward svc/storageos\""

