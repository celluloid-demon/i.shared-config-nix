#!/bin/bash

# check if IOMMU grouping is enabled
#sudo dmesg | grep -i -e DMAR -e IOMMU

# check if IOMMU groups are valid
shopt -s nullglob

for g in /sys/kernel/iommu_groups/*; do
  echo "IOMMMU Group ${g##*/}:"
  for d in $g/devices/*; do
    echo -e "\t$(lspci -nns ${d##*/})"
  done;
done;
