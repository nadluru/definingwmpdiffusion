#!/bin/bash
dwmpdir=DWMP
lateral=(AF CB CST Fornix IFOF ILF MLF OR POPT SLF-I SLF-II SLF-III UF)
commissural=(CC AC PC)
export codedir=definingwmpdiffusion/Scripts

parallel --dry-run -j10 bash $codedir/Dissect_{1}.sh $dwmpdir/TCK-Streamlines/{2}/{3} $dwmpdir/SubmissionMaterial/{2} {4} ::: ${lateral[@]} ::: s{2..6} ::: tracking-deterministic-left.Bfloat tracking-probabilistic-left.Bfloat tracking-*-left.Bfloat :::+ det prob detprob
parallel --dry-run -j10 bash $codedir/Dissect_{1}.sh $dwmpdir/TCK-Streamlines/{2}/{3} $dwmpdir/SubmissionMaterial/{2} {4} ::: ${commissural[@]} ::: s{2..6} ::: tracking-deterministic-comm.Bfloat tracking-probabilistic-comm.Bfloat tracking-*-comm.Bfloat :::+ det prob detprob
parallel --dry-run mrview {1}/fa.nii.gz -tractography.load {1}/{2}Tract/{2}_{3}.tck -tractography.slab -1 -mode 2 -capture.folder {1}/{2}Tract -capture.prefix {2}_{3}_ -capture.grab -exit ::: s{2..6} ::: ${lateral[@]} ${commissural[@]} ::: det prob detprob

commissural=(AC PC)
parallel --dry-run 'bash $codedir/Render_MRTRIX_Scene.sh {1}/fa.nii.gz {1}/{2}Tract/{2}_{3}.tck {1}/{2}Tract $(echo "{1/}-{2}\n\n{3}\n\ncount:$(tckstats {1}/{2}Tract/{2}_{3}.tck -output count -quiet)")' ::: $dwmpdir/SubmissionMaterial/s{2..6} ::: ${lateral[@]} ${commissural[@]} ::: det prob detprob
parallel --dry-run -j5 'bash $codedir/Render_MRTRIX_Scene.sh {1}/fa.nii.gz {1}/{2}Tract/{2}_{3}.tck {1}/{2}Tract $(echo "{1/}-{2}\n\n{3}\n\ncount:$(tckstats {1}/{2}Tract/{2}_{3}.tck -output count -quiet)")' ::: $dwmpdir/SubmissionMaterial/s{2..6} ::: CC ::: det prob detprob
