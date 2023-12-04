#!/bin/bash

# Make the fake user's UID and GID the same as the host
usermod  -u $HOST_UID user
groupmod -g $HOST_GID user

# Change the owner of directories to new user
chown -R user:user /workspace
chown -R user:user /home/user

# Execute the specified command as the new user using gosu
exec gosu user "$@"
