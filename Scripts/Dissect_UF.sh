#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/UFTract
filterdir=$subjdir/UFFilterRegions
finaltract=$tractdir/UF_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the uncinate fasciculus
frontal_temporal_ep=$filterdir/Frontal_Temporal_Pole_EP.nii.gz
axialfilter=$filterdir/AxialSlabFilter_dil2.nii.gz
coronalfilter=$filterdir/CoronalSlabFilter_dil2.nii.gz

cat $tractfile | procstreamlines -endpointfile $frontal_temporal_ep | procstreamlines -exclusionfile $axialfilter | procstreamlines -exclusionfile $coronalfilter -discardloops > $finaltract.Bfloat

# converting to other formats for visualization.
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force

# Code to extract the axial and coronal slab filters.
#bbox=($(fslstats {}/$filterdir/*Brain-Stem* -w));slicenum=$(echo ${bbox[4]}+${bbox[5]}+5|bc);padabove=$(echo 181-$slicenum-1-2 | bc);echo {} $slicenum $padabove' | parallel --colsep " " --dry-run 'fslroi {1}/mask-brain.nii.gz {1}/$filterdir/AxialSlab.nii.gz 0 -1 0 -1 {2} 3;mrpad {1}/$filterdir/AxialSlab.nii.gz -axis 2 {2} {3} {1}/$filterdir/AxialSlabFilter.nii.gz -force;fslmaths {1}/$filterdir/AxialSlabFilter.nii.gz -dilM -dilM {1}/$filterdir/AxialSlabFilter_dil2.nii.gz