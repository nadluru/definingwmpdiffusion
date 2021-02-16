#!/bin/bash

img=$1
tract=$2
outdir=$3
annotation=$4

prefix=$(basename $tract .tck)
parallel mrview $img -tractography.load $tract -tractography.slab -1 -mode 1 -plane {} -noannotations -capture.folder $outdir -capture.prefix ${prefix}_{}_ -capture.grab -exit ::: 0 1 2

convert $outdir/${prefix}_0_0000.png -trim $outdir/${prefix}_1_0000.png -trim $outdir/${prefix}_2_0000.png -trim -background black +append $outdir/${prefix}_Views.png

echo $annotation
convert $outdir/${prefix}_Views.png -layers merge +repage -gravity south -fill white -pointsize 60 -annotate 0 $annotation $outdir/${prefix}_Views_Annotated.png

rm $outdir/${prefix}_?_0000.png