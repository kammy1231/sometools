#!/bin/bash

readonly XX=$1 #start time xxxx
readonly YY=$2 #end time xxxx
readonly ZZ=$3 #iostat time 1=10sec
readonly END="==============================endline=================================\n"
readonly LOGDIR=/var/log/stat
readonly LOGDAY=`date +"%Y%m%d"`

Xtop()
{
  while :
  do
    t=`date +"%H%M"`
    if [ $t -ge $XX ] && [ $t -lt $YY ]; then
      date >> $LOGDIR/toplog-$LOGDAY.log
      top -bc -n 1 | head -15 >> $LOGDIR/toplog-$LOGDAY.log
      vmstat >> $LOGDIR/toplog-$LOGDAY.log
      echo -e "$END" >> $LOGDIR/toplog-$LOGDAY.log
      sleep 10
    else
      echo -e "----------- next day -----------" >> $LOGDIR/toplog-$LOGDAY.log
      return 0
    fi
  done
}

Xps()
{
  while :
  do
    t=`date +"%H%M"`
    if [ $t -ge $XX ] && [ $t -lt $YY ]; then
      date >> $LOGDIR/pslog-$LOGDAY.log
      ps auxf | egrep -v "\[*\]" >> $LOGDIR/pslog-$LOGDAY.log
      echo -e "$END" >> $LOGDIR/pslog-$LOGDAY.log
      sleep 10
    else
      echo -e "----------- next day -----------" >> $LOGDIR/pslog-$LOGDAY.log
      return 0
    fi
  done
}

Xiostat()
{
  while :
  do
    t=`date +"%H%M"`
    if [ $t -ge $XX ] && [ $t -lt $YY ]; then
      echo -e "--- `date` start iostart command/10sec-----------" >> $LOGDIR/iolog-$LOGDAY.log
      iostat -mxN 10 $ZZ >> $LOGDIR/iolog-$LOGDAY.log
      echo -e "$END" >> $LOGDIR/iolog-$LOGDAY.log
      sleep 10
    else
      echo -e "----------- next day -----------" >> $LOGDIR/iolog-$LOGDAY.log
      return 0
    fi
  done
}

Xmpstat()
{
  while :
  do
    t=`date +"%H%M"`
    if [ $t -ge $XX ] && [ $t -lt $YY ]; then
      echo -e "--- `date` start mpstart command/10sec-----------" >> $LOGDIR/mplog-$LOGDAY.log
      mpstat -P ALL 10 $ZZ >> $LOGDIR/mplog-$LOGDAY.log
      echo -e "$END" >> $LOGDIR/mplog-$LOGDAY.log
      sleep 10
    else
      echo -e "----------- next day -----------" >> $LOGDIR/mplog-$LOGDAY.log
      return 0
    fi
  done
}

Main()
{
  mkdir -p $LOGDIR
  while :
  do
    t=`date +"%H%M"`
    if [ $t -lt $XX ]; then
      sleep 10
    else
      Xps $1 $2 &
      Xtop $1 $2 &
      Xiostat $1 $2 $3 &
      Xmpstat $1 $2 $3 &
      wait
      return 0
    fi
  done
}

ArgsCheck()
{
  if [ $# -ne 3 ]; then
    echo "command starttime[xxxx] endtime[xxxx] iotimes[*]"
    exit 1
  elif [ $1 -ge $2 ]; then
    echo "bad start datetime"
    exit 1
  elif [ $1 -ge 0001 ] && [ $1 -le 2359 ] && [ $2 -ge 0001 ] && [ $2 -le 2359 ]; then
    return 0
  else
    echo "bad start or end datetime"
    exit 1
  fi
}

#####
ArgsCheck $1 $2 $3
Main $1 $2 $3
exit 0
#####
