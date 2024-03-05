# qmri-ald
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/umn-milab/qmri-ald/issues)

Image analysis pipelines of qunatitative MRI (qMRI), including diffusion MRI (dMRI), in patients with adrenoleukodystrophy (ALD)

## Content

-   [Introduction](#introduction)
-   [DICOM to NIfTI conversion](#dicom-to-nifti-conversion)
-   [MRI info check](#mri-info-check)
-   [Automated pipelines](#automated-pipelines)
-   [DTI analysis](#dti-analysis)
-   [References](#references)
-   [Copyright](#copyright)

## Introduction

**ANYONE CAN CONTRIBUTE** to the open-source MATLAB/Octave software library for **automated image and statistical analyses**. The library includes:
- DTI analysis of longitudinal 12-directional diffusion MRI data `(Pierpont and Labounek, et al. 2024)`

## DICOM to NIfTI conversion

The script `bin/ald_convert_data.sh` demonstrates how a multi-center MRI data were converted from DICOM format into NIfTI format and stored in a unified folder and file naming structure. 

The script `bin/ald_datacheck.sh` can further check whether specific MRI image is or is not abvailable over list of subjects and particular MRI sessions.

## MRI info check

The script `bin/ald_mri_info.sh` can read MRI image info such as voxel dimensions and voxel volume over list of subjects and particular MRI sessions.

## Automated pipelines

The bash script `bin/ald_pipeline.sh` proceed the entire image analysis. The pipeline provides:
- MPRAGE image analysis
- DTI analysis
- T1-rho / T2-rho image analysis

## DTI analysis

The bash script `bin/ald_dmri_process.sh` proceed automated preprocessing and DTI analysis of longitudinal 12-directional diffusion MRI data for the protocol optimized and presented in `(Pierpont and Labounek, et al. 2024)`.

After DTI analysis is done, the matlab script `matlab/ald_extract_dmri_metrics.m` can extract local microstructural measurements from DTI results.

When all results are organized in excell sheet like in the `data/data_pierpont_labounek_2024.xlsx` file, then the matlab script `matlab/ald_evaluation.m` can provide statistical analysis and make figures including graphs and tables as presented in `(Pierpont and Labounek, et al. 2024)`.

## References
Pierpont E I, Labounek R, Gupta A O, Lund T C, Orchard P J, Dobyns W B, Bondy M, Paulson A, Metz A, Shanley R, Wozniak J R, Mueller B A, Loes D, Nascene D R, & Nestrasil I (2024). Diffusion tensor imaging is sensitive to early demyelinating lesions and predicts neurocognitive outcome in boys with adrenoleukodystrophy. *Neurology*. [Under review]

## Copyright

The "qmri-ald" program provides automated image-processing pipelines for structural MRI images primarily acquired in pediatric healthy controls and pediatric patients with cerebral adrenoleukodystrophy. The program provides preprocessing, processing, quantitative, and statistical analysis of MRI images such as T1-weighted anatomical scans, diffusion MRI scans utilizing DTI and HARDI protocols or T1-rho and T2-rho scans.

Copyright (C) 2024  Rene Labounek (1,a), Igor Nestrasil (1,b), Medical Imaging Lab (MILab)

1 Medical Imaging Lab (MILab), Division of Clinical Behavioral Neuroscience, Department of Pediatrics, University of Minnesota, Masonic Institute for the Developing Brain, 2025 East River Parkway, Minneapolis, MN 55414, USA

a) email: rlaboune@umn.edu

b) email: nestr007@umn.edu

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
