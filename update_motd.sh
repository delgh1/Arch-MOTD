#!/bin/bash
#Script to update motd with relevant information.

#Define output file
motd="/etc/motd"

# Collect information
HOSTNAME=`uname -n`
KERNEL=`uname -r`
CPU=`awk -F '[ :][ :]+' '/^model name/ { print $2; exit; }' /proc/cpuinfo`
CPU_VENDOR=`lscpu | grep "Vendor ID:" | awk '{print $3}'`
CORES=`lscpu | grep 'Core(s) per socket:' | awk '{print $4}'`
ARCH=`uname -m`
#if [ -x "/usr/bin/checkupdates" ]; then
#  PACMAN=`checkupdates -n | wc -l`
#fi
DETECTDISK=`mount -v | grep -F 'on / ' | sed -n 's_^\(/dev/[^ ]*\) .*$_\1_p'`
DISC=`df -h | grep $DETECTDISK | awk '{print $5 }'`
MEMORY1=`free -t -m | grep "Mem" | awk '{print $6" MB";}'`
MEMORY2=`free -t -m | grep "Mem" | awk '{print $2" MB";}'`
MEMPERCENT=`free | awk '/Mem/{printf("%.2f% (Used) "), $3/$2*100}'`

BOOT_TYPE=""
CPU_TEMP="N/A"
MAX_OK_TEMP="85.0'C"
SERVICES_RUNNING=`systemctl | grep running | wc -l`
FAILED_SERVICES=`systemctl status | grep Failed | head -n1 | awk {'print $2'}`
NET_INTERFACE=`ip -o link show | grep "state UP" | awk {'print $2'} | sed "s|:||g"`
#IPV4_ADDRESS=`ip -4 -o address show $NET_INTERFACE | grep inet | awk {'print $4'}`
#IPV6_ADDRESS=`ip -6 -o address show $NET_INTERFACE | grep inet6 | grep "scope global" | awk {'print $4'}`
#IPV6LL_ADDRESS=`ip -6 -o address show $NET_INTERFACE | grep inet6 | grep "scope link" | awk {'print $4'}`
LOCAL_TIME=`timedatectl status | grep "Local time" | sed "s|\s* Local time: ||g"`
NTP_SERVICE_STATUS=`timedatectl status | grep "NTP service" | sed "s|\s* NTP service: ||g" | awk {'print $1'}`
TIME_SYNCED=`timedatectl status | grep "clock synchronized" | sed "s|.* clock synchronized: ||g" | awk {'print $1'}`
TIME_ZONE=`timedatectl status | grep "Time zone" | sed "s|.* Time zone: ||g" | awk {'print $1'}`


if [ "$TIME_SYNCED" == "yes" ]; then
  TIME_SYNC_STATUS="Synchronised"
else
  TIME_SYNC_STATUS="NOT Synchronised"
fi

if [ "$CPU_VENDOR" == "ARM" ]; then
  BOOT_TYPE="PI"
elif [ -d /sys/firmware/efi ]; then
  BOOT_TYPE="UEFI"
else
  BOOT_TYPE="BIOS"
fi


#Time of day
HOUR=$(date +"%H")
if [ $HOUR -lt 12  -a $HOUR -ge 0 ]
then   TIME="morning"
elif [ $HOUR -lt 17 -a $HOUR -ge 12 ]
then   TIME="afternoon"
else   TIME="evening"
fi

#System uptime
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))


