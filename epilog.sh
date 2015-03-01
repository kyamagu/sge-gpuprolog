#!/bin/sh
#
# Finish script to release GPU devices.
#
# Kota Yamaguchi 2015 <kyamagu@vision.is.tohoku.ac.jp>

# Check if the environment file is readable.
if [ ! -f $SGE_JOB_SPOOL_DIR/environment -o \
     ! -r $SGE_JOB_SPOOL_DIR/environment ]
then
  exit 1
fi

SGE_GPU=$(grep SGE_GPU $SGE_JOB_SPOOL_DIR/environment | \
  sed -n "s/SGE_GPU=\(.*\)/\1/p")

for device_id in $SGE_GPU
do
  lockfile=/tmp/lock-nvidia$device_id
  if [ -f $lockfile ]
  then
    rm $lockfile
  fi
done
exit 0
