#!/bin/sh

# create a dump on a external harddisk

##
# For each HOST you should define the directories to backup 
##
case $HOSTNAME in
        elektron*)
        DIRS="/home/miekg/bin"
        ;;

        floep*)
        DIRS=
        ;;
esac

if [ ! -x /usr/sbin/rdup ]; then 
        zenity --error --title "rdup @ $HOSTNAME" --text "rdup can not be found"
        exit 1
fi

# get the path were we live
if [[ $0 =~ ^/ ]]; then
        p=$0
 else
        p=`pwd`/$0
fi

d=`date +%Y%m`
mountpath=`dirname $p`

if [[ -z $DIRS ]]; then
         zenity --error --title "rdup @ $HOSTNAME" --text "No backup directories defined"
         exit 1
fi

# only to get root 
gksudo -m "Perform backup of $HOSTNAME to $mountpath as root?" -t "rdup @ $HOSTNAME" "cat /dev/null"
if [[ $? -ne 0 ]]; then
        exit
fi

## Set the directories ##
STAMP="$mountpath/$HOSTNAME/$HOSTNAME.timestamp"
LIST="$mountpath/$HOSTNAME/$HOSTNAME.list"
BACKUPDIR="$mountpath/$HOSTNAME"
BACKUPDIR_DATE="$mountpath/$HOSTNAME/$d"

# create top-level backup dir
sudo mkdir -p $BACKUPDIR
if [[ ! -d "$BACKUPDIR_DATE" ]]; then
        # kill the timestamp and inc list
        sudo mkdir -p "$BACKUPDIR_DATE"
        sudo rm -f "$LIST"
        sudo rm -f "$STAMP"
        TEXT="Full dump of $HOSTNAME completed"
else
        TEXT="Incremental dump of $HOSTNAME completed"
fi

sudo /usr/sbin/rdup -N $STAMP $LIST $DIRS |\
sudo /usr/sbin/mirror.sh -b $BACKUPDIR 2>&1 |\
mail -s "$TEXT" root@localhost
# backup completed
zenity --info --title "rdup @ $HOSTNAME" --text "$TEXT"
