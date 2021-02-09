#!/bin/bash
cfg=$1
latsize=$2
b_script=$3
logloc="logs"

if [ $latsize != 24c32 ] && [ "$latsize" != "48c64" ] && [ $latsize != 64c64 ];
then
    echo "BAD LATSIZE: $latsize"
    exit 1
fi

ct=1
it=0
while [ $ct == 1 ]
do
    it=$(( $it + 1 ))
    if [ ! -f ${logloc}/npr.out.$latsize.$cfg.$it.txt ]; then
	out=${logloc}/npr.out.$latsize.$cfg.$it.txt
	ct=0
	echo $out created
    else
	echo "skip npr.out.$latsize.$cfg.$it.txt"
    fi
done
err=${out/"out"/"err"}

runjob=runjob/runjob.job.$cfg.npr.qlua
config=config.64c64.npr.qlua
main=npr.qlua
#main=gaugefix_ncg_save.qlua  # coulombfix_ncg_save.qlua

echo "job_key = '$cfg'" > $runjob
echo "network_geom = {2, 2, 2, 4}" >> $runjob
echo "hyp_ind = 1" >> $runjob
echo "lsize = 'l_${latsize}'" >> $runjob

echo "jsrun -o $out -k $err -n 32 -c 6 -a 1 -g 1 /gpfs/alpine/phy138/proj-shared/phy138hot/xgao/mybin/qlua-bkend $runjob $config $main &" >> ${b_script}
