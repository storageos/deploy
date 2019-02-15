#!/bin/bash


kubectl -n storageos exec cli -- storageos node ls | tail -n1 | awk '{print $1}'

