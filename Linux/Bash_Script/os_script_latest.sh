#!/usr/bin/env bash

base=${1%/*}
masksize=${1#*/}

[ $masksize -lt 8 ] && { echo "Max range is /8."; exit 1;}

mask=$(( 0xFFFFFFFF << (32 - $masksize) ))

IFS=. read a b c d <<< $base

ip=$(( ($b << 16) + ($c << 8) + $d ))

ipstart=$(( $ip & $mask ))
ipend=$(( ($ipstart | ~$mask ) & 0x7FFFFFFF ))

seq $ipstart $ipend | while read i; do
    ttlstr=$(ping -c1 -w1  $a.$(( ($i & 0xFF0000) >> 16 )).$(( ($i & 0xFF00) >> 8 )).$(( $i & 0x00FF )) | grep -o 'ttl=[0-9][0-9]*') || {
        printf "%s is Offline\n" "$a.$(( ($i & 0xFF0000) >> 16 )).$(( ($i & 0xFF00) >> 8 )).$(( $i & 0x00FF ))"
        continue;
    }
    ttl="${ttlstr#*=}"           
    printf "%s is Online, ttl=%d\n" "$a.$(( ($i & 0xFF0000) >> 16 )).$(( ($i & 0xFF00) >> 8 )).$(( $i & 0x00FF ))" "$ttl"
    if [ $ttl -eq 64 ]
            then
                echo "Operating is Linux"
            elif [ $ttl -eq 128 ]
            then
                echo "Operating is Windows"
            else
                echo "Operating is IOS"
                fi

done