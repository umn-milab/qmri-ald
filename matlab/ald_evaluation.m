% The "qmri-ald" program provides automated image-processing pipelines for
% structural MRI images primarily acquired in pediatric healthy controls
% and pediatric patients with cerebral adrenoleukodystrophy. The program
% provides preprocessing, processing, quantitative, and statistical analysis
% of MRI images such as T1-weighted anatomical scans, diffusion MRI scans
% utilizing DTI and HARDI protocols or T1-rho and T2-rho scans.
% 
% Copyright (C) 2024  Rene Labounek (1,a), Igor Nestrasil (1,b)
% Medical Imaging Lab (MILab)
% 
% 1 Medical Imaging Lab (MILab), Division of Clinical Behavioral Neuroscience,
%   Department of Pediatrics, University of Minnesota,
%   Masonic Institute for the Developing Brain,
%   2025 East River Parkway, Minneapolis, MN 55414, USA
% a) email: rlaboune@umn.edu
% b) email: nestr007@umn.edu
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

clear all; close all;
xls_file = '../data/data_pierpont_labounek_2024.xlsx';
save_path = '~/Pictures/ALD/pictures/graphs';

draw_boxplot_dist = 1;
box_order = [2:5 1 6];
rd_order = [2:4 1 5];
md_order = [2:4 1 5];
ad_order = [2:4 1 5];

draw_predict_corr = 1; % Value 0, 1 or 2
neuropsych_draw = 'Processing Speed';
% neuropsych_draw = 'Visual Reasoning';
% neuropsych_draw = 'Visual-Motor Integration';
% neuropsych_draw = 'Verbal Reasoning';
% neuropsych_draw = 'Working Memory';
% neuropsych_draw = 'Fine Motor Dexterity';

neuropsych_order = 'xpre-ypost';
% neuropsych_order = 'xpre-ypre';
% neuropsych_order = 'trend';

include_advanced = 1;
show_rapid = 0;

neuropsych_name_select = {'Processing Speed', 'Visual Reasoning','Visual-Motor Integration','Verbal Reasoning','Working Memory','Fine Motor Dexterity'};

jhu_labels = {
    1 'Middle cerebellar peduncle'
    2 'Pontine crossing tract (a part of MCP)'
    3 'Genu of corpus callosum'
    4 'Body of corpus callosum'
    5 'Splenium of corpus callosum'
    6 'Fornix (column and body of fornix)'
    7 'Corticospinal tract R'
    8 'Corticospinal tract L'
    9 'Medial lemniscus R'
    10 'Medial lemniscus L'
    11 'Inferior cerebellar peduncle R'  
    12 'Inferior cerebellar peduncle L'
    13 'Superior cerebellar peduncle R'
    14 'Superior cerebellar peduncle L'
    15 'Cerebral peduncle R'
    16 'Cerebral peduncle L'
    17 'Anterior limb of internal capsule R'
    18 'Anterior limb of internal capsule L'
    19 'Posterior limb of internal capsule R'
    20 'Posterior limb of internal capsule L'
    21 'Retrolenticular part of internal capsule R'
    22 'Retrolenticular part of internal capsule L'
    23 'Anterior corona radiata R'
    24 'Anterior corona radiata L'
    25 'Superior corona radiata R'
    26 'Superior corona radiata L'
    27 'Posterior corona radiata R'
    28 'Posterior corona radiata L'
    29 'Posterior thalamic radiation (include OR) R'
    30 'Posterior thalamic radiation (include OR) L'
    31 'Sagittal stratum (include ILF and IFOF) R'
    32 'Sagittal stratum (include ILF and IFOF) L'
    33 'External capsule R'
    34 'External capsule L'
    35 'Cingulum (cingulate gyrus) R'
    36 'Cingulum (cingulate gyrus) L'
    37 'Cingulum (hippocampus) R'
    38 'Cingulum (hippocampus) L'
    39 'Fornix (cres) / Stria terminalis R'
    40 'Fornix (cres) / Stria terminalis L'
    41 'Superior longitudinal fasciculus R'
    42 'Superior longitudinal fasciculus L'
    43 'Superior fronto-occipital fasciculus R'
    44 'Superior fronto-occipital fasciculus L'
    45 'Uncinate fasciculus R'
    46 'Uncinate fasciculus L'
    47 'Tapetum R'
    48 'Tapetum L'
    };

fs_labels={
    2 'Left Cerebral White Matter'
    3 'Left Cerebral Cortex'
    4 'Left Lateral Ventricle'
    5 'Left Inf Lat Vent'
    7 'Left Cerebellum White Matter'
    8 'Left Cerebellum Cortex'
    10 'Left Thalamus Proper'
    11 'Left Caudate'
    12 'Left Putamen'
    13 'Left Pallidum'
    14 '3rd Ventricle'
    15 '4th Ventricle'
    16 'Brain Stem'
    17 'Left Hippocampus'
    18 'Left Amygdala'
    24 'CSF'
    26 'Left Accumbens area'
    28 'Left VentralDC'
    31 'Left choroid plexus'
    41 'Right Cerebral White Matter'
    42 'Right Cerebral Cortex'
    43 'Right Lateral Ventricle'
    44 'Right Inf Lat Vent'
    46 'Right Cerebellum White Matter'
    47 'Right Cerebellum Cortex'
    49 'Right Thalamus Proper'
    50 'Right Caudate'
    51 'Right Putamen'
    52 'Right Pallidum'
    53 'Right Hippocampus'
    54 'Right Amygdala'
    58 'Right Accumbens area'
    60 'Right VentralDC'
    63 'Right choroid plexus'
    77 'WM hypointensities'
    85 'Optic Chiasm'
    251 'Corpus Callosum Posterior'
    252 'Corpus Callosum Mid Posterior'
    253 'Corpus Callosum Central'
    254 'Corpus Callosum Mid Anterior'
    255 'Corpus Callosum Anterior'
    };

[num, txt, raw] = xlsread(xls_file);
cols = size(raw,2);

