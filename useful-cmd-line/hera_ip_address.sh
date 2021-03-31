#!/bin/bash
# Print IP Address for this specific compute node
# only known to work for GPU nodes on Hera's fge partition


export interface=eno1
export ip_address=`ip address show $interface | grep -Po '(?<=[inet]) (\d+\.\d+\.\d+\.\d+)' | sed 's: ::g'`

echo " --- Compute Node Connection ---"
echo "interface: $interface"
echo "ip_address: $ip_address"
echo ""
