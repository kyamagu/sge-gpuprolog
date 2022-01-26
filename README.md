Gridengine GPU prolog
=====================

Scripts to manage NVIDIA GPU devices in SGE 6.2u5.

The last Sun Grid Engine that is packaged in Ubuntu 14.04 LTS does not contain
the RSMAP functionality that is implemented in recent Univa Grid Engine. The
ad-hoc scripts in this package implement resource allocation for NVIDIA devices.


Installation
------------

First, set up consumable complex `gpu`.

    qconf -mc

    #name               shortcut   type        relop   requestable consumable default  urgency
    #----------------------------------------------------------------------------------------------
    gpu                 gpu        INT         <=      YES         JOB        0        0

At each exec-host, add `gpu` resource complex. For example,

    qconf -aattr exechost complex_values gpu=1 node01

Set up `prolog` and `epilog` in the queue.

    qconf -mq gpu.q

    prolog                sgeadmin@/path/to/sge-gpuprolog/prolog.sh
    epilog                sgeadmin@/path/to/sge-gpuprolog/epilog.sh

Alternatively, you may set up a parallel environment for GPU and set
`start_proc_args` and `stop_proc_args` to the packaged scripts.

Usage
-----

Request `gpu` resource in the designated queue.

    qsub -q gpu.q -l gpu=1 gpujob.sh

The job script can access `CUDA_VISIBLE_DEVICES` variable.

    #!/bin/sh
    echo $CUDA_VISIBLE_DEVICES

The variable contains a comma-delimited device IDs, such as `0` or `0,1,2`
depending on the number of `gpu` resources to be requested. Use the device ID
for `cudaSetDevice()`.

Interactive jobs
--------------------
The environment variables provided by Grid Engine for batch jobs are not available to interactive jobs.  Therefore prolog.sh may fail for interactive jobs created using qlogin command. To make all the environment variables available in the job, one can use set_sge_qlogin_env.sh file in ~/.profile or systemwide /etc/profile as shown below:
#
# Sets SGE env variables for qlogin sessions
SGE_QLOGIN_ENV=path_file/set_sge_qlogin_env.sh
if [ -f ${SGE_QLOGIN_ENV} ]
then
    source ${SGE_QLOGIN_ENV}
fi

