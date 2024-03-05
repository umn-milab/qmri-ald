#!/bin/bash
# The "qmri-ald" program provides automated image-processing pipelines for
# structural MRI images primarily acquired in pediatric healthy controls
# and pediatric patients with cerebral adrenoleukodystrophy. The program
# provides preprocessing, processing, quantitative, and statistical analysis
# of MRI images such as T1-weighted anatomical scans, diffusion MRI scans
# utilizing DTI and HARDI protocols or T1-rho and T2-rho scans.
# 
# Copyright (C) 2024  Rene Labounek (1,a), Igor Nestrasil (1,b)
# Medical Imaging Lab (MILab)
# 
# 1 Medical Imaging Lab (MILab), Division of Clinical Behavioral Neuroscience,
#   Department of Pediatrics, University of Minnesota,
#   Masonic Institute for the Developing Brain,
#   2025 East River Parkway, Minneapolis, MN 55414, USA
# a) email: rlaboune@umn.edu
# b) email: nestr007@umn.edu
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

NIIFOLDER=$1
RESULTFOLDER=$2
MPRFOLDER=$3
SUB=$4
SESS=$5
DICOMFOLDER=$6

#FSLOUTPUTTYPE=NIFTI_GZ
#export FSLOUTPUTTYPE

if [ -f $MPRFOLDER/mprage_brain.nii.gz ] && [ ! -L $RESULTFOLDER/mprage_brain.nii.gz ]; then
    ln -s $MPRFOLDER/mprage_brain.nii.gz $RESULTFOLDER/mprage_brain.nii.gz
fi
if [ -f $MPRFOLDER/mprage_JHU-ICBM-labels.nii.gz ] && [ ! -L $RESULTFOLDER/mprage_JHU-ICBM-labels.nii.gz ];then
    ln -s $MPRFOLDER/mprage_JHU-ICBM-labels.nii.gz $RESULTFOLDER/mprage_JHU-ICBM-labels.nii.gz
fi
if [ -f $MPRFOLDER/MNI_mprage_brain_fnirt.nii.gz ] && [ ! -L $RESULTFOLDER/MNI_mprage_brain_fnirt.nii.gz ];then
    ln -s $MPRFOLDER/MNI_mprage_brain_fnirt.nii.gz $RESULTFOLDER/MNI_mprage_brain_fnirt.nii.gz
fi

