#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/ORTract
filterdir=$subjdir/ORFilterRegions
finaltract=$tractdir/OR_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the optic radiations (nice)
thalamus_occipital_pole=$filterdir/Thalamus-Occipital_Pole.nii.gz

# filtering the tracts
cat $tractfile | procstreamlines -endpointfile $thalamus_occipital_pole -maxtractlength 135 -discardloops > $finaltract.Bfloat

# converting to trackvis
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

# convert to vtk and tck
cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force