#!/bin/sh
#
# Finish script to release GPU devices.
#
# Kota Yamaguchi 2015 <kyamagu@vision.is.tohoku.ac.jp>

# Check if the environment file is readable.
ENV_FILE=$SGE_JOB_SPOOL_DIR/environment
if [ ! -f $ENV_FILE -o ! -r $ENV_FILE ]
then
  exit 1
fi

# Remove lock files.
for device_id in $(grep SGE_GPU $ENV_FILE | sed -n "s/SGE_GPU=\(.*\)/\1/p" | xargs shuf -e)
do
  lockfile=/tmp/lock-nvidia$device_id
  if [ -f $lockfile ]
  then
    rm $lockfile
  fi
done
exit 0
