#!/bin/bash

#check if already joined to domain

if [[ $(realm list) != "" ]]
then
echo "This server is already joined to domain."
realm list | head -n 1
exit
fi

function update_sssd_config() {
    sed -i 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf
    sed -i 's|/home/%u@%d|/home/%u|g' /etc/sssd/sssd.conf
    systemctl restart sssd
}

function restrict_ssh_access_group() {
    if [[ $(cat /etc/ssh/sshd_config | grep -o "updated_by_ad_join") != "updated_by_ad_join" ]]
    then
    echo "###############updated_by_ad_join.sh###############" >> /etc/ssh/sshd_config
    echo "AllowGroups root ssh-access-group" >> /etc/ssh/sshd_config
    systemctl restart sshd
    fi
}

function sudo_access_level_group() {
    if [[ $(cat /etc/sudoers | grep -o "updated_by_ad_join") != "updated_by_ad_join" ]]
    then
    echo "###############updated_by_ad_join.sh###############" >> /etc/sudoers
    echo "Cmnd_Alias SUDO_ACCESS_LEVEL1 = /usr/bin/ls, /usr/bin/cat " >> /etc/sudoers
    echo "Cmnd_Alias SUDO_ACCESS_LEVEL2 = /usr/bin/vi, /usr/bin/nano " >> /etc/sudoers

    echo "%sudo-group-level1 ALL=(ALL) NOPASSWD: SUDO_ACCESS_LEVEL1"  >> /etc/sudoers
    echo "%sudo-group-level2 ALL=(ALL) NOPASSWD: SUDO_ACCESS_LEVEL2"  >> /etc/sudoers
    echo "%sudo-group-full-access ALL=(ALL) NOPASSWD: ALL"  >> /etc/sudoers
    fi
}

#check os 
if [[ $(cat /etc/os-release | egrep "centos|redhat|fedora|rhel|oracle|rocky") != "" ]]
then
yum install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients  -y
realm join -vvv --user=administrator ad.example.com

#call function
update_sssd_config

restrict_ssh_access_group

sudo_access_level_group

fi