subid=unique({raw{2:end,1}}');

subnum=zeros(size(raw,1),1);
for ind = 1:size(subid,1)
    subnum(strcmp({raw{:,1}},subid{ind,1}),1) = ind;
end
subnum(1)=[];

selection=[raw{2:end,strcmp(raw(1,:),'Selection202304')}]';
early_disease=[raw{2:end,strcmp(raw(1,:),'Early-Disease')}]';
slow_progression=[raw{2:end,strcmp(raw(1,:),'Slow-Progression')}]';
loes=[raw{2:end,strcmp(raw(1,:),'LoesScore2023')}]';

varidxdmri = find(strcmp(raw(1,:),'FA12_jhu_wm')==1):find(strcmp(raw(1,:),'RD12_jhu_aCRNOles')==1);
varidxvol = [find(strcmp(raw(1,:),'Left-Lateral-Ventricle')==1):find(strcmp(raw(1,:),'Right-choroid-plexus')==1) ...
    find(strcmp(raw(1,:),'Optic-Chiasm')==1):find(strcmp(raw(1,:),'MaskVol')==1) ...
    find(strcmp(raw(1,:),'Total Ventricles')==1):find(strcmp(raw(1,:),'BGG+Thalamus')==1)];
varidxsurf = find(strcmp(raw(1,:),'BrainSegVol-to-eTIV')==1):find(strcmp(raw(1,:),'MaskVol-to-eTIV')==1);
varidxthick = find(strcmp(raw(1,:),'thickness-lh')==1):find(strcmp(raw(1,:),'thickness-avg')==1);
varidxles = find(strcmp(raw(1,:),'LesionVol')==1):find(strcmp(raw(1,:),'CerebralWMLesionVol')==1);
varidxlessplit = find(strcmp(raw(1,:),'RightLesionVol')==1):find(strcmp(raw(1,:),'LeftLesionVol')==1);
varidxneuropsych = find(strcmp(raw(1,:),'FSIQ')==1):find(strcmp(raw(1,:),'VMI')==1);

ageatscan=[raw{2:end,strcmp(raw(1,:),'Age at Scan')}]';
time=[raw{2:end,strcmp(raw(1,:),'Time (days)')}]';
type=[raw{2:end,strcmp(raw(1,:),'Type')}]';
type2020=[raw{2:end,11}]';
dmri12voxelvol = [raw{2:end,strcmp(raw(1,:),'dmri_12dir_vol')}]';
mpragevoxelvol = [raw{2:end,strcmp(raw(1,:),'mprage_vol')}]';
intracranvol=[raw{2:end,strcmp(raw(1,:),'EstimatedTotalIntraCranialVol')}]';


BrainSegVolNotVent = [raw{2:end,strcmp(raw(1,:),'BrainSegVolNotVent')}]';

bmttime=zeros(size(raw,1)-1,1);
bmtage=zeros(size(raw,1)-1,1);
dmri=zeros(size(raw,1)-1,size(varidxdmri,2));
vols=zeros(size(raw,1)-1,size(varidxvol,2));
surface=zeros(size(raw,1)-1,size(varidxsurf,2));
thickness=zeros(size(raw,1)-1,size(varidxthick,2));
neuropsych = NaN*ones(size(raw,1)-1,length(varidxneuropsych));

for ind = 2:size(raw,1)
    for vr = 1:length(varidxneuropsych)
        if ~strcmp(raw{ind,varidxneuropsych(vr)},'.') && ~isnan(raw{ind,varidxneuropsych(vr)})
            neuropsych(ind-1,vr) = raw{ind,varidxneuropsych(vr)};
        end
    end
end
neuropsych_name = {raw{1,varidxneuropsych}};
percept = neuropsych(:,strcmp(neuropsych_name,'PERCEPT'));
psi = neuropsych(:,strcmp(neuropsych_name,'PSI'));
vmi = neuropsych(:,strcmp(neuropsych_name,'VMI'));
verbal = neuropsych(:,strcmp(neuropsych_name,'VERBAL'));
wmi = neuropsych(:,strcmp(neuropsych_name,'WMI'));
fmdex = neuropsych(:,strcmp(neuropsych_name,'Pegs-Ave'));

for ind = 2:size(raw,1)
    if ~ischar(raw{ind,strcmp(raw(1,:),'time to BMT [day]')})
        bmttime(ind-1,1) = raw{ind,strcmp(raw(1,:),'time to BMT [day]')};
        bmtage(ind-1,1) = raw{ind,strcmp(raw(1,:),'Age at HSCT1')};
    else
        if selection(ind-1,1)==1
%             bmttime(ind-1,1) = -110+round(randn(1,1)*8);
            bmttime(ind-1,1) = -100;
%         else
%             bmttime(ind-1,1) = NaN;
        end
        bmtage(ind-1,1) = NaN;
    end
    for cl = 1:size(varidxdmri,2)
        if ~ischar(raw{ind,varidxdmri(cl)})
            dmri(ind-1,cl) = raw{ind,varidxdmri(cl)};
        else
            dmri(ind-1,cl) = NaN;
        end
    end
end
dmri_name = {raw{1,varidxdmri}};

ageattransplant = zeros(size(ageatscan));
for ind = 1:size(ageattransplant,1)
    if type2020(ind) > 1
        ageattransplant(ind) = raw{ind+1,strcmp(raw(1,:),'Age at HSCT1')};
    end
end

bmttime0pos= bmttime==0;
subnum0pos = subnum(bmttime0pos);
for ind=1:size(subnum0pos,1)
    pairpos= subnum==subnum0pos(ind);
    timestamps = time(pairpos);
    timeval=bmttime(pairpos);
    bmttime(pairpos & bmttime0pos) = timeval(timeval~=0) + max(timestamps) - min(timestamps);
end

intracranvol_mean = zeros(size(intracranvol));
for ind = 1:max(subnum)
    pom = intracranvol(subnum==ind);
    pom(isnan(pom)) = [];
    if ~isempty(pom)
        pom = mean(pom);
        intracranvol_mean(subnum==ind) = pom;
    end
end
intracranvol_mean(intracranvol_mean==0) = NaN;

for cl = 1:size(varidxvol,2)
    vols(:,cl) = [raw{2:end,varidxvol(cl)}]';
end
vols = vols ./ repmat(intracranvol_mean,1,size(vols,2)) .*100;
vols(:, end+1) = intracranvol;
vols_name = {raw{1,varidxvol} 'IntraCranialVol'};

for cl = 1:size(varidxsurf,2)
    surface(:,cl) = [raw{2:end,varidxsurf(cl)}]';
end
surface_name = {raw{1,varidxsurf}};

for cl = 1:size(varidxthick,2)
    thickness(:,cl) = [raw{2:end,varidxthick(cl)}]';
end
thickness_name = {raw{1,varidxthick}};

lesion=zeros(size(raw,1)-1,size(varidxles,2));
for ind = 1:size(varidxles,2)
    lesion(:,ind)=[raw{2:end,varidxles(ind)}]';
end
lession(sum(lesion,2)==0) = NaN;
spleniumvol_mean = zeros(size(lesion,1),1);
cerebralwmvol_mean = zeros(size(lesion,1),1);
for ind = 1:size(subid,1)
    sbpos=subnum==ind;
    spleniumvol_mean(sbpos,1) = mean(lesion(sbpos,2),'omitnan');
    cerebralwmvol_mean(sbpos,1) = mean(lesion(sbpos,4),'omitnan');
end
lesion_name = {raw{1,varidxles}};

lesion_brainnoventnorm = 100*lesion(:,[1 3 5])./BrainSegVolNotVent;
lesion_brainnoventnorm_name = lesion_name(1,[1 3 5]);
for ind = 1:size(lesion_brainnoventnorm_name,2)
    lesion_brainnoventnorm_name{1,ind} = [lesion_brainnoventnorm_name{1,ind} '_BrainSegVolNotVent'];
end
lesionmm3 = lesion(:,1);
lesionmm3_name = {'Lesion Volume [mm^3]'};

lesion(:,3) = lesion(:,3) ./ spleniumvol_mean .* 100;
lesion(:,5) = lesion(:,5) ./ cerebralwmvol_mean .* 100;
lesion(:,1) = lesion(:,1) ./ intracranvol_mean .* 100;
lesion(:,2) = lesion(:,2) ./ intracranvol_mean .* 100;
lesion(:,4) = lesion(:,4) ./ intracranvol_mean .* 100;
lesion(isnan(vols(:,20)),2:5)=NaN;


data = [thickness surface lesion vols dmri loes lesion_brainnoventnorm neuropsych lesionmm3];
data_name = [thickness_name surface_name lesion_name vols_name dmri_name 'LoesScore' lesion_brainnoventnorm_name neuropsych_name lesionmm3_name];

for ind = 1:size(data_name,2)
    for ps = 1:size(data_name{1,ind},2)
        if strcmp(data_name{1,ind}(ps),'_')
            data_name{1,ind}(ps) = '-';
        end
    end
end


demographics{1,2} = 'baseline';
demographics{2,2} = 'Nsub';
demographics{2,3} = 'Age_mean';
demographics{2,4} = 'Age_STD';
demographics{1,5} = 'followup';
demographics{2,5} = 'Nsub';
demographics{2,6} = 'Age_mean';
demographics{2,7} = 'Age_STD';
demographics{1,8} = 'Transplant';
demographics{2,8} = 'Age_mean';
demographics{2,9} = 'Age_STD';
demographics{2,1} = 'Group';
demographics{3,1} = 'No-lesion';

demographics2020 = demographics;


demographics{4,1} = 'Early-slow-progression';
demographics{5,1} = 'Early-fast-progression';
demographics{6,1} = 'Advanced-slow-progression';
demographics{7,1} = 'Advanced-fast-progression';
demographics{8,1} = 'Slow-progression';
demographics{9,1} = 'Fast-progression';
demographics{10,1} = 'All-lesion';

demographics2020{4,1} = '0<Loes<=2';
demographics2020{5,1} = '2<Loes<=4.5';
demographics2020{6,1} = '4.5<Loes<9';
demographics2020{7,1} = '9<=Loes';
demographics2020{8,1} = '2<Loes<=4.5; atypical lesion';
demographics2020{9,1} = '2<Loes<=4.5; frontal lesion';
demographics2020{10,1} = '0<Loes<=4.5';
demographics2020{11,1} = '0<Loes<=4.5-slow-progression';
demographics2020{12,1} = '0<Loes<=4.5-rapid-progression';
demographics2020{13,1} = '0<Loes<9-slow-progression';
demographics2020{14,1} = '0<Loes<9-rapid-progression';
demographics2020{15,1} = 'All-lesion';
demographics2020{16,1} = 'All-pCC-lesion';



for scan = 1:2
    for ind = 1:max(type)
        demographics{ind+2,2+(scan-1)*3} = sum(type==ind & selection==scan);
        demographics{ind+2,3+(scan-1)*3} = mean(ageatscan(type==ind & selection==scan));
        demographics{ind+2,4+(scan-1)*3} = std(ageatscan(type==ind & selection==scan));
        if ind>1 && scan==2
            demographics{ind+2,5+(scan-1)*3} = mean(ageattransplant(type==ind & selection==scan));
            demographics{ind+2,6+(scan-1)*3} = std(ageattransplant(type==ind & selection==scan));
        end
    end
    demographics{8,2+(scan-1)*3} = sum((type==2 | type==4) & selection==scan);
    demographics{8,3+(scan-1)*3} = mean(ageatscan((type==2 | type==4) & selection==scan));
    demographics{8,4+(scan-1)*3} = std(ageatscan((type==2 | type==4) & selection==scan));
    if scan==2
        demographics{8,5+(scan-1)*3} = mean(ageattransplant((type==2 | type==4) & selection==scan));
        demographics{8,6+(scan-1)*3} = std(ageattransplant((type==2 | type==4) & selection==scan));
        demographics{9,5+(scan-1)*3} = mean(ageattransplant((type==3 | type==5) & selection==scan));
        demographics{9,6+(scan-1)*3} = std(ageattransplant((type==3 | type==5) & selection==scan));
        demographics{10,5+(scan-1)*3} = mean(ageattransplant(type>1 & selection==scan));
        demographics{10,6+(scan-1)*3} = std(ageattransplant(type>1 & selection==scan));
    end
    demographics{9,2+(scan-1)*3} = sum((type==3 | type==5) & selection==scan);
    demographics{9,3+(scan-1)*3} = mean(ageatscan((type==3 | type==5) & selection==scan));
    demographics{9,4+(scan-1)*3} = std(ageatscan((type==3 | type==5) & selection==scan));
    
    demographics{10,2+(scan-1)*3} = sum(type>1 & selection==scan);
    demographics{10,3+(scan-1)*3} = mean(ageatscan(type>1 & selection==scan));
    demographics{10,4+(scan-1)*3} = std(ageatscan(type>1 & selection==scan));
end

for scan = 1:2
    for ind = 1:max(type2020)
        demographics2020{ind+2,2+(scan-1)*3} = sum(type2020==ind & selection==scan);
        demographics2020{ind+2,3+(scan-1)*3} = mean(ageatscan(type2020==ind & selection==scan));
        demographics2020{ind+2,4+(scan-1)*3} = std(ageatscan(type2020==ind & selection==scan));
        if ind>1 && scan==2
            demographics2020{ind+2,5+(scan-1)*3} = mean(ageattransplant(type2020==ind & selection==scan));
            demographics2020{ind+2,6+(scan-1)*3} = std(ageattransplant(type2020==ind & selection==scan));
        end
    end
    
    demographics2020{10,2+(scan-1)*3} = sum((type2020==2 | type2020==3) & selection==scan);
    demographics2020{10,3+(scan-1)*3} = mean(ageatscan((type2020==2 | type2020==3) & selection==scan));
    demographics2020{10,4+(scan-1)*3} = std(ageatscan((type2020==2 | type2020==3) & selection==scan));
    
    demographics2020{11,2+(scan-1)*3} = sum((type2020>=2 & type2020<=3) & selection==scan & slow_progression==1);
    demographics2020{11,3+(scan-1)*3} = mean(ageatscan((type2020>=2 & type2020<=3) & selection==scan & slow_progression==1));
    demographics2020{11,4+(scan-1)*3} = std(ageatscan((type2020>=2 & type2020<=3) & selection==scan & slow_progression==1));
    
    demographics2020{12,2+(scan-1)*3} = sum((type2020>=2 & type2020<=3) & selection==scan & slow_progression==0);
    demographics2020{12,3+(scan-1)*3} = mean(ageatscan((type2020>=2 & type2020<=3) & selection==scan & slow_progression==0));
    demographics2020{12,4+(scan-1)*3} = std(ageatscan((type2020>=2 & type2020<=3) & selection==scan & slow_progression==0));
    
    demographics2020{13,2+(scan-1)*3} = sum((type2020>=2 & type2020<=4) & selection==scan & slow_progression==1);
    demographics2020{13,3+(scan-1)*3} = mean(ageatscan((type2020>=2 & type2020<=4) & selection==scan & slow_progression==1));
    demographics2020{13,4+(scan-1)*3} = std(ageatscan((type2020>=2 & type2020<=4) & selection==scan & slow_progression==1));
    
    demographics2020{14,2+(scan-1)*3} = sum((type2020>=2 & type2020<=4) & selection==scan & slow_progression==0);
    demographics2020{14,3+(scan-1)*3} = mean(ageatscan((type2020>=2 & type2020<=4) & selection==scan & slow_progression==0));
    demographics2020{14,4+(scan-1)*3} = std(ageatscan((type2020>=2 & type2020<=4) & selection==scan & slow_progression==0));
    
    demographics2020{15,2+(scan-1)*3} = sum(type2020>1 & selection==scan);
    demographics2020{15,3+(scan-1)*3} = mean(ageatscan(type2020>1 & selection==scan));
    demographics2020{15,4+(scan-1)*3} = std(ageatscan(type2020>1 & selection==scan));
    
    demographics2020{16,2+(scan-1)*3} = sum(type2020>1 & type2020<6 & selection==scan);
    demographics2020{16,3+(scan-1)*3} = mean(ageatscan(type2020>1 & type2020<6 & selection==scan));
    demographics2020{16,4+(scan-1)*3} = std(ageatscan(type2020>1 & type2020<6 & selection==scan));
    
    if scan==2
        demographics2020{10,5+(scan-1)*3} = mean(ageattransplant((type2020==2 | type2020==3) & selection==scan));
        demographics2020{10,6+(scan-1)*3} = std(ageattransplant((type2020==2 | type2020==3) & selection==scan));
        
        demographics2020{11,5+(scan-1)*3} = mean(ageattransplant((type2020>=2 & type2020<=3) & selection==scan & slow_progression==1));
        demographics2020{11,6+(scan-1)*3} = std(ageattransplant((type2020>=2 & type2020<=3) & selection==scan & slow_progression==1));
        
        demographics2020{12,5+(scan-1)*3} = mean(ageattransplant((type2020>=2 & type2020<=3) & selection==scan & slow_progression==0));
        demographics2020{12,6+(scan-1)*3} = std(ageattransplant((type2020>=2 & type2020<=3) & selection==scan & slow_progression==0));
        
        demographics2020{13,5+(scan-1)*3} = mean(ageattransplant((type2020>=2 & type2020<=4) & selection==scan & slow_progression==1));
        demographics2020{13,6+(scan-1)*3} = std(ageattransplant((type2020>=2 & type2020<=4) & selection==scan & slow_progression==1));
        
        demographics2020{14,5+(scan-1)*3} = mean(ageattransplant((type2020>=2 & type2020<=4) & selection==scan & slow_progression==0));
        demographics2020{14,6+(scan-1)*3} = std(ageattransplant((type2020>=2 & type2020<=4) & selection==scan & slow_progression==0));
        
        demographics2020{15,5+(scan-1)*3} = mean(ageattransplant(type2020>1 & selection==scan));
        demographics2020{15,6+(scan-1)*3} = std(ageattransplant(type2020>1 & selection==scan));
        
        demographics2020{16,5+(scan-1)*3} = mean(ageattransplant(type2020>1 & type2020<6 & selection==scan));
        demographics2020{16,6+(scan-1)*3} = std(ageattransplant(type2020>1 & type2020<6 & selection==scan));
    end
end

% CerebralWhiteMatterVol CerebralWMVol

data_name_select = {'CortexVol' 'CerebralWhiteMatterVol' 'Total Ventricles' 'Thalamus' 'BGG' 'thickness-avg'... %  'LoesScore' 'LesionVol' 'Lesion Volume [mm^3]' 'BGG' 'thickness-avg' 
    'FA12-jhu-wm' 'FA12-jhu-cc' 'FA12-jhu-5' 'FA12-jhu-3' 'FA12-jhu-4' 'FA12-jhu-cst' ...
    'MD12-jhu-wm' 'MD12-jhu-cc' 'MD12-jhu-5' 'MD12-jhu-3' 'MD12-jhu-4' 'MD12-jhu-cst' ...
    'RD12-jhu-wm' 'RD12-jhu-cc' 'RD12-jhu-5' 'RD12-jhu-3' 'RD12-jhu-4' 'RD12-jhu-cst' ...
    'AD12-jhu-wm' 'AD12-jhu-cc' 'AD12-jhu-5' 'AD12-jhu-3' 'AD12-jhu-4' 'AD12-jhu-cst' ...
    'FA12-jhu-wmNOles' 'FA12-jhu-ccNOles' 'FA12-jhu-5NOles' 'FA12-jhu-3NOles' 'FA12-jhu-4NOles' 'FA12-jhu-cstNOles' ...
    'MD12-jhu-wmNOles' 'MD12-jhu-ccNOles' 'MD12-jhu-5NOles' 'MD12-jhu-3NOles' 'MD12-jhu-4NOles' 'MD12-jhu-cstNOles' ...
    'RD12-jhu-wmNOles' 'RD12-jhu-ccNOles' 'RD12-jhu-5NOles' 'RD12-jhu-3NOles' 'RD12-jhu-4NOles' 'RD12-jhu-cstNOles' ...
    'AD12-jhu-wmNOles' 'AD12-jhu-ccNOles' 'AD12-jhu-5NOles' 'AD12-jhu-3NOles' 'AD12-jhu-4NOles' 'AD12-jhu-cstNOles'}; % 'FA12-jhu-aCR' 'FA12-jhu-retroIC'
data_select_pos = zeros(size(data_name_select,2),1);
st_abstract{2,1} = 'Measure - Atlas - Region of Interest';
st_abstract{1,2} = 'No Lesion (G1)';
st_abstract{2,2} = 'pre-Mean';
st_abstract{2,3} = 'pre-STD';
st_abstract{2,4} = 'post-Mean';
st_abstract{2,5} = 'post-STD';
st_abstract{2,6} = 'slope-Mean';
st_abstract{2,7} = 'slope-STD';
st_abstract{1,8} = 'Posterior Lesion (0<Loes<=2; G2)';
st_abstract{2,8} = 'pre-Mean';
st_abstract{2,9} = 'pre-STD';
st_abstract{2,10} = 'post-Mean';
st_abstract{2,11} = 'post-STD';
st_abstract{2,12} = 'slope-Mean';
st_abstract{2,13} = 'slope-STD';
st_abstract{1,14} = 'Posterior Lesion (0<Loes<=4.5; G3)';
st_abstract{2,14} = 'pre-Mean';
st_abstract{2,15} = 'pre-STD';
st_abstract{2,16} = 'post-Mean';
st_abstract{2,17} = 'post-STD';
st_abstract{2,18} = 'slope-Mean';
st_abstract{2,19} = 'slope-STD';
st_abstract{1,20} = 'Posterior Lesion (4.5<Loes; G4)';
st_abstract{2,20} = 'pre-Mean';
st_abstract{2,21} = 'pre-STD';
st_abstract{2,22} = 'post-Mean';
st_abstract{2,23} = 'post-STD';
st_abstract{2,24} = 'slope-Mean';
st_abstract{2,25} = 'slope-STD';
st_abstract{1,26} = 'Wilcoxon rank sum tests (p-values)';
st_abstract{2,26} = 'pre-G1vsG2';
st_abstract{2,27} = 'pre-G1vsG3';
st_abstract{2,28} = 'pre-G1vsG4';
st_abstract{2,29} = 'slope-G1vsG2';
st_abstract{2,30} = 'slope-G1vsG3';
st_abstract{2,31} = 'slope-G1vsG4';
st_abstract{1,32} = 'ANCOVA (p-values; counfouding factor = dMRI voxel volume)';
st_abstract{2,32} = 'pre-G1vsG2';
st_abstract{2,33} = 'pre-G1vsG3';
st_abstract{2,34} = 'pre-G1vsG4';
st_abstract{2,35} = 'slope-G1vsG2';
st_abstract{2,36} = 'slope-G1vsG3';
st_abstract{2,37} = 'slope-G1vsG4';

st_partcorr(1,2:7) = neuropsych_name_select;

sess1_pos = subnum(selection==1);
slope=zeros(size(sess1_pos,1),size(data_name_select,2));
sbplid = 1;
if strcmp(neuropsych_draw,'Processing Speed')
    figid = 4501;
elseif strcmp(neuropsych_draw,'Visual Reasoning')
    figid = 4601;
elseif strcmp(neuropsych_draw,'Visual-Motor Integration')
    figid = 4701;
elseif strcmp(neuropsych_draw,'Verbal Reasoning')
    figid = 4201;
elseif strcmp(neuropsych_draw,'Working Memory')
    figid = 4301;
elseif strcmp(neuropsych_draw,'Fine Motor Dexterity')
    figid = 4401;
end

if include_advanced == 0 
    figid = figid + 1000;
end
if strcmp(neuropsych_order,'xpre-ypre') 
    figid = figid + 20;
end
if strcmp(neuropsych_order,'trend') 
    figid = figid + 40;
end
if draw_predict_corr == 1
    h(figid).fig=figure(figid);
    set(h(figid).fig,'Position',[50 50 2100 1200])
end

boxid = 1;
box_g1 = [];
box_g2 = [];
box_name = cell(1,1);
rdid = 1;
rd_g1 = [];
rd_g2 = [];
rd_name = cell(1,1);
mdid = 1;
md_g1 = [];
md_g2 = [];
md_name = cell(1,1);
adid = 1;
ad_g1 = [];
ad_g2 = [];
ad_name = cell(1,1);

for idx = 1:size(data_name_select,2)
    pos = find(strcmp(data_name,data_name_select{1,idx})==1);
    data_select_pos(idx,1) = pos;
    
    if strcmp(data_name_select{1,idx},'CerebralWMVol') || strcmp(data_name_select{1,idx},'CerebralWhiteMatterVol')
        st_abstract{2+idx,1} = 'Cerebral White Matter Volume [% of Cranial Volume]';
    elseif strcmp(data_name_select{1,idx},'CortexVol')
        st_abstract{2+idx,1} = 'Cortex Volume [% of Cranial Volume]';
    elseif strcmp(data_name_select{1,idx},'Total Ventricles')
        st_abstract{2+idx,1} = 'Total Ventricles Volume [% of Cranial Volume]';
    elseif strcmp(data_name_select{1,idx},'Thalamus')
        st_abstract{2+idx,1} = 'Thalamus Volume [% of Cranial Volume]';
    elseif strcmp(data_name_select{1,idx},'BGG')
        st_abstract{2+idx,1} = 'Basal Ganglia Volume [% of Cranial Volume]';
    elseif strcmp(data_name_select{1,idx},'BGG+Thalamus')
        st_abstract{2+idx,1} = 'Basal Ganglia + Thalamus Volume [% of Cranial Volume]';
    elseif strcmp(data_name_select{1,idx},'thickness-avg')
        st_abstract{2+idx,1} = 'Cortical Thickness [mm]';
    elseif strcmp(data_name_select{1,idx},'LesionVol')
        st_abstract{2+idx,1} = 'LesionVolume [% of Cranial Volume]';
    elseif strcmp(data_name_select{1,idx},'Lesion Volume [mm^3]')
        st_abstract{2+idx,1} = 'Lesion Volume [mm^3]';
    elseif strcmp(data_name_select{1,idx},'LoesScore')
        st_abstract{2+idx,1} = 'Loes Score';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-wm')
        st_abstract{2+idx,1} = 'FA - JHU - White Matter';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-cc')
        st_abstract{2+idx,1} = 'FA - JHU - Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-5')
        st_abstract{2+idx,1} = 'FA - JHU - Splenium of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-3')
        st_abstract{2+idx,1} = 'FA - JHU - Genu of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-4')
        st_abstract{2+idx,1} = 'FA - JHU - Body of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-cst')
        st_abstract{2+idx,1} = 'FA - JHU - Corticospinal Tract';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-aCR')
        st_abstract{2+idx,1} = 'FA - JHU - Anterior Corona Radiata';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-retroIC')
        st_abstract{2+idx,1} = 'FA - JHU - Retrolenticular Part of Internal Capsule';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-wm')
        st_abstract{2+idx,1} = 'MD - JHU - White Matter';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-cc')
        st_abstract{2+idx,1} = 'MD - JHU - Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-5')
        st_abstract{2+idx,1} = 'MD - JHU - Splenium of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-3')
        st_abstract{2+idx,1} = 'MD - JHU - Genu of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-4')
        st_abstract{2+idx,1} = 'MD - JHU - Body of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-cst')
        st_abstract{2+idx,1} = 'MD - JHU - Corticospinal Tract';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-aCR')
        st_abstract{2+idx,1} = 'MD - JHU - Anterior Corona Radiata';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-retroIC')
        st_abstract{2+idx,1} = 'MD - JHU - Retrolenticular Part of Internal Capsule';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-wm')
        st_abstract{2+idx,1} = 'RD - JHU - White Matter';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-cc')
        st_abstract{2+idx,1} = 'RD - JHU - Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-5')
        st_abstract{2+idx,1} = 'RD - JHU - Splenium of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-3')
        st_abstract{2+idx,1} = 'RD - JHU - Genu of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-4')
        st_abstract{2+idx,1} = 'RD - JHU - Body of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-cst')
        st_abstract{2+idx,1} = 'RD - JHU - Corticospinal Tract';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-aCR')
        st_abstract{2+idx,1} = 'RD - JHU - Anterior Corona Radiata';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-retroIC')
        st_abstract{2+idx,1} = 'RD - JHU - Retrolenticular Part of Internal Capsule';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-wm')
        st_abstract{2+idx,1} = 'AD - JHU - White Matter';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-cc')
        st_abstract{2+idx,1} = 'AD - JHU - Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-5')
        st_abstract{2+idx,1} = 'AD - JHU - Splenium of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-3')
        st_abstract{2+idx,1} = 'AD - JHU - Genu of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-4')
        st_abstract{2+idx,1} = 'AD - JHU - Body of Corpus Callosum';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-cst')
        st_abstract{2+idx,1} = 'AD - JHU - Corticospinal Tract';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-aCR')
        st_abstract{2+idx,1} = 'AD - JHU - Anterior Corona Radiata';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-retroIC')
        st_abstract{2+idx,1} = 'AD - JHU - Retrolenticular Part of Internal Capsule';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-wmNOles')
        st_abstract{2+idx,1} = 'FA - JHU - White Matter without Lesion';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-ccNOles')
        st_abstract{2+idx,1} = 'FA - JHU - Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-5NOles')
        st_abstract{2+idx,1} = 'FA - JHU - Splenium of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-3NOles')
        st_abstract{2+idx,1} = 'FA - JHU - Genu of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-4NOles')
        st_abstract{2+idx,1} = 'FA - JHU - Body of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'FA12-jhu-cstNOles')
        st_abstract{2+idx,1} = 'FA - JHU - Corticospinal Tract without Lesion';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-wmNOles')
        st_abstract{2+idx,1} = 'MD - JHU - White Matter without Lesion';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-ccNOles')
        st_abstract{2+idx,1} = 'MD - JHU - Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-5NOles')
        st_abstract{2+idx,1} = 'MD - JHU - Splenium of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-3NOles')
        st_abstract{2+idx,1} = 'MD - JHU - Genu of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-4NOles')
        st_abstract{2+idx,1} = 'MD - JHU - Body of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'MD12-jhu-cstNOles')
        st_abstract{2+idx,1} = 'MD - JHU - Corticospinal Tract without Lesion';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-wmNOles')
        st_abstract{2+idx,1} = 'AD - JHU - White Matter without Lesion';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-ccNOles')
        st_abstract{2+idx,1} = 'AD - JHU - Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-5NOles')
        st_abstract{2+idx,1} = 'AD - JHU - Splenium of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-3NOles')
        st_abstract{2+idx,1} = 'AD - JHU - Genu of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-4NOles')
        st_abstract{2+idx,1} = 'AD - JHU - Body of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'AD12-jhu-cstNOles')
        st_abstract{2+idx,1} = 'AD - JHU - Corticospinal Tract without Lesion';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-wmNOles')
        st_abstract{2+idx,1} = 'RD - JHU - White Matter without Lesion';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-ccNOles')
        st_abstract{2+idx,1} = 'RD - JHU - Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-5NOles')
        st_abstract{2+idx,1} = 'RD - JHU - Splenium of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-3NOles')
        st_abstract{2+idx,1} = 'RD - JHU - Genu of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-4NOles')
        st_abstract{2+idx,1} = 'RD - JHU - Body of Corpus Callosum without Lesion';
    elseif strcmp(data_name_select{1,idx},'RD12-jhu-cstNOles')
        st_abstract{2+idx,1} = 'RD - JHU - Corticospinal Tract without Lesion';
    else
        st_abstract{2+idx,1} = data_name_select{1,idx};
    end
    
    [vec1,vec1_slope,vec1_stat,vec1_info] = extract_measures(data(:,pos),type2020,selection,1,bmttime,loes,dmri12voxelvol,slow_progression,[psi percept vmi verbal wmi fmdex],neuropsych_name_select,ageatscan);
    [vec2,vec2_slope,vec2_stat,vec2_info] = extract_measures(data(:,pos),type2020,selection,2,bmttime,loes,dmri12voxelvol,slow_progression,[psi percept vmi verbal wmi fmdex],neuropsych_name_select,ageatscan);
    [vec3,vec3_slope,vec3_stat,vec3_info] = extract_measures(data(:,pos),type2020,selection,3,bmttime,loes,dmri12voxelvol,slow_progression,[psi percept vmi verbal wmi fmdex],neuropsych_name_select,ageatscan);
    [vec4,vec4_slope,vec4_stat,vec4_info] = extract_measures(data(:,pos),type2020,selection,4,bmttime,loes,dmri12voxelvol,slow_progression,[psi percept vmi verbal wmi fmdex],neuropsych_name_select,ageatscan);
    [vec5,vec5_slope,vec5_stat,vec5_info] = extract_measures(data(:,pos),type2020,selection,5,bmttime,loes,dmri12voxelvol,slow_progression,[psi percept vmi verbal wmi fmdex],neuropsych_name_select,ageatscan);
    [vec6,vec6_slope,vec6_stat,vec6_info] = extract_measures(data(:,pos),type2020,selection,6,bmttime,loes,dmri12voxelvol,slow_progression,[psi percept vmi verbal wmi fmdex],neuropsych_name_select,ageatscan);
    [vec7,vec7_slope,vec7_stat,vec7_info] = extract_measures(data(:,pos),type2020,selection,7,bmttime,loes,dmri12voxelvol,slow_progression,[psi percept vmi verbal wmi fmdex],neuropsych_name_select,ageatscan);

    cell_slope{1,1} = vec1_slope;
    cell_slope{2,1} = vec2_slope;
    cell_slope{3,1} = vec3_slope;
    cell_slope{4,1} = vec4_slope;
    cell_slope{5,1} = vec5_slope;
    cell_slope{6,1} = vec6_slope;
    cell_slope{7,1} = vec7_slope;
    
    positive_slope1(idx,1) = sum(vec1_slope>0);
    positive_slope2(idx,1) = sum(vec2_slope>0);
    positive_slope234567(idx,1) = sum([vec2_slope; vec3_slope; vec4_slope; vec5_slope; vec6_slope; vec7_slope]>0);
    positive_slope1(idx,2) = positive_slope1(idx,1)/size(vec1_slope,1);
    positive_slope2(idx,2) = positive_slope2(idx,1)/size(vec2_slope,1);
    positive_slope234567(idx,2) = positive_slope234567(idx,1)/size([vec2_slope; vec3_slope; vec4_slope; vec5_slope; vec6_slope; vec7_slope],1);
    
    vec23 = [vec2; vec3];
    vec23_slope = [vec2_slope; vec3_slope];
    vec23_stat = mean(vec23,'omitnan')';
    vec23_stat(:,2) = std(vec23,'omitnan')';
    vec23_stat(3,1) = mean(vec23_slope,'omitnan');
    vec23_stat(3,2) = std(vec23_slope,'omitnan');
    
    vec45 = [vec4; vec5];
    vec45_slope = [vec4_slope; vec5_slope];
    vec45_stat = mean(vec45,'omitnan')';
    vec45_stat(:,2) = std(vec45,'omitnan')';
    vec45_stat(3,1) = mean(vec45_slope,'omitnan');
    vec45_stat(3,2) = std(vec45_slope,'omitnan');
    
    p_abstract(1,1) = ranksum(vec1(:,1),vec2(:,1));
    p_abstract(1,2) = ranksum(vec1(:,1),vec23(:,1));
    p_abstract(2,1) = ranksum(vec1(:,1),vec45(:,1));
    p_abstract(2,2) = ranksum(vec1_slope,vec2_slope);
    p_abstract(3,1) = ranksum(vec1_slope,vec23_slope);
    p_abstract(3,2) = ranksum(vec1_slope,vec45_slope);
    
    if strcmp(st_abstract{2+idx,1}(1:2),'FA') || strcmp(st_abstract{2+idx,1}(1:2),'MD') || strcmp(st_abstract{2+idx,1}(1:2),'AD') || strcmp(st_abstract{2+idx,1}(1:2),'RD')
%         p_ancova(1,1) = eval_ancova(vec1,vec2,vec1_info.dmrivoxelvol,vec2_info.dmrivoxelvol,'pre');
%         p_ancova(1,2) = eval_ancova(vec1,vec23,vec1_info.dmrivoxelvol,[vec2_info.dmrivoxelvol; vec3_info.dmrivoxelvol],'pre');
%         p_ancova(2,1) = eval_ancova(vec1,vec45,vec1_info.dmrivoxelvol,[vec4_info.dmrivoxelvol; vec5_info.dmrivoxelvol],'pre');
%         p_ancova(2,2) = eval_ancova(vec1_slope,vec2_slope,vec1_info.dmrivoxelvol,vec2_info.dmrivoxelvol,'slope');
%         p_ancova(3,1) = eval_ancova(vec1_slope,vec23_slope,vec1_info.dmrivoxelvol,[vec2_info.dmrivoxelvol; vec3_info.dmrivoxelvol],'slope');
%         p_ancova(3,2) = eval_ancova(vec1_slope,vec45_slope,vec1_info.dmrivoxelvol,[vec4_info.dmrivoxelvol; vec5_info.dmrivoxelvol],'slope');
        p_ancova(1,1) = eval_ancova_with_age(vec1,vec2,vec1_info.dmrivoxelvol,vec2_info.dmrivoxelvol,'pre',vec1_info.age,vec2_info.age);
        p_ancova(1,2) = eval_ancova_with_age(vec1,vec23,vec1_info.dmrivoxelvol,[vec2_info.dmrivoxelvol; vec3_info.dmrivoxelvol],'pre',vec1_info.age,[vec2_info.age; vec3_info.age]);
        p_ancova(2,1) = eval_ancova_with_age(vec1,vec45,vec1_info.dmrivoxelvol,[vec4_info.dmrivoxelvol; vec5_info.dmrivoxelvol],'pre',vec1_info.age,[vec4_info.age; vec5_info.age]);
        p_ancova(2,2) = eval_ancova_with_age(vec1_slope,vec2_slope,vec1_info.dmrivoxelvol,vec2_info.dmrivoxelvol,'slope',vec1_info.age,vec2_info.age);
        p_ancova(3,1) = eval_ancova_with_age(vec1_slope,vec23_slope,vec1_info.dmrivoxelvol,[vec2_info.dmrivoxelvol; vec3_info.dmrivoxelvol],'slope',vec1_info.age,[vec2_info.age; vec3_info.age]);
        p_ancova(3,2) = eval_ancova_with_age(vec1_slope,vec45_slope,vec1_info.dmrivoxelvol,[vec4_info.dmrivoxelvol; vec5_info.dmrivoxelvol],'slope',vec1_info.age,[vec4_info.age; vec5_info.age]);
    else
        p_ancova(1,1) = eval_ancova(vec1,vec2,vec1_info.age,vec2_info.age,'pre');
        p_ancova(1,2) = eval_ancova(vec1,vec23,vec1_info.age,[vec2_info.age; vec3_info.age],'pre');
        p_ancova(2,1) = eval_ancova(vec1,vec45,vec1_info.age,[vec4_info.age; vec5_info.age],'pre');
        p_ancova(2,2) = eval_ancova(vec1_slope,vec2_slope,vec1_info.age,vec2_info.age,'slope');
        p_ancova(3,1) = eval_ancova(vec1_slope,vec23_slope,vec1_info.age,[vec2_info.age; vec3_info.age],'slope');
        p_ancova(3,2) = eval_ancova(vec1_slope,vec45_slope,vec1_info.age,[vec4_info.age; vec5_info.age],'slope');
