
# `bash_ec2_completion`

Bash helper script that fetches ec2 instances via aws-cli
and adds their Name=>PublicIp pairs to ~/.ssh/config
and thus allows you to see them with SSH completion
and to connect by their names

## The benefits

`bash_ec2_completion` is written in pure shell scrit, and
depends on aws-cli and perl only.

## Configuration

Autofetch is performed daily.

To set the default user name for SSH connection, 
change the `$_EC2_DEFAULT_SSH_USER` variable.

## Dependencies:
 * bash_completion (with SSH completion of course)
 * aws-cli (must be configured)
 * perl

## Installation

Put the `bash_ec2_completion.sh` somewhere in your system
and the invoke it in your `~/.bash_profile`:

```
. /path/to/bash_ec2_completion.sh
```

For OS X + brew users it may look like that:

```
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
  . /path/to/bash_ec2_completion.sh
fi
```