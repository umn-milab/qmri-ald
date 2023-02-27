#!/bin/bash
NIIFOLDER=$1
RESULTFOLDER=$2
MPRFOLDER=$3
SUB=$4
SESS=$5
DICOMFOLDER=$6

if [ -f $RESULTFOLDER/t1rho_mc_t1rho_proc.nii.gz ];then
	if [ ! -f $RESULTFOLDER/t1rho_mc_t1rho_proc_brain_mask.nii.gz ];then
		dt=$(date '+%Y/%m/%d %H:%M:%S');
        	echo "$dt $SESS: Brain extraction started"
		#bet $RESULTFOLDER/t1rho_mc_t1rho_proc.nii.gz $RESULTFOLDER/t1rho_mc_t1rho_proc_brain -m -o -B -f 0.25
		bet $RESULTFOLDER/t1rho_mc_t1rho_proc.nii.gz $RESULTFOLDER/t1rho_mc_t1rho_proc_brain -m -o -f 0.5
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: Brain extraction done"
	fi
	if [ -f $MPRFOLDER/fs_aseg.nii.gz ] && [ ! -f $RESULTFOLDER/fs_aseg_failed.txt ];then
		if [ ! -f $RESULTFOLDER/flirt_t1rho2fs.mat ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: flirt t1rho-freesurfer registration started"
			flirt -in $RESULTFOLDER/t1rho_mc_t1rho_proc_brain.nii.gz -ref $MPRFOLDER/fs_brain.nii.gz -omat $RESULTFOLDER/flirt_t1rho2fs.mat -cost mutualinfo -interp sinc -o $MPRFOLDER/fs_t1rho.nii.gz
			convert_xfm -omat $RESULTFOLDER/flirt_fs2t1rho.mat -inverse $RESULTFOLDER/flirt_t1rho2fs.mat
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: flirt t1rho-freesurfer registration done"
		fi
		if [ ! -f $RESULTFOLDER/t1rho_aseg.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: warp freesurfer-aseg to t1rho started"
			flirt -in $MPRFOLDER/fs_aseg.nii.gz -ref $RESULTFOLDER/t1rho_mc_t1rho_proc_brain.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2t1rho.mat -interp nearestneighbour -out $RESULTFOLDER/t1rho_aseg.nii.gz
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: warp freesurfer-aseg to t1rho done"
		fi
	fi
	if [ -f $MPRFOLDER/mprage_brain.nii.gz ]; then
		if [ ! -f $RESULTFOLDER/flirt_t1rho2nat.mat ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: flirt t1rho-mprage registration started"
			flirt -in $RESULTFOLDER/t1rho_mc_t1rho_proc_brain.nii.gz -ref $MPRFOLDER/mprage_brain.nii.gz -omat $RESULTFOLDER/flirt_t1rho2nat.mat -cost mutualinfo -interp sinc -o $MPRFOLDER/mprage_t1rho.nii.gz
			convert_xfm -omat $RESULTFOLDER/flirt_nat2t1rho.mat -inverse $RESULTFOLDER/flirt_t1rho2nat.mat
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: flirt t1rho-mprage registration done"
		fi
		if [ -f $MPRFOLDER/mprage_lesion.nii.gz ] && [ ! -f $RESULTFOLDER/t1rho_lesion.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: warp lesion to t1rho started"
			flirt -in $MPRFOLDER/mprage_lesion.nii.gz -ref $RESULTFOLDER/t1rho_mc_t1rho_proc_brain.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2t1rho.mat -interp nearestneighbour -out $RESULTFOLDER/t1rho_lesion.nii.gz
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: warp lesion to t1rho done"
		fi
		if [ -f $MPRFOLDER/mprage_aseg.nii.gz ] && [ ! -f $RESULTFOLDER/t1rho_aseg.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: warp mprage-aseg to t1rho started"
			flirt -in $MPRFOLDER/mprage_aseg.nii.gz -ref $RESULTFOLDER/t1rho_mc_t1rho_proc_brain.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2t1rho.mat -interp nearestneighbour -out $RESULTFOLDER/t1rho_aseg.nii.gz
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: warp mprage-aseg to t1rho done"
		fi
	fi
	chmod -R g=u $RESULTFOLDER
	chmod -R o-rwx $RESULTFOLDER
fi