%         p_ancova = ones(3,2)*1000;
    end
    
    if strcmp(data_name_select{1,idx},'FA12-jhu-5')
        p_ancova_FAsplenium = eval_ancova(vec1,vec2,vec1_info.age,vec2_info.age,'pre');
    end
    
    pom=[vec1_stat; vec2_stat; vec23_stat; vec45_stat; p_abstract; p_ancova]';
    pom = pom(:);
    for psx = 1:size(pom,1)
        st_abstract{2+idx,1+psx} = pom(psx);
    end
    
    slope_name{1,idx} = [data_name_select{1,idx} '-slope'];
    for g = 1:size(cell_slope,1)
        slope = reorder_slope(slope,cell_slope{g,1},subnum,selection,type2020,g,idx,sess1_pos);
    end
    
    if draw_predict_corr == 1
        draw_scatter_corr(neuropsych_draw,neuropsych_order,sbplid,vec1,vec2,vec3,vec4,vec5,vec6,vec7,vec1_info,vec2_info,vec3_info,vec4_info,vec5_info,vec6_info,vec7_info,st_abstract{2+idx,1},include_advanced,show_rapid)
        sbplid = sbplid + 1;
        if mod(idx,6) == 0       
            set(gcf, 'color', [1 1 1])
            set(gcf, 'InvertHardcopy', 'off')
            pause(0.10)
            print(fullfile(save_path,['graph' num2str(figid,'%04.f')]),'-dpng','-r300')
    %         export_fig(fullfile(save_path,['graph' num2str(figid,'%04.f')]),'-m3.0','-png')
            pause(0.10)
            close(h(figid).fig)
            pause(0.05)
            if idx < size(data_name_select,2)
                figid = figid + 1;
                sbplid = 1;

                h(figid).fig=figure(figid);
                set(h(figid).fig,'Position',[50 50 2100 1200])
            end
        end       
    elseif draw_boxplot_dist == 1
        if strcmp(data_name_select{1,idx},'FA12-jhu-5')
            box_g1(:,boxid) = vec1(:,1);
            box_g2(:,boxid) = vec2(:,1);
            box_name{1,boxid} = st_abstract{2+idx,1};
            if contains(box_name{1,boxid},'JHU')
                box_name{1,boxid}(3:10) = [];
            end
            boxid = boxid + 1;
        end
        if contains(data_name_select{1,idx},'FA') && ~strcmp(data_name_select{1,idx},'FA12-jhu-cc') && ~strcmp(data_name_select{1,idx},'FA12-jhu-ccNOles') && ~strcmp(data_name_select{1,idx},'FA12-jhu-cstNOles') && ~contains(data_name_select{1,idx},'NOles')
            box_g1(:,boxid) = vec1_slope;
            box_g2(:,boxid) = vec2_slope;
            box_name{1,boxid} = st_abstract{2+idx,1};
            if contains(box_name{1,boxid},'JHU')
                box_name{1,boxid}(3:10) = [];
            end
            box_name{1,boxid} = ['Slope of ' box_name{1,boxid}];
            boxid = boxid + 1;
        end
        if contains(data_name_select{1,idx},'RD') && ~strcmp(data_name_select{1,idx},'RD12-jhu-cc') && ~strcmp(data_name_select{1,idx},'RD12-jhu-ccNOles') && ~strcmp(data_name_select{1,idx},'RD12-jhu-cstNoles') && ~contains(data_name_select{1,idx},'NOles')
            rd_g1(:,rdid) = vec1_slope;
            rd_g2(:,rdid) = vec2_slope;
            rd_name{1,rdid} = st_abstract{2+idx,1};
            if contains(rd_name{1,rdid},'JHU')
                rd_name{1,rdid}(3:10) = [];
            end
            rd_name{1,rdid} = ['Slope of ' rd_name{1,rdid}];
            rdid = rdid + 1;
        end
        if contains(data_name_select{1,idx},'MD') && ~strcmp(data_name_select{1,idx},'MD12-jhu-cc') && ~strcmp(data_name_select{1,idx},'MD12-jhu-ccNOles') && ~strcmp(data_name_select{1,idx},'MD12-jhu-cstNOles') && ~contains(data_name_select{1,idx},'NOles')
            md_g1(:,mdid) = vec1_slope;
            md_g2(:,mdid) = vec2_slope;
            md_name{1,mdid} = st_abstract{2+idx,1};
            if contains(md_name{1,mdid},'JHU')
                md_name{1,mdid}(3:10) = [];
            end
            md_name{1,mdid} = ['Slope of ' md_name{1,mdid}];
            mdid = mdid + 1;
        end
        if contains(data_name_select{1,idx},'AD') && ~strcmp(data_name_select{1,idx},'AD12-jhu-cc') && ~strcmp(data_name_select{1,idx},'AD12-jhu-ccNOles') && ~strcmp(data_name_select{1,idx},'AD12-jhu-cstNOles') && ~contains(data_name_select{1,idx},'NOles')
            ad_g1(:,adid) = vec1_slope;
            ad_g2(:,adid) = vec2_slope;
            ad_name{1,adid} = st_abstract{2+idx,1};
            if contains(ad_name{1,adid},'JHU')
                ad_name{1,adid}(3:10) = [];
            end
            ad_name{1,adid} = ['Slope of ' ad_name{1,adid}];
            adid = adid + 1;
        end
    end
    
    
    [rho(idx,:), p_rho(idx,:)] = estimate_partial_corr(vec2,vec3,vec4,vec5,vec6,vec7,vec2_info,vec3_info,vec4_info,vec5_info,vec6_info,vec7_info,include_advanced);
    st_partcorr{1+idx,1} = st_abstract{2+idx,1};
    tpos=find((st_partcorr{1+idx,1}=='[')==1);
    if tpos>0
        st_partcorr{1+idx,1}(tpos-1:end) = [];
    end
    tpos=find((st_partcorr{1+idx,1}=='-')==1);
    if sum(tpos>0)
        st_partcorr{1+idx,1}(tpos(1):tpos(2)+1) = [];
    end
    for nind = 1:size(rho,2)
        st_partcorr{1+idx,1+nind} = rho(idx,nind);
    end
end
st_abstract = stat_table_correction(st_abstract);
st_manuscript = stat_table_selection(st_abstract,positive_slope1,positive_slope2,positive_slope234567,data_name_select);
pBH_rho = ones(size(p_rho));
for cl = 1:size(p_rho,2)
    [~,~,~,pBH_rho(:,cl)]=fdr_bh(p_rho(:,cl),0.05,'pdep');
end

st_partcorr_thr = st_partcorr;
st_partcorr_thrBH = st_partcorr;
for rw = 1:size(p_rho,1)
    for cl = 1:size(p_rho,2)
            if p_rho(rw,cl)>=0.05
                st_partcorr_thr{rw+1,cl+1}=0;
            end
            if pBH_rho(rw,cl)>=0.05
                st_partcorr_thrBH{rw+1,cl+1}=0;
            end
    end
end

if draw_boxplot_dist == 1
    figid = 7111;
    h(figid).fig=figure(figid);
    set(h(figid).fig,'Position',[50 50 2100 500])
    for sbplid = 1:size(box_g1,2)
        if sbplid == 1
            draw_zero = 0;
        else
            draw_zero = 1;
        end
        subplot(1,6,sbplid)
        draw_boxplot_distribution(box_g1(:,box_order(1,sbplid)),box_g2(:,box_order(1,sbplid)),box_name{1,box_order(1,sbplid)},draw_zero)
    end
    pause(0.10)
    print(fullfile(save_path,['graph' num2str(figid,'%04.f')]),'-dpng','-r300')
    pause(0.10)
    close(h(figid).fig)
    pause(0.05)
    
    figid = 7112;
    h(figid).fig=figure(figid);
    set(h(figid).fig,'Position',[50 50 2100 500])
    for sbplid = 1:size(rd_g1,2)
        subplot(1,6,sbplid)
        draw_boxplot_distribution(rd_g1(:,rd_order(1,sbplid)),rd_g2(:,rd_order(1,sbplid)),rd_name{1,rd_order(1,sbplid)},1)
    end
    pause(0.10)
    print(fullfile(save_path,['graph' num2str(figid,'%04.f')]),'-dpng','-r300')
    pause(0.10)
    close(h(figid).fig)
    pause(0.05)
    
    figid = 7113;
    h(figid).fig=figure(figid);
    set(h(figid).fig,'Position',[50 50 2100 500])
    for sbplid = 1:size(md_g1,2)
        subplot(1,6,sbplid)
        draw_boxplot_distribution(md_g1(:,md_order(1,sbplid)),md_g2(:,md_order(1,sbplid)),md_name{1,md_order(1,sbplid)},1)
    end
    pause(0.10)
    print(fullfile(save_path,['graph' num2str(figid,'%04.f')]),'-dpng','-r300')
    pause(0.10)
    close(h(figid).fig)
    pause(0.05)
    
    figid = 7114;
    h(figid).fig=figure(figid);
    set(h(figid).fig,'Position',[50 50 2100 500])
    for sbplid = 1:size(ad_g1,2)
        subplot(1,6,sbplid)
        draw_boxplot_distribution(ad_g1(:,ad_order(1,sbplid)),ad_g2(:,ad_order(1,sbplid)),ad_name{1,ad_order(1,sbplid)},1)
    end
    pause(0.10)
    print(fullfile(save_path,['graph' num2str(figid,'%04.f')]),'-dpng','-r300')
    pause(0.10)
    close(h(figid).fig)
    pause(0.05)
end



figid = 4801;
if include_advanced == 0 
    figid = figid + 1000;
end
if strcmp(neuropsych_order,'xpre-ypre') 
    figid = figid + 20;
end
if strcmp(neuropsych_order,'trend') 
    figid = figid + 40;
end
h(figid).fig=figure(figid);
set(h(figid).fig,'Position',[50 50 2100 1200])
draw_scatter_corr('Processing Speed',neuropsych_order,1,vec1_info.loes,vec2_info.loes,vec3_info.loes,vec4_info.loes,vec5_info.loes,vec6_info.loes,vec7_info.loes,vec1_info,vec2_info,vec3_info,vec4_info,vec5_info,vec6_info,vec7_info,'Loes Score',include_advanced,show_rapid)
draw_scatter_corr('Visual Reasoning',neuropsych_order,2,vec1_info.loes,vec2_info.loes,vec3_info.loes,vec4_info.loes,vec5_info.loes,vec6_info.loes,vec7_info.loes,vec1_info,vec2_info,vec3_info,vec4_info,vec5_info,vec6_info,vec7_info,'Loes Score',include_advanced,show_rapid)
draw_scatter_corr('Visual-Motor Integration',neuropsych_order,3,vec1_info.loes,vec2_info.loes,vec3_info.loes,vec4_info.loes,vec5_info.loes,vec6_info.loes,vec7_info.loes,vec1_info,vec2_info,vec3_info,vec4_info,vec5_info,vec6_info,vec7_info,'Loes Score',include_advanced,show_rapid)
draw_scatter_corr('Verbal Reasoning',neuropsych_order,4,vec1_info.loes,vec2_info.loes,vec3_info.loes,vec4_info.loes,vec5_info.loes,vec6_info.loes,vec7_info.loes,vec1_info,vec2_info,vec3_info,vec4_info,vec5_info,vec6_info,vec7_info,'Loes Score',include_advanced,show_rapid)
draw_scatter_corr('Working Memory',neuropsych_order,5,vec1_info.loes,vec2_info.loes,vec3_info.loes,vec4_info.loes,vec5_info.loes,vec6_info.loes,vec7_info.loes,vec1_info,vec2_info,vec3_info,vec4_info,vec5_info,vec6_info,vec7_info,'Loes Score',include_advanced,show_rapid)
draw_scatter_corr('Fine Motor Dexterity',neuropsych_order,6,vec1_info.loes,vec2_info.loes,vec3_info.loes,vec4_info.loes,vec5_info.loes,vec6_info.loes,vec7_info.loes,vec1_info,vec2_info,vec3_info,vec4_info,vec5_info,vec6_info,vec7_info,'Loes Score',include_advanced,show_rapid)
set(gcf, 'color', [1 1 1])
set(gcf, 'InvertHardcopy', 'off')
pause(0.10)
print(fullfile(save_path,['graph' num2str(figid,'%04.f')]),'-dpng','-r300')
pause(0.10)
close(h(figid).fig)
pause(0.05)
        


st{1,3}='1prevs2+3+4+5preBMT';
st{2,3}='ttest2';
st{2,4}='Wilcoxon';
st{1,5}='1prevs2+3preBMT';
st{2,5}='ttest2';
st{2,6}='Wilcoxon';
st{1,7}='1prevs4+5preBMT';
st{2,7}='ttest2';
st{2,8}='Wilcoxon';
st{1,9}='1prevs2+4preBMT';
st{2,9}='ttest2';
st{2,10}='Wilcoxon';
st{1,11}='1prevs3+5preBMT';
st{2,11}='ttest2';
st{2,12}='Wilcoxon';
st{1,13}='2+3+4+5preBMTvs2+3+4+5postBMT';
st{2,13}='ttest2';
st{2,14}='Wilcoxon';
st{1,15}='2+3preBMTvs2+3postBMT';
st{2,15}='ttest2';
st{2,16}='Wilcoxon';
st{1,17}='4+5preBMTvs4+5postBMT';
st{2,17}='ttest2';
st{2,18}='Wilcoxon';
st{1,19}='2+4preBMTvs2+4postBMT';
st{2,19}='ttest2';
st{2,20}='Wilcoxon';
st{1,21}='3+5preBMTvs3+5postBMT';
st{2,21}='ttest2';
st{2,22}='Wilcoxon';
st{1,23}='Paired_t-test';
st{2,23}='1';
st{2,24}='2+3+4+5';
st{2,25}='2+3';
st{2,26}='4+5';
st{2,27}='2+4';
st{2,28}='3+5';
st{1,29}='Slope_ttest2+dLoes_corr';
st{2,29}='1vs2+3+4+5';
st{2,30}='1vs2+3';
st{2,31}='1vs4+5';
st{2,32}='1vs2+4';
st{2,33}='1vs3+5';
st{2,34}='corr';
st{2,35}='p_corr';
st{1,36}='Loes_score';
st{2,36}='corr';
st{2,37}='p_corr';



st{1,38}='1-baseline';
st{2,38}='Mean';
st{2,39}='STD';
st{1,40}='2+3+4+5-baseline';
st{2,40}='Mean';
st{2,41}='STD';
st{1,42}='2+3-baseline';
st{2,42}='Mean';
st{2,43}='STD';
st{1,44}='4+5-baseline';
st{2,44}='Mean';
st{2,45}='STD';
st{1,46}='2+4-baseline';
st{2,46}='Mean';
st{2,47}='STD';
st{1,48}='3+5-baseline';
st{2,48}='Mean';
st{2,49}='STD';

st{1,50}='1-followup';
st{2,50}='Mean';
st{2,51}='STD';
st{1,52}='2+3+4+5-followup';
st{2,52}='Mean';
st{2,53}='STD';
st{1,54}='2+3-followup';
st{2,54}='Mean';
st{2,55}='STD';
st{1,56}='4+5-followup';
st{2,56}='Mean';
st{2,57}='STD';
st{1,58}='2+4-followup';
st{2,58}='Mean';
st{2,59}='STD';
st{1,60}='3+5-followup';
st{2,60}='Mean';
st{2,61}='STD';

st{1,62}='2-baseline';
st{2,62}='Mean';
st{2,63}='STD';
st{1,64}='3-baseline';
st{2,64}='Mean';
st{2,65}='STD';

st{1,66}='2prevs3preBMT';
st{2,66}='ttest2';
st{2,67}='Wilcoxon';

st{1,68}='SlopeVSdLesVol';
st{2,68}='corr';
st{2,69}='p_corr';

st{1,70}='Lesion_Volume';
st{2,70}='corr';
st{2,71}='p_corr';

st{1,72}='type2020pre1VSpre2';
st{2,72}='ttest2';
st{2,73}='Wilcoxon';
st{1,74}='type2020pre1VSpre3';
st{2,74}='ttest2';
st{2,75}='Wilcoxon';
st{1,76}='type2020pre1VSpre4';
st{2,76}='ttest2';
st{2,77}='Wilcoxon';
st{1,78}='type2020pre1VSpre5';
st{2,78}='ttest2';
st{2,79}='Wilcoxon';
st{1,80}='type2020pre2VSpre3';
st{2,80}='ttest2';
st{2,81}='Wilcoxon';
st{1,82}='type2020pre2VSpre4';
st{2,82}='ttest2';
st{2,83}='Wilcoxon';
st{1,84}='type2020pre2VSpre5';
st{2,84}='ttest2';
st{2,85}='Wilcoxon';
st{1,86}='type2020pre23VSpre4';
st{2,86}='ttest2';
st{2,87}='Wilcoxon';
st{1,88}='type2020pre23VSpre5';
st{2,88}='ttest2';
st{2,89}='Wilcoxon';
st{1,90}='type2020pre3VSpre4';
st{2,90}='ttest2';
st{2,91}='Wilcoxon';
st{1,92}='type2020pre3VSpre5';
st{2,92}='ttest2';
st{2,93}='Wilcoxon';
st{1,94}='type2020pre4VSpre5';
st{2,94}='ttest2';
st{2,95}='Wilcoxon';
st{1,96}='type2020pre23rapidVSpre23slow';
st{2,96}='ttest2';
st{2,97}='Wilcoxon';
st{1,98}='type2020pre234rapidVSpre234slow';
st{2,98}='ttest2';
st{2,99}='Wilcoxon';

st{1,100}='2020-1-baseline';
st{2,100}='Mean';
st{2,101}='STD';
st{1,102}='2020-2-baseline';
st{2,102}='Mean';
st{2,103}='STD';
st{1,104}='2020-3-baseline';
st{2,104}='Mean';
st{2,105}='STD';
st{1,106}='2020-23-baseline';
st{2,106}='Mean';
st{2,107}='STD';
st{1,108}='2020-4-baseline';
st{2,108}='Mean';
st{2,109}='STD';
st{1,110}='2020-5-baseline';
st{2,110}='Mean';
st{2,111}='STD';
st{1,112}='2020-23rapid-baseline';
st{2,112}='Mean';
st{2,113}='STD';
st{1,114}='2020-23slow-baseline';
st{2,114}='Mean';
st{2,115}='STD';
st{1,116}='2020-234rapid-baseline';
st{2,116}='Mean';
st{2,117}='STD';
st{1,118}='2020-234slow-baseline';
st{2,118}='Mean';
st{2,119}='STD';

st{1,120}='2020-1-followup';
st{2,120}='Mean';
st{2,121}='STD';
st{1,122}='2020-2-followup';
st{2,122}='Mean';
st{2,123}='STD';
st{1,124}='2020-3-followup';
st{2,124}='Mean';
st{2,125}='STD';
st{1,126}='2020-23-followup';
st{2,126}='Mean';
st{2,127}='STD';
st{1,128}='2020-4-followup';
st{2,128}='Mean';
st{2,129}='STD';
st{1,130}='2020-5-followup';
st{2,130}='Mean';
st{2,131}='STD';
st{1,132}='2020-23rapid-followup';
st{2,132}='Mean';
st{2,133}='STD';
st{1,134}='2020-23slow-followup';
st{2,134}='Mean';
st{2,135}='STD';
st{1,136}='2020-234rapid-followup';
st{2,136}='Mean';
st{2,137}='STD';
st{1,138}='2020-234slow-followup';
st{2,138}='Mean';
st{2,139}='STD';


st{1,140}='Paired t-tests type2020 preVSpost';
st{2,140}='2';
st{2,141}='3';
st{2,142}='2+3';
st{2,143}='4';
st{2,144}='5';
st{2,145}='2+3_rapid';
st{2,146}='2+3_slow';
st{2,147}='2+3+4_rapid';
st{2,148}='2+3+4_slow';
st{2,149}='all_lesion';
st{2,150}='controls';


st{1,151}='Slope t-tests2 type2020';
st{2,151}='1vsall_lesion';
st{2,152}='1vs2';
st{2,153}='1vs3';
st{2,154}='1vs2+3';
st{2,155}='1vs4';
st{2,156}='1vs5';
st{2,157}='1vs2+3_rapid';
st{2,158}='1vs2+3_slow';
st{2,159}='1vs2+3+4_rapid';
st{2,160}='1vs2+3+4_slow';
st{2,161}='2+3_slowVS2+3_rapid';
st{2,162}='2+3+4_slowVS2+3+4_rapid';

st{1,163}='6-baseline';
st{2,163}='Mean';
st{2,164}='STD';
st{1,165}='6-followup';
st{2,165}='Mean';
st{2,166}='STD';

st{1,167}='type2020pre6VSpre1';
st{2,167}='ttest2';
st{2,168}='Wilcoxon';
st{1,169}='type2020pre6VSpre2';
st{2,169}='ttest2';
st{2,170}='Wilcoxon';
st{1,171}='type2020pre6VSpre3';
st{2,171}='ttest2';
st{2,172}='Wilcoxon';
st{1,173}='type2020pre6VSpre4';
st{2,173}='ttest2';
st{2,174}='Wilcoxon';
st{1,175}='type2020pre6VSpre5';
st{2,175}='ttest2';
st{2,176}='Wilcoxon';
st{1,177}='type2020pre6VSpre23';
st{2,177}='ttest2';
st{2,178}='Wilcoxon';

st{1,179}='Paired t-test type2020 preVSpost';
st{2,179}='6';

st{1,180}='Slope t-tests2 type2020';
st{2,180}='1vs6';
st{2,181}='3vs6';

st{1,182}='BMTage';
st{2,182}='corr';
st{2,183}='p_corr';

