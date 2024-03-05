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
