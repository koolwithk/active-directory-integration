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

sudo_access_level_group