#!/bin/bash

echo "If you see the date, the test is successful"

docker run -it --rm -v /mnt:/mnt:shared busybox sh -c /bin/date
