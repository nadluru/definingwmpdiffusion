#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/MLFTract
filterdir=$subjdir/MLFFilterRegions
finaltract=$tractdir/MLF_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the middle longitudinal fasciculus (MLF)
angular_temporal_ep=$filterdir/Angular_Temporal_EP.nii.gz

cat $tractfile | procstreamlines -endpointfile $angular_temporal_ep -discardloops > $finaltract.Bfloat

# converting to other formats for visualization
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force