#!/bin/sh -eux

rm -rf /etc/udev/rules.d/70-persistent-net.rules;

# cleanup ubuntu user account (if it exists)
if id -u ubuntu > /dev/null 2>&1; then
    /usr/sbin/userdel -rf ubuntu
fi

# cleanup any ssh keys nova/cloud-init may have injected
rm -rf /root/.ssh
find  /home/ -maxdepth 2 -type d -name .ssh -exec rm -rf {} \; || true

# per https://aws.amazon.com/articles/0155828273219400
find /root/.*history /home/*/.*history -print0 | xargs -0 rm -f || true
find /home/*/.ssh -name "authorized_keys" -print0 | xargs -0 rm -f || true

sed -i.bak \
    -e 's/^#PermitRootLogin yes/PermitRootLogin yes/' \
    -e 's/^#PermitEmptyPasswords yes/PermitEmptyPasswords no/' \
    -e 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/' \
    -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' \
    -e 's/PasswordAuthentication yes/PasswordAuthentication no/' \
    -e 's/^#X11Forwarding yes/X11Forwarding no/' \
    -e 's/X11Forwarding yes/X11Forwarding no/' \
        /etc/ssh/sshd_config