st{1,184}='AgeAtScan';
st{2,184}='corr';
st{2,185}='p_corr';

btwscans = [];
btwscanshc = [];
corr_dloes_k=zeros(size(data,2),2);
for vr = 1:size(data,2)
% for vr = 316:size(data,2)
    dt1pre = data(type==1 & selection==1,vr);
    dt1post = data(type==1 & selection==2,vr);
    dt25pre = data(type>1 & selection==1,vr);
    dt25post = data(type>1 & selection==2,vr);
    dt23pre = data(type>=2 & type<=3 & selection==1,vr);
    dt23post = data(type>=2 & type<=3 & selection==2,vr);
    dt45pre = data(type>=4 & type<=5 & selection==1,vr);
    dt45post = data(type>=4 & type<=5 & selection==2,vr);
    dt24pre = data((type==2 | type==4) & selection==1,vr);
    dt24post = data((type==2 | type==4) & selection==2,vr);
    dt35pre = data((type==3 | type==5) & selection==1,vr);
    dt35post = data((type==3 | type==5) & selection==2,vr);
    dt2pre = data(type==2 & selection==1,vr);
    dt3pre = data(type==3 & selection==1,vr);
    dt1pre(isnan(dt1pre))=[];
    dt1post(isnan(dt1post))=[];
    dt25pre(isnan(dt25pre))=[];
    dt25post(isnan(dt25post))=[];
    dt23pre(isnan(dt23pre))=[];
    dt23post(isnan(dt23post))=[];
    dt45pre(isnan(dt45pre))=[];
    dt45post(isnan(dt45post))=[];
    dt2pre(isnan(dt2pre))=[];
    dt3pre(isnan(dt3pre))=[];
    
    d2020t1pre = data(type2020==1 & selection==1,vr);
    d2020t1post = data(type2020==1 & selection==2,vr);
    d2020t2pre = data(type2020==2 & selection==1,vr);
    d2020t2post = data(type2020==2 & selection==2,vr);
    d2020t3pre = data(type2020==3 & selection==1,vr);
    d2020t3post = data(type2020==3 & selection==2,vr);
    d2020t4pre = data(type2020==4 & selection==1,vr);
    d2020t4post = data(type2020==4 & selection==2,vr);
    d2020t5pre = data(type2020==5 & selection==1,vr);
    d2020t5post = data(type2020==5 & selection==2,vr);
    d2020t6pre = data(type2020==6 & selection==1,vr);
    d2020t6post = data(type2020==6 & selection==2,vr);
    d2020t23pre = data(type2020>=2 & type2020<=3 & selection==1,vr);
    d2020t23post = data(type2020>=2 & type2020<=3 & selection==2,vr);
    d2020t23rapidpre = data(type2020>=2 & type2020<=3 & slow_progression==0 & selection==1,vr);
    d2020t23rapidpost = data(type2020>=2 & type2020<=3 & slow_progression==0 & selection==2,vr);
    d2020t23slowpre = data(type2020>=2 & type2020<=3 & slow_progression==1 & selection==1,vr);
    d2020t23slowpost = data(type2020>=2 & type2020<=3 & slow_progression==1 & selection==2,vr);
    d2020t234rapidpre = data(type2020>=2 & type2020<=4 & slow_progression==0 & selection==1,vr);
    d2020t234rapidpost = data(type2020>=2 & type2020<=4 & slow_progression==0 & selection==2,vr);
    d2020t234slowpre = data(type2020>=2 & type2020<=4 & slow_progression==1 & selection==1,vr);
    d2020t234slowpost = data(type2020>=2 & type2020<=4 & slow_progression==1 & selection==2,vr);
    d2020t1pre(isnan(d2020t1pre))=[];
    d2020t1post(isnan(d2020t1post))=[];
    d2020t2pre(isnan(d2020t2pre))=[];
    d2020t2post(isnan(d2020t2post))=[];
    d2020t3pre(isnan(d2020t3pre))=[];
    d2020t3post(isnan(d2020t3post))=[];
    d2020t4pre(isnan(d2020t4pre))=[];
    d2020t4post(isnan(d2020t4post))=[];
    d2020t5pre(isnan(d2020t5pre))=[];
    d2020t5post(isnan(d2020t5post))=[];
    d2020t6pre(isnan(d2020t6pre))=[];
    d2020t6post(isnan(d2020t6post))=[];
    d2020t23pre(isnan(d2020t23pre))=[];
    d2020t23post(isnan(d2020t23post))=[];
    d2020t23rapidpre(isnan(d2020t23rapidpre))=[];
    d2020t23rapidpost(isnan(d2020t23rapidpost))=[];
    d2020t23slowpre(isnan(d2020t23slowpre))=[];
    d2020t23slowpost(isnan(d2020t23slowpost))=[];
    d2020t234rapidpre(isnan(d2020t234rapidpre))=[];
    d2020t234rapidpost(isnan(d2020t234rapidpost))=[];
    d2020t234slowpre(isnan(d2020t234slowpre))=[];
    d2020t234slowpost(isnan(d2020t234slowpost))=[];
    
    st{vr+2,2} = data_name{1,vr};
    if ~isempty(dt1pre) && ~isempty(dt25pre)
        [~, st{vr+2,3}] = ttest2(dt1pre,dt25pre);
        st{vr+2,4} = ranksum(dt1pre,dt25pre);
    else
        st{vr+2,3} = 1;
        st{vr+2,4} = 1;
    end
    if ~isempty(dt1pre) && ~isempty(dt23pre)
        [~, st{vr+2,5}] = ttest2(dt1pre,dt23pre);
        st{vr+2,6} = ranksum(dt1pre,dt23pre);
    else
        st{vr+2,5} = 1;
        st{vr+2,6} = 1;
    end
    if ~isempty(dt1pre) && ~isempty(dt45pre)
        [~, st{vr+2,7}] = ttest2(dt1pre,dt45pre);
        st{vr+2,8} = ranksum(dt1pre,dt45pre);
    else
        st{vr+2,7} = 1;
        st{vr+2,8} = 1;
    end
    if ~isempty(dt1pre) && ~isempty(dt24pre)
        [~, st{vr+2,9}] = ttest2(dt1pre,dt24pre);
        st{vr+2,10} = ranksum(dt1pre,dt24pre);
    else
        st{vr+2,9} = 1;
        st{vr+2,10} = 1;
    end
    if ~isempty(dt1pre) && ~isempty(dt35pre)
        [~, st{vr+2,11}] = ttest2(dt1pre,dt35pre);
        st{vr+2,12} = ranksum(dt1pre,dt35pre);
    else
        st{vr+2,11} = 1;
        st{vr+2,12} = 1;
    end
    if ~isempty(dt25post) && ~isempty(dt25pre)
        [~, st{vr+2,13}] = ttest2(dt25pre,dt25post);
        st{vr+2,14} = ranksum(dt25pre,dt25post);
    else
        st{vr+2,13} = 1;
        st{vr+2,14} = 1;
    end
    if ~isempty(dt23post) && ~isempty(dt23pre)
        [~, st{vr+2,15}] = ttest2(dt23pre,dt23post);
        st{vr+2,16} = ranksum(dt23pre,dt23post);
    else
        st{vr+2,15} = 1;
        st{vr+2,16} = 1;
    end
    if ~isempty(dt45post) && ~isempty(dt45pre)
        [~, st{vr+2,17}] = ttest2(dt45pre,dt45post);
        st{vr+2,18} = ranksum(dt45pre,dt45post);
    else
        st{vr+2,17} = 1;
        st{vr+2,18} = 1;
    end
    if ~isempty(dt24post) && ~isempty(dt24pre)
        [~, st{vr+2,19}] = ttest2(dt24pre,dt24post);
        st{vr+2,20} = ranksum(dt24pre,dt24post);
    else
        st{vr+2,19} = 1;
        st{vr+2,20} = 1;
    end
    if ~isempty(dt35post) && ~isempty(dt35pre)
        [~, st{vr+2,21}] = ttest2(dt35pre,dt35post);
        st{vr+2,22} = ranksum(dt35pre,dt35post);
    else
        st{vr+2,21} = 1;
        st{vr+2,22} = 1;
    end
    
    if ~isempty(dt1pre)
        st{vr+2,38} = mean(dt1pre);
        st{vr+2,39} = std(dt1pre);
    else
        st{vr+2,38} = 0;
        st{vr+2,39} = 0;
    end
    st{vr+2,40} = mean(dt25pre);
    st{vr+2,41} = std(dt25pre);
    st{vr+2,42} = mean(dt23pre);
    st{vr+2,43} = std(dt23pre);
    st{vr+2,44} = mean(dt45pre);
    st{vr+2,45} = std(dt45pre);
    st{vr+2,46} = mean(dt23pre);
    st{vr+2,47} = std(dt23pre);
    st{vr+2,48} = mean(dt45pre);
    st{vr+2,49} = std(dt45pre);
    
    if ~isempty(dt1post)
        st{vr+2,50} = mean(dt1post);
        st{vr+2,51} = std(dt1post);
    else
        st{vr+2,50} = 0;
        st{vr+2,51} = 0;
    end
    st{vr+2,52} = mean(dt25post);
    st{vr+2,53} = std(dt25post);
    st{vr+2,54} = mean(dt23post);
    st{vr+2,55} = std(dt23post);
    st{vr+2,56} = mean(dt45post);
    st{vr+2,57} = std(dt45post);
    st{vr+2,58} = mean(dt23post);
    st{vr+2,59} = std(dt23post);
    st{vr+2,60} = mean(dt45post);
    st{vr+2,61} = std(dt45post);
    
    st{vr+2,62} = mean(dt2pre);
    st{vr+2,63} = std(dt2pre);
    st{vr+2,64} = mean(dt3pre);
    st{vr+2,65} = std(dt3pre);
    
    if ~isempty(dt2pre) && ~isempty(dt3pre)
        [~, st{vr+2,66}] = ttest2(dt2pre,dt3pre);
        st{vr+2,67} = ranksum(dt2pre,dt3pre);
    else
        st{vr+2,66} = 1;
        st{vr+2,67} = 1;
    end
    
%     st{vr+2,12} = mean(dt25post);
%     st{vr+2,13} = std(dt25post);
    
    
    if ~isempty(d2020t1pre) && ~isempty(d2020t2pre)
        [~, st{vr+2,72}] = ttest2(d2020t1pre,d2020t2pre);
        st{vr+2,73} = ranksum(d2020t1pre,d2020t2pre);
    else
        st{vr+2,72} = 1;
        st{vr+2,73} = 1;
    end
    if ~isempty(d2020t1pre) && ~isempty(d2020t3pre)
        [~, st{vr+2,74}] = ttest2(d2020t1pre,d2020t3pre);
        st{vr+2,75} = ranksum(d2020t1pre,d2020t3pre);
    else
        st{vr+2,74} = 1;
        st{vr+2,75} = 1;
    end
    if ~isempty(d2020t1pre) && ~isempty(d2020t4pre)
        [~, st{vr+2,76}] = ttest2(d2020t1pre,d2020t4pre);
        st{vr+2,77} = ranksum(d2020t1pre,d2020t4pre);
    else
        st{vr+2,76} = 1;
        st{vr+2,77} = 1;
    end
    if ~isempty(d2020t1pre) && ~isempty(d2020t5pre)
        [~, st{vr+2,78}] = ttest2(d2020t1pre,d2020t5pre);
        st{vr+2,79} = ranksum(d2020t1pre,d2020t5pre);
    else
        st{vr+2,78} = 1;
        st{vr+2,79} = 1;
    end
    if ~isempty(d2020t2pre) && ~isempty(d2020t3pre)
        [~, st{vr+2,80}] = ttest2(d2020t2pre,d2020t3pre);
        st{vr+2,81} = ranksum(d2020t2pre,d2020t3pre);
    else
        st{vr+2,80} = 1;
        st{vr+2,81} = 1;
    end
    if ~isempty(d2020t2pre) && ~isempty(d2020t4pre)
        [~, st{vr+2,82}] = ttest2(d2020t2pre,d2020t4pre);
        st{vr+2,83} = ranksum(d2020t2pre,d2020t4pre);
    else
        st{vr+2,82} = 1;
        st{vr+2,83} = 1;
    end
    if ~isempty(d2020t2pre) && ~isempty(d2020t5pre)
        [~, st{vr+2,84}] = ttest2(d2020t2pre,d2020t5pre);
        st{vr+2,85} = ranksum(d2020t2pre,d2020t5pre);
    else
        st{vr+2,84} = 1;
        st{vr+2,85} = 1;
    end
    if ~isempty(d2020t23pre) && ~isempty(d2020t4pre)
        [~, st{vr+2,86}] = ttest2(d2020t23pre,d2020t5pre);
        st{vr+2,87} = ranksum(d2020t23pre,d2020t5pre);
    else
        st{vr+2,86} = 1;
        st{vr+2,87} = 1;
    end
    if ~isempty(d2020t23pre) && ~isempty(d2020t5pre)
        [~, st{vr+2,88}] = ttest2(d2020t23pre,d2020t5pre);
        st{vr+2,89} = ranksum(d2020t23pre,d2020t5pre);
    else
        st{vr+2,88} = 1;
        st{vr+2,89} = 1;
    end
    if ~isempty(d2020t3pre) && ~isempty(d2020t4pre)
        [~, st{vr+2,90}] = ttest2(d2020t3pre,d2020t4pre);
        st{vr+2,91} = ranksum(d2020t3pre,d2020t4pre);
    else
        st{vr+2,90} = 1;
        st{vr+2,91} = 1;
    end
    if ~isempty(d2020t3pre) && ~isempty(d2020t5pre)
        [~, st{vr+2,92}] = ttest2(d2020t3pre,d2020t5pre);
        st{vr+2,93} = ranksum(d2020t3pre,d2020t5pre);
    else
        st{vr+2,92} = 1;
        st{vr+2,93} = 1;
    end
    if ~isempty(d2020t4pre) && ~isempty(d2020t5pre)
        [~, st{vr+2,94}] = ttest2(d2020t4pre,d2020t5pre);
        st{vr+2,95} = ranksum(d2020t4pre,d2020t5pre);
    else
        st{vr+2,94} = 1;
        st{vr+2,95} = 1;
    end
    if ~isempty(d2020t23rapidpre) && ~isempty(d2020t23slowpre)
        [~, st{vr+2,96}] = ttest2(d2020t23rapidpre,d2020t23slowpre);
        st{vr+2,97} = ranksum(d2020t23rapidpre,d2020t23slowpre);
    else
        st{vr+2,96} = 1;
        st{vr+2,97} = 1;
    end
    if ~isempty(d2020t234rapidpre) && ~isempty(d2020t234slowpre)
        [~, st{vr+2,98}] = ttest2(d2020t234rapidpre,d2020t234slowpre);
        st{vr+2,99} = ranksum(d2020t234rapidpre,d2020t234slowpre);
    else
        st{vr+2,98} = 1;
        st{vr+2,99} = 1;
    end
    if ~isempty(d2020t6pre) && ~isempty(d2020t1pre)
        [~, st{vr+2,167}] = ttest2(d2020t6pre,d2020t1pre);
        st{vr+2,168} = ranksum(d2020t6pre,d2020t1pre);
    else
        st{vr+2,167} = 1;
        st{vr+2,168} = 1;
    end
    if ~isempty(d2020t6pre) && ~isempty(d2020t2pre)
        [~, st{vr+2,169}] = ttest2(d2020t6pre,d2020t2pre);
        st{vr+2,170} = ranksum(d2020t6pre,d2020t2pre);
    else
        st{vr+2,169} = 1;
        st{vr+2,170} = 1;
    end
    if ~isempty(d2020t6pre) && ~isempty(d2020t3pre)
        [~, st{vr+2,171}] = ttest2(d2020t6pre,d2020t3pre);
        st{vr+2,172} = ranksum(d2020t6pre,d2020t3pre);
    else
        st{vr+2,171} = 1;
        st{vr+2,172} = 1;
    end
    if ~isempty(d2020t6pre) && ~isempty(d2020t4pre)
        [~, st{vr+2,173}] = ttest2(d2020t6pre,d2020t4pre);
        st{vr+2,174} = ranksum(d2020t6pre,d2020t4pre);
    else
        st{vr+2,173} = 1;
        st{vr+2,174} = 1;
    end
    if ~isempty(d2020t6pre) && ~isempty(d2020t5pre)
        [~, st{vr+2,175}] = ttest2(d2020t6pre,d2020t5pre);
        st{vr+2,176} = ranksum(d2020t6pre,d2020t5pre);
    else
        st{vr+2,175} = 1;
        st{vr+2,176} = 1;
    end
    if ~isempty(d2020t6pre) && ~isempty(d2020t23pre)
        [~, st{vr+2,177}] = ttest2(d2020t6pre,d2020t23pre);
        st{vr+2,178} = ranksum(d2020t6pre,d2020t23pre);
    else
        st{vr+2,177} = 1;
        st{vr+2,178} = 1;
    end
    

    if ~isempty(d2020t1pre)
        st{vr+2,100} = mean(d2020t1pre);
        st{vr+2,101} = std(d2020t1pre);
    else
        st{vr+2,100} = 0;
        st{vr+2,101} = 0;
    end
    st{vr+2,102} = mean(d2020t2pre);
    st{vr+2,103} = std(d2020t2pre);
    st{vr+2,104} = mean(d2020t3pre);
    st{vr+2,105} = std(d2020t3pre);
    st{vr+2,106} = mean(d2020t23pre);
    st{vr+2,107} = std(d2020t23pre);
    st{vr+2,108} = mean(d2020t4pre);
    st{vr+2,109} = std(d2020t4pre);
    st{vr+2,110} = mean(d2020t5pre);
    st{vr+2,111} = std(d2020t5pre);
    st{vr+2,112} = mean(d2020t23rapidpre);
    st{vr+2,113} = std(d2020t23rapidpre);
    st{vr+2,114} = mean(d2020t23slowpre);
    st{vr+2,115} = std(d2020t23slowpre);
    st{vr+2,116} = mean(d2020t234rapidpre);
    st{vr+2,117} = std(d2020t234rapidpre);
    st{vr+2,118} = mean(d2020t234slowpre);
    st{vr+2,119} = std(d2020t234slowpre);
    
    if ~isempty(d2020t1post)
        st{vr+2,120} = mean(d2020t1post);
        st{vr+2,121} = std(d2020t1post);
    else
        st{vr+2,120} = 0;
        st{vr+2,121} = 0;
    end
    st{vr+2,122} = mean(d2020t2post);
    st{vr+2,123} = std(d2020t2post);
    st{vr+2,124} = mean(d2020t3post);
    st{vr+2,125} = std(d2020t3post);
    st{vr+2,126} = mean(d2020t23post);
    st{vr+2,127} = std(d2020t23post);
    st{vr+2,128} = mean(d2020t4post);
    st{vr+2,129} = std(d2020t4post);
    st{vr+2,130} = mean(d2020t5post);
    st{vr+2,131} = std(d2020t5post);
    st{vr+2,132} = mean(d2020t23rapidpost);
    st{vr+2,133} = std(d2020t23rapidpost);
    st{vr+2,134} = mean(d2020t23slowpost);
    st{vr+2,135} = std(d2020t23slowpost);
    st{vr+2,136} = mean(d2020t234rapidpost);
    st{vr+2,137} = std(d2020t234rapidpost);
    st{vr+2,138} = mean(d2020t234slowpost);
    st{vr+2,139} = std(d2020t234slowpost);
    
    st{vr+2,163} = mean(d2020t6pre);
    st{vr+2,164} = std(d2020t6pre);
    st{vr+2,165} = mean(d2020t6post);
    st{vr+2,166} = std(d2020t6post);
    
    
    h(vr).fig = figure(vr);
    set(h(vr).fig,'Position',[50 50 600 500])
    
    pbase = st{vr+2,3};
    ppost = st{vr+2,13};
    
    mx = max(data(:,vr));
    if mx>=0
        mx=1.02*mx;
    else
        mx = 0.98*mx;
    end
    mn = min(data(:,vr));
    if mn<0
        mn = 1.02*mn;
    else
        mn = 0.98*mn;
    end
    plot([0 0],[mn mx],'k-.','LineWidth',3)
    hold on
    x=zeros(1,1);
    y=zeros(1,1);
    k=zeros(1,1);
    tpxy=zeros(1,1);
    dloes=zeros(1,1);
    dLesVol=zeros(1,1);
    psx = 1;
    hcx=zeros(1,1);
    hcy=zeros(1,1);
    hck=zeros(1,1);
    hcpsx = 1;
    for ind = 1:size(subid,1)
        pos=subnum==ind;
        tp=type(pos);
        tp = tp(1);
        if tp==1
            lns = ':o';
            clr = [0 0 1];
            wd = 2;
        elseif tp == 2
            lns = ':o';
            clr = [1 1 1]*0.5;
            wd = 2;
        elseif tp == 3
            lns = ':o';
            clr = [1 0 0];
            wd = 2;
        elseif tp == 4
            lns = ':x';
            clr = [1 1 1]*0.5;
            wd = 2;
        elseif tp == 5
            lns = ':x';
            clr = [1 0 0];
            wd = 2;
        end
        plot(bmttime(pos),data(pos,vr),lns,'Color',clr,'LineWidth',wd,'MarkerSize',10)
        if sum(pos)==2
            xt=bmttime(pos & selection==1);
            yt=bmttime(pos & selection==2);
            if tp>1
                if vr == 1
                    btwscans = [btwscans; sum(abs(bmttime(pos)))];
                end
                
                x(psx,1) = data(pos & selection==1,vr);
                y(psx,1) = data(pos & selection==2,vr);
                kk = polyfit([xt yt],[x(psx,1) y(psx,1)],1);
                k(psx,1)=kk(1);
                tpxy(psx,1) = tp;
                dloes(psx,1) = loes(pos & selection==2) - loes(pos & selection==1);
                dLesVol(psx,1) = lesion(pos & selection==2,1) - lesion(pos & selection==1,1);
                psx = psx + 1;
            elseif tp == 1
                if vr == 1
                    btwscanshc = [btwscanshc; sum(abs(bmttime(pos)))];
                end
                
                hcx(hcpsx,1) = data(pos & selection==1,vr);
                hcy(hcpsx,1) = data(pos & selection==2,vr);
                kk = polyfit([xt yt],[hcx(hcpsx,1) hcy(hcpsx,1)],1);
                hck(hcpsx,1)=kk(1);
                hcpsx = hcpsx + 1;
            end
        end
