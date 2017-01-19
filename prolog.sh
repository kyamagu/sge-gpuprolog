#!/bin/sh
#
# Startup script to allocate GPU devices.
#
# Kota Yamaguchi 2015 <kyamagu@vision.is.tohoku.ac.jp>
# Geert Geurts 2017 <geert.geurts@dalco.ch>
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
NGPUS=$(expr $NGPUS \* ${NSLOTS=1})

# Check if the environment file is writable.
ENV_FILE=$SGE_JOB_SPOOL_DIR/environment
if [ ! -f $ENV_FILE -o ! -w $ENV_FILE ]
then
  exit 1
fi

# Allocate and lock GPUs.
SGE_GPU=""
i=0
device_ids=$(ls /dev/nvidia[0-9]*|grep -oE "[0-9]+")
for device_id in $device_ids
do
  lockfile=/tmp/lock-gpu$device_id
  if mkdir $lockfile
  then
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
  echo "ERROR: Only able to reserve $i of $NGPUS requested devices."
  for device_id in $SGE_GPU; do
	lockfile=/tmp/lock-gpu$device_id
	rmdir $lockfile
  done
  exit 1
fi

# Set the environment.
echo SGE_GPU="$(echo $SGE_GPU | sed -e 's/^ //' | sed -e 's/ /,/g')" >> $ENV_FILE
exit 0
