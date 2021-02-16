#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/FornixTract
filterdir=$subjdir/FornixFilterRegions
finaltract=$tractdir/Fornix_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the inferior longitudinal fasciculus (nice)
parahippant_hipp=$filterdir/Parahipp_Anterior-Hippocampus.nii.gz

# filtering the tracts
cat $tractfile | procstreamlines -endpointfile $parahippant_hipp -maxtractlength 135 -discardloops > $finaltract.Bfloat

# converting to trackvis
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

# convert to vtk and tck
cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force