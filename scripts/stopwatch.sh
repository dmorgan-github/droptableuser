#!/bin/sh

start=$(date +%s)
while true; do
    time="$(($(date +%s) - $start))"
    printf '%s\r' "$(date -u -r "$time" +%H:%M:%S)"
    sleep 0.1
done
