#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/AFTract
filterdir=$subjdir/AFFilterRegions
finaltract=$tractdir/AF_${tractnamesuffix}
mkdir -p $tractdir

# filter regions for the arcuate fasciculus
ba_brodmann_ep=$filterdir/BA_Brodmann_EP.nii.gz
temporal_pole=$filterdir/HarvardOxford-cort_Temporal-Pole_dil2.nii.gz

cat $tractfile | procstreamlines -endpointfile $ba_brodmann_ep -exclusionfile $temporal_pole -maxtractlength 125 -discardloops > $finaltract.Bfloat

# converting to other formats for visualization.
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force