%         if tp > 1
%             x(psx,1) = data(pos & selection==1,vr);
%             y(psx,1) = data(pos & selection==2,vr);
%             psx = psx + 1;
%         elseif tp == 1 && sum(pos)>1
%             hcx(hcpsx,1) = data(pos & selection==1,vr);
%             hcy(hcpsx,1) = data(pos & selection==2,vr);
%             hcpsx = hcpsx + 1;
%         end
    end
    hold off
    xlabel('Time from treatment [days]')
    if vr <= 3
        ylabel('Cortical thickness [mm]')
    elseif vr==4 || vr==5
        ylabel('???')
    elseif vr==8 || vr==10
        ylabel('Volume [% of the ROI]')
    elseif (vr>=11 && vr<=72) || vr== 6 || vr==7 || vr==9
        ylabel('Volume [% of Cranial Volume]')
    elseif vr == 73
        ylabel('Volume [mm^3]')
    elseif vr>=74 && vr<=194
        ylabel('Fractional anisotropy')
    elseif vr>=195 && vr<=315
        ylabel('Mean diffusivity [*10^{-9}m^{2}/s]')
    elseif vr>=316 && vr<=335
        ylabel('Axial diffusivity [*10^{-9}m^{2}/s]')
    elseif vr>=336 && vr<=355
        ylabel('Radial diffusivity [*10^{-9}m^{2}/s]')
    elseif vr==356
        ylabel('Loes Score')
    elseif vr>=357 && vr<=359
        ylabel('Volume [% of Brain Volume without Ventricles]')
    elseif vr==362
        ylabel('Visual Reasoning')
    elseif vr==364
        ylabel('Processing Speed')
    elseif vr==369
        ylabel('Visual-Motor Integration')    
    else
        ylabel(data_name{1,vr})
    end
    if ~isempty(x) && ~isempty(y)
        [~, st{vr+2,24}] = ttest(x,y);
        [~, st{vr+2,25}] = ttest(x(tpxy==2 | tpxy==3),y(tpxy==2 | tpxy==3));
        [~, st{vr+2,26}] = ttest(x(tpxy==4 | tpxy==5),y(tpxy==4 | tpxy==5));
        [~, st{vr+2,27}] = ttest(x(tpxy==2 | tpxy==4),y(tpxy==2 | tpxy==4));
        [~, st{vr+2,28}] = ttest(x(tpxy==3 | tpxy==5),y(tpxy==3 | tpxy==5));
    else
        st{vr+2,24} = 1;
        st{vr+2,25} = 1;
        st{vr+2,26} = 1;
        st{vr+2,27} = 1;
        st{vr+2,28} = 1;
    end
    if ~isempty(hcx) && ~isempty(hcy)
        [~, st{vr+2,23}] = ttest(hcx,hcy);
    else
        st{vr+2,23} = 1;
    end
    if sum(abs(hck))~=0 && sum(abs(k))~=0 && ~isempty(dt1pre)
        [~, st{vr+2,29}] = ttest2(hck,k);
        [~, st{vr+2,30}] = ttest2(hck,k(tpxy==2 | tpxy==3));
        [~, st{vr+2,31}] = ttest2(hck,k(tpxy==4 | tpxy==5));
        [~, st{vr+2,32}] = ttest2(hck,k(tpxy==2 | tpxy==4));
        [~, st{vr+2,33}] = ttest2(hck,k(tpxy==3 | tpxy==5));
    else
        st{vr+2,29} = 1;
        st{vr+2,30} = 1;
        st{vr+2,31} = 1;
        st{vr+2,32} = 1;
        st{vr+2,33} = 1;
    end
%     [crr, crr_p] = corrcoef(dloes,k);
    [crr, crr_p] = corrcoef([dloes; zeros(size(hck))],[k; hck],'Rows','Pairwise');
    st{vr+2,34} = crr(1,2);
    st{vr+2,35} = crr_p(1,2);
    
    [crr, crr_p] = corrcoef([dLesVol; zeros(size(hck))],[k; hck],'Rows','Pairwise');
    st{vr+2,68} = crr(1,2);
    st{vr+2,69} = crr_p(1,2);
    
    [crr, crr_p] = corrcoef(loes,data(:,vr),'Rows','Pairwise');
    st{vr+2,36} = crr(1,2);
    st{vr+2,37} = crr_p(1,2);
    
    [crr, crr_p] = corrcoef(lesion(:,1),data(:,vr),'Rows','Pairwise');
    st{vr+2,70} = crr(1,2);
    st{vr+2,71} = crr_p(1,2);
    
    [crr, crr_p] = corrcoef(ageatscan,data(:,vr),'Rows','Pairwise');
    st{vr+2,184} = crr(1,2);
    st{vr+2,185} = crr_p(1,2);
    
