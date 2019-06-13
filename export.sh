#!/bin/bash
#
#@author : SHERTY BEN
#@mail   : shertyben@gmail.com
#@Date   : 13/06/2019
#
#

start_time="$(date -u +%s)"

cd /home/migration/

WD="/home/migration"
remote="A.B.C.D"
Directory_Paths= "accounts accounts_details aliases distro domains mailboxes passwords quotas signatures"

echo "****************************";
echo "!Début Création Répertoires!" ;
echo "****************************";

for dir in Directory_Paths;
do
        echo " >>>> Checking if directory $dir exists ..." ;

        if [ ! -d "$WD/$dir" ]; then
                echo " >>>>@@@@ Directory $dir doesn't exists ..." ;
                mkdir -p $WD/$dir# Control will enter here if $DIRECTORY doesn't exist.
                echo " >>>>@@@@ Directory $dir created..." ;
        else
                echo " >>>>@@@@ Directory $dir exists ..." ;
                rm -r $WD/$dir/*
                echo " >>>>@@@@ Directory $dir truncated ..." ;
        fi
done
echo "**************************";
echo "!Fin Création Répertoires!" ;
echo "**************************";



# Exporting all domains existing on Zimbra Server
#truncate --size 0  $WD/domains/domains.txt

echo "***********************";
echo "!Début export domaines!" ;
echo "***********************";
zmprov gad | tee -a  $WD/domains/domains.txt
echo "*********************";
echo "!Fin export domaines!" ;
echo "*********************";

echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";


# Exporting all users ID
truncate --size 0  $WD/accounts/users.txt

# Exporting all users
echo "***************************";
echo "!Début export utilisateurs!" ;
echo "***************************";
zmprov -l gaa | egrep -v 'admin|wiki|galsync|spam|ham|virus' | tee -a  $WD/accounts/users.txt
echo "*************************";
echo "!Fin export utilisateurs!" ;
echo "*************************";

echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";



# Exporting all users details and Password
echo "*******************************";
echo "!Début export details accounts!" ;
echo "*******************************";


rm -rf  $WD/passwords/*.shadow

for user in `cat  $WD/accounts/users.txt`;
do
    zmprov ga $user  | grep -i Name: | tee -a  $WD/account_details/$user.txt ;
    zmprov -l ga $user userPassword | grep userPassword: | awk '{ print $2}' | tee -a  $WD/passwords/$user.shadow;
done

echo "*****************************";
echo "!Fin export details accounts!" ;
echo "*****************************";
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";


# Exporting all distro lists
truncate --size 0  $WD/distro/distro_list.txt

echo "*************************************";
echo "!Début export liste de distributions!"
echo "*************************************";


zmprov gadl | tee -a  $WD/distro/distro_list.txt
for list in `cat  $WD/distro/distro_list.txt`;
do
    zmprov gdlm $list >  $WD/distro/$list.txt ;
    echo "$list";
done
echo "***********************************";
echo "!Fin export liste de distributions!"
echo "***********************************";
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";


# Exporting all aliasess

echo "**************************************"
echo "!Debut Export des alias  utilisateurs!" ;
echo "**************************************"

#for user in `cat accounts/users.txt`;
#do
#   zmprov ga  $user | grep zimbraMailAlias | awk '{print $2}' | tee -a $user.txt ;
#   echo $i ;
#   echo "Exporting alias $i" ;
#done
#
#echo "Fin export Utilisateurs"
echo "***********************************";
echo "!Fin export des alias utilisateurs!"
echo "**********************************";
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";


## Exporting users's Mail boxes

echo "****************************************"
echo "!Debut Export des mailbox  utilisateurs!" ;
echo "****************************************"

rm -rf $WD/mailboxes/*

for user in `cat  $WD/accounts/users.txt`;
    do
        echo " >>>> Exporting mailbox $user" ;
        zmmailbox -z -m $user getRestURL '/?fmt=tgz' >  $WD/mailboxes/$user.tgz ; #mailboxes
    done
echo "Fin Export des mails";

echo "***************************************";
echo "!Fin export des mailboxes utilisateurs!"
echo "***************************************";
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";


## Exporting users's quotas
echo "***************************************"
echo "!Debut Export des quotas  utilisateurs!" ;
echo "***************************************"

FILE_QUOTAS="$WD/quotas/users_quota.sh"

if [ -f "$FILE_QUOTAS" ];
then
    $FILE_QUOTAS
    truncate --size 0 $FILE_QUOTAS
else
    touch $FILE_QUOTAS
    chmod +x $FILE_QUOTAS
fi


echo "#!/bin/bash" >> $FILE_QUOTAS
for user in `cat $WD/accounts/users.txt`;
        do
                echo " >>>> Exporting quota of user  $user" ;
                QUOTA_TOTAL=`zmprov ga ${user} | grep "zimbraMailQuota" | cut -d ":" -f2`
        echo " zmprov ma ${user} zimbraMailQuota ${QUOTA_TOTAL} " >> $FILE_QUOTAS
        done
echo "************************************"
echo "!Fin Export des quotas utilisateurs!" ;
echo "************************************"
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";

## Exporting users's signatures
rm -rf $WD/signatures/*

FILE_SIGNATURE="$WD/signatures/singatures.sh"

if [ -f "$FILE_SIGNATURE" ];
then
    $FILE_SIGNATURE
    truncate --size 0 $FILE_SIGNATURE
else
    touch $FILE_SIGNATURE
    chmod +x $FILE_SIGNATURE
fi

echo "#!/bin/bash"  >> $FILE_SIGNATURE

echo "*****************************************";
echo "!Début export signatures utilisateurs...!"
echo "*****************************************";

for user in `cat  $WD/accounts/users.txt`;
do
    echo " >>>> Exporting Signature for user $user " ;
    zmprov ga $user zimbraPrefMailSignatureHTML > $WD/signatures/$user
    sed -i -e "1d" $WD/signatures/$user
    sed 's/zimbraPrefMailSignatureHTML: //g' $WD/signatures/$user > $WD/signatures/$user.sig
    rm $WD/signatures/$user
    echo "zmprov ma $Acc zimbraPrefMailSignature '$user.sig'" >> $FILE_SIGNATURE
done

echo "***************************************";
echo "!Fin export signatures utilisateurs...!";
echo "***************************************";
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";

echo "*****************************************************";
echo "!Début synchronisation du répertoire de migration...!"
echo "*****************************************************";

rsync -arvz $WD/* $remote:$WD/

echo "***************************************************";
echo "!Fin synchronisation du répertoire de migration...!";
echo "***************************************************";
echo " ";
echo " ";
echo "///////////////////////////////////////////////////////////////////////////////";
echo " ";
echo " ";



echo "Done!" ;
echo " ";
echo " ";
echo "******     *     *      *" ;
echo "*          *     * *    *";
echo "*          *     *  *   *";
echo "*****      *     *   *  *";
echo "*          *     *    * *";
echo "*          *     *     * ";
echo "*          *     *      *";
echo " ";
echo " ";
echo " ";

end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"

days=$(( elapsed/60/60/24  ))
hours=$(( elapsed/60/60%24  ))
minutes=$(( elapsed/60%60  ))
secondes==$(( elapsed%60  ))


echo "...Le processus d'export a pris $days jour(s) $hours heure(s) et $secondes seconde(s)...";

echo " ";
echo " ";
echo " ";
echo " ";
echo " ";

start_time="$(date -u +%s)"

echo "+++++++++++++++++++++++++++++++++++++++++++++++++";
echo "!Début import des données sur le serveur distant! ";
echo "+++++++++++++++++++++++++++++++++++++++++++++++++";

ssh root@$remote $WD/start_backup.sh

echo "+++++++++++++++++++++++++++++++++++++++++++++++";
echo "!Fin import des données sur le serveur distant!";
echo "+++++++++++++++++++++++++++++++++++++++++++++++";

end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"

days=$(( elapsed/60/60/24  ))
hours=$(( elapsed/60/60%24  ))
minutes=$(( elapsed/60%60  ))
secondes==$(( elapsed%60  ))


echo "...Le processus d'import a pris $days jour(s) $hours heure(s) et $secondes seconde(s)...";


exit;





