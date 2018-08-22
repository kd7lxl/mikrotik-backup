#!/bin/bash
# Returns a list of HamWAN Mikrotik routers from the HamWAN portal
json=$(curl -s https://encrypted.hamwan.org/host/ansible.json)
hamwan=$(jq -r '.HamWAN[]' <<< "$json" | sort -u)
mikrotik=$(jq -r '.mikrotik[]' <<< "$json" | sort -u)
comm -12 <(echo "$hamwan") <(echo "$mikrotik")
