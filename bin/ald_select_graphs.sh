#!/bin/bash
GRAPHFOLDER=/home/range1-raid1/labounek/data-on-porto/ALD/pictures/20230307/graphs202304
SELECTIONFOLDER=${GRAPHFOLDER}_manuscript_selection

cd $GRAPHFOLDER
cp 00000_legend2020*.png graph4*.png graph2003.png graph2054.png graph2057.png graph2064.png graph2070.png graph2071.png graph2073.png graph2074.png graph2075.png graph2076.png graph2091.png graph2092.png graph2093.png graph2195.png graph2196.png graph2197.png graph2212.png graph2213.png graph2214.png graph2316.png graph2317.png graph2318.png graph2333.png graph2334.png graph2335.png graph2336.png graph2337.png graph2338.png graph2344.png graph2346.png graph2361.png graph2362.png graph2363.png graph2364.png graph2365.png graph2366.png graph2367.png graph2368.png graph2369.png graph2372.png graph2386.png graph7111.png graph7112.png graph7113.png graph7114.png $SELECTIONFOLDER

cp graph12003.png graph12054.png graph12057.png graph12064.png graph12070.png graph12071.png graph12073.png graph12074.png graph12075.png graph12076.png graph12091.png graph12092.png graph12093.png graph12195.png graph12196.png graph12197.png graph12212.png graph12213.png graph12214.png graph12316.png graph12317.png graph12318.png graph12333.png graph12334.png graph12335.png graph12336.png graph12337.png graph12338.png graph12344.png graph12346.png graph12361.png graph12362.png graph12363.png graph12364.png graph12365.png graph12366.png graph12367.png graph12368.png graph12369.png graph12372.png graph12386.png $SELECTIONFOLDER

#cp graph4[0-9]4[0-9].png ${SELECTIONFOLDER}_trajectories

#graph2187-graph2194 FA without lesion JHU
#graph2308-graph2315 MD without lesion JHU

