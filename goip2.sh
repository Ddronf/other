#!/bin/bash
file=/var/log/asterisk/full                     # LOG
patch=/var/spool/asterisk/monitor/goip          # Files for Zabbix
date=$(date -I)

mv $patch/trunk_mts $patch/$date-trunk_mts
mv $patch/trunk_tele2 $patch/$date-trunk_tele2
cat $file | grep DIAL_TRUNK=20 | cut -c 102- | cut -c -8 | sed 's/-//g;s/"//g;s/,//g' > $patch/trunk_mts
cat $file | grep DIAL_TRUNK=21 | cut -c 102- | cut -c -8 | sed 's/-//g;s/"//g;s/,//g' >> $patch/trunk_mts
cat $file | grep DIAL_TRUNK=19 | cut -c 102- | cut -c -8 | sed 's/-//g;s/"//g;s/,//g' > $patch/trunk_tele2

asterisk_report_mobile(){
#rm $patch/$2
mv $patch/$2 $patch/$date$2
mapfile -t ARR < $patch/$1
for i in "${ARR[@]}";
do
    a=$(grep answer $file | grep "$i" | grep "$date" | sed 's/  //g')
    if [[ "$a" ]]; then
        start=$a;
        b=$(grep 'outbound-allroutes-custom-all, 989' $file | grep "$i" | awk '{print $1, $2}' | sed 's/  //g');
            if [[ "$b" ]]; then
                finish=$b;
                echo "Start - "${start:1:19}", Finish - "${finish:1:19} >> $patch/$2;
            fi
    fi
done
mapfile -t ARR_SORT < $patch/$2
#printf "%s\n" "${ARR_SORT[@]}" | wc -l > $3
echo ${#ARR_SORT[@]} > $patch/$3
}

asterisk_report_mobile "trunk_mts" "mts_phone" "mts_count"
asterisk_report_mobile "trunk_tele2" "tele2_phone" "tele2_count"
