#!/bin/sh
#
# Finish script to release GPU devices.
#
# Kota Yamaguchi 2015 <kyamagu@vision.is.tohoku.ac.jp>
# Geert Geurts 2017 <geert.geurts@dalco.ch>
# Check if the environment file is readable.
ENV_FILE=$SGE_JOB_SPOOL_DIR/environment
if [ ! -f $ENV_FILE -o ! -r $ENV_FILE ]
then
  exit 1
fi

# Remove lock files.
device_ids=$(awk -F "=" '{if ($1=="SGE_GPU") print $2}' $ENV_FILE|tr "," " ")
for device_id in $device_ids
do
  lockfile=/tmp/lock-gpu$device_id
  if [ -d $lockfile ]
  then
    rmdir $lockfile
  fi
done
exit 0
