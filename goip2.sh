#!/bin/bash
file=/home/user/phone/time1/full        # LOG
patch=/home/user/phone/time1/22         # Files for Zabbix
date=$(date -I)

cat $file | grep DIAL_TRUNK=20 | cut -c 102- | cut -c -8 > $patch/trunk_mts
cat $file | grep DIAL_TRUNK=21 | cut -c 102- | cut -c -8 >> $patch/trunk_mts
cat $file | grep DIAL_TRUNK=19 | cut -c 102- | cut -c -8 > $patch/trunk_tele2

asterisk_report_mobile(){
rm $patch/$2
mapfile -t ARR < $patch/$1
for i in "${ARR[@]}";
do
    a=$(grep answer $file | grep "$i" | grep "$date" | sed 's/  //g')
    if [ "$a" > 1 ]; then
        start=$a;
        b=$(grep 'outbound-allroutes-custom-all, 989' $file | grep "$i" | awk '{print $1, $2}' | sed 's/  //g');
            if [ "$b" > 1 ]; then
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

# $1 - trunks_file - id calls  / mapfile -t MTS < trunk_mts
# $2 - lists phone  / rm mts_phone
#                   / echo "Start - "${start:1:19}", Finish - "${finish:1:19} >> mts_phone;
#                   / mapfile -t MTS_SORT < mts_phone
# $3 - phone count  / printf "%s\n" "${MTS_SORT[@]}" | wc -l > mts_count
