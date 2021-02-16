#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/CSTTract
filterdir=$subjdir/CSTFilterRegions
finaltract=$tractdir/CST_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the corticospinal tract (nice)
brainstem_precentralgyrus=$filterdir/Brain_Stem-Precentral_Gyrus.nii.gz
insularcortex=$filterdir/HarvardOxford-cort_Insular-Cortex.nii.gz

# filtering the tracts
cat $tractfile | procstreamlines -endpointfile $brainstem_precentralgyrus -exclusionfile $insularcortex -discardloops > $finaltract.Bfloat

# converting to trackvis
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

# convert to vtk and tck
cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force