#!/bin/bash

# Access UI from localhost:5705
echo "Sending a tunnel for UI in background"
oc -n storageos port-forward svc/storageos 5705:5705 &>/dev/null &

echo "You can use localhost to send cli requests by running export STORAGEOS_HOST=127.0.0.1"
echo "To kill the tunnel you can run pkill --full \"oc -n storageos port-forward svc/storageos\""


