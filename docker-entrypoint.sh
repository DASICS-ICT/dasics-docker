#!/bin/bash

# Add a new user with the same host UID
useradd -u $HOST_UID -s /bin/bash -o -m user

# Add the new user to the root group
usermod -aG root user

# Change ownership of the /workspace directory to the new user
chown -R $HOST_UID /workspace

# Configure sudoers file to allow the new user to run sudo commands without a password
echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Copy zsh configurations to user
cp -r /root/.oh-my-zsh /home/user/.oh-my-zsh && chown -R user:user /home/user/.oh-my-zsh
cp /root/.zshrc /home/user/.zshrc && chown -R user:user /home/user/.zshrc
chsh -s /bin/zsh user

# Execute the specified command as the new user using gosu
exec gosu user "$@"
