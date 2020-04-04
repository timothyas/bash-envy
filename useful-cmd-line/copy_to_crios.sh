#!/bin/bash

forcing_v4r2=$STOCKYARD/ecco-data/forcing_baseline2
inputs_v4r2=$STOCKYARD/ecco-data/inputs_baseline2 

v4r3=$communitydir//ECCO/ECCOv4/Release3/input.ecco_v4r3
forcing_v4r3=$v4r3/input_forcing
inputs_v4r3=$v4r3/input_ecco
xx_v4r3=$v4r3/xx
namelist_v4r3=$v4r3/input_init/NAMELIST
error_v4r3=$v4r3/input_init/error_weight
profiles_30=$v4r3/profiles
profiles_15=$v4r3/profiles_15x30
profiles_45=$v4r3/profiles_45x45


echo " --- ECCOv4r2 --- "
echo ""
echo " --- copying forcing"
echo ""

echo " size: "
du -sh $forcing_v4r2
st=`date +%s`
cp -rv $forcing_v4r2 $crios_dir/llc90/global/eccov4r2/forcing
end=`date +%s`
runtime=$((end-st))
echo " time: "
echo $runtime "sec"
echo ""

echo ""
echo " --- copying input obs"
echo ""

echo " size: "
du -sh $inputs_v4r2
st=`date +%s`
cp -rv $inputs_v4r2 $crios_dir/llc90/global/eccov4r2/input_obs
end=`date +%s`
runtime=$((end-st))
echo " time: "
echo $runtime "sec"
echo ""


echo ""
echo " --- ECCOv4r3 --- "
echo ""

echo " --- copying forcing"
echo ""

echo " size: "
du -sh $forcing_v4r3
st=`date +%s`
cp -rv $forcing_v4r3 $crios_dir/llc90/global/eccov4r3/forcing
end=`date +%s`
runtime=$((end-st))
echo " time: "
echo $runtime "sec"
echo ""

echo " --- copying input_obs"
echo ""

echo " size: "
du -sh $inputs_v4r3
st=`date +%s`
cp -rv $inputs_v4r3 $crios_dir/llc90/global/eccov4r3/input_obs
end=`date +%s`
runtime=$((end-st))
echo " time: "
echo $runtime "sec"
echo ""

echo " --- copying ctrls"
echo ""

echo " size: "
du -sh $xx_v4r3
st=`date +%s`
cp -rv $xxs_v4r3 $crios_dir/llc90/global/eccov4r3/xx
end=`date +%s`
runtime=$((end-st))
echo " time: "
echo $runtime "sec"
echo ""

echo " --- copying namelist"
echo ""

echo " size: "
du -sh $namelist_v4r3
st=`date +%s`
cp -rv $namelist_v4r3 $crios_dir/llc90/global/eccov4r3/namelists
end=`date +%s`
runtime=$((end-st))
echo " time: "
echo $runtime "sec"
echo ""

echo " --- copying error weights"
echo ""

echo " size: "
du -sh $error_v4r3
st=`date +%s`
cp $error_v4r3 $crios_dir/llc90/global/eccov4r3/error_weights
end=`date +%s`
runtime=$((end-st))
echo " time: "
echo $runtime "sec"
echo ""

echo " --- copying profiles 30x30"
echo ""

echo " size: "
du -sh $profiles_30
st=`date +%s`
cp -rv $profiles_30 $crios_dir/llc90/global/eccov4r3/profiles_30x30
end=`date +%s`
runtime=$((end-st))
echo " time: "
echo $runtime "sec"
echo ""

echo " --- copying profiles 15x30"
echo ""

echo " size: "
du -sh $profiles_15
st=`date +%s`
cp -rv $profiles_15 $crios_dir/llc90/global/eccov4r3/profiles_15x30
end=`date +%s`
runtime=$((end-st))
echo " time: "
echo $runtime "sec"
echo ""

echo " --- copying profiles 45x45"
echo ""

echo " size: "
du -sh $profiles_45
st=`date +%s`
cp -rv $profiles_45 $crios_dir/llc90/global/eccov4r3/profiles_45x45
end=`date +%s`
runtime=$((end-st))
echo " time: "
echo $runtime "sec"
