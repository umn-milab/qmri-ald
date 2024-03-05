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

LIST=$DATAFOLDER/subject_list_20230307.txt
DICOMFOLDER=$DATAFOLDER/dicom
NIIFOLDER=$DATAFOLDER/nii

OLDFOLDER=`pwd`
cd $DICOMFOLDER
for SUB in `cat $LIST`;do
    if [ ! -d $NIIFOLDER/${SUB} ];then
		mkdir $NIIFOLDER/${SUB}
		chmod 770 $NIIFOLDER/${SUB}
	fi
    
    for SESS in `ls -d ${SUB}/*`;do
        if [ ! -d $NIIFOLDER/$SESS ];then
		    mkdir $NIIFOLDER/$SESS
		    chmod 770 $NIIFOLDER/$SESS
	    fi
		#echo $SESS
        if [ ! -f $NIIFOLDER/$SESS/mprage.nii.gz ];then
            # mprage export
            STRING="MPRAGE_Series"
            if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="T1*MPRAGE*SAG_Series"
            fi
            if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="MPRAGE*SAG_Series"
            fi
			if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
				STRING="SAG_T1_MPRAGE"
			fi
			if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
				STRING="SAG_T1_MPRAGE_Series"
			fi
            if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="MPRAGE_SAG_accelerated_Series"
            fi
            if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="AX*RECON*PRE_Series"
            fi
            if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="recon*ax*pre_Series"
            fi
            if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="T1_FLASH_MPRAGE_SAG_2"
            fi
            if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="cor_recon_mprage_pre"
            fi
            if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="T1_MPRAGE_SAG_accelerated_ND"
            fi
			if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="SAG_T1_MPRAGE_2"
            fi
			if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="SAG*T1*MPRAGE_Series"
            fi
			if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                STRING="MPRAGE_SAG_2"
            fi
			if [ -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
				echo "$SESS: mprage export from DICOM to NIFTI"
				cp $DICOMFOLDER/$SESS/*$STRING*.nii.gz $NIIFOLDER/$SESS/mprage.nii.gz
				cp $DICOMFOLDER/$SESS/*$STRING*.json $NIIFOLDER/$SESS/mprage.json
				chmod 660 $NIIFOLDER/$SESS/mprage.*
			else
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="T1*MPRAGE*SAG_Series"
		        fi
			if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="SAG_T1_MPRAGE"
		        fi
			if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="SAG_T1_MPRAGE_Series"
		        fi
		        if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="MPRAGE*SAG_Series"
		        fi
		        if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="MPRAGE_SAG_accelerated_Series"
		        fi
		        if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="AX*RECON*PRE_Series"
		        fi
		        if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="recon*ax*pre_Series"
		        fi
		        if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="T1_FLASH_MPRAGE_SAG"
		        fi
		        if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="cor_recon_mprage_pre"
		        fi
		        if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="T1_MPRAGE_SAG_accelerated_ND"
		        fi
			if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="SAG_T1_MPRAGE_2"
		        fi
			if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="SAG*T1*MPRAGE_Series"
		        fi
			if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="T1_TFLASH_MPRAGE_SAG_PreContrast"
		        fi
				if [ -d $DICOMFOLDER/$SESS/*$STRING* ];then
					echo "$SESS: mprage export from DICOM to NIFTI"
				    mkdir $NIIFOLDER/$SESS/temp
				    dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/*$STRING*/* > /dev/null
				    cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/mprage.nii.gz
				    cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/mprage.json
				    rm -r $NIIFOLDER/$SESS/temp
					chmod 660 $NIIFOLDER/$SESS/mprage.*
				fi
			fi
	    fi
        if [ ! -f $NIIFOLDER/$SESS/mprageGd.nii.gz ];then
			if [ -f $DICOMFOLDER/$SESS/*Post_Series*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/T1*MPRAGE*C_Series*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/T1_FLASH_MPRAGE_SAG_post*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/*cor_recon_mprage_CE*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/*SAG_T1_MPRAGE_Post_*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/*SAG_T1_MPRAGE_POST_*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/*SAG_T1_MPRAGE_post_*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/T1_FLASH_MPRAGE_SAG_+C_2*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/MPRAGE_SAG_+C_2*.nii.gz ];then
				echo "$SESS: mprageGd export from DICOM to NIFTI"
                STRING="Post_Series"
                if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="T1*MPRAGE*C_Series*"
                fi
                if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="T1_FLASH_MPRAGE_SAG_post"
                fi
                if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="cor_recon_mprage_CE"
                fi
                if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="SAG_T1_MPRAGE_Post_"
                fi
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="SAG_T1_MPRAGE_POST_"
                fi
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="SAG_T1_MPRAGE_post_"
                fi
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="T1_FLASH_MPRAGE_SAG_+C_2"
                fi
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="MPRAGE_SAG_+C_2"
                fi
				if [ -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
					cp $DICOMFOLDER/$SESS/*$STRING*.nii.gz $NIIFOLDER/$SESS/mprageGd.nii.gz
					cp $DICOMFOLDER/$SESS/*$STRING*.json $NIIFOLDER/$SESS/mprageGd.json
					chmod 660 $NIIFOLDER/$SESS/mprageGd.*
				fi
            elif [ -d $DICOMFOLDER/$SESS/*Post_Series* ] || [ -d $DICOMFOLDER/$SESS/T1*MPRAGE*C_Series* ] || [ -d $DICOMFOLDER/$SESS/T1_FLASH_MPRAGE_SAG_post* ] || [ -d $DICOMFOLDER/$SESS/*cor_recon_mprage_CE* ] || [ -d $DICOMFOLDER/$SESS/*SAG_T1_MPRAGE_POST* ] || [ -d $DICOMFOLDER/$SESS/*SAG_T1_MPRAGE_post* ] || [ -d $DICOMFOLDER/$SESS/*T1_TFLASH_MPRAGE_SAG_PostContrast* ];then
                # mprage export
		        echo "$SESS: mprageGd export from DICOM to NIFTI"
                STRING="Post_Series"
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="T1*MPRAGE*C_Series*"
                fi
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="T1_FLASH_MPRAGE_SAG_post"
                fi
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="cor_recon_mprage_CE"
                fi
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="SAG*T1*MPRAGE*Post_Series"
                fi
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="SAG_T1_MPRAGE_POST"
                fi
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="SAG_T1_MPRAGE_post"
                fi
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="T1_TFLASH_MPRAGE_SAG_PostContrast"
		        fi
				if [ -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            mkdir $NIIFOLDER/$SESS/temp
		            dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/*$STRING*/* > /dev/null
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/mprageGd.nii.gz
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/mprageGd.json
		            rm -r $NIIFOLDER/$SESS/temp
					chmod 660 $NIIFOLDER/$SESS/mprageGd.*
				fi
            fi
	    fi             
        if [ ! -f $NIIFOLDER/$SESS/swi.nii.gz ];then
			if [ -f $DICOMFOLDER/$SESS/*SWI_Images_Series*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/*SWI_Images_2*.nii.gz ];then
				STRING="SWI_Images_Series"
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
		            STRING="SWI_Images_2"
		        fi
				if [ -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
					echo "$SESS: swi export from DICOM to NIFTI"
					cp $DICOMFOLDER/$SESS/*$STRING*.nii.gz $NIIFOLDER/$SESS/swi.nii.gz
					cp $DICOMFOLDER/$SESS/*$STRING*.json $NIIFOLDER/$SESS/swi.json
					chmod 660 $NIIFOLDER/$SESS/swi.*
		        fi 
            elif [ -d $DICOMFOLDER/$SESS/*SWI_Images_Series* ] || [ -d $DICOMFOLDER/$SESS/*SWI_Images_2* ];then
                STRING="SWI_Images_Series"
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="SWI_Images_2"
		        fi
				if [ -d $DICOMFOLDER/$SESS/*$STRING* ];then
					echo "$SESS: swi export from DICOM to NIFTI"
		            mkdir $NIIFOLDER/$SESS/temp
		            dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/$STRING*/* > /dev/null
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/swi.nii.gz
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/swi.json
		            rm -r $NIIFOLDER/$SESS/temp
		            chmod 660 $NIIFOLDER/$SESS/swi.*
				fi
			fi
	    fi
        if [ ! -f $NIIFOLDER/$SESS/phase.nii.gz ];then
			if [ -f $DICOMFOLDER/$SESS/*Pha_Images_Series*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/*Pha_Images_2*.nii.gz ];then
				STRING="Pha_Images_Series"
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
		            STRING="Pha_Images_2"
		        fi
				if [ -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
					echo "$SESS: phase export from DICOM to NIFTI"
					cp $DICOMFOLDER/$SESS/*$STRING*.nii.gz $NIIFOLDER/$SESS/phase.nii.gz
					cp $DICOMFOLDER/$SESS/*$STRING*.json $NIIFOLDER/$SESS/phase.json
					chmod 660 $NIIFOLDER/$SESS/phase.*
            	fi
            elif [ -d $DICOMFOLDER/$SESS/*Pha_Images_Series* ] || [ -d $DICOMFOLDER/$SESS/*Pha_Images_2* ];then
                STRING="Pha_Images_Series"
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="Pha_Images_2"
		        fi
		        echo "$SESS: phase export from DICOM to NIFTI"
                mkdir $NIIFOLDER/$SESS/temp
                dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/$STRING*/* > /dev/null
                cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/phase.nii.gz
                cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/phase.json
                rm -r $NIIFOLDER/$SESS/temp
                chmod 660 $NIIFOLDER/$SESS/phase.*
			fi
	    fi
        
        if [ ! -f $NIIFOLDER/$SESS/flair.nii.gz ];then
			if [ -f $DICOMFOLDER/$SESS/T2*3DSPACE*SAG_Series*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/ax*flair*fs_Series*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/ax*flair*fs_2*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/Ax*FLAIR*FS*.nii.gz ];then
				STRING="T2*3DSPACE*SAG_Series"
                if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="ax*flair*fs_Series*"
                fi
		if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="ax*flair*fs_2*"
                fi
		if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
                    STRING="Ax*FLAIR*FS*"
                fi
				if [ -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
					echo "$SESS: flair export from DICOM to NIFTI"
					cp $DICOMFOLDER/$SESS/*$STRING*.nii.gz $NIIFOLDER/$SESS/flair.nii.gz
					cp $DICOMFOLDER/$SESS/*$STRING*.json $NIIFOLDER/$SESS/flair.json
					chmod 660 $NIIFOLDER/$SESS/flair.*
				fi
            elif [ -d $DICOMFOLDER/$SESS/T2*3DSPACE*SAG_Series* ] || [ -d $DICOMFOLDER/$SESS/ax*flair*fs_Series* ] || [ -d $DICOMFOLDER/$SESS/ax*flair*fs_2* ] || [ -d $DICOMFOLDER/$SESS/Sag_T2_Flair_Space_Series* ];then
                # mprage export
                STRING="T2*3DSPACE*SAG_Series"
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="ax*flair*fs_Series*"
                fi
		if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="ax*flair*fs_2*"
                fi
		if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="Sag_T2_Flair_Space_Series*"
                fi
				if [ -d $DICOMFOLDER/$SESS/*$STRING* ];then
					echo "$SESS: flair export from DICOM to NIFTI"
		            mkdir $NIIFOLDER/$SESS/temp
		            dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/$STRING*/* > /dev/null
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/flair.nii.gz
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/flair.json
		            rm -r $NIIFOLDER/$SESS/temp
		            chmod 660 $NIIFOLDER/$SESS/flair.*
				fi
            fi
	    fi

        SAVENAME=dmri_12dir
        if [ ! -f $NIIFOLDER/$SESS/$SAVENAME.nii.gz ];then
			if [ -f $DICOMFOLDER/$SESS/*12*DIR*DTI_Series*.bval ] || [ -f $DICOMFOLDER/$SESS/*12*DIR*P-A_Series*.bval ] || [ -f $DICOMFOLDER/$SESS/*DTI*12*DIRECTIONS_Series*.bval ] || [ -f $DICOMFOLDER/$SESS/*AX_DTI_12_DIRECTIONS_PA_11*.bval ] || [ -f $DICOMFOLDER/$SESS/*AX*DTI-12*DIRECTIONS*post_Series*.bval ] || [ -f $DICOMFOLDER/$SESS/*AX*DWI_Series*.bval ] || [ -f $DICOMFOLDER/$SESS/*AX*DTI-12*DIRECTIONS*post_2*.bval ] || [ -f $DICOMFOLDER/$SESS/*AX*DTI_12*DIRECTIONS_2*.bval ] || [ -f $DICOMFOLDER/$SESS/AX_DTI_12_DIRECTIONS_P-A*.bval ] || [ -f $DICOMFOLDER/$SESS/EPI_DIFF_AX_12_DIR_-_DTI_2*.bval ];then
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
                    STRING="12*DIR*P-A_Series"
                fi
                if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
                    STRING="DTI*12*DIRECTIONS_Series"
                fi
                if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
                    STRING="AX_DTI_12_DIRECTIONS_PA_11"
                fi
                if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
                    STRING="AX*DTI-12*DIRECTIONS*post_Series"
                fi
                if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
                    STRING="AX*DWI_Series"
                fi
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
                    STRING="AX*DTI-12*DIRECTIONS*post_2"
                fi
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
                    STRING="AX*DTI_12*DIRECTIONS_2"
                fi
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
                    STRING="AX_DTI_12_DIRECTIONS_P-A"
                fi
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
                    STRING="EPI_DIFF_AX_12_DIR_-_DTI_2"
                fi
		        echo "$SESS: $SAVENAME export from DICOM to NIFTI"
				if [ -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
					cp $DICOMFOLDER/$SESS/*$STRING*.bval $NIIFOLDER/$SESS/$SAVENAME.bval
					cp $DICOMFOLDER/$SESS/*$STRING*.bvec $NIIFOLDER/$SESS/$SAVENAME.bvec
					BASENAME=$(ls -d $DICOMFOLDER/$SESS/*$STRING*[0-9].bval)
					BASENAME=${BASENAME%.bval}
					cp $BASENAME.nii.gz $NIIFOLDER/$SESS/$SAVENAME.nii.gz
					cp $BASENAME.json $NIIFOLDER/$SESS/$SAVENAME.json
					chmod 660 $NIIFOLDER/$SESS/$SAVENAME.*
				fi
            elif [ -d $DICOMFOLDER/$SESS/*12*DIR*DTI_Series* ] || [ -d $DICOMFOLDER/$SESS/*12*DIR*P-A_Series* ] || [ -d $DICOMFOLDER/$SESS/*DTI*12*DIRECTIONS_Series* ] || [ -d $DICOMFOLDER/$SESS/*AX_DTI_12_DIRECTIONS_PA_11* ] || [ -d $DICOMFOLDER/$SESS/*AX*DTI-12*DIRECTIONS*post_Series* ] || [ -d $DICOMFOLDER/$SESS/*AX*DWI_Series* ] || [ -d $DICOMFOLDER/$SESS/*AX*DTI-12*DIRECTIONS*post_2* ];then
                # mprage export
                STRING="12*DIR*DTI_Series"
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="12*DIR*P-A_Series"
                fi
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="DTI*12*DIRECTIONS_Series"
                fi
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="AX_DTI_12_DIRECTIONS_PA_11"
                fi
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="AX*DTI-12*DIRECTIONS*post_Series"
                fi
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="AX*DWI_Series"
                fi
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="AX*DTI-12*DIRECTIONS*post_2"
                fi
		        echo "$SESS: $SAVENAME export from DICOM to NIFTI"
				if [ -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            mkdir $NIIFOLDER/$SESS/temp
		            dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/*$STRING*/* > /dev/null
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/$SAVENAME.nii.gz
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/$SAVENAME.json
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.bval $NIIFOLDER/$SESS/$SAVENAME.bval
			        cp $NIIFOLDER/$SESS/temp/*$STRING*.bvec $NIIFOLDER/$SESS/$SAVENAME.bvec
		            rm -r $NIIFOLDER/$SESS/temp
		            chmod 660 $NIIFOLDER/$SESS/$SAVENAME.*
				fi
            fi
	    fi

        SAVENAME=dmri_66dir_pa
        if [ ! -f $NIIFOLDER/$SESS/$SAVENAME.nii.gz ];then
			if [ -f $DICOMFOLDER/$SESS/ep2d_diff_66dir_P_A_Series*.bval ] || [ -f $DICOMFOLDER/$SESS/ep2d_diff_66dir_P__A*.bval ];then
				# mprage export
                STRING="ep2d_diff_66dir_P_A_Series"
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="ep2d_diff_66dir_P__A"
                fi
		        echo "$SESS: $SAVENAME export from DICOM to NIFTI"
				if [ -f $DICOMFOLDER/$SESS/*$STRING*.bval ];then
					cp $DICOMFOLDER/$SESS/*$STRING*.bval $NIIFOLDER/$SESS/$SAVENAME.bval
					cp $DICOMFOLDER/$SESS/*$STRING*.bvec $NIIFOLDER/$SESS/$SAVENAME.bvec
					BASENAME=$(ls -d $DICOMFOLDER/$SESS/*$STRING*.bval)
					BASENAME=${BASENAME%.bval}
					cp $BASENAME.nii.gz $NIIFOLDER/$SESS/$SAVENAME.nii.gz
					cp $BASENAME.json $NIIFOLDER/$SESS/$SAVENAME.json
					chmod 660 $NIIFOLDER/$SESS/$SAVENAME.*
				fi
            elif [ -d $DICOMFOLDER/$SESS/ep2d_diff_66dir_P_A_Series* ] || [ -d $DICOMFOLDER/$SESS/ep2d_diff_66dir_P__A_2* ] || [ -d $DICOMFOLDER/$SESS/ep2d_diff_66dir_PA_[0-9]* ];then
                # mprage export
                STRING="ep2d_diff_66dir_P_A_Series"
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="ep2d_diff_66dir_P__A_2"
                fi
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="ep2d_diff_66dir_PA_[0-9]"
                fi
		        echo "$SESS: $SAVENAME export from DICOM to NIFTI"
				if [ -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            mkdir $NIIFOLDER/$SESS/temp
		            dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/*$STRING*/* > /dev/null
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/$SAVENAME.nii.gz
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/$SAVENAME.json
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.bval $NIIFOLDER/$SESS/$SAVENAME.bval
			        cp $NIIFOLDER/$SESS/temp/*$STRING*.bvec $NIIFOLDER/$SESS/$SAVENAME.bvec
		            rm -r $NIIFOLDER/$SESS/temp
		            chmod 660 $NIIFOLDER/$SESS/$SAVENAME.*
				fi
            fi
	    fi

        SAVENAME=dmri_66dir_ap
        if [ ! -f $NIIFOLDER/$SESS/$SAVENAME.nii.gz ];then
			if [ -f $DICOMFOLDER/$SESS/ep2d_diff_66dir_A_P*_Series*.nii.gz ] || [ -f $DICOMFOLDER/$SESS/ep2d_diff_66dir_A__P*.nii.gz ];then
				STRING="ep2d_diff_66dir_A_P*_Series"
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="ep2d_diff_66dir_A__P"
                fi
		        echo "$SESS: $SAVENAME export from DICOM to NIFTI"
				if [ -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
					cp $DICOMFOLDER/$SESS/*$STRING*.nii.gz $NIIFOLDER/$SESS/$SAVENAME.nii.gz
					cp $DICOMFOLDER/$SESS/*$STRING*.json $NIIFOLDER/$SESS/$SAVENAME.json
					chmod 660 $NIIFOLDER/$SESS/$SAVENAME.*
				fi
            elif [ -d $DICOMFOLDER/$SESS/ep2d_diff_66dir_A_P*_Series* ] || [ -d $DICOMFOLDER/$SESS/ep2d_diff_66dir_A__P_2* ] || [ -d $DICOMFOLDER/$SESS/ep2d_diff_66dir_AP_* ];then
                # mprage export
                STRING="ep2d_diff_66dir_A_P*_Series"
                if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="ep2d_diff_66dir_A__P_2"
                fi
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
                    STRING="ep2d_diff_66dir_AP_"
                fi
		        echo "$SESS: $SAVENAME export from DICOM to NIFTI"
				if [ -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            mkdir $NIIFOLDER/$SESS/temp
		            dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/*$STRING*/* > /dev/null
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/$SAVENAME.nii.gz
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/$SAVENAME.json
		            #cp $NIIFOLDER/$SESS/temp/*$STRING*.bval $NIIFOLDER/$SESS/$SAVENAME.bval
			        #cp $NIIFOLDER/$SESS/temp/*$STRING*.bvec $NIIFOLDER/$SESS/$SAVENAME.bvec
		            rm -r $NIIFOLDER/$SESS/temp
		            chmod 660 $NIIFOLDER/$SESS/$SAVENAME.*
				fi
            fi
	    fi
	    
	    if [ ! -f $NIIFOLDER/$SESS/raff4_plus.nii.gz ];then
			if [ -f $DICOMFOLDER/$SESS/gre_prep_30_slices_RAFF4_plusZ*.nii.gz ];then
				STRING="gre_prep_30_slices_RAFF4_plusZ"
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
		            STRING="gre_prep_30_slices_RAFF4_plusZ"
		        fi
				if [ -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
					echo "$SESS: raff4_plus export from DICOM to NIFTI"
					cp $DICOMFOLDER/$SESS/*$STRING*.nii.gz $NIIFOLDER/$SESS/raff4_plus.nii.gz
					cp $DICOMFOLDER/$SESS/*$STRING*.json $NIIFOLDER/$SESS/raff4_plus.json
					chmod 660 $NIIFOLDER/$SESS/raff4_plus.*
		        fi 
            elif [ -d $DICOMFOLDER/$SESS/gre_prep_30_slices_RAFF4_plusZ* ];then
                STRING="gre_prep_30_slices_RAFF4_plusZ"
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="gre_prep_30_slices_RAFF4_plusZ"
		        fi
				if [ -d $DICOMFOLDER/$SESS/*$STRING* ];then
					echo "$SESS: raff4_plus export from DICOM to NIFTI"
		            mkdir $NIIFOLDER/$SESS/temp
		            dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/$STRING*/* > /dev/null
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/raff4_plus.nii.gz
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/raff4_plus.json
		            rm -r $NIIFOLDER/$SESS/temp
		            chmod 660 $NIIFOLDER/$SESS/raff4_plus.*
				fi
			fi
	    fi
	    
	    if [ ! -f $NIIFOLDER/$SESS/raff4_minus.nii.gz ];then
			if [ -f $DICOMFOLDER/$SESS/gre_prep_30_slices_RAFF4_minusZ*.nii.gz ];then
				STRING="gre_prep_30_slices_RAFF4_minusZ"
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
		            STRING="gre_prep_30_slices_RAFF4_minusZ"
		        fi
				if [ -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
					echo "$SESS: raff4_minus export from DICOM to NIFTI"
					cp $DICOMFOLDER/$SESS/*$STRING*.nii.gz $NIIFOLDER/$SESS/raff4_minus.nii.gz
					cp $DICOMFOLDER/$SESS/*$STRING*.json $NIIFOLDER/$SESS/raff4_minus.json
					chmod 660 $NIIFOLDER/$SESS/raff4_minus.*
		        fi 
            elif [ -d $DICOMFOLDER/$SESS/gre_prep_30_slices_RAFF4_minusZ* ];then
                STRING="gre_prep_30_slices_RAFF4_minusZ"
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="gre_prep_30_slices_RAFF4_minusZ"
		        fi
				if [ -d $DICOMFOLDER/$SESS/*$STRING* ];then
					echo "$SESS: raff4_minus export from DICOM to NIFTI"
		            mkdir $NIIFOLDER/$SESS/temp
		            dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/$STRING*/* > /dev/null
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/raff4_minus.nii.gz
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/raff4_minus.json
		            rm -r $NIIFOLDER/$SESS/temp
		            chmod 660 $NIIFOLDER/$SESS/raff4_minus.*
				fi
			fi
	    fi
	    
	    if [ ! -f $NIIFOLDER/$SESS/t1rho.nii.gz ];then
			if [ -f $DICOMFOLDER/$SESS/gre_prep_30_slices_T1r*.nii.gz ];then
				STRING="gre_prep_30_slices_T1r"
				if [ ! -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
		            STRING="gre_prep_30_slices_T1r"
		        fi
				if [ -f $DICOMFOLDER/$SESS/*$STRING*.nii.gz ];then
					echo "$SESS: t1rho export from DICOM to NIFTI"
					cp $DICOMFOLDER/$SESS/*$STRING*.nii.gz $NIIFOLDER/$SESS/t1rho.nii.gz
					cp $DICOMFOLDER/$SESS/*$STRING*.json $NIIFOLDER/$SESS/t1rho.json
					chmod 660 $NIIFOLDER/$SESS/t1rho.*
		        fi 
            elif [ -d $DICOMFOLDER/$SESS/gre_prep_30_slices_T1r* ];then
                STRING="gre_prep_30_slices_T1r"
				if [ ! -d $DICOMFOLDER/$SESS/*$STRING* ];then
		            STRING="gre_prep_30_slices_T1r"
		        fi
				if [ -d $DICOMFOLDER/$SESS/*$STRING* ];then
					echo "$SESS: t1rho export from DICOM to NIFTI"
		            mkdir $NIIFOLDER/$SESS/temp
		            dcm2niix -z y -o $NIIFOLDER/$SESS/temp $DICOMFOLDER/$SESS/$STRING*/* > /dev/null
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.nii.gz $NIIFOLDER/$SESS/t1rho.nii.gz
		            cp $NIIFOLDER/$SESS/temp/*$STRING*.json $NIIFOLDER/$SESS/t1rho.json
		            rm -r $NIIFOLDER/$SESS/temp
		            chmod 660 $NIIFOLDER/$SESS/t1rho.*
				fi
			fi
	    fi
        #if [ -f $NIIFOLDER/$SESS/*_T1_*[0-9]_Segmentation.nii.gz ]; then
        #    flirt -in $NIIFOLDER/$SESS/*_T1_*[0-9].nii.gz -ref $NIIFOLDER/$SESS/mprage.nii.gz -omat $NIIFOLDER/$SESS/t1-2-mprage.mat
        #    flirt -in $NIIFOLDER/$SESS/*_T1_*[0-9]_Segmentation.nii.gz -ref $NIIFOLDER/$SESS/mprage.nii.gz -applyxfm -init $NIIFOLDER/$SESS/t1-2-mprage.mat -out $NIIFOLDER/$SESS/mprage_lesion.nii.gz
        #fi 
        #ls -d $NIIFOLDER/$SESS/*
        #ls -d $DICOMFOLDER/$SESS/AX\ DTI\ 12\ DIRECTIONS\ P-A_Series*
    done
done


