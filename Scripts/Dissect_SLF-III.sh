#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/SLF-IIITract
filterdir=$subjdir/SLF-IIIFilterRegions
finaltract=$tractdir/SLF-III_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the SLF-III
operctrainsupra_ep=$filterdir/OpercTriang_SupraMarginal_EP.nii.gz
porale=$filterdir/HarvardOxford-cort_Planum-Polare_dil2.nii.gz
temporale=$filterdir/HarvardOxford-cort_Planum-Temporale_dil2.nii.gz

cat $tractfile | procstreamlines -endpointfile $operctrainsupra_ep | procstreamlines -exclusionfile $porale | procstreamlines -exclusionfile $temporale -maxtractlength 140 -discardloops > $finaltract.Bfloat

# converting to other formats for visualization.
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force