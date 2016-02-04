#!/bin/bash

#
# bash_ec2_completion
# Bash helper script that fetches ec2 instances via aws-cli
# and adds their Name=>PublicIp pairs to ~/.ssh/config
# and thus allows you to see them with SSH completion
# and to connect by their names
#
# Autofetch is performed daily.
# To set the default user name for SSH connections
#    change the $_EC2_DEFAULT_SSH_USER variable below
#
# Dependencies:
#  * aws-cli (must be configured)
#  * perl
#

# Default user name for ssh connections to EC2 instances
# You can change it if you use username different from a local one
_EC2_DEFAULT_SSH_USER=$(whoami)

# Reload period of EC2 instance list 
_EC2_UPDATE_INTERVAL="1440"

# Path to ssh_config file
_SSH_USER_CONFIG_PATH="$HOME/.ssh/config"

# Fetches PublicIp=>InstanceName pairs and prints an ssh_config-ready text
_ec2_completion_fetch()
{
	aws ec2 describe-instances \
		--query 'Reservations[].Instances[].[PublicIpAddress,Tags[?Key==`Name`].Value[]]' \
		--output text \
		| sed '$!N;s/\n/ /' \
		| while read line; do \
	    	cols=($line)
	    	cat << EOT
Host ${cols[1]}
	Hostname ${cols[0]}
	User ${_EC2_DEFAULT_SSH_USER}
EOT
		done
}

# Updates the contents of ssh_config file
_ec2_completion_reload()
{
	rm -f ${_SSH_USER_CONFIG_PATH}_bak
	rm -f ${_SSH_USER_CONFIG_PATH}_tmp
	cp ${_SSH_USER_CONFIG_PATH} ${_SSH_USER_CONFIG_PATH}_bak
	cp ${_SSH_USER_CONFIG_PATH} ${_SSH_USER_CONFIG_PATH}_tmp

	perl -0pi -e 's/\s*# AWS BEGIN.+AWS END//sg' ${_SSH_USER_CONFIG_PATH}_tmp

	echo '# AWS BEGIN' >> ${_SSH_USER_CONFIG_PATH}_tmp
	echo '# This section is created automatically at ' `date` >> ${_SSH_USER_CONFIG_PATH}_tmp
	_ec2_completion_fetch >> ${_SSH_USER_CONFIG_PATH}_tmp
	echo '# AWS END' >> ${_SSH_USER_CONFIG_PATH}_tmp

	mv -f ${_SSH_USER_CONFIG_PATH}_tmp ${_SSH_USER_CONFIG_PATH}
}

# Check if it is time to refresh the list of EC2 instances, and updates
# the list if necessary. Then calls the default ssh completion script
_ec2_completion_complete()
{
	# replocess daily
	if [[ -n $(find ${_SSH_USER_CONFIG_PATH} -mmin +${_EC2_UPDATE_INTERVAL}) ]]
	then
		# run asyncronously if possible
		_ec2_completion_reload >/dev/null 2>/dev/null &
	fi
	
	# proxy call to the default ssh completion handler
    _ssh "$@"
}

# attach to ssh
complete -o default -F _ec2_completion_complete ssh
