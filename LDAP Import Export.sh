#/bin/bash
mkdir -p /home/migration/accounts
mkdir -p /home/migration/account_details
mkdir -p /home/migration/passwords
mkdir -p /home/migration/aliases
mkdir -p /home/migration/distro
mkdir -p /home/migration/domains
su -c "/home/migration/migration.sh" - zimbra