#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/IFOFTract
filterdir=$subjdir/IFOFFilterRegions
finaltract=$tractdir/IFOF_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the inferior fronto occipital fasciculus (nice)
frontal_occipital_pole=$filterdir/Frontal_Pole-Occipital_Pole.nii.gz
caudate=$filterdir/HarvardOxford-sub_Left-Caudate.nii.gz
thalamus=$filterdir/HarvardOxford-sub_Left-Thalamus.nii.gz

# filtering the tracts
cat $tractfile | procstreamlines -endpointfile $frontal_occipital_pole -exclusionfile $caudate | procstreamlines -exclusionfile $thalamus -discardloops > $finaltract.Bfloat

# converting to trackvis
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

# convert to vtk and tck
cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force