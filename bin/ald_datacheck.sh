#/bin/bash
DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/ALD
#DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/controls/brain_ALD

#NAME=*Segmentation
#NAME=mprage
#NAME=flair
#NAME=dmri_12dir
#NAME=dmri_66dir_ap
#NAME=dmri_66dir_pa
#NAME=swi
NAME=phase

LIST=$DATAFOLDER/subject_list_20230307.txt
DICOMFOLDER=$DATAFOLDER/dicom
NIIFOLDER=$DATAFOLDER/nii

OLDFOLDER=`pwd`
cd $NIIFOLDER
for SUB in `cat $LIST`;do
    for SESS in `ls -d ${SUB}/*`;do
        if [ -f $NIIFOLDER/$SESS/$NAME.nii.gz ];then
            #echo $SESS            
            echo 1
        else
            #echo $SESS            
            echo 0
        fi
    done
done
