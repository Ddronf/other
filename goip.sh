#!/bin/bash
file=/home/user/phone/full
date=2021-20-27

rm mts_phone
rm tele2_phone

cat $file | grep DIAL_TRUNK=20 | cut -c 102- | cut -c -8 > trunk_mts
cat $file | grep DIAL_TRUNK=21 | cut -c 102- | cut -c -8 >> trunk_mts
cat $file | grep DIAL_TRUNK=19 | cut -c 102- | cut -c -8 > trunk_tele2


echo "MTS"
mapfile -t MTS < trunk_mts
for i in "${MTS[@]}";
do
    a=$(grep answer $file | grep "$i" | sed 's/  //g')
    if [ "$a" > 1 ]; then
        start=$a;
        finish=$(grep 'outbound-allroutes-custom-all, 989' $file | grep "$i" | awk '{print $1, $2}');
        echo "Start - "${start:1:19}", Finish - "${finish:1:19} >> mts_phone;
    fi
done

mapfile -t MTS_SORT < mts_phone
printf "%s\n" "${MTS_SORT[@]}" | wc -l > mts_count

#####################################################

echo "TELE2"
mapfile -t TELE2 < trunk_tele2
for i in "${TELE2[@]}";
do
    a=$(cat $file | grep answer | grep "$i" | sed 's/  //g')
    if [ "$a" > 1 ]; then
        start=$a;
        finish=$(cat $file | grep 'outbound-allroutes-custom-all, 989' | grep "$i" | awk '{print $1, $2}');
        echo "Start - "${start:1:19}", Finish - "${finish:1:19} >> tele2_phone;
    fi
done

mapfile -t TELE2_SORT < tele2_phone
printf "%s\n" "${TELE2_SORT[@]}" | wc -l > tele2_count

