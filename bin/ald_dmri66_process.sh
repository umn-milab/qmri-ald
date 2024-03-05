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

NIFTITOOLS=/home/range1-raid1/labounek/toolbox/matlab/NIfTI_tools
BINDIR=/home/range1-raid1/labounek/bin
MATLABDIR=/opt/local/matlab2017b
SPM=/home/range1-raid1/labounek/toolbox/matlab/spm12

DISTANCE=12 #mm
VOXELEDGE=2 #mm
MEDFILTGLOBAL=1

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
cyan=`tput setaf 6`
magneta=`tput setaf 5`
bold=$(tput bold)
normal=$(tput sgr0)

#FSLOUTPUTTYPE=NIFTI_GZ
#export FSLOUTPUTTYPE

print_help()
{
	LINE="===================================================================================================================="	
	SCRIPT_NAME=${0##*/}
	VERSION=26.09.2018	

	echo -e "$LINE\nHelp for script performing analysis of the spinal cord diffusion data (ZOOMit and/or RESOLVE), version $VERSION."
	echo -e "Analysis contains:\n\tdiffusion preprocessing (merge AP and PA b0 images) with or withnout motion correction by sct_dmri_moco\n\ttopup and eddy (with whole FOV or with manually segmented mask of SC from topup_mean image)\n\tDTI estimation (using dtifit)\n\tregistration between T2TRA and DIFF spaces\n\tvertebrae labeling in DIFF space\n\tmasking results from dtifit by mask of SC"
	echo -e "REQUIREMENTS: Installed bash interpreter, Matlab, FSL and Spinal Cord Toolbox libraries.\n$LINE"
	echo -e "USAGE:\n\n$SCRIPT_NAME <path to subjects directory> <subject> <diff. seq. order>\n\nEXAMPLE:\n\n$SCRIPT_NAME /md2/NA-CSD 2007B 11001"
	echo -e "or\n$SCRIPT_NAME /md2/NA-CSD subjects.txt\n$LINE"
	echo -e "Valosek, Labounek 2018\tfMRI laboratory, Olomouc, CZ\n$LINE"
	exit
}


run_matlab()
{
	# Run Matlab without GUI in bash command line
	$MATLABDIR/bin/matlab -nosplash -nodisplay -nodesktop -r  "$1"
}

main()
{
    DMRI_AP=$NIIFOLDER/dmri_${DIRNUM}dir_ap
    DMRI_PA=$NIIFOLDER/dmri_${DIRNUM}dir_pa
    READOUT=0.041975

	if [ ! -d $RESULTFOLDER ];then
		mkdir -p $RESULTFOLDER
		chmod 770 $RESULTFOLDER
	fi
	if [ ! -d $RESULTFOLDER/mask ];then
		mkdir -p $RESULTFOLDER/mask
		chmod 770 $RESULTFOLDER/mask
	fi
	if [ ! -d $RESULTFOLDER/mask_mni ];then
		mkdir -p $RESULTFOLDER/mask_mni
		chmod 770 $RESULTFOLDER/mask_mni
	fi
	if [ ! -d $MPRFOLDER/mask_mni ];then
		mkdir -p $MPRFOLDER/mask_mni
		chmod 770 $MPRFOLDER/mask_mni
	fi
	if [ ! -d $RESULTFOLDER/dsistudio ];then
		mkdir -p $RESULTFOLDER/dsistudio
		chmod 770 $RESULTFOLDER/dsistudio
	fi

	if [ -f $MPRFOLDER/mprage_brain.nii.gz ] && [ ! -L $RESULTFOLDER/mprage_brain.nii.gz ]; then
		ln -s $MPRFOLDER/mprage_brain.nii.gz $RESULTFOLDER/mprage_brain.nii.gz
	fi
	if [ -f $MPRFOLDER/mprage_JHU-ICBM-labels.nii.gz ] && [ ! -L $RESULTFOLDER/mprage_JHU-ICBM-labels.nii.gz ];then
		ln -s $MPRFOLDER/mprage_JHU-ICBM-labels.nii.gz $RESULTFOLDER/mprage_JHU-ICBM-labels.nii.gz
	fi
	if [ -f $MPRFOLDER/MNI_mprage_brain_fnirt.nii.gz ] && [ ! -L $RESULTFOLDER/MNI_mprage_brain_fnirt.nii.gz ];then
		ln -s $MPRFOLDER/MNI_mprage_brain_fnirt.nii.gz $RESULTFOLDER/MNI_mprage_brain_fnirt.nii.gz
	fi

	if [ ! -f $RESULTFOLDER/b0.nii.gz ];then
		diff_prep $DMRI_AP $DMRI_PA $READOUT $RESULTFOLDER	# Call diff_preop function
	else
		echo "${green}$(date +%x_%T): Preprocessing of diffusion data in $RESULTFOLDER folder has been done before.${normal}"
		OPENC=AP
	fi
	if [ $OPENC == "PA" ];then
	    echo "${red}$(date +%x_%T): Both dMRI acquisition acquired with PA phase encoding for $RESULTFOLDER${normal}" 
	    echo "$(date +%x_%T): Both dMRI acquisition acquired with PA phase encoding for $RESULTFOLDER" > $RESULTFOLDER/dmri_processing_abort.txt
    elif [ `tail -n 1 $RESULTFOLDER/acq_file.txt | cut -d " " -f2` -ne  "1" ];then
        if [ ! -f $RESULTFOLDER/b0_topup.nii.gz ]; then
		    topup_function $RESULTFOLDER		# Call function for topup
	    else
		    echo "${green}$(date +%x_%T): topup on data in $RESULTFOLDER folder has been done before.${normal}"
	    fi
        if [ ! -f $RESULTFOLDER/eddy.nii.gz ]; then
		    eddy_function $RESULTFOLDER	# Call function for eddy
	    else
		    echo "${green}$(date +%x_%T): eddy on data in $RESULTFOLDER folder has been done before.${normal}"
	    fi
	    #if [ ! -f $RESULTFOLDER/eddy_medfilt.nii.gz ]; then
	    #    dt=$(date '+%Y/%m/%d %H:%M:%S');
        #	echo "$dt $SESS: median filtration of the eddy output started"
	    #	fslmaths $RESULTFOLDER/eddy.nii.gz -kernel 2D -fmedian $RESULTFOLDER/eddy_medfilt.nii.gz
	    #	dt=$(date '+%Y/%m/%d %H:%M:%S');
        #	echo "$dt $SESS: median filtration of the eddy output done"
	    #fi
        if [ ! -f $RESULTFOLDER/dti_FA.nii.gz ]; then
		    dtifit_function $RESULTFOLDER		# Call function for dtifit
	    else
		    echo "${green}$(date +%x_%T): Estimation of DTI model using dtifit on data in $FOLDER folder is done.${normal}"
	    fi
	    if [ ! -f $RESULTFOLDER/dti_RD.nii.gz ]; then
		    fslmaths $RESULTFOLDER/dti_L2.nii.gz -add $RESULTFOLDER/dti_L3.nii.gz -div 2 $RESULTFOLDER/dti_RD.nii.gz
	    fi
	    if [ ! -L $RESULTFOLDER/dti_AD.nii.gz ]; then
	        ln -s $RESULTFOLDER/dti_L1.nii.gz $RESULTFOLDER/dti_AD.nii.gz
	    fi 
	    if [ ! -f $RESULTFOLDER/dsistudio/data.nii.gz ]; then
	        dt=$(date '+%Y/%m/%d %H:%M:%S');
        	echo "$dt $SESS: copy dmri data into dsistudio folder started"
        	cp $RESULTFOLDER/data.nii.gz $RESULTFOLDER/dsistudio/data.nii.gz
        	cp $RESULTFOLDER/bvals $RESULTFOLDER/dsistudio/bvals
        	cp $RESULTFOLDER/bvecs $RESULTFOLDER/dsistudio/bvecs
        	cp $RESULTFOLDER/nodif_brain_mask.nii.gz $RESULTFOLDER/dsistudio/nodif_brain_mask.nii.gz
        	dt=$(date '+%Y/%m/%d %H:%M:%S');
        	echo "$dt $SESS: copy dmri data into dsistudio folder done"
	    fi
	    if [ ! -f $RESULTFOLDER.bedpostX/dyads1.nii.gz ]; then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
        	echo "$dt $SESS: bedpostx_gpu started"
		    export LD_LIBRARY_PATH=/opt/local/cuda-9.1/lib64:$LD_LIBRARY_PATH
		    export PATH=/opt/local/cuda-9.1/lib64:/opt/local/cuda-9.1/bin:$PATH
		    bedpostx_gpu $RESULTFOLDER -n 3 -model 1
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
        	echo "$dt $SESS: bedpostx_gpu done"
	    fi
	    SESSNAME=$(echo $SESS | awk -F'/' '{print $2}')
	    if [ ! -f $RESULTFOLDER/dsistudio/${SESSNAME}_bedpostX.fib.gz ]; then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
        	echo "$dt $SESS: export bedpostx results into DSI Studio file format started"
		    run_matlab "addpath('$NIFTITOOLS'),addpath('$BINDIR/matlab_scripts'),msp_bedpostx2trackvis('$RESULTFOLDER'),exit"
		    mv $RESULTFOLDER/dsistudio/bedpostX.fib $RESULTFOLDER/dsistudio/${SESSNAME}_bedpostX.fib
		    gzip $RESULTFOLDER/dsistudio/${SESSNAME}_bedpostX.fib
		    chmod 660 $RESULTFOLDER/dsistudio/${SESSNAME}_bedpostX.fib.gz
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
        	echo "$dt $SESS: export bedpostx results into DSI Studio file format done"
	    fi
	    if [ -f $MPRFOLDER/mprage_brain.nii.gz ];then
		    if [ ! -f $RESULTFOLDER/flirt_diff2nat.mat ];then
	        	dt=$(date '+%Y/%m/%d %H:%M:%S');
	        	echo "$dt $SESS: flirt diff-mprage registration started"
	        	flirt -in $RESULTFOLDER/dti_FA.nii.gz -ref $MPRFOLDER/mprage_brain.nii.gz -omat $RESULTFOLDER/flirt_diff2nat.mat -cost mutualinfo -interp sinc
	        	convert_xfm -omat $RESULTFOLDER/flirt_nat2diff.mat -inverse $RESULTFOLDER/flirt_diff2nat.mat
	        	dt=$(date '+%Y/%m/%d %H:%M:%S');
	        	echo "$dt $SESS: flirt diff-mprage registration done"
		    fi
		    if [ -f $MPRFOLDER/mprage_lesion.nii.gz ] && [ ! -f $RESULTFOLDER/dmri_lesion.nii.gz ];then
			    dt=$(date '+%Y/%m/%d %H:%M:%S');
	        	echo "$dt $SESS: warp lesion to diff started"
	        	flirt -in $MPRFOLDER/mprage_lesion.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2diff.mat -interp nearestneighbour -out $RESULTFOLDER/dmri_lesion.nii.gz
	        	dt=$(date '+%Y/%m/%d %H:%M:%S');
	        	echo "$dt $SESS: warp lesion to diff done"
		    fi
		    if [ ! -f $RESULTFOLDER/dmri_mprage.nii.gz ];then
		        dt=$(date '+%Y/%m/%d %H:%M:%S');
	        	echo "$dt $SESS: warp mprage to diff started"
	        	flirt -in $MPRFOLDER/mprage_brain.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2diff.mat -interp spline -out $RESULTFOLDER/dmri_mprage.nii.gz
	        	dt=$(date '+%Y/%m/%d %H:%M:%S');
	        	echo "$dt $SESS: warp mprage to diff done"
		    fi
		    NAME=LV
            if [ ! -f $RESULTFOLDER/mask_mni/${NAME}.nii.gz ];then
                 dt=$(date '+%Y/%m/%d %H:%M:%S');
                echo "$dt $SESS: Warp ${NAME} atlas to mprage & diffusion space started"
                cp $FSLDIR/data/atlases/Juelich/Juelich-prob-1mm.nii.gz $RESULTFOLDER/Juelich-prob-1mm.nii.gz
                fslsplit $RESULTFOLDER/Juelich-prob-1mm.nii.gz $RESULTFOLDER/juelich
                fslmaths $RESULTFOLDER/juelich0038.nii.gz -add $RESULTFOLDER/juelich0080.nii.gz -add $RESULTFOLDER/juelich0082.nii.gz -add $RESULTFOLDER/juelich0084.nii.gz -add $RESULTFOLDER/juelich0086.nii.gz -add $RESULTFOLDER/juelich0088.nii.gz $RESULTFOLDER/${NAME}_mni.nii.gz
                rm $RESULTFOLDER/juelich*.nii.gz
                rm $RESULTFOLDER/Juelich-prob-1mm.nii.gz
                applywarp -i $RESULTFOLDER/${NAME}_mni.nii.gz -r $MPRFOLDER/mprage_brain.nii.gz -o $MPRFOLDER/mask_mni/${NAME}.nii.gz -w $MPRFOLDER/fnirt_std2nat_warp.nii.gz --interp=nn
                flirt -in $MPRFOLDER/mask_mni/${NAME}.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2diff.mat -interp nearestneighbour -out $RESULTFOLDER/mask_mni/${NAME}.nii.gz
                fslmaths $MPRFOLDER/mask_mni/${NAME}.nii.gz -thr 40 -bin $MPRFOLDER/mask_mni/${NAME}.nii.gz
			    fslmaths $RESULTFOLDER/mask_mni/${NAME}.nii.gz -thr 40 -bin $RESULTFOLDER/mask_mni/${NAME}.nii.gz
                rm $RESULTFOLDER/${NAME}_mni.nii.gz 
                dt=$(date '+%Y/%m/%d %H:%M:%S');
                echo "$dt $SESS: Warp ${NAME} atlas to mprage & diffusion space done"
            fi
            NAME=RV
            if [ ! -f $RESULTFOLDER/mask_mni/${NAME}.nii.gz ];then
                 dt=$(date '+%Y/%m/%d %H:%M:%S');
                echo "$dt $SESS: Warp ${NAME} atlas to mprage & diffusion space started"
                cp $FSLDIR/data/atlases/Juelich/Juelich-prob-1mm.nii.gz $RESULTFOLDER/Juelich-prob-1mm.nii.gz
                fslsplit $RESULTFOLDER/Juelich-prob-1mm.nii.gz $RESULTFOLDER/juelich
                fslmaths $RESULTFOLDER/juelich0039.nii.gz -add $RESULTFOLDER/juelich0081.nii.gz -add $RESULTFOLDER/juelich0083.nii.gz -add $RESULTFOLDER/juelich0085.nii.gz -add $RESULTFOLDER/juelich0087.nii.gz -add $RESULTFOLDER/juelich0089.nii.gz $RESULTFOLDER/${NAME}_mni.nii.gz
                rm $RESULTFOLDER/juelich*.nii.gz
                rm $RESULTFOLDER/Juelich-prob-1mm.nii.gz
                applywarp -i $RESULTFOLDER/${NAME}_mni.nii.gz -r $MPRFOLDER/mprage_brain.nii.gz -o $MPRFOLDER/mask_mni/${NAME}.nii.gz -w $MPRFOLDER/fnirt_std2nat_warp.nii.gz --interp=nn
			    flirt -in $MPRFOLDER/mask_mni/${NAME}.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2diff.mat -interp nearestneighbour -out $RESULTFOLDER/mask_mni/${NAME}.nii.gz
                fslmaths $MPRFOLDER/mask_mni/${NAME}.nii.gz -thr 40 -bin $MPRFOLDER/mask_mni/${NAME}.nii.gz
			    fslmaths $RESULTFOLDER/mask_mni/${NAME}.nii.gz -thr 40 -bin $RESULTFOLDER/mask_mni/${NAME}.nii.gz
                rm $RESULTFOLDER/${NAME}_mni.nii.gz 
                dt=$(date '+%Y/%m/%d %H:%M:%S');
                echo "$dt $SESS: Warp ${NAME} atlas to mprage & diffusion space done"
            fi
            NAME=SPL
            STOP=0
            if [ ! -f $RESULTFOLDER/mask_mni/${NAME}.nii.gz ] && [ $STOP -ne 0 ];then
                 dt=$(date '+%Y/%m/%d %H:%M:%S');
                echo "$dt $SESS: Warp ${NAME} atlas to mprage & diffusion space started"
                cp $FSLDIR/data/atlases/HarvardOxford/HarvardOxford-cort-prob-1mm.nii.gz $RESULTFOLDER/HarvardOxford-cort-prob-1mm.nii.gz
                fslsplit $RESULTFOLDER/HarvardOxford-cort-prob-1mm.nii.gz $RESULTFOLDER/harvard
                cp $RESULTFOLDER/harvard0017.nii.gz $RESULTFOLDER/${NAME}_mni.nii.gz

			    cluster -i $RESULTFOLDER/harvard0017.nii.gz -t 20 --minextent=100 -o $RESULTFOLDER/${NAME}_mni_cluster.nii.gz > $RESULTFOLDER/cluster_spl.log # -t 0.1
			    MAXX=$(head -n 2 $RESULTFOLDER/cluster_spl.log | tail -n 1 | awk '{ print $4 }')
			    MAXVAL=$(head -n 2 $RESULTFOLDER/cluster_spl.log | tail -n 1 | awk '{ print $1 }')
			    VAL2=$(($MAXVAL-1))
			    echo $MAXX
                echo $MAXVAL
                echo $VAL2
			    if [ $MAXX -gt 90 ];then
				    fslmaths $RESULTFOLDER/${NAME}_mni_cluster.nii.gz -thr $MAXVAL -uthr $MAXVAL $RESULTFOLDER/${NAME}_mni_cluster_left.nii.gz
				    fslmaths $RESULTFOLDER/${NAME}_mni_cluster.nii.gz -thr $VAL2 -uthr $VAL2 $RESULTFOLDER/${NAME}_mni_cluster_right.nii.gz
			    else
				    fslmaths $RESULTFOLDER/${NAME}_mni_cluster.nii.gz -thr $MAXVAL -uthr $MAXVAL $RESULTFOLDER/${NAME}_mni_cluster_right.nii.gz
				    fslmaths $RESULTFOLDER/${NAME}_mni_cluster.nii.gz -thr $VAL2 -uthr $VAL2 $RESULTFOLDER/${NAME}_mni_cluster_left.nii.gz
			    fi
			    fslmaths $RESULTFOLDER/${NAME}_mni_cluster.nii.gz -mas $RESULTFOLDER/${NAME}_mni_cluster_left.nii.gz $RESULTFOLDER/${NAME}_mni_cluster_left.nii.gz
			    fslmaths $RESULTFOLDER/${NAME}_mni_cluster.nii.gz -mas $RESULTFOLDER/${NAME}_mni_cluster_right.nii.gz $RESULTFOLDER/${NAME}_mni_cluster_right.nii.gz

                rm $RESULTFOLDER/harvard*.nii.gz
                rm $RESULTFOLDER/HarvardOxford-cort-prob-1mm.nii.gz

                applywarp -i $RESULTFOLDER/${NAME}_mni.nii.gz -r $MPRFOLDER/mprage_brain.nii.gz -o $MPRFOLDER/mask_mni/${NAME}.nii.gz -w $MPRFOLDER/fnirt_std2nat_warp.nii.gz --interp=nn
                flirt -in $MPRFOLDER/mask_mni/${NAME}.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2diff.mat -interp nearestneighbour -out $RESULTFOLDER/mask_mni/${NAME}.nii.gz
                fslmaths $MPRFOLDER/mask_mni/${NAME}.nii.gz -thr 40 -bin $MPRFOLDER/mask_mni/${NAME}.nii.gz
			    fslmaths $RESULTFOLDER/mask_mni/${NAME}.nii.gz -thr 40 -bin $RESULTFOLDER/mask_mni/${NAME}.nii.gz

			    applywarp -i $RESULTFOLDER/${NAME}_mni_cluster_left.nii.gz -r $MPRFOLDER/mprage_brain.nii.gz -o $MPRFOLDER/mask_mni/L${NAME}.nii.gz -w $MPRFOLDER/fnirt_std2nat_warp.nii.gz --interp=nn
			    flirt -in $MPRFOLDER/mask_mni/L${NAME}.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2diff.mat -interp nearestneighbour -out $RESULTFOLDER/mask_mni/L${NAME}.nii.gz
			    fslmaths $MPRFOLDER/mask_mni/L${NAME}.nii.gz -thr 40 -bin $MPRFOLDER/mask_mni/L${NAME}.nii.gz
			    fslmaths $RESULTFOLDER/mask_mni/L${NAME}.nii.gz -thr 40 -bin $RESULTFOLDER/mask_mni/L${NAME}.nii.gz

			    applywarp -i $RESULTFOLDER/${NAME}_mni_cluster_right.nii.gz -r $MPRFOLDER/mprage_brain.nii.gz -o $MPRFOLDER/mask_mni/R${NAME}.nii.gz -w $MPRFOLDER/fnirt_std2nat_warp.nii.gz --interp=nn
			    flirt -in $MPRFOLDER/mask_mni/R${NAME}.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_nat2diff.mat -interp nearestneighbour -out $RESULTFOLDER/mask_mni/R${NAME}.nii.gz
			    fslmaths $MPRFOLDER/mask_mni/R${NAME}.nii.gz -thr 40 -bin $MPRFOLDER/mask_mni/R${NAME}.nii.gz
			    fslmaths $RESULTFOLDER/mask_mni/R${NAME}.nii.gz -thr 40 -bin $RESULTFOLDER/mask_mni/R${NAME}.nii.gz

                rm $RESULTFOLDER/${NAME}_mni*.nii.gz 
                dt=$(date '+%Y/%m/%d %H:%M:%S');
                echo "$dt $SESS: Warp ${NAME} atlas to mprage & diffusion space done"
            fi     
	    fi
	    if [ ! -f $RESULTFOLDER/diff2jhu_warp.nii.gz ];then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SESS: JHU-FA to diff registration started"
		    fsl_reg $RESULTFOLDER/dti_FA.nii.gz $FSLDIR/data/atlases/JHU/JHU-ICBM-FA-1mm.nii.gz $RESULTFOLDER/diff2jhu -FA -e
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SESS: JHU-FA to diff registration done"
        fi
        if [ ! -f $RESULTFOLDER/jhu2diff_warp.nii.gz ];then
		    invwarp -w $RESULTFOLDER/diff2jhu_warp.nii.gz -o $RESULTFOLDER/jhu2diff_warp.nii.gz -r $RESULTFOLDER/dti_FA.nii.gz
        fi
        if [ ! -f $RESULTFOLDER/jhu_labels.nii.gz ];then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SESS: Warp JHU-ICBM atlas to diff space started"
		    applywarp -i $FSLDIR/data/atlases/JHU/JHU-ICBM-labels-1mm.nii.gz -r $RESULTFOLDER/dti_FA.nii.gz -o $RESULTFOLDER/jhu_labels.nii.gz -w $RESULTFOLDER/jhu2diff_warp.nii.gz --interp=nn
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SESS: Warp JHU-ICBM atlas to diff space done"
        fi
	    if [ -f $MPRFOLDER/fs_aseg.nii.gz ];then
		    if [ ! -f $RESULTFOLDER/flirt_diff2fs.mat ];then
			    dt=$(date '+%Y/%m/%d %H:%M:%S');
                echo "$dt $SESS: flirt diff-freesurfer registration started"
                flirt -in $RESULTFOLDER/dti_FA.nii.gz -ref $MPRFOLDER/fs_brain.nii.gz -omat $RESULTFOLDER/flirt_diff2fs.mat -cost mutualinfo -interp sinc
                convert_xfm -omat $RESULTFOLDER/flirt_fs2diff.mat -inverse $RESULTFOLDER/flirt_diff2fs.mat
                dt=$(date '+%Y/%m/%d %H:%M:%S');
                echo "$dt $SESS: flirt diff-freesurfer registration done"
		    fi
		    if [ ! -f $RESULTFOLDER/dmri_aseg.nii.gz ];then
			    dt=$(date '+%Y/%m/%d %H:%M:%S');
                echo "$dt $SESS: warp freesurfer-aseg to diff started"
                flirt -in $MPRFOLDER/fs_aseg.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp nearestneighbour -out $RESULTFOLDER/dmri_aseg.nii.gz
                dt=$(date '+%Y/%m/%d %H:%M:%S');
                echo "$dt $SESS: warp freesurfer-aseg to diff done"
		    fi
	    fi
	    if [ -f $RESULTFOLDER/dmri_aseg.nii.gz ];then
		    NAME=cc_posterior
		    THR=251
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
		    NAME=brainstem
		    THR=16
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
		    NAME=cc_mid_posterior
		    THR=252
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
		    NAME=cc_central
		    THR=253
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
		    NAME=cc_mid_anterior
		    THR=254
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
		    NAME=cc_anterior
		    THR=255
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
		    NAME=fornix
		    THR=250
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
		    NAME=cc_not_splenium
		    THR=252
		    THR2=255
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR2 -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
		    NAME=thalamus_right
		    THR=48
		    THR2=49
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR2 -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
		    NAME=thalamus_left
		    THR=9
		    THR2=10
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR2 -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
		    if [ ! -f $RESULTFOLDER/mask/thalamus_mask_prob50.nii.gz ];then
	            fslmaths $RESULTFOLDER/mask/thalamus_left.nii.gz -add $RESULTFOLDER/mask/thalamus_right.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/thalamus_mask_prob50.nii.gz
            fi
            NAME=hippocampus_left
		    THR=17
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
            NAME=hippocampus_right
		    THR=53
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
            if [ ! -f $RESULTFOLDER/mask/hippocampus_mask_prob50.nii.gz ];then
	            fslmaths $RESULTFOLDER/mask/hippocampus_left.nii.gz -add $RESULTFOLDER/mask/hippocampus_right.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/hippocampus_mask_prob50.nii.gz
            fi
            NAME=pallidum_left
		    THR=13
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
            NAME=pallidum_right
		    THR=52
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
            if [ ! -f $RESULTFOLDER/mask/pallidum_mask_prob50.nii.gz ];then
	            fslmaths $RESULTFOLDER/mask/pallidum_left.nii.gz -add $RESULTFOLDER/mask/pallidum_right.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/pallidum_mask_prob50.nii.gz
            fi
            NAME=putamen_left
		    THR=12
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
            NAME=putamen_right
		    THR=51
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
            if [ ! -f $RESULTFOLDER/mask/putamen_mask_prob50.nii.gz ];then
	            fslmaths $RESULTFOLDER/mask/putamen_left.nii.gz -add $RESULTFOLDER/mask/putamen_right.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/putamen_mask_prob50.nii.gz
            fi
            NAME=ventraldc_left
		    THR=28
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
            NAME=ventraldc_right
		    THR=60
	        if [ ! -f $RESULTFOLDER/mask/$NAME.nii.gz ];then		
	            fslmaths $MPRFOLDER/fs_aseg.nii.gz -thr $THR -uthr $THR -bin $RESULTFOLDER/mask/$NAME.nii.gz
			    flirt -in $RESULTFOLDER/mask/$NAME.nii.gz -ref $RESULTFOLDER/dti_FA.nii.gz -applyxfm -init $RESULTFOLDER/flirt_fs2diff.mat -interp trilinear -out $RESULTFOLDER/mask/$NAME.nii.gz
			    fslmaths $RESULTFOLDER/mask/$NAME.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/${NAME}_mask_prob50.nii.gz
            fi
            if [ ! -f $RESULTFOLDER/mask/ventraldc_mask_prob50.nii.gz ];then
	            fslmaths $RESULTFOLDER/mask/ventraldc_left.nii.gz -add $RESULTFOLDER/mask/ventraldc_right.nii.gz -thr 0.5 -bin $RESULTFOLDER/mask/ventraldc_mask_prob50.nii.gz
            fi
		    MASKNAME=cc_posterior_mask_prob50
		    PLANENAME=plane_splenium_anterior_not
		    DIRECTION=anterior
		    if [ ! -f $RESULTFOLDER/mask/$PLANENAME.nii.gz ]; then
			    gunzip $RESULTFOLDER/mask/$MASKNAME.nii.gz
			    run_matlab "addpath('$SPM'),addpath('$BINDIR/matlab_scripts'),msp_ald_plane_position('$RESULTFOLDER','$MASKNAME','$PLANENAME','$DIRECTION',$DISTANCE,$VOXELEDGE),exit"
			    gzip $RESULTFOLDER/mask/$MASKNAME.nii
			    gzip $RESULTFOLDER/mask/$PLANENAME.nii
		    fi
	    fi
	    if [ ! -f $RESULTFOLDER/mask/avoid_splenium.nii.gz ];then
	        fslmaths $RESULTFOLDER/mask/plane_splenium_anterior_not.nii.gz -add $RESULTFOLDER/mask/cc_not_splenium.nii.gz -add $RESULTFOLDER/mask/brainstem.nii.gz -add $RESULTFOLDER/mask/thalamus_mask_prob50.nii.gz -add $RESULTFOLDER/mask/hippocampus_mask_prob50.nii.gz -add $RESULTFOLDER/mask/pallidum_mask_prob50.nii.gz -add $RESULTFOLDER/mask/putamen_mask_prob50.nii.gz -add $RESULTFOLDER/mask/ventraldc_mask_prob50.nii.gz -bin $RESULTFOLDER/mask/avoid_splenium.nii.gz
        fi
	    if [ ! -f $RESULTFOLDER.bedpostX/probtrackx.splenium/fdt_paths.nii.gz ] && [ -f $RESULTFOLDER/dmri_aseg.nii.gz ]; then
		    probtrackx2 -P 15000 -S 2000 --steplength=0.5 -c 0.2 -s $RESULTFOLDER.bedpostX/merged -m $RESULTFOLDER.bedpostX/nodif_brain_mask.nii.gz -x $RESULTFOLDER/mask/cc_posterior.nii.gz --avoid=$RESULTFOLDER/mask/avoid_splenium.nii.gz --dir=$RESULTFOLDER.bedpostX/probtrackx.splenium --out=fdt_paths --opd --ompl	
	    elif [ -f $RESULTFOLDER.bedpostX/probtrackx.splenium/fdt_paths.nii.gz ];then
	        echo "Splenium probtrackx has already been done. If you want to re-run it, backup or delete the folder:"
	        echo $RESULTFOLDER.bedpostX/probtrackx.splenium
	    fi
    else
        echo "${red}$(date +%x_%T): Both dMRI acquisition acquired with PA phase encoding for $RESULTFOLDER${normal}" 
	    echo "$(date +%x_%T): Both dMRI acquisition acquired with PA phase encoding for $RESULTFOLDER" > $RESULTFOLDER/dmri_processing_abort.txt
    fi
}

#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
# Function which is called for diffusion preprocessing of RESOLVE data
diff_prep()
{
	
	DMRI_AP=$1
	DMRI_PA=$2
	READOUT=$3
	DATA=$4

	echo "${yellow}$(date +%x_%T): Starting preprocessing of diffusion data in $DATA folder!${normal}"

	cd $DATA

	fslmerge -a dwi.nii.gz ${DMRI_PA}.nii.gz ${DMRI_AP}.nii.gz # Merge AP and PA ZOOMit data into one file
	mrconvert dwi.nii.gz dwi.mif
	dwidenoise dwi.mif dwi_denoised.mif
	mrdegibbs dwi_denoised.mif dwi_denoised_unringed.mif -axes 0,1
	mrconvert dwi_denoised_unringed.mif dwi_denoised_unringed.nii.gz
	
	if [ $MEDFILTGLOBAL -eq 1 ];then
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: dmri data global 2D median filter started"
		fslmaths dwi_denoised_unringed.nii.gz -kernel 2D -fmedian eddy_input.nii.gz
		dt=$(date '+%Y/%m/%d %H:%M:%S');
		echo "$dt $SESS: dmri data global 2D median filter done"
	else
		cp dwi_denoised_unringed.nii.gz eddy_input.nii.gz
	fi

	echo "`cat ${DMRI_PA}.bval` 0 0 0" > eddy_input.bval	# Create eddy_input.bval file by merge bval files of RESOLVE_AP and RESOLVE_PA
	echo "0 0 0" > dmri_ap.bvec
	echo "0 0 0" >> dmri_ap.bvec
	echo "0 0 0" >> dmri_ap.bvec
	paste -d " " ${DMRI_PA}.bvec dmri_ap.bvec > eddy_input.bvec	# Create eddy_input.bvec file by merge bvec files of RESOLVE_AP and RESOLVE_PA
	
	B0INDEX=""
	fslsplit eddy_input.nii.gz temporary	# Split RESOLVE data into infividual images
	B0IND=0
	IMAGEID=0

	MERGECOMMAND="fslmerge -a b0.nii.gz" 
	for BVAL in `cat eddy_input.bval`;do			# Create variable B0INDEX containg order of b0 images in merged file
		if [ $BVAL -eq 0 ];then
			B0IND=$(($B0IND+1))
			#fslmaths temporary`printf %04d $IMAGEID`.nii.gz -kernel 2D -fmedian temporary`printf %04d $IMAGEID`.nii.gz
			MERGECOMMAND="$MERGECOMMAND temporary`printf %04d $IMAGEID`.nii.gz"
		fi
		B0INDEX="$B0INDEX $B0IND"
		IMAGEID=$(($IMAGEID+1))
	done
	echo $B0INDEX > index.txt
	B0NUM=`cat index.txt | awk '{print $NF}'`			# Count number of b0 images in merged file
	B0PA=7
	
	#fslmerge -a eddy_input.nii.gz temporary*.nii.gz

	tmp=$(grep -i PhaseEncodingDirection ${DMRI_AP}.json | grep -v InPlane | grep '"j-"' | awk '{ print $1 }')
	if [ ! -z $tmp ];then
		OPENC=AP
	else
		tmp=$(grep -i PhaseEncodingDirection ${DMRI_AP}.json | grep -v InPlane | grep '"i"' | awk '{ print $1 }')
		if [ ! -z $tmp ];then
			OPENC=LR
		else
			tmp=$(grep -i PhaseEncodingDirection ${DMRI_AP}.json | grep -v InPlane | grep '"i-"' | awk '{ print $1 }')
			if [ ! -z $tmp ];then
				OPENC=RL
			else
				OPENC=PA
			fi
		fi
	fi
    
	echo "0 1 0 $READOUT" > acq_file.txt	
	for MES in `seq 2 $B0NUM`;do					# Create acq_file which is necessary for topup
		if [ $MES -le $B0PA ];then
			echo "0 1 0 $READOUT" >> acq_file.txt
		else
			if [ $OPENC == "AP" ];then
				echo "0 -1 0 $READOUT" >> acq_file.txt
			elif [ $OPENC == "LR" ];then
				echo "1 0 0 $READOUT" >> acq_file.txt
			elif [ $OPENC == "RL" ];then
				echo "-1 0 0 $READOUT" >> acq_file.txt
			else
				echo "0 1 0 $READOUT" >> acq_file.txt
			fi			    
		fi
	done

	`echo $MERGECOMMAND`						# Create file containing only b0 images
	rm temporary*.nii.gz
	rm dmri_ap.bvec

	chmod 660 eddy_input*
	chmod 660 index.txt
	chmod 660 b0.nii.gz
	chmod 660 acq_file.txt
	chmod 660 *.mif
	echo "${yellow}$(date +%x_%T): Preprocessing of diffusion data in $DATA folder is done.${normal}"
	
}
#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
# Function which is called for topup and mean of data after topup
topup_function()
{
	DATA=$1
	echo "${yellow}$(date +%x_%T): Starting topup on data in $DATA folder!${normal}"
	cd $DATA
	topup --imain=b0.nii.gz --datain=acq_file.txt --out=topup --subsamp=1,1,1,1,1,1,1,1,1 --config=b02b0.cnf --iout=b0_topup --fout=field_topup -v > topup_stdout.txt
	fslmaths b0_topup.nii.gz -Tmean b0_topup_mean.nii.gz # mean b0
	bet b0_topup_mean.nii.gz b0_topup_mean_brain -m -o -f 0.25 
	fslmaths b0_topup_mean_brain.nii.gz -thr 20 b0_topup_mean_brain.nii.gz
	fslmaths b0_topup_mean_brain_mask.nii.gz -mas b0_topup_mean_brain.nii.gz -fillh b0_topup_mean_brain_mask.nii.gz
	cluster -i b0_topup_mean_brain_mask.nii.gz -t 0.99 --minextent=100 -o b0_topup_mean_brain_cluster.nii.gz > cluster.log
	CLMAX=$(sed -n '2p' cluster.log | cut -f1)
	fslmaths b0_topup_mean_brain_cluster.nii.gz -thr $CLMAX -bin b0_topup_mean_brain_mask.nii.gz
	rm b0_topup_mean_brain_cluster.nii.gz
	echo "${yellow}$(date +%x_%T): topup on data in $DATA folder is done.${normal}"
	
}
#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
# Function which is called for eddy (eddy uses either manually segmented mask of SC or whole binarized FOV)
eddy_function()
{
	DATA=$1
	echo "${yellow}$(date +%x_%T): Starting eddy on data in $DATA folder!${normal}"
	cd $DATA
    EDDYCMD="eddy_openmp"
	${EDDYCMD} --imain=eddy_input.nii.gz --mask=b0_topup_mean_brain_mask.nii.gz --index=index.txt --acqp=acq_file.txt --bvecs=eddy_input.bvec --bvals=eddy_input.bval --topup=topup --out=eddy -v > eddy_stdout.txt
	echo "${yellow}$(date +%x_%T): eddy on data in $DATA folder is done.${normal}"
}
#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
# Function which is called for estimation of DTI model using dtifit
dtifit_function()
{
	DATA=$1
	echo "${yellow}$(date +%x_%T): Starting estimation of DTI model using dtifit on data in $FOLDER folder.${normal}"
	cd $DATA
	#cp eddy_medfilt.nii.gz data.nii.gz
	cp eddy.nii.gz data.nii.gz
	cp eddy_input.bval bvals
	cp eddy.eddy_rotated_bvecs bvecs
	cp b0_topup_mean_brain_mask.nii.gz nodif_brain_mask.nii.gz
	dtifit -k data.nii.gz -o dti -m nodif_brain_mask.nii.gz -r bvecs -b bvals -w	
	echo "${yellow}$(date +%x_%T): Estimation of DTI model using dtifit on data in $FOLDER folder is done.${normal}"	
}
#-----------------------------------------------------------------------------------------------------------
DIRNUM=66
if [ -f $NIIFOLDER/dmri_${DIRNUM}dir_pa.nii.gz ];then
	dt=$(date '+%Y/%m/%d %H:%M:%S');
    echo "$dt $SESS: dMRI 66dir data processing started"
	main
	chmod -R g=u $RESULTFOLDER > /dev/null
	chmod -R o-rwx $RESULTFOLDER > /dev/null
	dt=$(date '+%Y/%m/%d %H:%M:%S');
    echo "$dt $SESS: dMRI 66dir data processing done"
fi
