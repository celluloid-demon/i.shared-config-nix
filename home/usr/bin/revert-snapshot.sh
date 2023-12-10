#!/bin/bash

# More info: https://fabianlee.org/2021/01/10/kvm-creating-and-reverting-libvirt-external-snapshots/

# ==============================================================================
# =                                                                            =
# = To see the machanism underneath and prepare variables for the revert of    =
# = the snapshot, execute the commands below.                                  =
# =                                                                            =
# ==============================================================================

# name of the domain (vm), target disk space, and snapshot
domain="Windows11Pro"
targetdisk="sda"
snapshotname="snapshot1.qcow2"

# notice path to sda has now changed to snapshot file
virsh domblklist $domain

# <source> has changed to snapshot file
virsh dumpxml $domain | grep '<disk' -A5

# snapshot points to backing file, which is original disk
snapshotfile=$(virsh dumpxml $domain | xmllint --xpath "string(//domain[@type='kvm']/devices/disk[@type='file'][@device='disk']/source/@file)" -)
echo "snapshot file is: $snapshotfile"
sudo qemu-img info "$snapshotfile" -U --backing-chain

# reverse-engineer original backing file name so we can revert
backingfile=$(qemu-img info "$snapshotfile" -U | grep -Po 'backing file:\s\K(.*)')
echo "backing file is: $backingfile"

# ==============================================================================
# =                                                                            =
# = To do therevert we need to modify the domain xml back to the original      =
# = qcow2 file, delete the snapshot metadata, and finally the snapshot file.   =
# =                                                                            =
# ==============================================================================

# stop vm
virsh destroy $domain

# edit sda path back to original qcow2 disk
# todo instead of original disk this should probably be whatever current backing file is
virt-xml $domain --edit target=$targetdisk --disk path="$backingfile" --update

# validate that we are now pointing back at original qcow2 disk
virsh domblklist $domain

# delete snapshot metadata
virsh snapshot-delete --metadata $domain --snapshotname $snapshotname

# delete snapshot file
sudo rm "$snapshotfile"

# (optional) start guest domain
# virsh start $domain













