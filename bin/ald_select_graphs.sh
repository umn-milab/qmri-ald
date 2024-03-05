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

GRAPHFOLDER=/home/range1-raid1/labounek/data-on-porto/ALD/pictures/20230307/graphs202304
SELECTIONFOLDER=${GRAPHFOLDER}_manuscript_selection

cd $GRAPHFOLDER
cp 00000_legend2020*.png graph4*.png graph2003.png graph2054.png graph2057.png graph2064.png graph2070.png graph2071.png graph2073.png graph2074.png graph2075.png graph2076.png graph2091.png graph2092.png graph2093.png graph2195.png graph2196.png graph2197.png graph2212.png graph2213.png graph2214.png graph2316.png graph2317.png graph2318.png graph2333.png graph2334.png graph2335.png graph2336.png graph2337.png graph2338.png graph2344.png graph2346.png graph2361.png graph2362.png graph2363.png graph2364.png graph2365.png graph2366.png graph2367.png graph2368.png graph2369.png graph2372.png graph2386.png graph7111.png graph7112.png graph7113.png graph7114.png $SELECTIONFOLDER

cp graph12003.png graph12054.png graph12057.png graph12064.png graph12070.png graph12071.png graph12073.png graph12074.png graph12075.png graph12076.png graph12091.png graph12092.png graph12093.png graph12195.png graph12196.png graph12197.png graph12212.png graph12213.png graph12214.png graph12316.png graph12317.png graph12318.png graph12333.png graph12334.png graph12335.png graph12336.png graph12337.png graph12338.png graph12344.png graph12346.png graph12361.png graph12362.png graph12363.png graph12364.png graph12365.png graph12366.png graph12367.png graph12368.png graph12369.png graph12372.png graph12386.png $SELECTIONFOLDER

#cp graph4[0-9]4[0-9].png ${SELECTIONFOLDER}_trajectories

#graph2187-graph2194 FA without lesion JHU
#graph2308-graph2315 MD without lesion JHU


