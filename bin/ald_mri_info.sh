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

DATAFOLDER=~/data/ALD

#NAME=dmri_12dir
NAME=mprage
#NAME=*Segmentation

LIST=$DATAFOLDER/subject_list.txt
DICOMFOLDER=$DATAFOLDER/dicom
NIIFOLDER=$DATAFOLDER/nii

PRINTSUBLIST=0

OLDFOLDER=`pwd`
cd $NIIFOLDER
for SUB in `cat $LIST`;do
    for SESS in `ls -d ${SUB}/*`;do
        if [ $PRINTSUBLIST -ne 1 ];then
            if [ -f $NIIFOLDER/$SESS/$NAME.nii.gz ];then
                #echo $SESS            
                DIM1=`fslval $NIIFOLDER/$SESS/$NAME.nii.gz dim1`
                DIM2=`fslval $NIIFOLDER/$SESS/$NAME.nii.gz dim2`            
                DIM3=`fslval $NIIFOLDER/$SESS/$NAME.nii.gz dim3`
                DIM4=`fslval $NIIFOLDER/$SESS/$NAME.nii.gz dim4`
                PIXDIM1=`fslval $NIIFOLDER/$SESS/$NAME.nii.gz pixdim1`
                PIXDIM2=`fslval $NIIFOLDER/$SESS/$NAME.nii.gz pixdim2`            
                PIXDIM3=`fslval $NIIFOLDER/$SESS/$NAME.nii.gz pixdim3`
                PIXDIM4=`fslval $NIIFOLDER/$SESS/$NAME.nii.gz pixdim4`
            else
                #echo $SESS            
                DIM1="0 "
                DIM2="0 "
                DIM3="0 "
                DIM4="0 "
                PIXDIM1="0 "
                PIXDIM2="0 "
                PIXDIM3="0 "
                PIXDIM4="0"
            fi
            echo "$DIM1$DIM2$DIM3$DIM4$PIXDIM1$PIXDIM2$PIXDIM3$PIXDIM4" >> $DATAFOLDER/${NAME}_info_list.txt
        else
            echo $SESS >> ~/ald_session_list_git.txt
        fi
    done
done
