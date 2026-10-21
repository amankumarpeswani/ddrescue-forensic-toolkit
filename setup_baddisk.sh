#!/bin/bash
# Remove any old fake disk first (ignore errors if none exist)
sudo dmsetup remove baddisk 2>/dev/null
#Attach disk.img as a loop device and remember its name
LOOP=$(sudo losetup -f --show disk.img)

#Create the fake drive with two unreadable spots
sudo dmsetup create baddisk <<EOF
0 20000 linear $LOOP 0
20000 16 error
20016 129984 linear $LOOP 20016
150000 16 error
150016 259584 linear $LOOP 150016
EOF
sudo blockdev --setro /dev/mapper/baddisk
echo "Fake failing drive ready: /dev/mapper/baddisk (backed by $LOOP)"

