# Make qlogin set SGE env variables in interactive sessions
# To make all the environemt variables available in the job, you can use this 
# in your ~/.profile or systemwide /etc/profile as shown below:
#
# Sets SGE env variables for qlogin sessions
# SGE_QLOGIN_ENV=path_file/set_sge_qlogin_env.sh
# if [ -f ${SGE_QLOGIN_ENV} ]
# then
#    source ${SGE_QLOGIN_ENV}
# fi
# 

MYPARENT=`ps -p $$ -o ppid --no-header`
MYSTARTUP=`ps -p ${MYPARENT} -o command --no-header`

if [ "${MYSTARTUP:0:13}" = "sge_shepherd-" ]; then
	MYJOBID=${MYSTARTUP:13}
	MYJOBID=${MYJOBID% -bg}
	HOST_SHORT="$(cut -d'.' -f1 <<<"${HOSTNAME}")"	# extract host from host.xxx.yyy
	ENV_FILE=/var/spool/sge/betsy/execd/"${HOST_SHORT}"/active_jobs/"${MYJOBID}".1/environment
	if [ -f "${ENV_FILE}" ]; then
		while read LINE; do export "${LINE}"; done < "${ENV_FILE}"
		unset HISTFILE
	fi
fi