%     ppostpaired = st{vr+2,24};
%     text(-140,0.97*mx,'Baseline','FontSize',12);
%     text(-140,0.94*mx,['p=' num2str(pbase,'%.6f')],'FontSize',12);
%     text(150,0.97*mx,'PreBMT vs PostBMT','FontSize',12);
%     text(150,0.94*mx,['p=' num2str(ppostpaired,'%.6f')],'FontSize',12);
    if length(data_name{1,vr})>8 && strcmp(data_name{1,vr}(6:8),'jhu')
        if strcmp(data_name{1,vr}(end-1:end),'wm')
            st{vr+2,1} = 'JHU: White Matter';
        elseif strcmp(data_name{1,vr}(end-1:end),'cc')
            st{vr+2,1} = 'JHU: Corpus Callosum';
        elseif strcmp(data_name{1,vr}(end-2:end),'cst')
            st{vr+2,1} = 'JHU: Corticospinal Tract';
        elseif strcmp(data_name{1,vr}(end-7:end),'Peduncle')
            st{vr+2,1} = 'JHU: Cerebral Peduncle';
        elseif strcmp(data_name{1,vr}(end-2:end),'aIC')
            st{vr+2,1} = 'JHU: Anterior Limb of Internal Capsule';
        elseif strcmp(data_name{1,vr}(end-2:end),'pIC')
            st{vr+2,1} = 'JHU: Posterior Limb of Internal Capsule';
        elseif strcmp(data_name{1,vr}(end-6:end),'retroIC')
            st{vr+2,1} = 'JHU: Retrolenticular Part of Internal Capsule';
        elseif strcmp(data_name{1,vr}(end-1:end),'IC')
            st{vr+2,1} = 'JHU: Internal Capsule';
        elseif strcmp(data_name{1,vr}(end-2:end),'aCR')
            st{vr+2,1} = 'JHU: Anterior Corona Radiata';
        elseif strcmp(data_name{1,vr}(end-2:end),'sCR')
            st{vr+2,1} = 'JHU: Superior Corona Radiata';
        elseif strcmp(data_name{1,vr}(end-2:end),'pCR')
            st{vr+2,1} = 'JHU: Posterior Corona Radiata';
        elseif strcmp(data_name{1,vr}(end-9:end),'sagStratum')
            st{vr+2,1} = 'JHU: Sagittal Stratum';
        elseif strcmp(data_name{1,vr}(end-3:end),'cing')
            st{vr+2,1} = 'JHU: Cingulum';
        elseif strcmp(data_name{1,vr}(end-7:end),'cc+tapet')
            st{vr+2,1} = 'JHU: Corpus Callosum + Tapetum';
        elseif strcmp(data_name{1,vr}(end-4:end),'tapet')
            st{vr+2,1} = 'JHU: Tapetum';
        elseif strcmp(data_name{1,vr}(end-5:end),'3NOles')
            st{vr+2,1} = 'JHU: Genu of corpus callosum without Lesion';
        elseif strcmp(data_name{1,vr}(end-5:end),'4NOles')
            st{vr+2,1} = 'JHU: Body of corpus callosum without Lesion';
        elseif strcmp(data_name{1,vr}(end-5:end),'5NOles')
            st{vr+2,1} = 'JHU: Splenium of corpus callosum without Lesion';
        elseif strcmp(data_name{1,vr}(end-6:end),'wmNOles')
            st{vr+2,1} = 'JHU: White Matter without Lesion';
        elseif strcmp(data_name{1,vr}(end-6:end),'ccNOles')
            st{vr+2,1} = 'JHU: Corpus Callosum without Lesion';
        elseif strcmp(data_name{1,vr}(end-7:end),'cstNOles')
            st{vr+2,1} = 'JHU: Corticospinal Tract without Lesion';
        elseif strcmp(data_name{1,vr}(end-7:end),'aCRNOles')
            st{vr+2,1} = 'JHU: Anterior Corona Radiata without Lesion';
        elseif strcmp(data_name{1,vr}(end-8:end),'roICNOles')
            st{vr+2,1} = 'JHU: Retrolenticular Part of Internal Capsule without Lesion';
        else
            psl=abs(str2double(data_name{1,vr}(end-1:end)));
            st{vr+2,1} = ['JHU: ' jhu_labels{psl,2}];
        end
        title(st{vr+2,1})
    elseif length(data_name{1,vr})>7 && strcmp(data_name{1,vr}(6:7),'fs')
        if strcmp(data_name{1,vr}(end-5:end),'crblwm')
            st{vr+2,1} = 'FS: Cerebellar White Matter';
        elseif strcmp(data_name{1,vr}(end-1:end),'wm')
            st{vr+2,1} = 'FS: White Matter';
        elseif strcmp(data_name{1,vr}(end-1:end),'cc')
            st{vr+2,1} = 'FS: Corpus Callosum';
        elseif strcmp(data_name{1,vr}(end-7:end),'splNOles')
            st{vr+2,1} = 'FS: Splenium without Lesion';
        elseif strcmp(data_name{1,vr}(end-6:end),'spl&les')
            st{vr+2,1} = 'FS: Splenium & Lesion';
        elseif strcmp(data_name{1,vr}(end-6:end),'ccNOles')
            st{vr+2,1} = 'FS: Corpus Callosum without Lesion';
        elseif strcmp(data_name{1,vr}(end-5:end),'cc&les')
            st{vr+2,1} = 'FS: Corpus Callosum & Lesion';
        elseif strcmp(data_name{1,vr}(end-6:end),'wmNOles')
            st{vr+2,1} = 'FS: White Matter without Lesion';
        elseif strcmp(data_name{1,vr}(end-5:end),'wm&les')
            st{vr+2,1} = 'FS: White Matter & Lesion';
        elseif ~isnan(str2double(data_name{1,vr}(end-2:end))) && str2double(data_name{1,vr}(end-2:end))>=100
            psl=str2double(data_name{1,vr}(end-2:end));
            psl2=find([fs_labels{:,1}]'==psl);
            st{vr+2,1} = ['FS ' num2str(psl) ': ' fs_labels{psl2,2}];
        else
            psl=abs(str2double(data_name{1,vr}(end-1:end)));
            psl2=find([fs_labels{:,1}]'==psl);
            st{vr+2,1} = ['FS ' num2str(psl) ': ' fs_labels{psl2,2}];
        end
        title(st{vr+2,1})
    elseif strcmp(data_name{1,vr},'FSIQ')
        title('Full Scale IQ')
    elseif strcmp(data_name{1,vr},'VERBAL')
        title('Verbal Reasoning')
    elseif strcmp(data_name{1,vr},'PERCEPT')
        title('Visual Reasoning')
    elseif strcmp(data_name{1,vr},'WMI')
        title('Working Memory')
    elseif strcmp(data_name{1,vr},'PSI')
        title('Processing Speed')
    elseif strcmp(data_name{1,vr},'Pegs-Ave')
        title('Fine Motor Dexterity')
    elseif strcmp(data_name{1,vr},'WMI')
        title('Visual-Motor Integration')
    else
        title(data_name{1,vr})
    end
    axis([-150 460 mn mx])
    grid on
    set(gca,'FontSize',14,'LineWidth',2)
    
    pause(0.15)
%     print(fullfile(save_path,['graph' num2str(vr,'%03.f')]),'-dpng','-r300')
%     pause(0.15)
    close(h(vr).fig)
    pause(0.1)
    
      
    
    h(2000+vr).fig = figure(2000+vr);
    set(h(2000+vr).fig,'Position',[50 50 600 500])
    
    pbase = st{vr+2,76};
%     ppost = st{vr+2,13};
    
    plot([0 0],[mn mx],'k-.','LineWidth',3)
    hold on
    x=zeros(1,1);
    y=zeros(1,1);
    bmtagex=zeros(1,1);
    bmtagey=zeros(1,1);
    k=zeros(1,1);
    tpxy=zeros(1,1);
    prgxy=zeros(1,1);
    psx = 1;
    hcx=zeros(1,1);
    hcy=zeros(1,1);
    hck=zeros(1,1);
    hcpsx = 1;
    for ind = 1:size(subid,1)
        pos=subnum==ind;
        tp=type2020(pos);
        tp = tp(1);
        prg=slow_progression(pos);
        prg=prg(1);
        [lns,clr,wd,mrksz]=decide_plot_parameters(tp,prg,show_rapid);
        plot(bmttime(pos),data(pos,vr),lns,'Color',clr,'LineWidth',wd,'MarkerSize',mrksz)
        if sum(pos)==2
            xt=bmttime(pos & selection==1);
            yt=bmttime(pos & selection==2);
            if tp>1
                x(psx,1) = data(pos & selection==1,vr);
                y(psx,1) = data(pos & selection==2,vr);
                bmtagex(psx,1) = bmtage(pos & selection==1);
                bmtagey(psx,1) = bmtage(pos & selection==2);
                kk = polyfit([xt yt],[x(psx,1) y(psx,1)],1);
                k(psx,1)=kk(1);
                tpxy(psx,1) = tp;
                prgxy(psx,1) = prg;
                psx = psx + 1;
            elseif tp == 1           
                hcx(hcpsx,1) = data(pos & selection==1,vr);
                hcy(hcpsx,1) = data(pos & selection==2,vr);
                kk = polyfit([xt yt],[hcx(hcpsx,1) hcy(hcpsx,1)],1);
                hck(hcpsx,1)=kk(1);
                hcpsx = hcpsx + 1;
            end
        end
    end
    hold off
    xlabel('Time from treatment [days]')
    if vr <= 3
        YLBLgraph='Cortical thickness [mm]';
    elseif vr==4 || vr==5
        YLBLgraph='???';
    elseif vr==8 || vr==10
        YLBLgraph='Volume [% of the ROI]';
    elseif (vr>=11 && vr<=72) || vr== 6 || vr==7 || vr==9
        YLBLgraph='Volume [% of Cranial Volume]';
    elseif vr == 73
        YLBLgraph='Volume [mm^3]';
    elseif vr>=74 && vr<=194
        YLBLgraph='Fractional anisotropy';
    elseif vr>=195 && vr<=315
        YLBLgraph='Mean diffusivity [*10^{-9}m^{2}/s]';
    elseif vr>=316 && vr<=343
        YLBLgraph='Axial diffusivity [*10^{-9}m^{2}/s]';
    elseif vr>=344 && vr<=371
        YLBLgraph='Radial diffusivity [*10^{-9}m^{2}/s]';
    elseif vr==372
        YLBLgraph='Loes Score';
    elseif vr>=373 && vr<=375
        YLBLgraph='Volume [% of Brain Volume without Ventricles]';
    elseif vr==378
        YLBLgraph='Visual Reasoning';
    elseif vr==380
        YLBLgraph='Processing Speed';
    elseif vr==385
        YLBLgraph='Visual-Motor Integration';    
    else
        YLBLgraph=data_name{1,vr};
    end
    ylabel(YLBLgraph)
    if ~isempty(x) && ~isempty(y)
        [~, st{vr+2,140}] = ttest(x(tpxy==2),y(tpxy==2));
        [~, st{vr+2,141}] = ttest(x(tpxy==3),y(tpxy==3));
        [~, st{vr+2,142}] = ttest(x(tpxy==2 | tpxy==3),y(tpxy==2 | tpxy==3));
        [~, st{vr+2,143}] = ttest(x(tpxy==4),y(tpxy==4));
        [~, st{vr+2,144}] = ttest(x(tpxy==5),y(tpxy==5));
        [~, st{vr+2,145}] = ttest(x((tpxy==2 | tpxy==3) & prgxy==0),y((tpxy==2 | tpxy==3) & prgxy==0));
        [~, st{vr+2,146}] = ttest(x((tpxy==2 | tpxy==3) & prgxy==1),y((tpxy==2 | tpxy==3) & prgxy==1));
        [~, st{vr+2,147}] = ttest(x((tpxy>=2 & tpxy<=4) & prgxy==0),y((tpxy>=2 & tpxy<=4) & prgxy==0));
        [~, st{vr+2,148}] = ttest(x((tpxy>=2 & tpxy<=4) & prgxy==1),y((tpxy>=2 & tpxy<=4) & prgxy==1));
        [~, st{vr+2,149}] = ttest(x,y);
        [~, st{vr+2,179}] = ttest(x(tpxy==6),y(tpxy==6));
    else
        st{vr+2,140} = 1;
        st{vr+2,141} = 1;
        st{vr+2,142} = 1;
        st{vr+2,143} = 1;
        st{vr+2,144} = 1;
        st{vr+2,145} = 1;
        st{vr+2,146} = 1;
        st{vr+2,147} = 1;
        st{vr+2,148} = 1;
        st{vr+2,149} = 1;
        st{vr+2,179} = 1;
    end
    if ~isempty(hcx) && ~isempty(hcy)
        [~, st{vr+2,150}] = ttest(hcx,hcy);
    else
        st{vr+2,150} = 1;
    end
    if sum(abs(hck))~=0 && sum(abs(k))~=0 && ~isempty(d2020t1pre)
        [~, st{vr+2,151}] = ttest2(hck,k);
        [~, st{vr+2,152}] = ttest2(hck,k(tpxy==2));
        [~, st{vr+2,153}] = ttest2(hck,k(tpxy==3));
        [~, st{vr+2,154}] = ttest2(hck,k(tpxy==2 | tpxy==3));
        [~, st{vr+2,155}] = ttest2(hck,k(tpxy==4));
        [~, st{vr+2,156}] = ttest2(hck,k(tpxy==5));
        [~, st{vr+2,157}] = ttest2(hck,k((tpxy==2 | tpxy==3) & prgxy==0));
        [~, st{vr+2,158}] = ttest2(hck,k((tpxy==2 | tpxy==3) & prgxy==1));
        [~, st{vr+2,159}] = ttest2(hck,k((tpxy>=2 & tpxy<=4) & prgxy==0));
        [~, st{vr+2,160}] = ttest2(hck,k((tpxy>=2 & tpxy<=4) & prgxy==1));
        [~, st{vr+2,180}] = ttest2(hck,k(tpxy==6));
    else
        st{vr+2,151} = 1;
        st{vr+2,152} = 1;
        st{vr+2,153} = 1;
        st{vr+2,154} = 1;
        st{vr+2,155} = 1;
        st{vr+2,156} = 1;
        st{vr+2,157} = 1;
        st{vr+2,158} = 1;
        st{vr+2,159} = 1;
        st{vr+2,160} = 1;
        st{vr+2,180} = 1;
    end
    if sum(abs(k))~=0
        [~, st{vr+2,161}] = ttest2(k((tpxy==2 | tpxy==3) & prgxy==1),k((tpxy==2 | tpxy==3) & prgxy==0));
        [~, st{vr+2,162}] = ttest2(k((tpxy>=2 & tpxy<=4) & prgxy==1),k((tpxy>=2 & tpxy<=4) & prgxy==0));
        [~, st{vr+2,181}] = ttest2(k(tpxy==3),k(tpxy==6));
    else
        st{vr+2,161} = 1;
        st{vr+2,162} = 1;
        st{vr+2,181} = 1;
    end
    [crr, crr_p] = corrcoef([x; y],[bmtagex; bmtagey],'Rows','Pairwise');
    st{vr+2,182} = crr(1,2);
    st{vr+2,183} = crr_p(1,2);
    
%     ppostpaired = st{vr+2,149};
%     text(-140,0.97*mx,'Baseline','FontSize',12);
%     text(-140,0.94*mx,['p=' num2str(pbase,'%.6f')],'FontSize',12);
%     text(150,0.97*mx,'PreBMT vs PostBMT','FontSize',12);
%     text(150,0.94*mx,['p=' num2str(ppostpaired,'%.6f')],'FontSize',12);
    if length(data_name{1,vr})>8 && strcmp(data_name{1,vr}(6:8),'jhu')
        TTLE=st{vr+2,1};
    elseif length(data_name{1,vr})>7 && strcmp(data_name{1,vr}(6:7),'fs')
        TTLE=st{vr+2,1};
    elseif strcmp(data_name{1,vr},'FSIQ')
        TTLE='Full Scale IQ';
    elseif strcmp(data_name{1,vr},'VERBAL')
        TTLE='Verbal Reasoning';
    elseif strcmp(data_name{1,vr},'PERCEPT')
        TTLE='Visual Reasoning';
    elseif strcmp(data_name{1,vr},'WMI')
        TTLE='Working Memory';
    elseif strcmp(data_name{1,vr},'PSI')
        TTLE='Processing Speed';
    elseif strcmp(data_name{1,vr},'Pegs-Ave')
        TTLE='Fine Motor Dexterity';
    elseif strcmp(data_name{1,vr},'WMI')
        TTLE='Visual-Motor Integration';
    else
        TTLE=data_name{1,vr};
    end
    title(TTLE)
    axis([-150 460 mn mx])
    grid on
    set(gca,'FontSize',14,'LineWidth',2)
    
    pause(0.15)
    print(fullfile(save_path,['graph' num2str(2000+vr,'%04.f')]),'-dpng','-r300')
    pause(0.15)
    close(h(2000+vr).fig)
    pause(0.1)
  
    
    h(12000+vr).fig = figure(12000+vr);
    set(h(12000+vr).fig,'Position',[50 50 480 500])
    Yp1 = data(type2020==1 & selection==1,vr);
    Yp2 = data(type2020==2 & selection==1,vr);
    Yp3 = data(type2020==3 & selection==1,vr);
    Yp4 = data(type2020==4 & selection==1,vr);
    Yp5 = data(type2020==5 & selection==1,vr); 
    draw_boxplot_distribution_baseline(Yp1,Yp2,Yp3,Yp4,Yp5,YLBLgraph,TTLE)
    pause(0.15)
    print(fullfile(save_path,['graph' num2str(12000+vr,'%05.f')]),'-dpng','-r300')
    pause(0.15)
    close(h(12000+vr).fig)
    pause(0.1)
    disp(vr)
end

time_stat(1,1) = mean(btwscanshc);
time_stat(1,2) = std(btwscanshc);
time_stat(1,3) = min(btwscanshc);
time_stat(1,4) = max(btwscanshc);

time_stat(2,1) = mean(btwscans);
time_stat(2,2) = std(btwscans);
time_stat(2,3) = min(btwscans);
time_stat(2,4) = max(btwscans)


clear stselect
stvol = [8:10 12 56 59 66:70 72 73 75];
stjhufa = [76:90 93:95];
stfsfa = 175:188;
stjhumd = [189:203 206:208];
stfsmd = 288:301;
strow = [302 3 stvol stjhufa stfsfa stjhumd stfsmd];
stcol = [2 1 36 37 34 35 70 71 68 69 184 185 182 183 ...
    72:2:78 167 80:2:84 169 86 88 177 90 92 171 94 175 96 98 ...
    152 153 155 156 180 151 157 159 158 160:162 ...
    150 149 140:144 179 145 147 146 148 ...
    100:111 163 164 112:119 ...
    120:131 165 166 132:139];
tmp=st(strow,stcol);
stselect=cell(size(tmp,1)+2,size(tmp,2));
stselect{1,1} = 'ROI';
stselect{1,2} = 'Variable type';
stselect{1,3} = 'Loes';
stselect{2,3} = 'corr';
stselect{2,4} = 'p_corr';
stselect{1,5} = 'dLoes';
stselect{2,5} = 'corr';
stselect{2,6} = 'p_corr';
stselect{1,7} = 'LesionVol';
stselect{2,7} = 'corr';
stselect{2,8} = 'p_corr';
stselect{1,9} = 'dLesionVol';
stselect{2,9} = 'corr';
stselect{2,10} = 'p_corr';
stselect{1,11} = 'AgeAtScan';
stselect{2,11} = 'corr';
stselect{2,12} = 'p_corr';
stselect{1,13} = 'BMTage';
stselect{2,13} = 'corr';
stselect{2,14} = 'p_corr';
stselect{1,15} = 'preBMT-ttests2';
stselect{2,15} = '1-2';
stselect{2,16} = '1-3';
stselect{2,17} = '1-4';
stselect{2,18} = '1-5';
stselect{2,19} = '1-6';
stselect{2,20} = '2-3';
stselect{2,21} = '2-4';
stselect{2,22} = '2-5';
stselect{2,23} = '2-6';
stselect{2,24} = '23-4';
stselect{2,25} = '23-5';
stselect{2,26} = '23-6';
stselect{2,27} = '3-4';
stselect{2,28} = '3-5';
stselect{2,29} = '3-6';
stselect{2,30} = '4-5';
stselect{2,31} = '4-6';
stselect{2,32} = '23r-23s';
stselect{2,33} = '234r-234s';
stselect{1,34} = 'Slope-ttests2';
stselect{2,34} = '1-2';
stselect{2,35} = '1-3';
stselect{2,36} = '1-4';
stselect{2,37} = '1-5';
stselect{2,38} = '1-6';
stselect{2,39} = '1-all';
stselect{2,40} = '1-23r';
stselect{2,41} = '1-234r';
stselect{2,42} = '1-23s';
stselect{2,43} = '1-234s';
stselect{2,44} = '23r-23s';
stselect{2,45} = '234r-234s';
stselect{1,46} = 'Paired-ttest-prepostbmt';
stselect{2,46} = 'nolesion';
stselect{2,47} = 'alllesion';
stselect{2,48} = '2';
stselect{2,49} = '3';
stselect{2,50} = '23';
stselect{2,51} = '4';
stselect{2,52} = '5';
stselect{2,53} = '6';
stselect{2,54} = '23r';
stselect{2,55} = '234r';
stselect{2,56} = '23s';
stselect{2,57} = '234s';
stselect{1,58} = '1-baseline';
stselect{2,58} = 'mean';
stselect{2,59} = 'std';
stselect{1,60} = '2-baseline';
stselect{2,60} = 'mean';
stselect{2,61} = 'std';
stselect{1,62} = '3-baseline';
stselect{2,62} = 'mean';
stselect{2,63} = 'std';
stselect{1,64} = '23-baseline';
stselect{2,64} = 'mean';
stselect{2,65} = 'std';
stselect{1,66} = '4-baseline';
stselect{2,66} = 'mean';
stselect{2,67} = 'std';
stselect{1,68} = '5-baseline';
stselect{2,68} = 'mean';
stselect{2,69} = 'std';
stselect{1,70} = '6-baseline';
stselect{2,70} = 'mean';
stselect{2,71} = 'std';
stselect{1,72} = '23r-baseline';
stselect{2,72} = 'mean';
stselect{2,73} = 'std';
stselect{1,74} = '23s-baseline';
stselect{2,74} = 'mean';
stselect{2,75} = 'std';
stselect{1,76} = '234r-baseline';
stselect{2,76} = 'mean';
stselect{2,77} = 'std';
stselect{1,78} = '234s-baseline';
stselect{2,78} = 'mean';
stselect{2,79} = 'std';
stselect{1,80} = '1-followup';
stselect{2,80} = 'mean';
stselect{2,81} = 'std';
stselect{1,82} = '2-followup';
stselect{2,82} = 'mean';
stselect{2,83} = 'std';
stselect{1,84} = '3-followup';
stselect{2,84} = 'mean';
stselect{2,85} = 'std';
stselect{1,86} = '23-followup';
stselect{2,86} = 'mean';
stselect{2,87} = 'std';
stselect{1,88} = '4-followup';
stselect{2,88} = 'mean';
stselect{2,89} = 'std';
stselect{1,90} = '5-followup';
stselect{2,90} = 'mean';
stselect{2,91} = 'std';
stselect{1,92} = '6-followup';
stselect{2,92} = 'mean';
stselect{2,93} = 'std';
stselect{1,94} = '23r-followup';
stselect{2,94} = 'mean';
stselect{2,95} = 'std';
stselect{1,96} = '23s-followup';
stselect{2,96} = 'mean';
stselect{2,97} = 'std';
stselect{1,98} = '234r-followup';
stselect{2,98} = 'mean';
stselect{2,99} = 'std';
stselect{1,100} = '234s-followup';
stselect{2,100} = 'mean';
stselect{2,101} = 'std';

stselect(3:end,1:end)=tmp;
stselect(3,2) = stselect(3,1);
stselect{4,2} = 'Thickness';
for ind = 5:18
    stselect{ind,2} = 'Volume';
end
tmp = stselect(19:end,1);
stselect(19:end,1) = stselect(19:end,2);
stselect(19:end,2) = tmp;
clear tmp

h(1).fig = figure(1);
set(h(1).fig,'Position',[50 50 600 500])
plot([-5 5],[3 3],':^','Color',[0 0 1],'LineWidth',3,'MarkerSize',15)
hold on
scatter(-0,3,200,'ko','LineWidth',3)
scatter(-0,3,200,'kx','LineWidth',3)
plot([-5 5],[3 3],':','Color',[1 1 1]*0.5,'LineWidth',3,'MarkerSize',15)
plot([-5 5],[3 3],':','Color',[1 0 0],'LineWidth',3,'MarkerSize',15)
plot([0 0],[mn mx],'k-.','LineWidth',3)
hold off
legend('No lesion',...
    'Early disease',...
    'Advanced disease',...
    'Slow progression',...
    'Rapid progression',...
    'Treatment day')
set(gca,'FontSize',18,'LineWidth',2)
axis([6 12 5 10])
axis off
pause(0.15)
% print(fullfile(save_path,['00000_legend']),'-dpng','-r300')
% pause(0.15)
close(h(1).fig)
pause(0.1)


h(1).fig = figure(1);
set(h(1).fig,'Position',[50 50 600 500])
plot([-5 5],[3 3],':o','Color',[0 0 1],'LineWidth',3,'MarkerSize',7)
hold on
if show_rapid == 1
    plot([-5 5],[3 3],':','Color',[253, 218, 13]/255,'LineWidth',3,'MarkerSize',10)
    plot([-5 5],[3 3],':','Color',[0 1 0],'LineWidth',3,'MarkerSize',10)
    plot([-5 5],[3 3],':','Color',[1 0 1],'LineWidth',3,'MarkerSize',10)
    plot([-5 5],[3 3],':','Color',[0 1 1],'LineWidth',3,'MarkerSize',10)
    plot([-5 5],[3 3],':','Color',[1 1 1]*0.5,'LineWidth',3,'MarkerSize',10)
    plot([-5 5],[3 3],':','Color',[1 0 0],'LineWidth',3,'MarkerSize',10)
    scatter(-0,3,200,'k^','LineWidth',3)
    scatter(-0,3,200,'kx','LineWidth',3)
else
    plot([-5 5],[3 3],':^','Color',[253, 218, 13]/255,'LineWidth',3,'MarkerSize',10)
    plot([-5 5],[3 3],':x','Color',[0 1 0],'LineWidth',3,'MarkerSize',10)
    plot([-5 5],[3 3],':d','Color',[1 0 1],'LineWidth',3,'MarkerSize',10)
    plot([-5 5],[3 3],':s','Color',[0 1 1],'LineWidth',3,'MarkerSize',10)
    plot([-5 5],[3 3],':p','Color',[1 1 1]*0.5,'LineWidth',3,'MarkerSize',10)
    plot([-5 5],[3 3],':v','Color',[1 0 0],'LineWidth',3,'MarkerSize',10)
end
plot([0 0],[3 3],'k-.','LineWidth',3)
hold off
if show_rapid == 1
    legend('Loes 0, no lesion, no treatment',...
        'Loes 0.5-2; posterior',...
        'Loes 2.5-4.5; posterior',...
        'Loes 2.5-4.5; atypical',...
        'Loes 2.5-4.5; frontal',...
        'Loes 5-8.5; posterior',...
        'Loes \geq 9; posterior',...
        'Slow progression',...
        'Rapid progression',...
        'Treatment day')
else
    legend('Loes 0, no lesion, no treatment',...
        'Loes 0.5-2; posterior',...
        'Loes 2.5-4.5; posterior',...
        'Loes 2.5-4.5; atypical',...
        'Loes 2.5-4.5; frontal',...
        'Loes 5-8.5; posterior',...
        'Loes \geq 9; posterior',...
        'Treatment day')
end
set(gca,'FontSize',18,'LineWidth',2)
axis([6 12 5 10])
axis off
pause(0.15)
if show_rapid == 1
    print(fullfile(save_path,['00000_legend2020']),'-dpng','-r300')
else
    print(fullfile(save_path,['00000_legend2020_noprogress']),'-dpng','-r300')
end
pause(0.15)
close(h(1).fig)
pause(0.1)



function [vec1,vec1_slope,vec1_stat,vec1_info] = extract_measures(vec,type2020,selection,grp,bmttime,loes,dmrivoxelvol,slow_progression,neuropsych,neuropsych_name,age)
    vec1(:,1) = vec(type2020==grp & selection==1);
    vec1(:,2) = vec(type2020==grp & selection==2);
    vec1_time(:,1) = bmttime(type2020==grp & selection==1);
    vec1_time(:,2) = bmttime(type2020==grp & selection==2);
    vec1_slope = zeros(size(vec1,1),1);
    for psx = 1:size(vec1,1)
        kk = polyfit(vec1_time(psx,:),vec1(psx,:),1);
        vec1_slope(psx,1)=kk(1)*365.25;
    end
    
    lscore(:,1) = loes(type2020==grp & selection==1);
    lscore(:,2) = loes(type2020==grp & selection==2);
    
    vxvol(:,1) = dmrivoxelvol(type2020==grp & selection==1);
    vxvol(:,2) = dmrivoxelvol(type2020==grp & selection==2);
    
    slprg(:,1) = slow_progression(type2020==grp & selection==1);
    slprg(:,2) = slow_progression(type2020==grp & selection==2);
    
    tp2020(:,1) = type2020(type2020==grp & selection==1);
    tp2020(:,2) = type2020(type2020==grp & selection==2);
    
    neupsch(:,:,1) = neuropsych(type2020==grp & selection==1,:);
    neupsch(:,:,2) = neuropsych(type2020==grp & selection==2,:);
    
    ag(:,1) = age(type2020==grp & selection==1);
    ag(:,2) = age(type2020==grp & selection==2);
    
    vec1_stat = mean(vec1,'omitnan')';
    vec1_stat(:,2) = std(vec1,'omitnan')';
    vec1_stat(3,1) = mean(vec1_slope,'omitnan');
    vec1_stat(3,2) = std(vec1_slope,'omitnan');
    
    vec1_info.age = ag;
    vec1_info.loes = lscore;
    vec1_info.dmrivoxelvol = vxvol;
    vec1_info.slow_progression = slprg;
    vec1_info.type2020 = tp2020;
    vec1_info.time = vec1_time;
    vec1_info.neuropsych = neupsch;
    vec1_info.neuropsych_name = neuropsych_name;
end


function slope = reorder_slope(slope,vec_slope,subnum,selection,type,grp,idx,sess_pos)
    type_pos = subnum(selection==1 & type==grp);
    for sbx = 1:size(type_pos,1)
        rx = sess_pos==type_pos(sbx,1);
        slope(rx,idx) = vec_slope(sbx,1);
    end
end

function p_ancova = eval_ancova(vec1,vec2,confounder1,confounder2,measure_type)
    group = [zeros(size(vec1,1),1); ones(size(vec2,1),1)];
    if strcmp(measure_type,'pre')
        confounder = [confounder1(:,1); confounder2(:,1)];
    elseif strcmp(measure_type,'slope')
        confounder = [mean(confounder1,2); mean(confounder2,2)];
    end
    p_tmp = anovan([vec1(:,1);vec2(:,1)],{group,confounder},'Continuous',2,'varnames',{'Group','confounder'},'display','off');
    p_ancova= p_tmp(1);
end

function p_ancova = eval_ancova_with_age(vec1,vec2,confounder1,confounder2,measure_type,age1,age2)
    group = [zeros(size(vec1,1),1); ones(size(vec2,1),1)];
    if strcmp(measure_type,'pre')
        confounder = [confounder1(:,1); confounder2(:,1)];
        age = [age1(:,1); age2(:,1)];
    elseif strcmp(measure_type,'slope')
        confounder = [mean(confounder1,2); mean(confounder2,2)];
        age = [mean(age1,2); mean(age2,2)];
    end
    p_tmp = anovan([vec1(:,1);vec2(:,1)],{group,confounder,age},'Continuous',[2 3],'varnames',{'Group','Confounder','Age'},'display','off');
    p_ancova= p_tmp(1);
end

function [lns,clr,wd,mrksz]=decide_plot_parameters(tp,prg,show_rapid)
    if show_rapid == 1
        if tp==1
            lns = ':o';
            clr = [0 0 1];
            wd = 2;
            mrksz = 5;
        elseif tp == 2 && prg==1
            lns = ':^';
            clr = [253, 218, 13]/255;
            wd = 2;
            mrksz = 7;
        elseif tp == 2 && prg==0
            lns = ':x';
            clr = [253, 218, 13]/255;
            wd = 2;
            mrksz = 7;
        elseif tp == 3 && prg==1
            lns = ':^';
            clr = [0 1 0];
            wd = 2;
            mrksz = 7;
        elseif tp == 3 && prg==0
            lns = ':x';
            clr = [0 1 0];
            wd = 2;
            mrksz = 7;
        elseif tp == 6 && prg==1
            lns = ':^';
            clr = [1 0 1];
            wd = 2;
            mrksz = 7;
        elseif tp == 6 && prg==0
            lns = ':x';
            clr = [1 0 1];
            wd = 2;
            mrksz = 7;
        elseif tp == 7 && prg==1
            lns = ':^';
            clr = [0 1 1];
            wd = 2;
            mrksz = 7;
        elseif tp == 7 && prg==0
            lns = ':x';
            clr = [0 1 1];
            wd = 2;
            mrksz = 7;
        elseif tp == 4 && prg==1
            lns = ':^';
            clr = [1 1 1]*0.5;
            wd = 2;
            mrksz = 7;
        elseif tp == 4 && prg==0
            lns = ':x';
            clr = [1 1 1]*0.5;
            wd = 2;
            mrksz = 7;
        elseif tp == 5 && prg==1
            lns = ':^';
            clr = [1 0 0];
            wd = 2;
            mrksz = 7;
        elseif tp == 5 && prg==0
            lns = ':x';
            clr = [1 0 0];
            wd = 2;
            mrksz = 7;
        end
    else
        if tp==1
            lns = ':o';
            clr = [0 0 1];
            wd = 2;
            mrksz = 5;
        elseif tp == 2
            lns = ':^';
            clr = [253, 218, 13]/255;
            wd = 2;
            mrksz = 7;
        elseif tp == 3 
            lns = ':x';
            clr = [0 1 0];
            wd = 2;
            mrksz = 7;
        elseif tp == 6
            lns = ':d';
            clr = [1 0 1];
            wd = 2;
            mrksz = 7;
        elseif tp == 7
            lns = ':s';
            clr = [0 1 1];
            wd = 2;
            mrksz = 7;
        elseif tp == 4
            lns = ':p';
            clr = [1 1 1]*0.5;
            wd = 2;
            mrksz = 7;
        elseif tp == 5
            lns = ':v';
            clr = [1 0 0];
            wd = 2;
            mrksz = 7;
        end
    end
end


function draw_scatter_corr(neuropsych_draw,neuropsych_order,sbplid,vec1,vec2,vec3,vec4,vec5,vec6,vec7,vec1_info,vec2_info,vec3_info,vec4_info,vec5_info,vec6_info,vec7_info,xlbl,include_advanced,show_rapid)
    if strcmp(neuropsych_order,'xpre-ypost')
        xid = 1;
        yid = 2;
    elseif strcmp(neuropsych_order,'xpre-ypre')
        xid = 1;
        yid = 1;
    elseif strcmp(neuropsych_order,'trend')
        xid = [1 2];
        yid = [1 2];
    end
    if contains(neuropsych_order,'xpre')
        xtrt = 'pre';
    end
    if contains(neuropsych_order,'ypre')
        ytrt = 'pre';
    end
    if contains(neuropsych_order,'ypost')
        ytrt = 'post';
    end
    
    xtick = [];
    if strcmp(xlbl(1:2),'FA') || strcmp(xlbl(1:2),'MD') || strcmp(xlbl(1:2),'RD') || strcmp(xlbl(1:2),'AD')
        dti=xlbl(1:2);
        xlbl = xlbl([1:4 11:end]);
        if strcmp(dti,'FA')
            dti_text = 'Fractional Anisotropy';
            if contains(xlbl,'White') || contains(xlbl,'Corticospinal')
                step = 0.02;
            else
                step = 0.05;
            end
            xtick = 0:step:1;
        elseif strcmp(dti,'MD')
            dti_text = 'Mean Diffusivity';
        elseif strcmp(dti,'RD')
            dti_text = 'Radial Diffusivity';
        elseif strcmp(dti,'AD')
            dti_text = 'Axial Diffusivity';
        end
        if ~strcmp(dti,'FA')
            if contains(xlbl,'Splenium')
                step=0.2;
            elseif contains(xlbl,'White') || contains(xlbl,'Corticospinal')
                step=0.05;
            else
                step=0.1;
            end
            xtick=0:step:3;
        end           
    else
        dti=''; 
    end
    if strcmp(xlbl,'Loes Score')
        xtick=0:2:30;
    end
    
    if include_advanced == 1
        xdata = [vec1(:,xid); vec2(:,xid); vec3(:,xid); vec4(:,xid); vec5(:,xid); vec6(:,xid); vec7(:,xid)];
        ydata = squeeze([vec1_info.neuropsych(:,strcmp(vec1_info.neuropsych_name,neuropsych_draw),yid);...
            vec2_info.neuropsych(:,strcmp(vec2_info.neuropsych_name,neuropsych_draw),yid);...
            vec3_info.neuropsych(:,strcmp(vec3_info.neuropsych_name,neuropsych_draw),yid);...
            vec4_info.neuropsych(:,strcmp(vec4_info.neuropsych_name,neuropsych_draw),yid);...
            vec5_info.neuropsych(:,strcmp(vec5_info.neuropsych_name,neuropsych_draw),yid);...
            vec6_info.neuropsych(:,strcmp(vec6_info.neuropsych_name,neuropsych_draw),yid);...
            vec7_info.neuropsych(:,strcmp(vec7_info.neuropsych_name,neuropsych_draw),yid)]);
    else
        xdata = [vec1(:,xid); vec2(:,xid); vec3(:,xid); vec6(:,xid); vec7(:,xid)];
        ydata = squeeze([vec1_info.neuropsych(:,strcmp(vec1_info.neuropsych_name,neuropsych_draw),yid);...
            vec2_info.neuropsych(:,strcmp(vec2_info.neuropsych_name,neuropsych_draw),yid);...
            vec3_info.neuropsych(:,strcmp(vec3_info.neuropsych_name,neuropsych_draw),yid);...
            vec6_info.neuropsych(:,strcmp(vec6_info.neuropsych_name,neuropsych_draw),yid);...
            vec7_info.neuropsych(:,strcmp(vec7_info.neuropsych_name,neuropsych_draw),yid)]);
    end
    
    if ~strcmp(neuropsych_order,'trend')
        nonan = ~isnan(xdata) & ~isnan(ydata);
        xdata = xdata(nonan);
        ydata = ydata(nonan);
        [r, p] = corrcoef(xdata,ydata);r=r(1,2);p=p(1,2);

        minx=min(xdata);
        maxx=max(xdata);
        miny=min(ydata);
        maxy=max(ydata);
        x = [minx maxx];

        c = polyfit(xdata,ydata,1);
        y = c(1)*x + c(2);

        subplot(2,3,sbplid)
        plot(x,y,'k-.','LineWidth',5)
        hold on
        if show_rapid == 1 
            plot(vec2(vec2_info.slow_progression(:,xid)==1,xid),vec2_info.neuropsych(vec2_info.slow_progression(:,yid)==1,strcmp(vec2_info.neuropsych_name,neuropsych_draw),yid),'^','Color',[253, 218, 13]/255,'LineWidth',4,'MarkerSize',18)
            plot(vec2(vec2_info.slow_progression(:,xid)==0,xid),vec2_info.neuropsych(vec2_info.slow_progression(:,yid)==0,strcmp(vec2_info.neuropsych_name,neuropsych_draw),yid),'x','Color',[253, 218, 13]/255,'LineWidth',4,'MarkerSize',18)
            plot(vec3(vec3_info.slow_progression(:,xid)==1,xid),vec3_info.neuropsych(vec3_info.slow_progression(:,yid)==1,strcmp(vec3_info.neuropsych_name,neuropsych_draw),yid),'^','Color',[0 1 0],'LineWidth',4,'MarkerSize',18)
            plot(vec3(vec3_info.slow_progression(:,xid)==0,xid),vec3_info.neuropsych(vec3_info.slow_progression(:,yid)==0,strcmp(vec3_info.neuropsych_name,neuropsych_draw),yid),'x','Color',[0 1 0],'LineWidth',4,'MarkerSize',18)
            if include_advanced == 1
                plot(vec4(vec4_info.slow_progression(:,xid)==1,xid),vec4_info.neuropsych(vec4_info.slow_progression(:,yid)==1,strcmp(vec4_info.neuropsych_name,neuropsych_draw),yid),'^','Color',[1 1 1]*0.5,'LineWidth',4,'MarkerSize',18)
                plot(vec4(vec4_info.slow_progression(:,xid)==0,xid),vec4_info.neuropsych(vec4_info.slow_progression(:,yid)==0,strcmp(vec4_info.neuropsych_name,neuropsych_draw),yid),'x','Color',[1 1 1]*0.5,'LineWidth',4,'MarkerSize',18)
                plot(vec5(vec5_info.slow_progression(:,xid)==1,xid),vec5_info.neuropsych(vec5_info.slow_progression(:,yid)==1,strcmp(vec5_info.neuropsych_name,neuropsych_draw),yid),'^','Color',[1 0 0],'LineWidth',4,'MarkerSize',18)
                plot(vec5(vec5_info.slow_progression(:,xid)==0,xid),vec5_info.neuropsych(vec5_info.slow_progression(:,yid)==0,strcmp(vec5_info.neuropsych_name,neuropsych_draw),yid),'x','Color',[1 0 0],'LineWidth',4,'MarkerSize',18)
            end
            plot(vec6(vec6_info.slow_progression(:,xid)==1,xid),vec6_info.neuropsych(vec6_info.slow_progression(:,yid)==1,strcmp(vec6_info.neuropsych_name,neuropsych_draw),yid),'^','Color',[1 0 1],'LineWidth',4,'MarkerSize',18)
            plot(vec6(vec6_info.slow_progression(:,xid)==0,xid),vec6_info.neuropsych(vec6_info.slow_progression(:,yid)==0,strcmp(vec6_info.neuropsych_name,neuropsych_draw),yid),'x','Color',[1 0 1],'LineWidth',4,'MarkerSize',18)
            plot(vec7(vec7_info.slow_progression(:,xid)==1,xid),vec7_info.neuropsych(vec7_info.slow_progression(:,yid)==1,strcmp(vec7_info.neuropsych_name,neuropsych_draw),yid),'^','Color',[0 1 1],'LineWidth',4,'MarkerSize',18)
            plot(vec7(vec7_info.slow_progression(:,xid)==0,xid),vec7_info.neuropsych(vec7_info.slow_progression(:,yid)==0,strcmp(vec7_info.neuropsych_name,neuropsych_draw),yid),'x','Color',[0 1 1],'LineWidth',4,'MarkerSize',18)
            plot(vec1(vec1_info.slow_progression(:,xid)==1,xid),vec1_info.neuropsych(vec1_info.slow_progression(:,yid)==1,strcmp(vec1_info.neuropsych_name,neuropsych_draw),yid),'^','Color',[0 0 1],'LineWidth',4,'MarkerSize',18)
            plot(vec1(vec1_info.slow_progression(:,xid)==0,xid),vec1_info.neuropsych(vec1_info.slow_progression(:,yid)==0,strcmp(vec1_info.neuropsych_name,neuropsych_draw),yid),'x','Color',[0 0 1],'LineWidth',4,'MarkerSize',18)
        else
            plot(vec2(vec2_info.slow_progression(:,xid)==1,xid),vec2_info.neuropsych(vec2_info.slow_progression(:,yid)==1,strcmp(vec2_info.neuropsych_name,neuropsych_draw),yid),'^','Color',[253, 218, 13]/255,'LineWidth',4,'MarkerSize',18)
            plot(vec2(vec2_info.slow_progression(:,xid)==0,xid),vec2_info.neuropsych(vec2_info.slow_progression(:,yid)==0,strcmp(vec2_info.neuropsych_name,neuropsych_draw),yid),'^','Color',[253, 218, 13]/255,'LineWidth',4,'MarkerSize',18)
            plot(vec3(vec3_info.slow_progression(:,xid)==1,xid),vec3_info.neuropsych(vec3_info.slow_progression(:,yid)==1,strcmp(vec3_info.neuropsych_name,neuropsych_draw),yid),'x','Color',[0 1 0],'LineWidth',4,'MarkerSize',18)
            plot(vec3(vec3_info.slow_progression(:,xid)==0,xid),vec3_info.neuropsych(vec3_info.slow_progression(:,yid)==0,strcmp(vec3_info.neuropsych_name,neuropsych_draw),yid),'x','Color',[0 1 0],'LineWidth',4,'MarkerSize',18)
            if include_advanced == 1
                plot(vec4(vec4_info.slow_progression(:,xid)==1,xid),vec4_info.neuropsych(vec4_info.slow_progression(:,yid)==1,strcmp(vec4_info.neuropsych_name,neuropsych_draw),yid),'p','Color',[1 1 1]*0.5,'LineWidth',4,'MarkerSize',18)
                plot(vec4(vec4_info.slow_progression(:,xid)==0,xid),vec4_info.neuropsych(vec4_info.slow_progression(:,yid)==0,strcmp(vec4_info.neuropsych_name,neuropsych_draw),yid),'p','Color',[1 1 1]*0.5,'LineWidth',4,'MarkerSize',18)
                plot(vec5(vec5_info.slow_progression(:,xid)==1,xid),vec5_info.neuropsych(vec5_info.slow_progression(:,yid)==1,strcmp(vec5_info.neuropsych_name,neuropsych_draw),yid),'v','Color',[1 0 0],'LineWidth',4,'MarkerSize',18)
                plot(vec5(vec5_info.slow_progression(:,xid)==0,xid),vec5_info.neuropsych(vec5_info.slow_progression(:,yid)==0,strcmp(vec5_info.neuropsych_name,neuropsych_draw),yid),'v','Color',[1 0 0],'LineWidth',4,'MarkerSize',18)
            end
            plot(vec6(vec6_info.slow_progression(:,xid)==1,xid),vec6_info.neuropsych(vec6_info.slow_progression(:,yid)==1,strcmp(vec6_info.neuropsych_name,neuropsych_draw),yid),'d','Color',[1 0 1],'LineWidth',4,'MarkerSize',18)
            plot(vec6(vec6_info.slow_progression(:,xid)==0,xid),vec6_info.neuropsych(vec6_info.slow_progression(:,yid)==0,strcmp(vec6_info.neuropsych_name,neuropsych_draw),yid),'d','Color',[1 0 1],'LineWidth',4,'MarkerSize',18)
            plot(vec7(vec7_info.slow_progression(:,xid)==1,xid),vec7_info.neuropsych(vec7_info.slow_progression(:,yid)==1,strcmp(vec7_info.neuropsych_name,neuropsych_draw),yid),'s','Color',[0 1 1],'LineWidth',4,'MarkerSize',18)
            plot(vec7(vec7_info.slow_progression(:,xid)==0,xid),vec7_info.neuropsych(vec7_info.slow_progression(:,yid)==0,strcmp(vec7_info.neuropsych_name,neuropsych_draw),yid),'s','Color',[0 1 1],'LineWidth',4,'MarkerSize',18)
            plot(vec1(vec1_info.slow_progression(:,xid)==1,xid),vec1_info.neuropsych(vec1_info.slow_progression(:,yid)==1,strcmp(vec1_info.neuropsych_name,neuropsych_draw),yid),'o','Color',[0 0 1],'LineWidth',4,'MarkerSize',18)
            plot(vec1(vec1_info.slow_progression(:,xid)==0,xid),vec1_info.neuropsych(vec1_info.slow_progression(:,yid)==0,strcmp(vec1_info.neuropsych_name,neuropsych_draw),yid),'o','Color',[0 0 1],'LineWidth',4,'MarkerSize',18)
        end
        hold off
        
        if ~isempty(dti) && sbplid == 2
            title({['Correlation between ' xtrt '-treatment ' dti_text ' and ' ytrt '-treatment ' neuropsych_draw],' '})
        elseif strcmp(xlbl,'Cerebral White Matter Volume [% of Cranial Volume]') && sbplid == 2
            title({['Correlation between ' xtrt '-treatment cerebral morphology and ' ytrt '-treatment ' neuropsych_draw],' '})
        elseif strcmp(xlbl,'Loes Score') && sbplid == 2
            title({['Correlation between ' xtrt '-treatment ' xlbl ' and ' ytrt '-treatment Neuropsychological Testing'],' '})
        end
        
    else
        minx = min(xdata(:));
        maxx = max(xdata(:));
        miny = min(ydata(:));
        maxy = max(ydata(:));
        
        xdata_mean = mean(xdata,2,'omitnan');
        ydata_mean = mean(ydata,2,'omitnan');
        
        nonan = ~isnan(xdata_mean) & ~isnan(ydata_mean);
        xdata_mean = xdata_mean(nonan);
        ydata_mean = ydata_mean(nonan);
        
        [r, p] = corrcoef(xdata_mean,ydata_mean);r=r(1,2);p=p(1,2);
        
        x = [minx maxx];

        c = polyfit(xdata_mean,ydata_mean,1);
        y = c(1)*x + c(2);
        
        subplot(2,3,sbplid)
        plot(x,y,'k-.','LineWidth',5)
        hold on
        plot(vec2(1,xid),squeeze(vec2_info.neuropsych(1,strcmp(vec2_info.neuropsych_name,neuropsych_draw),yid)),':','Color',[253, 218, 13]/255,'LineWidth',3)
        plot(vec1(:,1),vec1_info.neuropsych(:,strcmp(vec1_info.neuropsych_name,neuropsych_draw),1),'o','Color',[0 0 1],'LineWidth',3,'MarkerSize',10)
        for sb = 2:size(vec2,1)
            plot(vec2(sb,xid),squeeze(vec2_info.neuropsych(sb,strcmp(vec2_info.neuropsych_name,neuropsych_draw),yid)),':','Color',[253, 218, 13]/255,'LineWidth',3)
        end
        for sb = 1:size(vec3,1)
            plot(vec3(sb,xid),squeeze(vec3_info.neuropsych(sb,strcmp(vec3_info.neuropsych_name,neuropsych_draw),yid)),':','Color',[0 1 0],'LineWidth',3)
        end
        if include_advanced == 1
            for sb = 1:size(vec4,1)
                plot(vec4(sb,xid),squeeze(vec4_info.neuropsych(sb,strcmp(vec4_info.neuropsych_name,neuropsych_draw),yid)),':','Color',[1 1 1]*0.5,'LineWidth',3)
            end
            for sb = 1:size(vec5,1)
                plot(vec5(sb,xid),squeeze(vec5_info.neuropsych(sb,strcmp(vec5_info.neuropsych_name,neuropsych_draw),yid)),':','Color',[1 0 0],'LineWidth',3)
            end
        end
        for sb = 1:size(vec6,1)
            plot(vec6(sb,xid),squeeze(vec6_info.neuropsych(sb,strcmp(vec6_info.neuropsych_name,neuropsych_draw),yid)),':','Color',[1 0 1],'LineWidth',3)
        end
        for sb = 1:size(vec7,1)
            plot(vec7(sb,xid),squeeze(vec7_info.neuropsych(sb,strcmp(vec7_info.neuropsych_name,neuropsych_draw),yid)),':','Color',[0 1 1],'LineWidth',3)
        end
        plot(vec2(:,2),vec2_info.neuropsych(:,strcmp(vec2_info.neuropsych_name,neuropsych_draw),2),'^','Color',[253, 218, 13]/255,'LineWidth',3,'MarkerSize',10)
        plot(vec3(:,2),vec3_info.neuropsych(:,strcmp(vec3_info.neuropsych_name,neuropsych_draw),2),'^','Color',[0 1 0],'LineWidth',3,'MarkerSize',10)
        if include_advanced == 1
            plot(vec4(:,2),vec4_info.neuropsych(:,strcmp(vec4_info.neuropsych_name,neuropsych_draw),2),'^','Color',[1 1 1]*0.5,'LineWidth',3,'MarkerSize',10)
            plot(vec5(:,2),vec5_info.neuropsych(:,strcmp(vec5_info.neuropsych_name,neuropsych_draw),2),'^','Color',[1 0 0],'LineWidth',3,'MarkerSize',10)
        end
        plot(vec6(:,2),vec6_info.neuropsych(:,strcmp(vec6_info.neuropsych_name,neuropsych_draw),2),'^','Color',[1 0 1],'LineWidth',3,'MarkerSize',10)
        plot(vec7(:,2),vec7_info.neuropsych(:,strcmp(vec7_info.neuropsych_name,neuropsych_draw),2),'^','Color',[0 1 1],'LineWidth',3,'MarkerSize',10)
        hold off
    end
    axis([minx maxx miny maxy])
    xlabel(xlbl)
    
    if strcmp(xlbl,'Loes Score') || sbplid == 1 || sbplid == 4
        ylabel(neuropsych_draw)
    end 
    
    if r(1)>0
        if miny>140
            coefy1 = 1.025;
        elseif maxy>110 && miny>40
            coefy1 = 1.10;
        elseif maxy>100 && miny>5
            coefy1 = 1.60;
        else
            coefy1 = 1.05;
        end
    elseif r(1)<=0
        if maxy<5
            coefy1 = 0.10;
        elseif miny>25
            coefy1 = 0.10;
        elseif maxy>100 && miny>5
            coefy1 = 0.60;
        else
            coefy1 = 0.08;
        end
    else
        coefy1 = 0.05;
    end
    if p(1) < 0.05
        set(gca,'Color',[255 255 240]/255)
        if r(1)>0
            txty = coefy1*miny;
        else
            txty = maxy - coefy1*miny;
        end
        if p(1) < 0.0001
            text(0.99*maxx,txty,['r=' num2str(r(1),'%.3f') '; p<0.0001'],'HorizontalAlignment','right','FontWeight','bold','FontSize',20)
        else
            text(0.99*maxx,txty,['r=' num2str(r(1),'%.3f') '; p=' num2str(p(1),'%.4f')],'HorizontalAlignment','right','FontWeight','bold','FontSize',20)
        end
    end
    
    grid on
    if ~isempty(xtick)
        set(gca,'XTick',xtick,'XTickLabel',xtick)
    end
    set(gca,'LineWidth',3,'FontSize',20)
    pause(0.01)
end

function [rho, p_rho] = estimate_partial_corr(vec2,vec3,vec4,vec5,vec6,vec7,vec2_info,vec3_info,vec4_info,vec5_info,vec6_info,vec7_info,include_advanced)
    rho = zeros(1,size(vec2_info.neuropsych,2));
    p_rho = zeros(1,size(vec2_info.neuropsych,2));
    for nind = 1:size(vec2_info.neuropsych,2)
        if include_advanced == 1
            xpre = [vec2(:,1); vec3(:,1); vec4(:,1); vec5(:,1); vec6(:,1); vec7(:,1)];
            ndata = squeeze([vec2_info.neuropsych(:,nind,:);...
                vec3_info.neuropsych(:,nind,:);...
                vec4_info.neuropsych(:,nind,:);...
                vec5_info.neuropsych(:,nind,:);...
                vec6_info.neuropsych(:,nind,:);...
                vec7_info.neuropsych(:,nind,:)]);
        else
            xpre = [vec2(:,1); vec3(:,1); vec6(:,1); vec7(:,1)];
            ndata = squeeze([vec2_info.neuropsych(:,nind,:);...
                vec3_info.neuropsych(:,nind,:);...
                vec6_info.neuropsych(:,nind,:);...
                vec7_info.neuropsych(:,nind,:)]);
        end
        
        [r,p] = partialcorr([xpre, ndata(:,2)],ndata(:,1),'Rows','pairwise');
        rho(1,nind) = r(1,2);
        p_rho(1,nind) = p(1,2);
    end
end

function st = stat_table_correction(st)
    vol_begin = find(strcmp(st(:,1),'Cortex Volume [% of Cranial Volume]')==1);
    vol_end = find(strcmp(st(:,1),'Basal Ganglia Volume [% of Cranial Volume]')==1);
    thick_begin = find(strcmp(st(:,1),'Cortical Thickness [mm]')==1);
    dti_begin = find(strcmp(st(:,1),'FA - JHU - White Matter')==1);
    dti_end = find(strcmp(st(:,1),'AD - JHU - Corticospinal Tract')==1);
    dtinolesion_begin = find(strcmp(st(:,1),'FA - JHU - White Matter without Lesion')==1);
    dtinolesion_end = find(strcmp(st(:,1),'AD - JHU - Corticospinal Tract without Lesion')==1);
    
    pre_begin = find(strcmp(st(2,:),'pre-G1vsG2')==1);
    pre_end = find(strcmp(st(2,:),'pre-G1vsG4')==1);
    pre_wilcox_begin = pre_begin(1);
    pre_wilcox_end = pre_end(1);
    pre_ancova_begin = pre_begin(2);
    pre_ancova_end = pre_end(2);
    
    slope_begin = find(strcmp(st(2,:),'slope-G1vsG2')==1);
    slope_end = find(strcmp(st(2,:),'slope-G1vsG4')==1);
    slope_wilcox_begin = slope_begin(1);
    slope_wilcox_end = slope_end(1);
    slope_ancova_begin = slope_begin(2);
    slope_ancova_end = slope_end(2);
    
    st = correct_table(st,vol_begin,vol_end,pre_wilcox_begin,pre_wilcox_end);
    st = correct_table(st,vol_begin,vol_end,slope_wilcox_begin,slope_wilcox_end);
    
    st = correct_table(st,thick_begin,thick_begin,pre_wilcox_begin,pre_wilcox_end);
    st = correct_table(st,thick_begin,thick_begin,slope_wilcox_begin,slope_wilcox_end);
    
    st = correct_table(st,dti_begin,dti_end,pre_wilcox_begin,pre_wilcox_end);
    st = correct_table(st,dti_begin,dti_end,slope_wilcox_begin,slope_wilcox_end);
    st = correct_table(st,dti_begin,dti_end,pre_ancova_begin,pre_ancova_end);
    st = correct_table(st,dti_begin,dti_end,slope_ancova_begin,slope_ancova_end);
    
    st = correct_table(st,dtinolesion_begin,dtinolesion_end,pre_wilcox_begin,pre_wilcox_end);
    st = correct_table(st,dtinolesion_begin,dtinolesion_end,slope_wilcox_begin,slope_wilcox_end);
    st = correct_table(st,dtinolesion_begin,dtinolesion_end,pre_ancova_begin,pre_ancova_end);
    st = correct_table(st,dtinolesion_begin,dtinolesion_end,slope_ancova_begin,slope_ancova_end);
end

function st = correct_table(st,var_begin,var_end,test_begin,test_end)
    rows_vec = var_begin:var_end;
    cols_vec = test_begin:test_end;

    p = cell2mat(st(rows_vec,cols_vec));
    [~,~,~,p_bh]=fdr_bh(p,0.05,'pdep');
     
    for row = 1:size(p_bh,1)
        for col = 1:size(p_bh,2)
            st{rows_vec(row),cols_vec(col)} = p_bh(row,col);
        end
    end    
end

function st_select = stat_table_selection(st,positive_slope1,positive_slope2,positive_slope234567,data_name_select)
    st_select{1,3} = 'No Lesion';
    st_select{1,7} = 'Posterior Lesion (0<Loes<=2)';
    st_select{1,11} = 'ANCOVA';
    st_select{1,13} = 'Slope > 0';
    st_select{2,1} = 'Variable';
    st_select{2,2} = 'Region of Interest';
    st_select{2,3} = 'baseline';
    st_select{2,5} = 'follow-up';
    st_select{2,7} = 'baseline';
    st_select{2,9} = 'follow-up';
    st_select{2,11} = 'baseline';
    st_select{2,12} = 'slope';
    st_select{2,13} = 'No Lesion (14)';
    st_select{2,15} = 'Posterior 0<Loes<=2 (13)';
    st_select{2,17} = 'cALD (38)';
    st_select{3,1} = 'Volume [% of Cranial Volume]';
    st_select{5,1} = 'Fractional Anisotropy';
    st_select{10,1} = 'Axial Diffusivity [*10^-9 m^2/s]';
    st_select{15,1} = 'Radial Diffusivity [*10^-9 m^2/s]';
    st_select{20,1} = 'Mean Diffusivity [*10^-9 m^2/s]';
    st_select{25,1} = 'Fractional Anisotropy';
    st_select{30,1} = 'Axial Diffusivity [*10^-9 m^2/s]';
    st_select{35,1} = 'Radial Diffusivity [*10^-9 m^2/s]';
    st_select{40,1} = 'Mean Diffusivity [*10^-9 m^2/s]';
    
    row = 3;
    st_select{row,2} = 'Cortex';
    pos = strcmp(st(:,1),'Cortex Volume [% of Cranial Volume]');
    keyword = 'CortexVol';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 4;
    st_select{row,2} = 'Cerebral White Matter';
    pos = strcmp(st(:,1),'Cerebral White Matter Volume [% of Cranial Volume]');
    keyword = 'CerebralWhiteMatterVol';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 5;
    st_select{row,2} = 'White Matter';
    pos = strcmp(st(:,1),'FA - JHU - White Matter');
    keyword = 'FA12-jhu-wm';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 6;
    st_select{row,2} = 'Splenium of Corpus Callosum';
    pos = strcmp(st(:,1),'FA - JHU - Splenium of Corpus Callosum');
    keyword = 'FA12-jhu-5';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 7;
    st_select{row,2} = 'Genu of Corpus Callosum';
    pos = strcmp(st(:,1),'FA - JHU - Genu of Corpus Callosum');
    keyword = 'FA12-jhu-3';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 8;
    st_select{row,2} = 'Body of Corpus Callosum';
    pos = strcmp(st(:,1),'FA - JHU - Body of Corpus Callosum');
    keyword = 'FA12-jhu-4';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 9;
    st_select{row,2} = 'Corticospinal Tract';
    pos = strcmp(st(:,1),'FA - JHU - Corticospinal Tract');
    keyword = 'FA12-jhu-cst';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 10;
    st_select{row,2} = 'White Matter';
    pos = strcmp(st(:,1),'AD - JHU - White Matter');
    keyword = 'AD12-jhu-wm';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 11;
    st_select{row,2} = 'Splenium of Corpus Callosum';
    pos = strcmp(st(:,1),'AD - JHU - Splenium of Corpus Callosum');
    keyword = 'AD12-jhu-5';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 12;
    st_select{row,2} = 'Genu of Corpus Callosum';
    pos = strcmp(st(:,1),'AD - JHU - Genu of Corpus Callosum');
    keyword = 'AD12-jhu-3';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 13;
    st_select{row,2} = 'Body of Corpus Callosum';
    pos = strcmp(st(:,1),'AD - JHU - Body of Corpus Callosum');
    keyword = 'AD12-jhu-4';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 14;
    st_select{row,2} = 'Corticospinal Tract';
    pos = strcmp(st(:,1),'AD - JHU - Corticospinal Tract');
    keyword = 'AD12-jhu-cst';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);    
    
    row = 15;
    st_select{row,2} = 'White Matter';
    pos = strcmp(st(:,1),'RD - JHU - White Matter');
    keyword = 'RD12-jhu-wm';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 16;
    st_select{row,2} = 'Splenium of Corpus Callosum';
    pos = strcmp(st(:,1),'RD - JHU - Splenium of Corpus Callosum');
    keyword = 'RD12-jhu-5';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 17;
    st_select{row,2} = 'Genu of Corpus Callosum';
    pos = strcmp(st(:,1),'RD - JHU - Genu of Corpus Callosum');
    keyword = 'RD12-jhu-3';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 18;
    st_select{row,2} = 'Body of Corpus Callosum';
    pos = strcmp(st(:,1),'RD - JHU - Body of Corpus Callosum');
    keyword = 'RD12-jhu-4';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 19;
    st_select{row,2} = 'Corticospinal Tract';
    pos = strcmp(st(:,1),'RD - JHU - Corticospinal Tract');
    keyword = 'RD12-jhu-cst';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);    
    
    row = 20;
    st_select{row,2} = 'White Matter';
    pos = strcmp(st(:,1),'MD - JHU - White Matter');
    keyword = 'MD12-jhu-wm';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 21;
    st_select{row,2} = 'Splenium of Corpus Callosum';
    pos = strcmp(st(:,1),'MD - JHU - Splenium of Corpus Callosum');
    keyword = 'MD12-jhu-5';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 22;
    st_select{row,2} = 'Genu of Corpus Callosum';
    pos = strcmp(st(:,1),'MD - JHU - Genu of Corpus Callosum');
    keyword = 'MD12-jhu-3';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 23;
    st_select{row,2} = 'Body of Corpus Callosum';
    pos = strcmp(st(:,1),'MD - JHU - Body of Corpus Callosum');
    keyword = 'MD12-jhu-4';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 24;
    st_select{row,2} = 'Corticospinal Tract';
    pos = strcmp(st(:,1),'MD - JHU - Corticospinal Tract');
    keyword = 'MD12-jhu-cst';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    % ROIs excluding voxels with lesion
    row = 25;
    st_select{row,2} = 'White Matter';
    pos = strcmp(st(:,1),'FA - JHU - White Matter without Lesion');
    keyword = 'FA12-jhu-wmNOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 26;
    st_select{row,2} = 'Splenium of Corpus Callosum';
    pos = strcmp(st(:,1),'FA - JHU - Splenium of Corpus Callosum without Lesion');
    keyword = 'FA12-jhu-5NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 27;
    st_select{row,2} = 'Genu of Corpus Callosum';
    pos = strcmp(st(:,1),'FA - JHU - Genu of Corpus Callosum without Lesion');
    keyword = 'FA12-jhu-3NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 28;
    st_select{row,2} = 'Body of Corpus Callosum';
    pos = strcmp(st(:,1),'FA - JHU - Body of Corpus Callosum without Lesion');
    keyword = 'FA12-jhu-4NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 29;
    st_select{row,2} = 'Corticospinal Tract';
    pos = strcmp(st(:,1),'FA - JHU - Corticospinal Tract without Lesion');
    keyword = 'FA12-jhu-cstNOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword); 
    
    row = 30;
    st_select{row,2} = 'White Matter';
    pos = strcmp(st(:,1),'AD - JHU - White Matter without Lesion');
    keyword = 'AD12-jhu-wmNOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 31;
    st_select{row,2} = 'Splenium of Corpus Callosum';
    pos = strcmp(st(:,1),'AD - JHU - Splenium of Corpus Callosum without Lesion');
    keyword = 'AD12-jhu-5NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 32;
    st_select{row,2} = 'Genu of Corpus Callosum';
    pos = strcmp(st(:,1),'AD - JHU - Genu of Corpus Callosum without Lesion');
    keyword = 'AD12-jhu-3NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 33;
    st_select{row,2} = 'Body of Corpus Callosum';
    pos = strcmp(st(:,1),'AD - JHU - Body of Corpus Callosum without Lesion');
    keyword = 'AD12-jhu-4NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 34;
    st_select{row,2} = 'Corticospinal Tract';
    pos = strcmp(st(:,1),'AD - JHU - Corticospinal Tract without Lesion');
    keyword = 'AD12-jhu-cstNOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword); 
    
    row = 35;
    st_select{row,2} = 'White Matter';
    pos = strcmp(st(:,1),'RD - JHU - White Matter without Lesion');
    keyword = 'RD12-jhu-wmNOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 36;
    st_select{row,2} = 'Splenium of Corpus Callosum';
    pos = strcmp(st(:,1),'RD - JHU - Splenium of Corpus Callosum without Lesion');
    keyword = 'RD12-jhu-5NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 37;
    st_select{row,2} = 'Genu of Corpus Callosum';
    pos = strcmp(st(:,1),'RD - JHU - Genu of Corpus Callosum without Lesion');
    keyword = 'RD12-jhu-3NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 38;
    st_select{row,2} = 'Body of Corpus Callosum';
    pos = strcmp(st(:,1),'RD - JHU - Body of Corpus Callosum without Lesion');
    keyword = 'RD12-jhu-4NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 39;
    st_select{row,2} = 'Corticospinal Tract';
    pos = strcmp(st(:,1),'RD - JHU - Corticospinal Tract without Lesion');
    keyword = 'RD12-jhu-cstNOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keyword);
    
    row = 40;
    st_select{row,2} = 'White Matter';
    pos = strcmp(st(:,1),'MD - JHU - White Matter without Lesion');
    keywoMD = 'MD12-jhu-wmNOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keywoMD);
    
    row = 41;
    st_select{row,2} = 'Splenium of Corpus Callosum';
    pos = strcmp(st(:,1),'MD - JHU - Splenium of Corpus Callosum without Lesion');
    keywoMD = 'MD12-jhu-5NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keywoMD);
    
    row = 42;
    st_select{row,2} = 'Genu of Corpus Callosum';
    pos = strcmp(st(:,1),'MD - JHU - Genu of Corpus Callosum without Lesion');
    keywoMD = 'MD12-jhu-3NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keywoMD);
    
    row = 43;
    st_select{row,2} = 'Body of Corpus Callosum';
    pos = strcmp(st(:,1),'MD - JHU - Body of Corpus Callosum without Lesion');
    keywoMD = 'MD12-jhu-4NOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keywoMD);
    
    row = 44;
    st_select{row,2} = 'Corticospinal Tract';
    pos = strcmp(st(:,1),'MD - JHU - Corticospinal Tract without Lesion');
    keywoMD = 'MD12-jhu-cstNOles';
    st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope234567,data_name_select,keywoMD);
