#/bin/bash

ldap stop

cd /opt/zimbra/data/ldap
mv mdb mdb.old
mkdir -p mdb/db
cd /opt/zimbra/data/ldap
mv accesslog accesslog.old
mkdir -p accesslog/db
