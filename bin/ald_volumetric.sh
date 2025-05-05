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

DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/ALD

LESION=fs_lesion
ASEG=fs_aseg

LIST=$DATAFOLDER/subject_list_20230307.txt
DICOMFOLDER=$DATAFOLDER/dicom
NIIFOLDER=$DATAFOLDER/nii
RESULTFOLDER=$DATAFOLDER/results
MPRFOLDER=$RESULTFOLDER/mprage
ITKFOLDER=$DATAFOLDER/results/itk-snap

OLDFOLDER=`pwd`
cd $NIIFOLDER
echo "LesionVol	SpleniumVol	SpleniumLesionVol	CerebralWMVol	CerebralWMLesionVol	RightLesionVol	LeftLesionVol" > $RESULTFOLDER/lesion_volumetrics.txt
for SUB in `cat $LIST`;do
    for SESS in `ls -d ${SUB}/*`;do
		TEMPFILE=$MPRFOLDER/$SESS/temp.nii.gz
		TEMPFILE1=$MPRFOLDER/$SESS/temp1.nii.gz
		TEMPFILE2=$MPRFOLDER/$SESS/temp2.nii.gz
		TEMPFILE3=$MPRFOLDER/$SESS/temp3.nii.gz
        if [ -f $MPRFOLDER/$SESS/$LESION.nii.gz ] && [ -f $MPRFOLDER/$SESS/$ASEG.nii.gz ];then
			LESIONVOL=`fslstats $MPRFOLDER/$SESS/$LESION.nii.gz -V | awk '{print $2}'`

			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 251 -uthr 251 -bin $TEMPFILE
			SPLVOL=`fslstats $TEMPFILE -V | awk '{print $2}'`
			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 251 -uthr 251 -mas $MPRFOLDER/$SESS/fs_lesion.nii.gz -bin $TEMPFILE
			SPLLESVOL=`fslstats $TEMPFILE -V | awk '{print $2}'`

			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 251 -uthr 255 -bin $TEMPFILE
			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 2 -uthr 2 -bin $TEMPFILE1
			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 41 -uthr 41 -bin $TEMPFILE2
			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 77 -uthr 79 -bin $TEMPFILE3
			fslmaths $TEMPFILE -add $TEMPFILE1 -add $TEMPFILE2 -add $TEMPFILE3 -bin $TEMPFILE
			CEREBWMVOL=`fslstats $TEMPFILE -V | awk '{print $2}'`

			fslmaths $TEMPFILE -mas $MPRFOLDER/$SESS/fs_lesion.nii.gz -bin $TEMPFILE
			CEREBWMLESVOL=`fslstats $TEMPFILE -V | awk '{print $2}'`

			if [ -f $ITKFOLDER/$SESS/*_Asym_Segmentation.nii.gz ];then
				fslmaths $ITKFOLDER/$SESS/*_Asym_Segmentation.nii.gz -thr 1 -uthr 1 -bin $TEMPFILE
				RIGHTLESIONVOL=`fslstats $TEMPFILE -V | awk '{print $2}'`

				fslmaths $ITKFOLDER/$SESS/*_Asym_Segmentation.nii.gz -thr 2 -uthr 2 -bin $TEMPFILE
				LEFTLESIONVOL=`fslstats $TEMPFILE -V | awk '{print $2}'`

				echo "$LESIONVOL	$SPLVOL	$SPLLESVOL	$CEREBWMVOL	$CEREBWMLESVOL	$RIGHTLESIONVOL	$LEFTLESIONVOL" >> $RESULTFOLDER/lesion_volumetrics.txt
			else
            			echo "$LESIONVOL	$SPLVOL	$SPLLESVOL	$CEREBWMVOL	$CEREBWMLESVOL	0	0" >> $RESULTFOLDER/lesion_volumetrics.txt
			fi

			rm $TEMPFILE $TEMPFILE1 $TEMPFILE2 $TEMPFILE3
		elif [ -f $MPRFOLDER/$SESS/$ASEG.nii.gz ];then
			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 251 -uthr 251 -bin $TEMPFILE
			SPLVOL=`fslstats $TEMPFILE -V | awk '{print $2}'`

			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 251 -uthr 255 -bin $TEMPFILE
			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 2 -uthr 2 -bin $TEMPFILE1
			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 41 -uthr 41 -bin $TEMPFILE2
			fslmaths $MPRFOLDER/$SESS/$ASEG.nii.gz -thr 77 -uthr 79 -bin $TEMPFILE3
			fslmaths $TEMPFILE -add $TEMPFILE1 -add $TEMPFILE2 -add $TEMPFILE3 -bin $TEMPFILE
			CEREBWMVOL=`fslstats $TEMPFILE -V | awk '{print $2}'`

			echo "0	$SPLVOL	0	$CEREBWMVOL	0	0	0" >> $RESULTFOLDER/lesion_volumetrics.txt

			rm $TEMPFILE $TEMPFILE1 $TEMPFILE2 $TEMPFILE3
		elif [ -f $MPRFOLDER/$SESS/$LESION.nii.gz ];then
			LESIONVOL=`fslstats $MPRFOLDER/$SESS/$LESION.nii.gz -V | awk '{print $2}'`

			echo "$LESIONVOL	0	0	0	0	0	0" >> $RESULTFOLDER/lesion_volumetrics.txt
        else           
            echo "0	0	0	0	0	0	0" >> $RESULTFOLDER/lesion_volumetrics.txt
        fi
		echo "$SESS processed."
    done
done