end

function st_select = fill_table(st_select,st,pos,row,positive_slope1,positive_slope2,positive_slope3,var_name,keyword)
    st_select{row,3} = st{pos,2};
    st_select{row,4} = st{pos,3};
    st_select{row,5} = st{pos,4};
    st_select{row,6} = st{pos,5};
    st_select{row,7} = st{pos,8};
    st_select{row,8} = st{pos,9};
    st_select{row,9} = st{pos,10};
    st_select{row,10} = st{pos,11};
%     st_select{row,11} = st{pos,26};
%     st_select{row,12} = st{pos,29};
    st_select{row,11} = st{pos,32};
    st_select{row,12} = st{pos,35};
    
    pos=strcmp(var_name,keyword);
    m1=positive_slope1(pos,:);
    m2=positive_slope2(pos,:);
    m3=positive_slope3(pos,:);
    
    st_select{row,13} = m1(1,1);
    st_select{row,14} = round(100*m1(1,2));
    st_select{row,15} = m2(1,1);
    st_select{row,16} = round(100*m2(1,2));
    st_select{row,17} = m3(1,1);
    st_select{row,18} = round(100*m3(1,2));
end

function draw_boxplot_distribution(Yp1,Yp2,ylbl,draw_zero)

    Yp1_Cinterval = quantile(Yp1,[0.025 0.25 0.50 0.75 0.975]);
    Yp2_Cinterval = quantile(Yp2,[0.025 0.25 0.50 0.75 0.975]);
    
    plot([0.27 0.73],[Yp1_Cinterval(2) Yp1_Cinterval(2)],'k','LineWidth',3);
    hold on
    if draw_zero==1
        plot([-5 5],[0 0],'r-.','LineWidth',3)
    end
    plot([0.27 0.73],[Yp1_Cinterval(4) Yp1_Cinterval(4)],'k','LineWidth',3);
    plot([0.27 0.27],[Yp1_Cinterval(2) Yp1_Cinterval(4)],'k','LineWidth',3);
    plot([0.73 0.73],[Yp1_Cinterval(2) Yp1_Cinterval(4)],'k','LineWidth',3);
    plot([0.5 0.5],[Yp1_Cinterval(1) Yp1_Cinterval(2)],'k','LineWidth',3);
    plot([0.48 0.52],[Yp1_Cinterval(1) Yp1_Cinterval(1)],'k','LineWidth',3);
    plot([0.5 0.5],[Yp1_Cinterval(4) Yp1_Cinterval(5)],'k','LineWidth',3);
    plot([0.48 0.52],[Yp1_Cinterval(5) Yp1_Cinterval(5)],'k','LineWidth',3);
    plot([0.77 1.23],[Yp2_Cinterval(2) Yp2_Cinterval(2)],'k','LineWidth',3);
    plot([0.77 1.23],[Yp2_Cinterval(4) Yp2_Cinterval(4)],'k','LineWidth',3);
    plot([0.77 0.77],[Yp2_Cinterval(2) Yp2_Cinterval(4)],'k','LineWidth',3);
    plot([1.23 1.23],[Yp2_Cinterval(2) Yp2_Cinterval(4)],'k','LineWidth',3);
    plot([1.0 1.0],[Yp2_Cinterval(1) Yp2_Cinterval(2)],'k','LineWidth',3);
    plot([0.98 1.02],[Yp2_Cinterval(1) Yp2_Cinterval(1)],'k','LineWidth',3);
    plot([1.0 1.0],[Yp2_Cinterval(4) Yp2_Cinterval(5)],'k','LineWidth',3);
    plot([0.98 1.02],[Yp2_Cinterval(5) Yp2_Cinterval(5)],'k','LineWidth',3);
    H1 = plot([0.27 0.73],[Yp1_Cinterval(3) Yp1_Cinterval(3)],'k-.','LineWidth',3);
    H2 = plot([0.77 1.23],[Yp2_Cinterval(3) Yp2_Cinterval(3)],'k-.','LineWidth',3);
    
    scatter(1*ones(size(Yp1))/2,Yp1,100, 'bo', 'jitter','on', 'jitterAmount', 0.14,'MarkerEdgeAlpha',0.95,'MarkerFaceAlpha',0.95,'Linewidth',3);
    scatter(2*ones(size(Yp2))/2,Yp2,100, '^', 'jitter','on', 'jitterAmount', 0.14,'MarkerEdgeAlpha',0.95,'MarkerFaceAlpha',0.95,'MarkerEdgeColor',[253, 218, 13]/255,'Linewidth',3);
    hold off
    xlim([0.2 1.3])
    grid on
    ylabel(ylbl)
    xlabel('Loes score')
    set(gca,'FontSize',14,'LineWidth',2,...
        'XTick',0.5:0.5:1,...
        'XTickLabel',{'0','0.5-2'})
