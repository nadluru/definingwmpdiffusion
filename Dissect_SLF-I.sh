#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/SLF-ITract
filterdir=$subjdir/SLF-IFilterRegions
finaltract=$tractdir/SLF-I_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the SLF-I
frontal_precuneous_ep=$filterdir/Frontal_Precuneous_EP.nii.gz
left_thalamus=$filterdir/HarvardOxford-sub_Left-Thalamus_dil3.nii.gz
left_putamen=$filterdir/HarvardOxford-sub_Left-Putamen_dil3.nii.gz
brain_stem=$filterdir/HarvardOxford-sub_Brain-Stem_dil3.nii.gz
paracingulate_gyrus=$filterdir/HarvardOxford-cort_Paracingulate-Gyrus_dil4.nii.gz
insular_cortex=$filterdir/HarvardOxford-cort_Insular-Cortex_dil3.nii.gz

cat $tractfile | procstreamlines -endpointfile $frontal_precuneous_ep | procstreamlines -exclusionfile $left_thalamus | procstreamlines -exclusionfile $left_putamen | procstreamlines -exclusionfile $brain_stem | procstreamlines -exclusionfile $paracingulate_gyrus | procstreamlines -exclusionfile $insular_cortex -maxtractlength 160 -discardloops > $finaltract.Bfloat

# converting to other formats for visualization
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force