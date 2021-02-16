#!/bin/bash

EnforceOrientHdr(){
	echo -e 'getsform\n getqform\n getsformcode\n getqformcode' | xargs -I {} \
		fslorient -set{} $(fslorient -get{} ${fI}) ${mI}
}
export -f EnforceOrientHdr

ANTSAffineRegister(){
	op=${1}AffineRegistered
	sh antsIntroduction.sh -d 3 -i $mI -r $fI -m 30x90x20 -n 0 -s CC -t "RA" -o $op
}
export -f ANTSAffineRegister

ANTSAffineTransform() {
	antsApplyTransforms -d 3 -i $mI -r $fI -t ${op}Affine.txt -o ${op}.nii.gz
	antsApplyTransforms -d 3 -i $mR -r $fI -n GenericLabel -t ${op}Affine.txt -o ${op}_regions.nii.gz
}
export -f ANTSAffineTransform

ANTSNLTransform() {
	antsApplyTransforms -d 3 -i $mI -r $fI -n BSpline -t ${op}PRWarp.nii -t ${op}PRAffine.txt -o ${op}.nii.gz
	antsApplyTransforms -d 3 -i $mR -r $fI -n NearestNeighbor -t ${op}PRWarp.nii -t ${op}PRAffine.txt -o ${op}_regions.nii.gz
}
export -f ANTSNLTransform

ANTSNLRegister() {
	op=${1}NLRegistered
	ANTS 3 -m PR[${fI},${mI},1,4] -i 10x20x5 -r Gauss[3,0] -t SyN[0.25] --affine-metric-type CC --number-of-affine-iterations 1000x1000x1000 -o ${op}PR.nii
}
export -f ANTSNLRegister

ANTSRANLRegister() {
	local op=${1}RANLRegistered
	local its=10000x111110x11110
  	local percentage=0.3
  	local syn="100x100x50,1e-6,5"
	antsRegistration -d 3 -v 1 -r [$fI, $mI , 1]  \
                    	-m mattes[$fI, $mI, 1, 32, regular, $percentage] \
                     	-t translation[0.1] \
                        -c [$its,1.e-8,20]  \
                        -s 4x2x1vox  \
                        -f 6x4x2 -l 1 \
                        \
			-m mattes[$fI, $mI, 1, 32, regular, $percentage] \
                        -t rigid[0.1] \
                        -c [$its,1.e-8,20]  \
                        -s 4x2x1vox  \
                        -f 3x2x1 -l 1 \
			\
                        -m mattes[$fI, $mI, 1, 32, regular, $percentage] \
                        -t affine[0.1] \
                        -c [$its,1.e-8,20]  \
                        -s 4x2x1vox  \
                        -f 3x2x1 -l 1 \
                        \
			-m mattes[$fI, $mI, 0.5, 32] \
                        -m cc[$fI, $mI, 0.5, 4] \
                        -t SyN[.20, 3, 0] \
                        -c [$syn]  \
                        -s 1x0.5x0vox  \
                        -f 4x2x1 -l 1 -u 1 -z 1 \
			\
                       	-o ${op}
}
export -f ANTSRANLRegister

ANTSRANLRegisterTransform() {
	op=${1}RANLRegistered
	ri=${2}
	rgn=${3}
	img=${4}
	(( $img )) && { antsApplyTransforms -d 3 -v 1 -i $mI -r $fI -n BSpline -t ${op}1Warp.nii.gz -t ${op}0GenericAffine.mat -o ${op}_$(basename $mI); }
	(( $rgn )) && { antsApplyTransforms -d 3 -v 1 -i $mR -r $fI -n $ri -t ${op}1Warp.nii.gz -t ${op}0GenericAffine.mat -o ${op}_regions_$(basename $mR); }
}
export -f ANTSRANLRegisterTransform

