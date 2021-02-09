#!/bin/bash
cfg=$1     # Configuration Number
latsize=$2 # Size of Lattice (e.g. 64c64)
miter=$3   # CG gauge-fixing max number of iterations
sample=$4  # ex, sl, or all
test=$5    # If Test Job
batch_script="mscripts_11/c3pt.all.64c64.mt600.script.hyp1q049.CG45.5.sh"
logloc="/gpfs/alpine/phy138/proj-shared/phy138hot/xgao/latwork/l64c64a076_x/data_a"

if [ ${#test} -gt 0 ];
then
    test=.$test
fi

if [ $cfg == rnd ];
then
    ncfg=1020  # creates random gauge field. ncfg just used to create source location
else
    ncfg=$cfg
fi

if [ $sample != ex ] && [ $sample != sl ] && [ $sample != all ];
then
    echo "BAD SAMPLE: $sample"
    exit 1
fi

if [ $latsize != 24c32 ] && [ "$latsize" != "48c64" ] && [ $latsize != 64c64 ] && [ $latsize != 32c32 ];
then
    echo "BAD LATSIZE: $latsize"
    exit 1
fi


# Generate log files
echo "HERE1"
ct=1
it=0
while [ $ct == 1 ]
do
    it=$(( $it + 1 ))
    if [ ! -f $logloc/logs_11/c3pt$test.$sample.out.$latsize.$cfg.mx$3.$it.txt ]; then
	out=$logloc/logs_11/c3pt$test.$sample.out.$latsize.$cfg.mx$3.$it.txt
	ct=0
	echo $out created
    else
	echo "skip c3pt$test.$sample.out.$latsize.$cfg.mx$3.$it.txt"
    fi
done
echo "HERE2"
ct=1
it=0
while [ $ct == 1 ]
do
    it=$(( $it + 1 ))
    if [ ! -f $logloc/logs_11/c3pt$test.$sample.err.$latsize.$cfg.mx$3.$it.txt ]; then
	err=$logloc/logs_11/c3pt$test.$sample.err.$latsize.$cfg.mx$3.$it.txt
	ct=0
	echo $err created
    else
	echo "skip c3pt$test.$sample.err.$latsize.$cfg.mx$3.$it.txt"
    fi
done

runjob=runjob/runjob.job.$cfg.mt$3.qlua
config=sx-da-k2k5hyp1-config.qbarq_coh.$latsize\_gpucntr.hyp1q049.CG45.11.qlua
main=sx-da-calc_c23pt_qbarq_posneg.qlua

echo "job_key = '$ncfg'" > $runjob
echo "max_iter = $miter" >> $runjob
echo "smpl = '$sample'" >> $runjob
echo "network_geom = {2, 2, 2, 4}" >> $runjob

#cp c3pt.$latsize.script.sh mscripts/c3pt$test.$sample.$latsize.$cfg.mt$3.script.sh
echo "jsrun -o $out -k $err -n 32 -c 6 -a 1 -g 1 /gpfs/alpine/phy138/proj-shared/phy138hot/xgao/mybin/qlua-bkend $runjob $config $main &">>${batch_script}
