#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/POPTTract
filterdir=$subjdir/POPTFilterRegions
finaltract=$tractdir/POPT_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the parieto-occipital pontine tract (POPT)
parietal_occipital_ep=$filterdir/MNI_Parietal-Occipital-Lobe_EP.nii.gz
pontine=$filterdir/JHU_Pontine-crossing-tract-a-part-of-MCP.nii.gz
cerebellum=$filterdir/MNI_Cerebellum_ero2.nii.gz
coronalfilter=$filterdir/CoronalSlabFilter.nii.gz

cat $tractfile | procstreamlines -endpointfile $parietal_occipital_ep -waypointfile $pontine | procstreamlines -exclusionfile $cerebellum | procstreamlines -exclusionfile $coronalfilter -discardloops > $finaltract.Bfloat

# converting to other formats for visualization
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force