#System load
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`

#Color variables
##W="\033[00;37m"
W="\033[0m"
B="\033[01;36m"
R="\033[01;31m"
G="\033[01;32m"
N="\033[0m"

# # Xterm 256 colors
# if [ "$TERM" == "xterm-256color" ]; then
  # R="\033[38;5;9m"
  # O="\033[38;5;214m"
  # Y="\033[38;5;11m"
  # G="\033[38;5;28m"
  # B="\033[38;5;21m"
  # P="\033[38;5;90m"
# fi

#Clear screen before motd
cat /dev/null > $motd

if [ "$CPU_VENDOR" == "ARM" ]; then
CPU_TEMP=`/opt/vc/bin/vcgencmd measure_temp | sed "s/=/ /" | awk {'print $2'}`

  # if [ "$TERM" == "xterm-256color" ]; then
    # echo -e "
       # $R. $W
      # $R/#\ $B                    _     $W _ _                   $W _ 
     # $O/###\ $B     __ _ _ __ ___| |__  $W| (_)_ __  _   ___  __ $W| |  _   ___ __  __ 
    # $Y/#####\ $B   / _' | '__/ __| '_ \ $W| | | '_ \| | | \ \/ / $W| | / \ | _ \  \/  |
   # $G/##.-.##\ $B | (_| | | | (__| | | |$W| | | | | | |_| |>  <  $W| |/ ^ \|   / |\/| |
  # $B/##(   )##\ $B \__,_|_|  \___|_| |_|$W|_|_|_| |_|\__._/_/\_\ $W| /_/ \_\_|_\_|  |_|
 # $P/#.--   --.#\ $W                                            $W|_|   $G>$R Raspberry Pi$W
# $P/'           '\ $W
# " > $motd
  # else
echo -e "
       $B. $W
      $B/#\ $B                    _     $W _ _                   $W _ 
     $B/###\ $B     __ _ _ __ ___| |__  $W| (_)_ __  _   ___  __ $W| |  _   ___ __  __ 
    $B/#####\ $B   / _' | '__/ __| '_ \ $W| | | '_ \| | | \ \/ / $W| | / \ | _ \  \/  |
   $B/##.-.##\ $B | (_| | | | (__| | | |$W| | | | | | |_| |>  <  $W| |/ ^ \|   / |\/| |
  $B/##(   )##\ $B \__,_|_|  \___|_| |_|$W|_|_|_| |_|\__._/_/\_\ $W| /_/ \_\_|_\_|  |_|
 $B/#.--   --.#\ $W                                            $W|_|   $G>$R Raspberry Pi$W
$B/'           '\ $W
" > $motd
  # fi
else
  # if [ "$TERM" == "xterm-256color" ]; then
    # echo -e "
        # $R. $W
       # $R/#\ $B                     _     $W _ _
      # $O/###\ $B      __ _ _ __ ___| |__  $W| (_)_ __  _   ___  __ 
     # $Y/#####\ $B    / _' | '__/ __| '_ \ $W| | | '_ \| | | \ \/ /
    # $G/##.-.##\ $B  | (_| | | | (__| | | |$W| | | | | | |_| |>  <  
   # $B/##(   )##\ $B  \__,_|_|  \___|_| |_|$W|_|_|_| |_|\__._/_/\_\\
  # $P/#.--   --.#\ $W
 # $P/'           '\ $W
# " > $motd
  # else
echo -e "
       $B. $W
      $B/#\ $B                    _     $W _ _
     $B/###\ $B     __ _ _ __ ___| |__  $W| (_)_ __  _   ___  __ 
    $B/#####\ $B   / _' | '__/ __| '_ \ $W| | | '_ \| | | \ \/ /
   $B/##.-.##\ $B | (_| | | | (__| | | |$W| | | | | | |_| |>  <  
  $B/##(   )##\ $B \__,_|_|  \___|_| |_|$W|_|_|_| |_|\__._/_/\_\\
 $B/#.--   --.#\ $W
$B/'           '\ $W
" > $motd
  # fi
fi

echo -e "$G--------------------------------------------------------------------" >> $motd
echo -e "$W   Good $TIME$A. You're Logged Into $B$A$HOSTNAME$W! " 	     >> $motd
echo -e "$G--------------------------------------------------------------------" >> $motd
echo -e "$B         KERNEL $G:$W $KERNEL $ARCH                                 " >> $motd
echo -e "$B            CPU $G:$W $CPU                                          " >> $motd
echo -e "$B          CORES $G:$W $CORES                                        " >> $motd
echo -e "$B         MEMORY $G:$W $MEMORY1 / $MEMORY2 - $MEMPERCENT             " >> $motd
echo -e "$B       USE DISK $G:$W $DISC (Used)                                  " >> $motd
echo -e "$B      BOOT TYPE $G:$W $BOOT_TYPE                                    " >> $motd
#echo -e "$B   IPV4 ADDRESS $G:$W $IPV4_ADDRESS ($NET_INTERFACE)                " >> $motd
#echo -e "$B   IPV6 ADDRESS $G:$W $IPV6_ADDRESS ($NET_INTERFACE)                " >> $motd
#echo -e "$B IPV6LL ADDRESS $G:$W $IPV6LL_ADDRESS ($NET_INTERFACE)              " >> $motd
if [ "$CPU_VENDOR" == "ARM" ]; then
echo -e "$B       CPU TEMP $G:$W $CPU_TEMP (max allowed: $MAX_OK_TEMP)         " >> $motd
fi
echo -e "$G--------------------------------------------------------------------" >> $motd
echo -e "$B       SERVICES $G:$W $SERVICES_RUNNING running / $FAILED_SERVICES failed " >> $motd
echo -e "$B       LOAD AVG $G:$W $LOAD1, $LOAD5, $LOAD15                       " >> $motd
echo -e "$B         UPTIME $G:$W $upDays days $upHours hours $upMins minutes $upSecs seconds " >> $motd
#if [ -x "/usr/bin/checkupdates" ]; then
#echo -e "$B        PACMAN $G:$W $PACMAN packages can be updated               " >> $motd
#fi
echo -e "$B          USERS $G:$W `users | wc -w` users logged in               " >> $motd
echo -e "$B            NTP $G:$W $NTP_SERVICE_STATUS ($TIME_SYNC_STATUS)       " >> $motd
echo -e "$B    SYSTEM TIME $G:$W $LOCAL_TIME ($TIME_ZONE)                      " >> $motd
echo -e "$G--------------------------------------------------------------------" >> $motd
echo -e "$N" >> $motd