end

function draw_boxplot_distribution_baseline(Yp1,Yp2,Yp3,Yp4,Yp5,ylbl,ttle)

    Yp1_Cinterval = quantile(Yp1,[0.025 0.25 0.50 0.75 0.975]);
    Yp2_Cinterval = quantile(Yp2,[0.025 0.25 0.50 0.75 0.975]);
    Yp3_Cinterval = quantile(Yp3,[0.025 0.25 0.50 0.75 0.975]);
    Yp4_Cinterval = quantile(Yp4,[0.025 0.25 0.50 0.75 0.975]);
    Yp5_Cinterval = quantile(Yp5,[0.025 0.25 0.50 0.75 0.975]);
    
    plot([0.27 0.73],[Yp1_Cinterval(2) Yp1_Cinterval(2)],'k','LineWidth',3);
    hold on
    plot([0.27 0.73],[Yp1_Cinterval(4) Yp1_Cinterval(4)],'k','LineWidth',3);
    plot([0.27 0.27],[Yp1_Cinterval(2) Yp1_Cinterval(4)],'k','LineWidth',3);
    plot([0.73 0.73],[Yp1_Cinterval(2) Yp1_Cinterval(4)],'k','LineWidth',3);
    plot([0.5 0.5],[Yp1_Cinterval(1) Yp1_Cinterval(2)],'k','LineWidth',3);
    plot([0.48 0.52],[Yp1_Cinterval(1) Yp1_Cinterval(1)],'k','LineWidth',3);
    plot([0.5 0.5],[Yp1_Cinterval(4) Yp1_Cinterval(5)],'k','LineWidth',3);
    plot([0.48 0.52],[Yp1_Cinterval(5) Yp1_Cinterval(5)],'k','LineWidth',3);
    
    plot([0.77 1.23],[Yp2_Cinterval(2) Yp2_Cinterval(2)],'k','LineWidth',3);
    plot([0.77 1.23],[Yp2_Cinterval(4) Yp2_Cinterval(4)],'k','LineWidth',3);
    plot([0.77 0.77],[Yp2_Cinterval(2) Yp2_Cinterval(4)],'k','LineWidth',3);
    plot([1.23 1.23],[Yp2_Cinterval(2) Yp2_Cinterval(4)],'k','LineWidth',3);
    plot([1.0 1.0],[Yp2_Cinterval(1) Yp2_Cinterval(2)],'k','LineWidth',3);
    plot([0.98 1.02],[Yp2_Cinterval(1) Yp2_Cinterval(1)],'k','LineWidth',3);
    plot([1.0 1.0],[Yp2_Cinterval(4) Yp2_Cinterval(5)],'k','LineWidth',3);
    plot([0.98 1.02],[Yp2_Cinterval(5) Yp2_Cinterval(5)],'k','LineWidth',3);
    
    plot([0.77+0.5 1.23+0.5],[Yp3_Cinterval(2) Yp3_Cinterval(2)],'k','LineWidth',3);
    plot([0.77+0.5 1.23+0.5],[Yp3_Cinterval(4) Yp3_Cinterval(4)],'k','LineWidth',3);
    plot([0.77+0.5 0.77+0.5],[Yp3_Cinterval(2) Yp3_Cinterval(4)],'k','LineWidth',3);
    plot([1.23+0.5 1.23+0.5],[Yp3_Cinterval(2) Yp3_Cinterval(4)],'k','LineWidth',3);
    plot([1.0+0.5 1.0+0.5],[Yp3_Cinterval(1) Yp3_Cinterval(2)],'k','LineWidth',3);
    plot([0.98+0.5 1.02+0.5],[Yp3_Cinterval(1) Yp3_Cinterval(1)],'k','LineWidth',3);
    plot([1.0+0.5 1.0+0.5],[Yp3_Cinterval(4) Yp3_Cinterval(5)],'k','LineWidth',3);
    plot([0.98+0.5 1.02+0.5],[Yp3_Cinterval(5) Yp3_Cinterval(5)],'k','LineWidth',3);
    
    plot([0.77+1.0 1.23+1.0],[Yp4_Cinterval(2) Yp4_Cinterval(2)],'k','LineWidth',3);
    plot([0.77+1.0 1.23+1.0],[Yp4_Cinterval(4) Yp4_Cinterval(4)],'k','LineWidth',3);
    plot([0.77+1.0 0.77+1.0],[Yp4_Cinterval(2) Yp4_Cinterval(4)],'k','LineWidth',3);
    plot([1.23+1.0 1.23+1.0],[Yp4_Cinterval(2) Yp4_Cinterval(4)],'k','LineWidth',3);
    plot([1.0+1.0 1.0+1.0],[Yp4_Cinterval(1) Yp4_Cinterval(2)],'k','LineWidth',3);
    plot([0.98+1.0 1.02+1.0],[Yp4_Cinterval(1) Yp4_Cinterval(1)],'k','LineWidth',3);
    plot([1.0+1.0 1.0+1.0],[Yp4_Cinterval(4) Yp4_Cinterval(5)],'k','LineWidth',3);
    plot([0.98+1.0 1.02+1.0],[Yp4_Cinterval(5) Yp4_Cinterval(5)],'k','LineWidth',3);
    
    plot([0.77+1.5 1.23+1.5],[Yp5_Cinterval(2) Yp5_Cinterval(2)],'k','LineWidth',3);
    plot([0.77+1.5 1.23+1.5],[Yp5_Cinterval(4) Yp5_Cinterval(4)],'k','LineWidth',3);
    plot([0.77+1.5 0.77+1.5],[Yp5_Cinterval(2) Yp5_Cinterval(4)],'k','LineWidth',3);
    plot([1.23+1.5 1.23+1.5],[Yp5_Cinterval(2) Yp5_Cinterval(4)],'k','LineWidth',3);
    plot([1.0+1.5 1.0+1.5],[Yp5_Cinterval(1) Yp5_Cinterval(2)],'k','LineWidth',3);
    plot([0.98+1.5 1.02+1.5],[Yp5_Cinterval(1) Yp5_Cinterval(1)],'k','LineWidth',3);
    plot([1.0+1.5 1.0+1.5],[Yp5_Cinterval(4) Yp5_Cinterval(5)],'k','LineWidth',3);
    plot([0.98+1.5 1.02+1.5],[Yp5_Cinterval(5) Yp5_Cinterval(5)],'k','LineWidth',3);
        
    H1 = plot([0.27 0.73],[Yp1_Cinterval(3) Yp1_Cinterval(3)],'k-.','LineWidth',3);
    H2 = plot([0.77 1.23],[Yp2_Cinterval(3) Yp2_Cinterval(3)],'k-.','LineWidth',3);
    H3 = plot([0.77+0.5 1.23+0.5],[Yp3_Cinterval(3) Yp3_Cinterval(3)],'k-.','LineWidth',3);
    H4 = plot([0.77+1.0 1.23+1.0],[Yp4_Cinterval(3) Yp4_Cinterval(3)],'k-.','LineWidth',3);
    H5 = plot([0.77+1.5 1.23+1.5],[Yp5_Cinterval(3) Yp5_Cinterval(3)],'k-.','LineWidth',3);
    
%     plot(0.5:0.5:2.5,[Yp1_Cinterval(3) Yp2_Cinterval(3) Yp3_Cinterval(3) Yp4_Cinterval(3) Yp5_Cinterval(3)],':','LineWidth',3,'Color',[255,140,0]/255)
    
    scatter(1*ones(size(Yp1))/2,Yp1,100, 'bo', 'jitter','on', 'jitterAmount', 0.14,'MarkerEdgeAlpha',0.95,'MarkerFaceAlpha',0.95,'Linewidth',3);
    scatter(2*ones(size(Yp2))/2,Yp2,100, '^', 'jitter','on', 'jitterAmount', 0.14,'MarkerEdgeAlpha',0.95,'MarkerFaceAlpha',0.95,'MarkerEdgeColor',[253, 218, 13]/255,'Linewidth',3);
    scatter(3*ones(size(Yp3))/2,Yp3,100, 'gx', 'jitter','on', 'jitterAmount', 0.14,'MarkerEdgeAlpha',0.95,'MarkerFaceAlpha',0.95,'Linewidth',3);
    scatter(4*ones(size(Yp4))/2,Yp4,100, 'p', 'jitter','on', 'jitterAmount', 0.14,'MarkerEdgeAlpha',0.95,'MarkerFaceAlpha',0.95,'MarkerEdgeColor',[1 1 1]*0.5,'Linewidth',3);
    scatter(5*ones(size(Yp5))/2,Yp5,100, 'rv', 'jitter','on', 'jitterAmount', 0.14,'MarkerEdgeAlpha',0.95,'MarkerFaceAlpha',0.95,'Linewidth',3);
    hold off
    xlim([0.2 2.8])
    grid on
    ylabel(ylbl)
    xlabel('Loes score')    
    set(gca,'FontSize',14,'LineWidth',2,...
        'XTick',0.5:0.5:2.5,...
        'XTickLabel',{'0','0.5-2','2.5-4.5','5-8.5','9-19'})
    title(ttle,'FontSize',12)
    
    
%         plot([-5 5],[3 3],':^','Color',[253, 218, 13]/255,'LineWidth',3,'MarkerSize',10)
%     plot([-5 5],[3 3],':x','Color',[0 1 0],'LineWidth',3,'MarkerSize',10)
%     plot([-5 5],[3 3],':d','Color',[1 0 1],'LineWidth',3,'MarkerSize',10)
%     plot([-5 5],[3 3],':s','Color',[0 1 1],'LineWidth',3,'MarkerSize',10)
%     plot([-5 5],[3 3],':p','Color',[1 1 1]*0.5,'LineWidth',3,'MarkerSize',10)
%     plot([-5 5],[3 3],':v','Color',[1 0 0],'LineWidth',3,'MarkerSize',10)
end
