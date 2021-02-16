#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/CBTract
filterdir=$subjdir/CBFilterRegions
finaltract=$tractdir/CB_${tractnamesuffix}
mkdir -p $tractdir

# filter regions for the cingulum bundle
frontal_orb_cortex_hippo=$filterdir/Frontal_Orb_Cortex_Hippo.nii.gz
axialfilter=$filterdir/AxialSlabFilter.nii.gz

cat $tractfile | procstreamlines -endpointfile $frontal_orb_cortex_hippo | procstreamlines -waypointfile $axialfilter -maxtractlength 155 -discardloops > $finaltract.Bfloat

# converting to other formats for visualization
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force