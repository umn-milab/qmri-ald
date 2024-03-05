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
SUB=$3
SESS=$4
DICOMFOLDER=$5
FSFOLDER=$6
ITKFOLDER=$7

#FSLOUTPUTTYPE=NIFTI_GZ
#export FSLOUTPUTTYPE

if [ -f $NIIFOLDER/mprage.nii.gz ]; then
    if [ ! -f $RESULTFOLDER/mprage_brain.nii.gz ];then
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Brain extraction started"
        bet $NIIFOLDER/mprage.nii.gz $RESULTFOLDER/mprage_brain -m -o -B -f 0.25
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Brain extraction done"
    fi
    if [ ! -f $RESULTFOLDER/mprage_brain_pveseg.nii.gz ];then
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: WM/GM segmentation started"
        fast -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -o $RESULTFOLDER/mprage_brain $RESULTFOLDER/mprage_brain.nii.gz
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: WM/GM segmentation done"
    fi
    if [ ! -f $RESULTFOLDER/fnirt_nat2std.mat ];then
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: flirt mprage-template registration started"
        flirt -in $RESULTFOLDER/mprage_brain.nii.gz -ref $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz -omat $RESULTFOLDER/fnirt_nat2std.mat -cost mutualinfo -interp sinc
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: flirt mprage-template registration done"
    fi
    if [ ! -f $RESULTFOLDER/fnirt_std2nat.mat ];then
        convert_xfm -omat $RESULTFOLDER/fnirt_std2nat.mat -inverse $RESULTFOLDER/fnirt_nat2std.mat
    fi
    if [ ! -f $RESULTFOLDER/MNI_mprage_brain_fnirt.nii.gz ];then
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: fnirt mprage-template registration started"
        fnirt --in=$RESULTFOLDER/mprage_brain.nii.gz --aff=$RESULTFOLDER/fnirt_nat2std.mat --ref=$FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz --cout=$RESULTFOLDER/fnirt_nat2std_warp --iout=$RESULTFOLDER/MNI_mprage_brain_fnirt.nii.gz --inmask=$RESULTFOLDER/mprage_brain_mask.nii.gz --refmask=$FSLDIR/data/standard/MNI152_T1_1mm_brain_mask_dil.nii.gz --infwhm=4,2,1,1 --reffwhm=2,1,0,0 --interp=spline
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: fnirt mprage-template registration done"
    fi
    if [ ! -f $RESULTFOLDER/fnirt_std2nat_warp.nii.gz ];then
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Inverse-Warp estimation started"
        invwarp -w $RESULTFOLDER/fnirt_nat2std_warp.nii.gz -o $RESULTFOLDER/fnirt_std2nat_warp.nii.gz -r $RESULTFOLDER/mprage_brain.nii.gz
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Inverse-Warp estimation done"
    fi
    if [ ! -f $RESULTFOLDER/mprage_JHU-ICBM-labels.nii.gz ];then
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Warp JHU-ICBM atlas to mprage space started"
        applywarp -i $FSLDIR/data/atlases/JHU/JHU-ICBM-labels-1mm.nii.gz -r $RESULTFOLDER/mprage_brain.nii.gz -o $RESULTFOLDER/mprage_JHU-ICBM-labels.nii.gz -w $RESULTFOLDER/fnirt_std2nat_warp.nii.gz --interp=nn
        #flirt -in $RESULTFOLDER/mprage_JHU-ICBM-labels.nii.gz -ref $RESULTFOLDER/mprage_brain.nii.gz -applyxfm -init $RESULTFOLDER/fnirt_std2nat.mat -interp nearestneighbour -out $RESULTFOLDER/mprage_JHU-ICBM-labels.nii.gz
        dt=$(date '+%Y/%m/%d %H:%M:%S');
        echo "$dt $SESS: Warp JHU-ICBM atlas to mprage space done"
    fi
	if [ -f $ITKFOLDER/*T1*[0-9]_Segmentation_v2.nii.gz ] && [ ! -f $RESULTFOLDER/mprage_lesion.nii.gz ]; then
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: copy lesion mask into mprage folder started"
		cp $ITKFOLDER/*T1*[0-9]_Segmentation_v2.nii.gz $RESULTFOLDER/mprage_lesion.nii.gz
		fslmaths $RESULTFOLDER/mprage_lesion.nii.gz -bin $RESULTFOLDER/mprage_lesion.nii.gz
		fslreorient2std $RESULTFOLDER/mprage_lesion.nii.gz $RESULTFOLDER/mprage_lesion.nii.gz
		chmod 660 $RESULTFOLDER/mprage_lesion.nii.gz
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: copy lesion mask into mprage folder done"
	elif [ -f $ITKFOLDER/*T1*[0-9]_Segmentation.nii.gz ] && [ ! -f $RESULTFOLDER/mprage_lesion.nii.gz ]; then
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: copy lesion mask into mprage folder started"
		cp $ITKFOLDER/*T1*[0-9]_Segmentation.nii.gz $RESULTFOLDER/mprage_lesion.nii.gz
		fslmaths $RESULTFOLDER/mprage_lesion.nii.gz -bin $RESULTFOLDER/mprage_lesion.nii.gz
		fslreorient2std $RESULTFOLDER/mprage_lesion.nii.gz $RESULTFOLDER/mprage_lesion.nii.gz
		chmod 660 $RESULTFOLDER/mprage_lesion.nii.gz
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: copy lesion mask into mprage folder done"
	fi
	if [ -f ${FSFOLDER}*lesionfilled/mri/aseg.mgz ] && [ ! -f $RESULTFOLDER/mprage_aseg.nii.gz ]; then
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: copy aseg file into mprage folder started"
		mri_convert ${FSFOLDER}*lesionfilled/mri/aseg.mgz $RESULTFOLDER/fs_aseg.nii.gz > /dev/null
		fslreorient2std $RESULTFOLDER/fs_aseg.nii.gz $RESULTFOLDER/fs_aseg.nii.gz
		mri_convert ${FSFOLDER}*lesionfilled/mri/brain.mgz $RESULTFOLDER/fs_brain.nii.gz > /dev/null
		fslreorient2std $RESULTFOLDER/fs_brain.nii.gz $RESULTFOLDER/fs_brain.nii.gz
		fslmaths $RESULTFOLDER/fs_brain.nii.gz -bin $RESULTFOLDER/fs_mask.nii.gz
		flirt -in $RESULTFOLDER/fs_brain.nii.gz -ref $RESULTFOLDER/mprage_brain.nii.gz -omat $RESULTFOLDER/fs2nat.mat
		convert_xfm -omat $RESULTFOLDER/nat2fs.mat -inverse $RESULTFOLDER/fs2nat.mat
		flirt -in $RESULTFOLDER/fs_aseg.nii.gz -ref $RESULTFOLDER/mprage_brain.nii.gz -applyxfm -init $RESULTFOLDER/fs2nat.mat -out $RESULTFOLDER/mprage_aseg.nii.gz -interp nearestneighbour
		chmod 660 $RESULTFOLDER/fs_*.nii.gz
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: copy aseg file into mprage folder done"
	elif [ -f $FSFOLDER/mri/aseg.mgz ] && [ ! -f $RESULTFOLDER/mprage_aseg.nii.gz ]; then
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: copy aseg file into mprage folder started"
		mri_convert ${FSFOLDER}/mri/aseg.mgz $RESULTFOLDER/fs_aseg.nii.gz > /dev/null
		fslreorient2std $RESULTFOLDER/fs_aseg.nii.gz $RESULTFOLDER/fs_aseg.nii.gz
		mri_convert ${FSFOLDER}/mri/brain.mgz $RESULTFOLDER/fs_brain.nii.gz > /dev/null
		fslreorient2std $RESULTFOLDER/fs_brain.nii.gz $RESULTFOLDER/fs_brain.nii.gz
		fslmaths $RESULTFOLDER/fs_brain.nii.gz -bin $RESULTFOLDER/fs_mask.nii.gz
		flirt -in $RESULTFOLDER/fs_brain.nii.gz -ref $RESULTFOLDER/mprage_brain.nii.gz -omat $RESULTFOLDER/fs2nat.mat
		convert_xfm -omat $RESULTFOLDER/nat2fs.mat -inverse $RESULTFOLDER/fs2nat.mat
		flirt -in $RESULTFOLDER/fs_aseg.nii.gz -ref $RESULTFOLDER/mprage_brain.nii.gz -applyxfm -init $RESULTFOLDER/fs2nat.mat -out $RESULTFOLDER/mprage_aseg.nii.gz -interp nearestneighbour
		chmod 660 $RESULTFOLDER/fs_*.nii.gz
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: copy aseg file into mprage folder done"
	fi
	if [ -f $RESULTFOLDER/mprage_lesion.nii.gz ] && [ -f $RESULTFOLDER/nat2fs.mat ] && [ ! -f $RESULTFOLDER/fs_lesion.nii.gz ]; then
		flirt -in $RESULTFOLDER/mprage_lesion.nii.gz -ref $RESULTFOLDER/fs_brain.nii.gz -applyxfm -init $RESULTFOLDER/nat2fs.mat -out $RESULTFOLDER/fs_lesion.nii.gz -interp nearestneighbour
	fi
    chmod -R g=u $RESULTFOLDER
    chmod -R o-rwx $RESULTFOLDER
else
    echo "MPRAGE file does not exist: $NIIFOLDER/mprage.nii.gz"
fi