AlignDiffusionAtlasesToPop(){
	atlasroot=$1
	pop=$2
	wD=$3
	mkdir -p $wD && cd $wD
	
	export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8
	export mI=$atlasroot/IIT/IITmean_FA.nii.gz
	export fI=template_iso_1mm.nii.gz
	ResampleImage 3 $pop $fI 1x1x1 [1,0] 4
	fslmaths $fI -thr 0.001 $fI 
	ImageMath 3 $fI Normalize $fI 
	ANTSRANLRegister IIT_
	
	aal=$atlasroot/AAL2IIT/AAL2IIT_RANLRegistered_regions.nii.gz
	jhu=$atlasroot/JHU2IIT/JHU2IIT_RANLRegistered_regions.nii.gz
	desikan=$atlasroot/IIT/IIT_GM_Desikan_atlas.nii.gz
	destrieux=$atlasroot/IIT/IIT_GM_Destrieux_atlas.nii.gz

	parallel -n2 -j4 'export mR={1};ANTSRANLRegisterTransform IIT_ GenericLabel 1 {2}' ::: $aal 1 $jhu 0 $desikan 0 $destrieux 0
	parallel -j18 'export mR={}; ANTSRANLRegisterTransform IIT_ Linear 1 0;' ::: $atlasroot/IIT/IIT_Major_bundles/*.nii.gz
}
export -f AlignDiffusionAtlasesToPop

WarpDiffusionAtlasesToNative_CANTs(){
	snroot=$1
	atlasroot=$2

	export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    	
	parallel -j12 'warp={1}/Normalize/{1/}_i3InverseWarp.nii.gz;
aff={1}/Normalize/{1/}_i3Affine.txt;
fI={1}/IMG/{1/}_native.nii.gz;
antsApplyTransforms -d 3 -v 1 -i {2} -r $fI -t [$aff, 1] -t $warp -n GenericLabel -o ${fI%.nii*}_{2/};' ::: $snroot ::: $atlasroot/IIT_RANLRegistered_regions*_*_*.nii.gz
 
    	parallel -j12 'warp={1}/Normalize/{1/}_i3InverseWarp.nii.gz;
aff={1}/Normalize/{1/}_i3Affine.txt;
fI={1}/IMG/{1/}_native.nii.gz;
antsApplyTransforms -d 3 -v 1 -i {2} -r $fI -t [$aff, 1] -t $warp -n Linear -o ${fI%.nii*}_{2/};' ::: $snroot ::: $(ls $atlasroot/IIT_RANLRegistered_regions*.nii.gz | grep -E 'IIT_RANLRegistered_regions_.{3,6}.nii.gz')
}
export -f WarpDiffusionAtlasesToNative_CANTs

WarpDiffusionAtlasesToNative_antsMultiVar(){
	snroot=$1
	atlasroot=$2

	export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    	
	parallel --plus -j12 --bar 'warp={1..}_1InverseWarp.nii.gz;
aff={1..}_0GenericAffine.mat;
fI={1};
antsApplyTransforms -d 3 -v 1 -i {2} -r $fI -t [$aff, 1] -t $warp -n GenericLabel -o ${fI%.nii*}_{2/};' ::: $snroot ::: $atlasroot/IIT_RANLRegistered_regions*_*_*.nii.gz
 
    	parallel --plus -j12 --bar 'warp={1..}_1InverseWarp.nii.gz;
aff={1..}_0GenericAffine.mat;
fI={1};
antsApplyTransforms -d 3 -v 1 -i {2} -r $fI -t [$aff, 1] -t $warp -n Linear -o ${fI%.nii*}_{2/};' ::: $snroot ::: $(ls $atlasroot/IIT_RANLRegistered_regions*.nii.gz | grep -E 'IIT_RANLRegistered_regions_.{3,6}.nii.gz')
}
export -f WarpDiffusionAtlasesToNative_antsMultiVar

WarpDiffusionAtlasesToNative(){
	nativefiles=$1
	affmats=$2
	invwarps=$3
	atlasroot=$4

	export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    	
	parallel --plus -j12 --bar '
fI={1};
aff={2};
warp={3};
antsApplyTransforms -d 3 -v 1 -i {4} -r $fI -t [$aff, 1] -t $warp -n GenericLabel -o ${fI%.nii*}_{4/};' ::: $nativefiles :::+ $affmats :::+ $invwarps ::: $atlasroot/IIT_RANLRegistered_regions*_*_*.nii.gz
 
    	parallel --plus -j12 --bar '
fI={1};
aff={2};
warp={3};
antsApplyTransforms -d 3 -v 1 -i {4} -r $fI -t [$aff, 1] -t $warp -n Linear -o ${fI%.nii*}_{4/};' ::: $nativefiles :::+ $affmats :::+ $invwarps ::: $(ls $atlasroot/IIT_RANLRegistered_regions*.nii.gz | grep -E 'IIT_RANLRegistered_regions_.{3,6}.nii.gz')
}
export -f WarpDiffusionAtlasesToNative
