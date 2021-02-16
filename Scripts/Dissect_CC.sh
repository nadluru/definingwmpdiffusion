#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/CCTract
filterdir=$subjdir/CCFilterRegions
finaltract=$tractdir/CC_$tractnamesuffix
ccmodtapetum=$tractdir/CCModTapetum_$tractnamesuffix
tapetum=$tractdir/CCTapetum_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the corpus callosum
# cc mod tapetum
frontal_parietal_occipital_ep=$filterdir/Frontal_Parietal_Occipital_EP.nii.gz
cat $tractfile | procstreamlines -endpointfile $frontal_parietal_occipital_ep -maxtractlength 150 -discardloops > $ccmodtapetum.Bfloat

# tapetum
splenium=$filterdir/JHU_Splenium-of-corpus-callosum_dil3.nii.gz
temporal_pole_ep=$filterdir/Temporal_Pole_EP.nii.gz
cat $tractfile | procstreamlines -waypointfile $splenium -endpointfile $temporal_pole_ep > $tapetum.Bfloat

# merging ccmodtapetum and tapetum
cat $ccmodtapetum.Bfloat $tapetum.Bfloat | procstreamlines -header $fa > $finaltract.Bfloat

# converting to other formats for visualization.
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force