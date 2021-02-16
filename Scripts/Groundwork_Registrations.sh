#!/bin/bash
codedir=definingwmpdiffusion/Scripts
source AtlasesAlignFunctions.sh
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4
dwmp=DWMP
IITDIR=$dwmp/IIT2019
FSLATLASDIR=$dwmp/FSLATLASES2019

# region MNI registration to t1 (FSL)
ls $dwmp/s?/t1.nii.gz | sed 's/*//' | parallel --dry-run -j6 bash FLIRTFNIRT.sh {} $FSLDIR/data/standard/MNI152_T1_1mm.nii.gz {//}
# endregion

# region bet
ls $dwmp/s?/t1.nii.gz | parallel --bar --plus -j6 bet {} {..}_bet -f 0.5 -m -R
# endregion

# region MNI registration to t1 (ANTS)
ls $dwmp/s?/t1_bet.nii.gz | sed 's/*//' | parallel --dry-run -j12 --plus 'export fI={1};export mI={2};cd {1//};ANTSRANLRegister {1/..}_ANTS_{2/..}_' :::: - ::: $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz $dwmp/$IITDIR/IITmean_t1.nii.gz
# endregion

# region warping the MNI atlases
# endregion

# region warping the IIT GM atlases
ls $dwmp/s?/t1_bet.nii.gz | sed 's/*//' | parallel --dry-run -j12 --plus 'export fI={1};export mI={2};cd {1//};export mR={3};ANTSRANLRegisterTransform {1/..}_ANTS_{2/..}_ GenericLabel 1 1' :::: - ::: $IITDIR/IITmean_t1.nii.gz ::: $IITDIR/IIT_GM_Desikan_atlas_mrtrix3.nii.gz $IITDIR/IIT_GM_Destrieux_atlas_mrtrix3.nii.gz
# endregion

# region using the mask-brain masked instead of bet
ls $dwmp/s?/t1.nii.gz | sed 's/*//' | parallel --bar --plus fslmaths {} -mas {//}/mask-brain.nii.gz {..}_brain.nii.gz
ls $dwmp/s?/t1_brain.nii.gz | sed 's/*//' | parallel --dry-run -j1 --plus 'export fI={1};export mI={2};cd {1//};ANTSRANLRegister {1/..}_ANTS_{2/..}_' :::: - ::: $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz $IITDIR/IITmean_t1.nii.gz
# endregion

# region LUT adjustments for mrtrix3
cat $FSLDIR/data/atlases/Cerebellum_MNIflirt.xml | grep index | sed 's/"//g;s/.*index=//;s/x=.*[0-9]>//;s/<.*//' | awk '{$1=NR;print $0}' | awk '{FS=" ";print $1" "$2"-"$3}' > $FSLATLASDIR/LUT_Cerebellum.txt

cat $FSLDIR/data/atlases/HarvardOxford-Cortical.xml | grep index | sed 's/"//g;s/.*index=//;s/x=.*[0-9]>//;s/<.*//' | awk '{$1=NR;print $0}' | sed 's/,//;s/(.*//;s/ /-/g;s/-/ /;s/-$//' > $FSLATLASDIR/LUT_HarvardOxfordCortical.txt

cat $FSLDIR/data/atlases/HarvardOxford-Subcortical.xml | grep index | sed 's/"//g;s/.*index=//;s/x=.*[0-9]>//;s/<.*//' | awk '{$1=NR;print $0}' | sed 's/ /-/g;s/-/ /' > $FSLATLASDIR/LUT_HarvardOxfordSubcortical.txt

cat $FSLDIR/data/atlases/MNI.xml | grep index | sed 's/"//g;s/.*index=//;s/x=.*[0-9]>//;s/<.*//' | awk '{$1=NR;print $0}' | sed 's/ /-/g;s/-/ /' > $FSLATLASDIR/LUT_MNI.txt

cat $FSLDIR/data/atlases/Striatum-Structural.xml | grep index | sed '1d;s/"//g;s/.*index=//;s/x=.*[0-9]>//;s/<.*//' | awk '{$1=NR;print $0}' > $FSLATLASDIR/LUT_StriatumStructural.txt

cat $FSLDIR/data/atlases/Thalamus.xml | grep index | sed 's/"//g;s/.*index=//;s/x=.*[0-9]>//;s/<.*//' | awk '{$1=NR;print $0}' | sed 's/ /-/g;s/-/ /' > $FSLATLASDIR/LUT_Thalamus.txt
# endregion

# region warping the IIT and FSL GM atlases
fslcerebellum=$FSLATLASDIR/Cerebellum/Cerebellum-MNIfnirt-maxprob-thr25-1mm.nii.gz
fslharvardoxfordcort=$FSLATLASDIR/HarvardOxford/HarvardOxford-cort-maxprob-thr50-1mm.nii.gz
fslharvardoxfordsub=$FSLATLASDIR/HarvardOxford/HarvardOxford-sub-maxprob-thr50-1mm.nii.gz
fslmni=$FSLATLASDIR/MNI/MNI-maxprob-thr50-1mm.nii.gz
fslstriatum=$FSLATLASDIR/Striatum/striatum-structural-1mm.nii.gz
fslthalamus=$FSLATLASDIR/Thalamus/Thalamus-maxprob-thr50-1mm.nii.gz
iitdesikan=$IITDIR/IIT_GM_Desikan_atlas_mrtrix3.nii.gz
iitdestrieux=$IITDIR/IIT_GM_Destrieux_atlas_mrtrix3.nii.gz

fslatlases=($fslcerebellum $fslharvardoxfordcort $fslharvardoxfordsub $fslmni $fslstriatum $fslthalamus)
iitatlases=($iitdesikan $iitdestrieux)

ls $dwmp/s?/t1_brain.nii.gz | sed 's/*//' | parallel --dry-run -j12 --plus 'export fI={1};export mI={2};cd {1//};export mR={3};ANTSRANLRegisterTransform {1/..}_ANTS_{2/..}_ GenericLabel 1 1' :::: - ::: $IITDIR/IITmean_t1.nii.gz ::: ${iitatlases[@]}

ls $dwmp/s?/t1_brain.nii.gz | sed 's/*//' | parallel --dry-run -j12 --plus 'export fI={1};export mI={2};cd {1//};export mR={3};ANTSRANLRegisterTransform {1/..}_ANTS_{2/..}_ GenericLabel 1 1' :::: - ::: $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz ::: ${fslatlases[@]} 
# endregion

# region warping JHU WM atlas
fsljhu=$FSLATLASDIR/JHU-ICBM-labels-1mm.nii.gz
ls $dwmp/s?/t1_brain.nii.gz | sed 's/*//' | parallel --dry-run -j12 --plus 'export fI={1};export mI={2};cd {1//};export mR={3};ANTSRANLRegisterTransform {1/..}_ANTS_{2/..}_ GenericLabel 1 1' :::: - ::: $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz ::: $fsljhu

cat $FSLDIR/data/atlases/JHU-labels.xml | grep index | sed '1d;s/"//g;s/.*index=//;s/x=.*[0-9]>//;s/<.*//' | awk '{$1=NR;print $0}' | sed 's/(//g;s/)//g;s/\///;s/include.*n//;s/could.*e//;s/can.*n//;s/ \+/ /g;s/ /-/g;s/-/ /' > $FSLATLASDIR/LUT_JHU.txt

ls -d s? | parallel mkdir -p {}JHUWMRegionsV2
cat $FSLATLASDIR/LUT_JHU.txt | parallel --dry-run --colsep " " -j28 --plus fslmaths {3} -thr {1} -uthr {1} {3//}/JHUWMRegionsV2/{3/..}_Label_{2}.nii.gz :::: - ::: $dwmp/s?/t1_brain_ANTS_MNI152_T1_1mm_brain_RANLRegistered_regions_JHU-ICBM-labels-1mm.nii.gz

ls s? -d | parallel mkdir -p {}/JHUWMRegionsV2Renamed
ls s?/JHUWMRegionsV2/*.gz | parallel --bar --plus --rpl '{i} s/.*Label_//' cp {} {+/}Renamed/JHU_{i}

parallel --plus --bar -j6 'mrcalc {1} {2} -add - | mrcalc - {3} -add {3//}/JHU_CC.nii.gz' ::: s?/JHUWMRegions/*Body* :::+ $dwmp/s?/JHUWMRegions/*Genu* :::+ $dwmp/s?/JHUWMRegions/*Splenium*
# endregion

# region warping Talairach and Juelich atlas for Brodmann and Broca respectively for Arcuate Fasciculus
fsljuelich=$FSLATLASDIR/Juelich-maxprob-thr50-1mm.nii.gz
fsltalairach=$FSLATLASDIR/Talairach-labels-1mm.nii.gz

ls $dwmp/s?/t1_brain.nii.gz | sed 's/*//' | parallel --dry-run -j12 --plus 'export fI={1};export mI={2};cd {1//};export mR={3};ANTSRANLRegisterTransform {1/..}_ANTS_{2/..}_ GenericLabel 1 1' :::: - ::: $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz ::: $fsljuelich $fsltalairach

cat $FSLDIR/data/atlases/Juelich.xml | grep index | sed '1d;s/"//g;s/.*index=//;s/x=.*[0-9]>//;s/<.*//' | awk '{$1=NR;print $0}' | sed "s/\/-//;s/'//;s/ /-/g;s/-/ /;s/\/-//" > $FSLATLASDIR/LUT_Juelich.txt
cat $FSLDIR/data/atlases/Talairach.xml | grep index | sed '1d;s/"//g;s/.*index=//;s/x=.*[0-9]>//;s/<.*//' | awk '{$1=NR;print $0}' | sed 's/\.\*\.\*//;s/\.\*\./-/;s/\.\*//;s/\./-/g;s/ /-/g;s/-/ /;s/\*-//;s/-\*//' > $FSLATLASDIR/LUT_Talairach.txt

ls -d $dwmp/s? | parallel --dry-run mkdir -p {}JuelichRegions {}TalairachRegions
cat $FSLATLASDIR/LUT_Juelich.txt | parallel --dry-run --colsep " " -j28 --plus fslmaths {3} -thr {1} -uthr {1} {3//}/JuelichRegions/{3/..}_Label_{2}.nii.gz :::: - ::: $dwmp/s?/t1_brain_ANTS_MNI152_T1_1mm_brain_RANLRegistered_regions_Juelich-maxprob-thr50-1mm.nii.gz

cat $FSLATLASDIR/LUT_Talairach.txt | parallel --dry-run --colsep " " -j28 --plus fslmaths {3} -thr {1} -uthr {1} {3//}/TalairachRegions/{3/..}_Label_{2}.nii.gz :::: - ::: $dwmp/s?/t1_brain_ANTS_MNI152_T1_1mm_brain_RANLRegistered_regions_Talairach-labels-1mm.nii.gz
# endregion

# region splitting the atlases into separate regions
ls -d $dwmp/s? | parallel mkdir -p {}/CerebellarRegions
ls -d $dwmp/s? | parallel rm -f {}/CerebellarRegions/*
cat $FSLATLASDIR/LUT_Cerebellum.txt | parallel --dry-run --colsep " " -j28 --plus fslmaths {3} -thr {1} -uthr {1} {3//}/CerebellarRegions/{3/..}_Label_{2}.nii.gz :::: - ::: $dwmp/s?/t1_brain_ANTS_MNI152_T1_1mm_brain_RANLRegistered_regions_Cerebellum-MNIfnirt-maxprob-thr25-1mm.nii.gz

ls -d $dwmp/s? | parallel mkdir -p {}/HarvardOxfordCorticalRegions
ls -d $dwmp/s? | parallel rm -f {}/HarvardOxfordCorticalRegions/*
cat $FSLATLASDIR/LUT_HarvardOxfordCortical.txt | parallel --dry-run --colsep " " -j48 --plus fslmaths {3} -thr {1} -uthr {1} {3//}/HarvardOxfordCorticalRegions/{3/..}_Label_{2}.nii.gz :::: - ::: $dwmp/s?/t1_brain_ANTS_MNI152_T1_1mm_brain_RANLRegistered_regions_HarvardOxford-cort-maxprob-thr50-1mm.nii.gz

ls -d $dwmp/s? | parallel mkdir -p {}/HarvardOxfordSubCorticalRegions
ls -d $dwmp/s? | parallel rm -f {}/HarvardOxfordSubCorticalRegions/*
cat $FSLATLASDIR/LUT_HarvardOxfordSubCortical.txt | parallel --dry-run --colsep " " -j28 --plus fslmaths {3} -thr {1} -uthr {1} {3//}/HarvardOxfordSubCorticalRegions/{3/..}_Label_{2}.nii.gz :::: - ::: $dwmp/s?/t1_brain_ANTS_MNI152_T1_1mm_brain_RANLRegistered_regions_HarvardOxford-sub-maxprob-thr50-1mm.nii.gz

ls -d $dwmp/s? | parallel mkdir -p {}/MNIRegions
ls -d $dwmp/s? | parallel rm -f {}/MNIRegions/*
cat $FSLATLASDIR/LUT_MNI.txt | parallel --dry-run --colsep " " -j28 --plus fslmaths {3} -thr {1} -uthr {1} {3//}/MNIRegions/{3/..}_Label_{2}.nii.gz :::: - ::: $dwmp/s?/t1_brain_ANTS_MNI152_T1_1mm_brain_RANLRegistered_regions_MNI-maxprob-thr50-1mm.nii.gz

ls -d $dwmp/s? | parallel mkdir -p {}/StriatumRegions
ls -d $dwmp/s? | parallel rm -f {}/StriatumRegions/*
cat $FSLATLASDIR/LUT_StriatumStructural.txt | parallel --dry-run --colsep " " -j28 --plus fslmaths {3} -thr {1} -uthr {1} {3//}/StriatumRegions/{3/..}_Label_{2}.nii.gz :::: - ::: $dwmp/s?/t1_brain_ANTS_MNI152_T1_1mm_brain_RANLRegistered_regions_striatum-structural-1mm.nii.gz

ls -d $dwmp/s? | parallel mkdir -p {}/ThalamusRegions
ls -d $dwmp/s? | parallel rm -f {}/ThalamusRegions/*
cat $FSLATLASDIR/LUT_Thalamus.txt | parallel --dry-run --colsep " " -j28 --plus fslmaths {3} -thr {1} -uthr {1} {3//}/ThalamusRegions/{3/..}_Label_{2}.nii.gz :::: - ::: s?/t1_brain_ANTS_MNI152_T1_1mm_brain_RANLRegistered_regions_Thalamus-maxprob-thr50-1mm.nii.gz

ls -d $dwmp/s? | parallel mkdir -p {}/DesikanRegions
ls -d $dwmp/s? | parallel rm -f {}/DesikanRegions/*
cat $IITDIR/LUT_GM_Desikan_0to255_noheader_mrtrix3.txt | sed '1d;s/"//g' | parallel --dry-run --colsep "\t" -j48 --plus fslmaths {9} -thr {1} -uthr {1} {9//}/DesikanRegions/{9/..}_Label_{8}.nii.gz :::: - ::: $dwmp/s?/t1_brain_ANTS_IITmean_t1_RANLRegistered_regions_IIT_GM_Desikan_atlas_mrtrix3.nii.gz

ls -d $dwmp/s? | parallel mkdir -p {}/DestrieuxRegions
ls -d $dwmp/s? | parallel rm -f {}/DestrieuxRegions/*
cat $IITDIR/LUT_GM_Destrieux_0to255_noheader_mrtrix3.txt | sed '1d;s/"//g' | parallel --dry-run --colsep "\t" -j48 --plus fslmaths {9} -thr {1} -uthr {1} {9//}/DestrieuxRegions/{9/..}_Label_{8}.nii.gz :::: - ::: $dwmp/s?/t1_brain_ANTS_IITmean_t1_RANLRegistered_regions_IIT_GM_Destrieux_atlas_mrtrix3.nii.gz
# endregion

# region splitting brain masks and padding them
ls -d $dwmp/s? | parallel mkdir -p {}mask-brain-slices
ls -d $dwmp/s? | parallel mkdir -p {}mask-brain-slices-padded
ls -d $dwmp/s? | parallel --bar fslsplit {1}mask-brain.nii.gz {1}mask-brain-slices/mask-brain-slices-{2} -{2} :::: - ::: x y z

ls -d $dwmp/s? | parallel --plus -k 'parallel --plus -k -I {_} echo slice-{1+/}-{2}-{3}-{_} ::: $(seq -w 0 0$(echo $(fslval {1}/mask-brain.nii.gz {2})-1 | bc))' :::: - ::: dim1 dim2 dim3 :::+ x y z
ls -d $dwmp/s? | parallel --plus -k 'parallel --plus -k -I {_} "echo {1+/}-{2}-{3}-{4}-{_};sz=2;echo mrpad {1}mask-brain-slices/mask-brain-slices-{3}-{_} {1}mask-brain-slices-padded/mask-brain-slices-{3}-{_}-padded.nii.gz -axis {4} {_}" ::: $(seq -w 0 0$(echo $(fslval {1}/mask-brain.nii.gz {2})-1 | bc))' :::: - ::: dim1 dim2 dim3 :::+ x y z :::+ 0 1 2

ls -d $dwmp/s? | parallel --dry-run --plus -k bash $codedir/PadSlices.sh {1+/} {2} {3} {4} :::: - ::: dim1 dim2 dim3 :::+ x y z :::+ 0 1 2
# endregion

# region left-right temporal-pole split
fslmaths HarvardOxfordCorticalRegions/HarvardOxford-cort_Temporal-Pole.nii.gz -mas HarvardOxfordSubCorticalRegions/HarvardOxford-sub_Left-Cerebral-Cortex.nii.gz HarvardOxfordCorticalRegions/HarvardOxford-cort_Left-Temporal-Pole.nii.gz
fslmaths HarvardOxfordCorticalRegions/HarvardOxford-cort_Temporal-Pole.nii.gz -mas HarvardOxfordSubCorticalRegions/HarvardOxford-sub_Right-Cerebral-Cortex.nii.gz HarvardOxfordCorticalRegions/HarvardOxford-cort_Right-Temporal-Pole.nii.gz
# endregion