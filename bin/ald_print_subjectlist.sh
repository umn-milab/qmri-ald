#/bin/bash
DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/ALD
#DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/controls/brain_ALD
NAME=dmri_12dir
#NAME=*Segmentation

LIST=$DATAFOLDER/subject_list_20230226.txt
DICOMFOLDER=$DATAFOLDER/dicom
NIIFOLDER=$DATAFOLDER/nii

OLDFOLDER=`pwd`
cd $NIIFOLDER
for SUB in `cat $LIST`;do
    for SESS in `ls -d ${SUB}/*`;do
        echo $SESS >> $DATAFOLDER/subject_list_20230226_allsessions.txt         
    done
done
