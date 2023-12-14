#!/bin/bash

# More info: https://fabianlee.org/2021/01/10/kvm-creating-and-reverting-libvirt-external-snapshots/

# name of the domain (vm) and target disk space
domain="Windows11Pro"
targetdisk="sda"

# name new snapshot
# todo hard-coded is fine for now (it's predictable), but should extract prefix from backing file via current active snapshot xml dump, copy xpath expression
backingfilebasename="win11"
if [ -z "$backingfilebasename" ]; then
  # if unset, no dot separator needed
  separator=""
else
  # if set, dot separator needed
  separator="."
fi
snapshotbasename="snapshot"
ext=""
# note: $ext could be empty, or be ".qcow2" (include the dot if you do!) - know what you're looking for

# look for an existing, latest snapshot image and set our new snapshot version
filebasename=${backingfilebasename}${separator}${snapshotbasename}
# first, ask if a snapshot file exists (at any version count)
if [[ -e ${filebasename}*${ext} || -L ${filebasename}*${ext} ]]; then

  # snapshots found!
  i=1

  while [[ -e ${snapshotprefix}.${snapshotbasename}${i}${ext} || -L ${snapshotprefix}.${snapshotbasename}${i}${ext} ]]; do

    let i++

  done

  snapshotname=${snapshotbasename}${i}

fi

# look at '<disk>' types, should be just 'file' types
virsh dumpxml $domain | grep '<disk' -A5

# show block level devices and qcow2 paths (sda, sdb, etc...)
virsh domblklist $domain

# save snapshot
# note: saved snapshot file is prefixed by (most-upstream) backing file's (basename) filename, rather than the domain
virsh snapshot-create-as $domain --name $snapshotname --disk-only
