#!/bin/bash
PROJECT=ALD
DATAFOLDER=/home/porto-raid2/nestrasil-data/$PROJECT
#PROJECT=controls/brain_ALD
#DATAFOLDER=/home/porto-raid2/nestrasil-data/$PROJECT

LIST=$DATAFOLDER/subject_list_20230307.txt
DICOMFOLDER=$DATAFOLDER/dicom
NIIFOLDER=$DATAFOLDER/nii
RESULTFOLDER=$DATAFOLDER/results

MPRRESULT=$RESULTFOLDER/mprage
DMRIRESULT=$RESULTFOLDER/dmri
DMRI66RESULT=$RESULTFOLDER/dmri66
RHORESULT=$RESULTFOLDER/rho

FSFOLDER=$DATAFOLDER/results/fs
ITKFOLDER=$DATAFOLDER/results/itk-snap

OLDFOLDER=`pwd`
cd $NIIFOLDER

if [ ! -d $RESULTFOLDER ];then
		mkdir $RESULTFOLDER
        chmod 770 $RESULTFOLDER
fi
if [ ! -d $MPRRESULT ];then
		mkdir $MPRRESULT
        chmod 770 $MPRRESULT
fi
if [ ! -d $DMRIRESULT ];then
		mkdir $DMRIRESULT
        chmod 770 $DMRIRESULT
fi
if [ ! -d $DMRI66RESULT ];then
		mkdir $DMRI66RESULT
        chmod 770 $DMRI66RESULT
fi

for SUB in `cat $LIST`;do
#for SUB in 7320MAKI;do # 2938ROPO 3450ADOR 4165LOCH 5797IACH 7226CRPO \ 7111GETI 7151DOBU 7166ASTH 7243LAVE 7320MAKI
    if [ ! -d $MPRRESULT/$SUB ];then
		mkdir $MPRRESULT/$SUB
        chmod 770 $MPRRESULT/$SUB
    fi
    if [ ! -d $DMRIRESULT/$SUB ];then
		mkdir $DMRIRESULT/$SUB
        chmod 770 $DMRIRESULT/$SUB
    fi
#	if [ ! -d $DMRI66RESULT/$SUB ];then
#		mkdir $DMRI66RESULT/$SUB
#        chmod 770 $DMRI66RESULT/$SUB
#    fi
    for SESS in `ls -d ${SUB}/*`;do
        if [ ! -d $MPRRESULT/$SESS ];then
		    mkdir $MPRRESULT/$SESS
            chmod 770 $MPRRESULT/$SESS
        fi
        if [ ! -d $DMRIRESULT/$SESS ];then
		    mkdir $DMRIRESULT/$SESS
            chmod 770 $DMRIRESULT/$SESS
        fi
        nice -n19 ald_mprage_process.sh $NIIFOLDER/$SESS $MPRRESULT/$SESS $SUB $SESS $DICOMFOLDER $FSFOLDER/$SESS $ITKFOLDER/$SESS
        nice -n19 ald_dmri_process.sh $NIIFOLDER/$SESS $DMRIRESULT/$SESS $MPRRESULT/$SESS $SUB $SESS $DICOMFOLDER
	nice -n19 ald_rho_process.sh $NIIFOLDER/$SESS $RHORESULT/$SESS $MPRRESULT/$SESS $SUB $SESS $DICOMFOLDER
	#nice -n19 ald_dmri66_process.sh $NIIFOLDER/$SESS $DMRI66RESULT/$SESS $MPRRESULT/$SESS $SUB $SESS $DICOMFOLDER
    done
    if [ -d $DMRI66RESULT/$SUB ];then
        chmod 770 $DMRI66RESULT/$SUB
    fi
done
