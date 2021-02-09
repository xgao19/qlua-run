#!/bin/bash
cfg=$1
latsize=$2
gfix=$3
maxiter=$4
b_script=$5
logloc="data_a/logs"

if [ $latsize != 24c32 ] && [ "$latsize" != "48c64" ] && [ $latsize != 64c64 ];
then
    echo "BAD LATSIZE: $latsize"
    exit 1
fi

if [ "$gfix" != "coulomb" ] && [ "$gfix" != "landau" ];
then
    echo "Bad gfix: $gfix"
    exit 1
fi

ct=1
it=0
while [ $ct == 1 ]
do
    it=$(( $it + 1 ))
    if [ ! -f ${logloc}/gfix.out.$latsize.$cfg.$gfix.mx$4.$it.txt ]; then
	out=${logloc}/gfix.out.$latsize.$cfg.$gfix.mx$4.$it.txt
	ct=0
	echo $out created
    else
	echo "skip gfix.out.$latsize.$cfg.$gfix.mx$4.$it.txt"
    fi
done
err=${out/"out"/"err"}

runjob=runjob/runjob.job.$cfg.$gfix.mt$4.qlua
config=gauge_config.$latsize.qlua
main=landaufix_ncg_save.qlua
#main=gaugefix_ncg_save.qlua  # coulombfix_ncg_save.qlua

echo "job_key = '$cfg'" > $runjob
echo "network_geom = {2, 4, 4, 4}" >> $runjob
echo "job_max_iter = $maxiter" >> $runjob
echo "job_gfix = '$gfix'" >> $runjob

echo "jsrun -o $out -k $err -n 8 -c 4 -a 16 -g 1 /gpfs/alpine/phy138/proj-shared/phy138hot/xgao/mybin/qlua-bkend $runjob $config $main &" >> ${b_script}
