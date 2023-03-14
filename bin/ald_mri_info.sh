#/bin/bash
#DATAFOLDER=/home/range1-raid1/labounek/data-on-range4/renda/CSPINE
#DATAFOLDER=/home/labounek/data/ALD
DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/ALD
#DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/controls/brain_ALD
NAME=dmri_12dir
#NAME=mprage
#NAME=*Segmentation

LIST=$DATAFOLDER/subject_list_20230307.txt
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
            echo $SESS >> /home/range1-raid1/labounek/ald_session_list_20201022.txt
        fi
    done
done
