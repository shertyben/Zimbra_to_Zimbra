#/bin/bash


# Importing and creating domains
WD="/home/migration"

echo "***********************";
echo "!Début import domaines!" ;
echo "***********************";

for domain in `cat $WD/domains/domains.txt `;
do
        zmprov cd $domain zimbraAuthMech zimbra ;
        echo " >>>> $domain " ;
done

echo "*********************";
echo "!Fin import domaines!" ;
echo "*********************";
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";

# Retoring users accounts and password
# Exporting all users
echo "***************************************";
echo "!Début import Utilisateurs & Passwords!" ;
echo "***************************************";

PASSWDS="passwords"
ACCOUNT_DETAILS="account_details"
USERS="accounts/users.txt"
for i in `cat $WD/$USERS`
do
        givenName=$(grep givenName: $WD/$ACCOUNT_DETAILS/$i.txt | cut -d ":" -f2)
        displayName=$(grep displayName: $WD/$ACCOUNT_DETAILS/$i.txt | cut -d ":" -f2)
        shadowpass=$(cat $WD/$PASSWDS/$i.shadow)
        echo " >>>> Creating user $i " ;
        zmprov ca $i "TeMpPa55^()" cn "$givenName" displayName "$displayName" givenName "$givenName"
        echo " >>>> Setting user password $i " ;
        zmprov ma $i userPassword "$shadowpass"
done

echo "*************************************";
echo "!Fin import Utilisateurs & Passwords!" ;
echo "*************************************";

echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";


# Restoring all distro lists
echo "*************************************";
echo "!Début export liste de distributions!"
echo "*************************************";


for lists in `cat  $WD/distro/distro_list.txt`;
do
        zmprov cdl $lists ;
        echo " >>>> $lists -- done " ;
done
echo "***********************************";
echo "!Fin export liste de distributions!"
echo "***********************************";
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";

## Adding users to distro List


#for list in `cat $WD/distro/distro_list.txt`
#do
#    for mbmr in `grep -v '#' $WD/distro/$list.txt | grep '@'`
#    do
#        zmprov adlm $list $mbmr
#        echo " >>>> $mbmr has been added to $list" ;
#    done
#done

#echo "Fin ajout utilisateurs dans les listes de distributions " ;

echo "****************************************"
echo "!Debut Export des mailbox  utilisateurs!" ;
echo "****************************************"

for user in `cat $WD/accounts/users.txt`;
do
        echo " >>>> Importing mailbox $user" ;
        zmmailbox -z -m $user postRestURL "/?fmt=tgz&resolve=reset" $WD/mailboxes/$user.tgz ;
done
echo "***************************************";
echo "!Fin export des mailboxes utilisateurs!"
echo "***************************************";
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";

## Importing users's quotas
echo "***************************************"
echo "!Debut Import des quotas  utilisateurs!" ;
echo "***************************************"

sh $WD/quotas/users_quota.sh

echo "************************************"
echo "!Fin import des quotas utilisateurs!" ;
echo "************************************"
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";

echo "*****************************************";
echo "!Début import signatures utilisateurs...!"
echo "*****************************************";

for user in `cat  $WD/accounts/users.txt`;
do
        echo " >>>> Importing signature $user" ;
        $signature=$WD/signatures/$user.sig
        zmprov ma $user zimbraPrefMailSignatureHTML $signature
done


echo "***************************************";
echo "!Fin export signatures utilisateurs...!";
echo "***************************************";
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";