DIRNUM=12
if [ -f $NIIFOLDER/dmri_${DIRNUM}dir.nii.gz ];then
    if [ ! -f $RESULTFOLDER/dmri_${DIRNUM}dir_EC.nii.gz ];then
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Eddy correct started"
        eddy_correct $NIIFOLDER/dmri_${DIRNUM}dir.nii.gz $RESULTFOLDER/dmri_${DIRNUM}dir_EC.nii.gz 0 spline > $RESULTFOLDER/dmri_${DIRNUM}dir_EC.log
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Eddy correct done"
    fi
    if [ ! -f $RESULTFOLDER/dmri_${DIRNUM}dir_EC_brain_mask.nii.gz ];then
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Diffusion mask estimation started"
        fslmaths $RESULTFOLDER/dmri_${DIRNUM}dir_EC.nii.gz -Tmean $RESULTFOLDER/dmri_${DIRNUM}dir_EC_mean.nii.gz
        bet $RESULTFOLDER/dmri_${DIRNUM}dir_EC_mean.nii.gz $RESULTFOLDER/dmri_${DIRNUM}dir_EC_brain -m -o -f 0.4
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Diffusion mask estimation done" 
    fi
    if [ ! -f $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz ];then
        dtifit -k $RESULTFOLDER/dmri_${DIRNUM}dir_EC.nii.gz -o $RESULTFOLDER/dti${DIRNUM} -r $NIIFOLDER/dmri_${DIRNUM}dir.bvec -b $NIIFOLDER/dmri_${DIRNUM}dir.bval -m $RESULTFOLDER/dmri_${DIRNUM}dir_EC_brain_mask.nii.gz > $RESULTFOLDER/dti${DIRNUM}.log
    fi
    if [ -f $MPRFOLDER/mprage_brain.nii.gz ];then
        if [ ! -f $RESULTFOLDER/flirt_diff2nat.mat ];then
            dt=$(date '+%Y/%m/%d %H:%M:%S');
            echo "$dt $SESS: flirt diff-mprage registration started"
            flirt -in $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz -ref $MPRFOLDER/mprage_brain.nii.gz -omat $RESULTFOLDER/flirt_diff2nat.mat -cost mutualinfo -interp sinc
            convert_xfm -omat $RESULTFOLDER/flirt_nat2diff.mat -inverse $RESULTFOLDER/flirt_diff2nat.mat
            dt=$(date '+%Y/%m/%d %H:%M:%S');
            echo "$dt $SESS: flirt diff-mprage registration done"
        fi

		if [ ! -f $RESULTFOLDER/mprage_FA_fnirt.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: fnirt diff-mprage registration started"
			fnirt --in=$RESULTFOLDER/dti${DIRNUM}_FA.nii.gz --aff=$RESULTFOLDER/flirt_diff2nat.mat --ref=$MPRFOLDER/mprage_brain.nii.gz --cout=$RESULTFOLDER/fnirt_diff2nat_warp --iout=$RESULTFOLDER/mprage_FA_fnirt.nii.gz --inmask=$RESULTFOLDER/dmri_${DIRNUM}dir_EC_brain_mask.nii.gz --refmask=$MPRFOLDER/mprage_brain_mask.nii.gz --infwhm=4,2,1,1 --reffwhm=2,1,0,0 --interp=spline
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: fnirt diff-mprage registration done"
		fi
		if [ ! -f $RESULTFOLDER/fnirt_nat2diff_warp.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: Inverse-Warp mprage-diff estimation started"
			invwarp -w $RESULTFOLDER/fnirt_diff2nat_warp.nii.gz -o $RESULTFOLDER/fnirt_nat2diff_warp.nii.gz -r $MPRFOLDER/mprage_brain.nii.gz
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: Inverse-Warp mprage-diff estimation done"
		fi
        if [ -f $MPRFOLDER/mprage_JHU-ICBM-labels.nii.gz ] && [ ! -f $RESULTFOLDER/dmri_JHU-ICBM-labels.nii.gz ] ;then
            dt=$(date '+%Y/%m/%d %H:%M:%S');
            echo "$dt $SESS: warp atlas to diff started"
            flirt -in $MPRFOLDER/mprage_JHU-ICBM-labels.nii.gz -ref $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2diff.mat -interp nearestneighbour -out $RESULTFOLDER/dmri_JHU-ICBM-labels.nii.gz
            dt=$(date '+%Y/%m/%d %H:%M:%S');
            echo "$dt $SESS: warp atlas to diff done"
        fi
		if [ -f $MPRFOLDER/mprage_lesion.nii.gz ] && [ ! -f $RESULTFOLDER/dmri_lesion.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: warp lesion to diff started"
			flirt -in $MPRFOLDER/mprage_lesion.nii.gz -ref $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2diff.mat -interp nearestneighbour -out $RESULTFOLDER/dmri_lesion.nii.gz
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: warp lesion to diff done"
		fi
		if [ -f $MPRFOLDER/mprage_lesion.nii.gz ] && [ ! -f $RESULTFOLDER/dmri_lesion_fnirt.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: Warp fnirt-warp lesion to diff started"
			applywarp -i $MPRFOLDER/mprage_lesion.nii.gz -r $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz -o $RESULTFOLDER/dmri_lesion_fnirt.nii.gz -w $RESULTFOLDER/fnirt_nat2diff_warp.nii.gz --interp=nn
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: Warp fnirt-warp lesion to diff started done"
		fi
    fi
    if [ ! -f $RESULTFOLDER/diff2jhu_warp.nii.gz ];then
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: JHU-FA to diff registration started"
        fsl_reg $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz $FSLDIR/data/atlases/JHU/JHU-ICBM-FA-1mm.nii.gz $RESULTFOLDER/diff2jhu -FA -e
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: JHU-FA to diff registration done"
    fi
    if [ ! -f $RESULTFOLDER/jhu2diff_warp.nii.gz ];then
        invwarp -w $RESULTFOLDER/diff2jhu_warp.nii.gz -o $RESULTFOLDER/jhu2diff_warp.nii.gz -r $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz
    fi
    if [ ! -f $RESULTFOLDER/jhu_labels.nii.gz ];then
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Warp JHU-ICBM atlas to diff space started"
        applywarp -i $FSLDIR/data/atlases/JHU/JHU-ICBM-labels-1mm.nii.gz -r $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz -o $RESULTFOLDER/jhu_labels.nii.gz -w $RESULTFOLDER/jhu2diff_warp.nii.gz --interp=nn
        #flirt -in $RESULTFOLDER/mprage_JHU-ICBM-labels.nii.gz -ref $RESULTFOLDER/mprage_brain.nii.gz -applyxfm -init $RESULTFOLDER/fnirt_std2nat.mat -interp nearestneighbour -out $RESULTFOLDER/mprage_JHU-ICBM-labels.nii.gz
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Warp JHU-ICBM atlas to diff space done"
    fi
	if [ -f $MPRFOLDER/fs_aseg.nii.gz ];then
		if [ ! -f $RESULTFOLDER/flirt_diff2fs.mat ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
            echo "$dt $SESS: flirt diff-freesurfer registration started"
            flirt -in $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz -ref $MPRFOLDER/fs_brain.nii.gz -omat $RESULTFOLDER/flirt_diff2fs.mat -cost mutualinfo -interp sinc
            convert_xfm -omat $RESULTFOLDER/flirt_fs2diff.mat -inverse $RESULTFOLDER/flirt_diff2fs.mat
            dt=$(date '+%Y/%m/%d %H:%M:%S');
            echo "$dt $SESS: flirt diff-freesurfer registration done"
		fi
		if [ ! -f $RESULTFOLDER/fs_FA_fnirt.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: fnirt diff-fs registration started"
			fnirt --in=$RESULTFOLDER/dti${DIRNUM}_FA.nii.gz --aff=$RESULTFOLDER/flirt_diff2fs.mat --ref=$MPRFOLDER/fs_brain.nii.gz --cout=$RESULTFOLDER/fnirt_diff2fs_warp --iout=$RESULTFOLDER/fs_FA_fnirt.nii.gz --inmask=$RESULTFOLDER/dmri_${DIRNUM}dir_EC_brain_mask.nii.gz --refmask=$MPRFOLDER/fs_mask.nii.gz --infwhm=4,2,1,1 --reffwhm=2,1,0,0 --interp=spline
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: fnirt diff-fs registration done"
		fi
		if [ ! -f $RESULTFOLDER/fnirt_fs2diff_warp.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: Inverse-Warp fs-diff estimation started"
			invwarp -w $RESULTFOLDER/fnirt_diff2fs_warp.nii.gz -o $RESULTFOLDER/fnirt_fs2diff_warp.nii.gz -r $MPRFOLDER/fs_brain.nii.gz
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: Inverse-Warp fs-diff estimation done"
		fi
		if [ ! -f $RESULTFOLDER/dmri_aseg.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
            echo "$dt $SESS: warp freesurfer-aseg to diff started"
            flirt -in $MPRFOLDER/fs_aseg.nii.gz -ref $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp nearestneighbour -out $RESULTFOLDER/dmri_aseg.nii.gz
            dt=$(date '+%Y/%m/%d %H:%M:%S');
            echo "$dt $SESS: warp freesurfer-aseg to diff done"
		fi
		if [ ! -f $RESULTFOLDER/dmri_aseg_fnirt.nii.gz ];then
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: Warp fnirt-warp aseg to diff started"
			applywarp -i $MPRFOLDER/fs_aseg.nii.gz -r $RESULTFOLDER/dti${DIRNUM}_FA.nii.gz -o $RESULTFOLDER/dmri_aseg_fnirt.nii.gz -w $RESULTFOLDER/fnirt_fs2diff_warp.nii.gz --interp=nn
			dt=$(date '+%Y/%m/%d %H:%M:%S');
			echo "$dt $SESS: Warp fnirt-warp aseg to diff started done"
		fi
	fi
fi
chmod -R g=u $RESULTFOLDER
chmod -R o-rwx $RESULTFOLDER
