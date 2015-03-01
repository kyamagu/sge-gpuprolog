#!/bin/sh
#
# Startup script to allocate GPU devices.
#
# Kota Yamaguchi 2015 <kyamagu@vision.is.tohoku.ac.jp>

# Query how many gpus to allocate.
NGPUS=$(qstat -j $JOB_ID | \
  sed -n "s/hard resource_list:.*gpu=\([[:digit:]]\+\).*/\1/p")
if [ -z $NGPUS ]
then
  exit 0
fi
if [ $NGPUS -le 0 ]
then
  exit 0
fi

# Check if the environment file is writable.
if [ ! -f $SGE_JOB_SPOOL_DIR/environment -o \
     ! -w $SGE_JOB_SPOOL_DIR/environment ]
then
  exit 1
fi

# Allocate and lock GPUs.
SGE_GPU=""
i=0
for device in $(ls /dev/nvidia[0-9])
do
  device=$(basename $device)
  device_id=$(echo $device | sed -e s/nvidia//g)
  lockfile=/tmp/lock-$device
  if [ -f $lockfile ]
  then
    continue
  else
    touch $lockfile
    SGE_GPU="$SGE_GPU $device_id"
    i=$(expr $i + 1)
    if [ $i -ge $NGPUS ]
    then
      break
    fi
  fi
done

if [ $i -lt $NGPUS ]
then
  echo "WARNING: Only reserved $i of $NGPUS requested devices."
fi

# Set the environment.
echo SGE_GPU="$(echo $SGE_GPU | sed -e 's/^ //')" >> $SGE_JOB_SPOOL_DIR/environment
exit 0
