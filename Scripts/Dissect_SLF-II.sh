#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/SLF-IITract
filterdir=$subjdir/SLF-IIFilterRegions
finaltract=$tractdir/SLF-II_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the SLF-II
angular_gyrus_mfg_ep=$filterdir/Angular_Gyrus_MFG_EP.nii.gz
axialfilter=$filterdir/AxialSlabFilter_dil2.nii.gz

cat $tractfile | procstreamlines -endpointfile $angular_gyrus_mfg_ep | procstreamlines -exclusionfile $axialfilter -maxtractlength 160 -discardloops > $finaltract.Bfloat

# converting to other formats for visualization.
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force