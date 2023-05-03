clear all; close all;
data_folder='/home/range1-raid1/labounek/data-on-porto';
project_folder=fullfile(data_folder,'ALD');
xls_file = fullfile(project_folder,'results','ALD_20230307_Selection202302.xlsx');
save_path = '/home/range1-raid1/labounek/data-on-porto/ALD/pictures/20230307/graphs';

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

% selection=[raw{2:end,336}]';
selection=[raw{2:end,377}]';
early_disease=[raw{2:end,354}]';
slow_progression=[raw{2:end,355}]';
loes=[raw{2:end,353}]';

varidxdmri = 20:261;
varidxvol = [262:293 301:321 328:336];
varidxsurf = 322:323;
varidxthick = 337:339;
varidxles = 365:369;%321:325;
varidxlessplit = 370:371;

ageatscan=[raw{2:end,9}]';
time=[raw{2:end,8}]';
type=[raw{2:end,10}]';
type2020=[raw{2:end,11}]';
dmri12voxelvol = [raw{2:end,348}]';
mpragevoxelvol = [raw{2:end,364}]';%320
intracranvol=[raw{2:end,327}]';


BrainSegVolNotVent = [raw{2:end,308}]';

bmttime=zeros(size(raw,1)-1,1);
bmtage=zeros(size(raw,1)-1,1);
dmri=zeros(size(raw,1)-1,size(varidxdmri,2));
vols=zeros(size(raw,1)-1,size(varidxvol,2));
surface=zeros(size(raw,1)-1,size(varidxsurf,2));
thickness=zeros(size(raw,1)-1,size(varidxthick,2));

for ind = 2:size(raw,1)
    if ~ischar(raw{ind,350})
        bmttime(ind-1,1) = raw{ind,350};
        bmtage(ind-1,1) = raw{ind,5};
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
        ageattransplant(ind) = raw{ind+1,5};
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
    spleniumvol_mean(sbpos,1) = mean(lesion(sbpos,2));
    cerebralwmvol_mean(sbpos,1) = mean(lesion(sbpos,4));
end
lesion_name = {raw{1,varidxles}};

lesion_brainnoventnorm = 100*lesion(:,[1 3 5])./BrainSegVolNotVent;
lesion_brainnoventnorm_name = lesion_name(1,[1 3 5]);

lesion(:,3) = lesion(:,3) ./ spleniumvol_mean .* 100;
lesion(:,5) = lesion(:,5) ./ cerebralwmvol_mean .* 100;
lesion(:,1) = lesion(:,1) ./ intracranvol_mean .* 100;
lesion(:,2) = lesion(:,2) ./ intracranvol_mean .* 100;
lesion(:,4) = lesion(:,4) ./ intracranvol_mean .* 100;
lesion(isnan(vols(:,20)),2:5)=NaN;


data = [thickness surface lesion vols dmri loes lesion_brainnoventnorm];
data_name = [thickness_name surface_name lesion_name vols_name dmri_name 'LoesScore' lesion_brainnoventnorm_name];

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


data_name_select = {'FA12-jhu-wm' 'FA12-jhu-cc' 'FA12-jhu-5' 'FA12-jhu-3' 'FA12-jhu-4' 'FA12-jhu-cst'}; % 'FA12-jhu-aCR' 'FA12-jhu-retroIC'
data_select_pos = zeros(size(data_name_select,2),1);
st_abstract{2,1} = 'Measure - Atlas - Region of Interest';
st_abstract{1,2} = 'No Lesion (G1)';
st_abstract{2,2} = 'pre-Mean';
st_abstract{2,3} = 'pre-STD';
st_abstract{2,4} = 'post-Mean';
st_abstract{2,5} = 'post-STD';
st_abstract{2,6} = 'slope-Mean';
st_abstract{2,7} = 'slope-STD';
st_abstract{1,8} = 'Posterior Lesion (0<Loes<=4.5; G2)';
st_abstract{2,8} = 'pre-Mean';
st_abstract{2,9} = 'pre-STD';
st_abstract{2,10} = 'post-Mean';
st_abstract{2,11} = 'post-STD';
st_abstract{2,12} = 'slope-Mean';
st_abstract{2,13} = 'slope-STD';
st_abstract{1,14} = 'Posterior Lesion (4.5<Loes; G3)';
st_abstract{2,14} = 'pre-Mean';
st_abstract{2,15} = 'pre-STD';
st_abstract{2,16} = 'post-Mean';
st_abstract{2,17} = 'post-STD';
st_abstract{2,18} = 'slope-Mean';
st_abstract{2,19} = 'slope-STD';
st_abstract{1,20} = 'Wilcoxon rank sum tests (p-values)';
st_abstract{2,20} = 'pre-G1vsG2';
st_abstract{2,21} = 'pre-G1vsG3';
st_abstract{2,22} = 'slope-G1vsG2';
st_abstract{2,23} = 'slope-G1vsG3';



sess1_pos = subnum(selection==1);
slope=zeros(size(sess1_pos,1),size(data_name_select,2));
for idx = 1:size(data_name_select,2)
    pos = find(strcmp(data_name,data_name_select{1,idx})==1);
    data_select_pos(idx,1) = pos;
    
    if strcmp(data_name_select{1,idx},'FA12-jhu-wm')
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
    end
    
    [vec1,vec1_time,vec1_slope,vec1_stat] = extract_measures(data(:,pos),type2020,selection,1,bmttime);
    [vec2,vec2_time,vec2_slope,vec2_stat] = extract_measures(data(:,pos),type2020,selection,2,bmttime);
    [vec3,vec3_time,vec3_slope,vec3_stat] = extract_measures(data(:,pos),type2020,selection,3,bmttime);
    [vec4,vec4_time,vec4_slope,vec4_stat] = extract_measures(data(:,pos),type2020,selection,4,bmttime);
    [vec5,vec5_time,vec5_slope,vec5_stat] = extract_measures(data(:,pos),type2020,selection,5,bmttime);
    [vec6,vec6_time,vec6_slope,vec6_stat] = extract_measures(data(:,pos),type2020,selection,6,bmttime);
    [vec7,vec7_time,vec7_slope,vec7_stat] = extract_measures(data(:,pos),type2020,selection,7,bmttime);
    
    cell_slope{1,1} = vec1_slope;
    cell_slope{2,1} = vec2_slope;
    cell_slope{3,1} = vec3_slope;
    cell_slope{4,1} = vec4_slope;
    cell_slope{5,1} = vec5_slope;
    cell_slope{6,1} = vec6_slope;
    cell_slope{7,1} = vec7_slope;
    
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
    
    p_abstract(1,1) = ranksum(vec1(:,1),vec23(:,1));
    p_abstract(1,2) = ranksum(vec1(:,1),vec45(:,1));
    p_abstract(2,1) = ranksum(vec1_slope,vec23_slope);
    p_abstract(2,2) = ranksum(vec1_slope,vec45_slope);
    
    pom=[vec1_stat; vec23_stat; vec45_stat; p_abstract]';
    pom = pom(:);
    for psx = 1:size(pom,1)
        st_abstract{2+idx,1+psx} = pom(psx);
    end
    
    slope_name{1,idx} = [data_name_select{1,idx} '-slope'];
    for g = 1:size(cell_slope,1)
        slope = reorder_slope(slope,cell_slope{g,1},subnum,selection,type2020,g,idx,sess1_pos);
    end
end

xdata=data(selection==1,strcmp(data_name,'FA12-jhu-5'));
ydata=slope(:,strcmp(slope_name,'FA12-jhu-5-slope'));
zdata=data(selection==1,strcmp(data_name,'FA12-jhu-3'));
gdata=slope(:,strcmp(slope_name,'FA12-jhu-3-slope'));
grp = type2020(selection==1);
h(21).fig = figure(21);
set(h(21).fig,'Position',[50 50 600 500])
scatter3(xdata(grp==1),ydata(grp==1),zdata(grp==1),850, 'b.')
hold on
scatter3(xdata(grp==2),ydata(grp==2),zdata(grp==2),850, 'y.')
scatter3(xdata(grp==3),ydata(grp==3),zdata(grp==3),850, 'g.')
scatter3(xdata(grp==4),ydata(grp==4),zdata(grp==4),850, '.','MarkerEdgeColor',[0.6 0.6 0.6])
scatter3(xdata(grp==5),ydata(grp==5),zdata(grp==5),850, 'r.')
scatter3(xdata(grp==6),ydata(grp==6),zdata(grp==6),850, 'm.')
scatter3(xdata(grp==7),ydata(grp==7),zdata(grp==7),850, 'c.')
hold off
xlabel('FA Splenium')
ylabel('FA Splenium Slope')
zlabel('FA Genu')
grid on
set(gca,'FontSize',14,'LineWidth',2)

h(22).fig = figure(22);
set(h(22).fig,'Position',[50 50 600 500])
scatter(xdata(grp==1),ydata(grp==1),850, 'b.')
hold on
scatter(xdata(grp==2),ydata(grp==2),850, 'y.')
scatter(xdata(grp==3),ydata(grp==3),850, 'g.')
scatter(xdata(grp==4),ydata(grp==4),850, '.','MarkerEdgeColor',[0.6 0.6 0.6])
scatter(xdata(grp==5),ydata(grp==5),850, 'r.')
scatter(xdata(grp==6),ydata(grp==6),850, 'm.')
scatter(xdata(grp==7),ydata(grp==7),850, 'c.')
hold off
xlabel('FA Splenium')
ylabel('FA Splenium Slope')
grid on
set(gca,'FontSize',14,'LineWidth',2)

h(23).fig = figure(23);
set(h(23).fig,'Position',[50 50 600 500])
scatter(xdata(grp==1),zdata(grp==1),850, 'b.')
hold on
scatter(xdata(grp==2),zdata(grp==2),850, 'y.')
scatter(xdata(grp==3),zdata(grp==3),850, 'g.')
scatter(xdata(grp==4),zdata(grp==4),850, '.','MarkerEdgeColor',[0.6 0.6 0.6])
scatter(xdata(grp==5),zdata(grp==5),850, 'r.')
scatter(xdata(grp==6),zdata(grp==6),850, 'm.')
scatter(xdata(grp==7),zdata(grp==7),850, 'c.')
hold off
xlabel('FA Splenium')
ylabel('FA Genu')
grid on
set(gca,'FontSize',14,'LineWidth',2)

h(24).fig = figure(24);
set(h(24).fig,'Position',[50 50 600 500])
scatter(zdata(grp==1),gdata(grp==1),850, 'b.')
hold on
scatter(zdata(grp==2),gdata(grp==2),850, 'y.')
scatter(zdata(grp==3),gdata(grp==3),850, 'g.')
scatter(zdata(grp==4),gdata(grp==4),850, '.','MarkerEdgeColor',[0.6 0.6 0.6])
scatter(zdata(grp==5),gdata(grp==5),850, 'r.')
scatter(zdata(grp==6),gdata(grp==6),850, 'm.')
scatter(zdata(grp==7),gdata(grp==7),850, 'c.')
hold off
xlabel('FA Genu')
ylabel('FA Genu Slope')
grid on
set(gca,'FontSize',14,'LineWidth',2)

h(25).fig = figure(25);
set(h(25).fig,'Position',[50 50 600 500])
scatter(ydata(grp==1),gdata(grp==1),850, 'b.')
hold on
scatter(ydata(grp==2),gdata(grp==2),850, 'y.')
scatter(ydata(grp==3),gdata(grp==3),850, 'g.')
scatter(ydata(grp==4),gdata(grp==4),850, '.','MarkerEdgeColor',[0.6 0.6 0.6])
scatter(ydata(grp==5),gdata(grp==5),850, 'r.')
scatter(ydata(grp==6),gdata(grp==6),850, 'm.')
scatter(ydata(grp==7),gdata(grp==7),850, 'c.')
hold off
xlabel('FA Splenium Slope')
ylabel('FA Genu Slope')
grid on
set(gca,'FontSize',14,'LineWidth',2)


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
    xlabel('BMT time [days]')
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
    elseif vr>=74 && vr<=173
        ylabel('Fractional anisotropy')
    elseif vr>=174 && vr<=273
        ylabel('Mean diffusivity [*10^{-9}m^{2}/s]')
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
    xlabel('BMT time [days]')
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
    elseif vr==316
        ylabel('Loes Score')
    elseif vr>=317 && vr<=319
        ylabel('Volume [% of Brain Volume without Ventricles]')
    end
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
        title(st{vr+2,1})
    elseif length(data_name{1,vr})>7 && strcmp(data_name{1,vr}(6:7),'fs')
        title(st{vr+2,1})
    else
        title(data_name{1,vr})
    end
    axis([-150 460 mn mx])
    grid on
    set(gca,'FontSize',14,'LineWidth',2)
    
    pause(0.15)
    print(fullfile(save_path,['graph' num2str(2000+vr,'%04.f')]),'-dpng','-r300')
    pause(0.15)
    close(h(2000+vr).fig)
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
    'BMT day')
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
plot([-5 5],[3 3],':','Color',[253, 218, 13]/255,'LineWidth',3,'MarkerSize',10)
plot([-5 5],[3 3],':','Color',[0 1 0],'LineWidth',3,'MarkerSize',10)
plot([-5 5],[3 3],':','Color',[1 0 1],'LineWidth',3,'MarkerSize',10)
plot([-5 5],[3 3],':','Color',[0 1 1],'LineWidth',3,'MarkerSize',10)
plot([-5 5],[3 3],':','Color',[1 1 1]*0.5,'LineWidth',3,'MarkerSize',10)
plot([-5 5],[3 3],':','Color',[1 0 0],'LineWidth',3,'MarkerSize',10)
scatter(-0,3,200,'k^','LineWidth',3)
scatter(-0,3,200,'kx','LineWidth',3)
plot([0 0],[mn mx],'k-.','LineWidth',3)
hold off
legend('No lesion',...
    '0 < Loes score \leq 2; posterior lesion',...
    '2 < Loes score \leq 4.5; posterior lesion',...
    '2 < Loes score \leq 4.5; atypical lesion',...
    '2 < Loes score \leq 4.5; frontal lesion',...
    '4.5 < Loes score < 9; posterior lesion',...
    '9 \leq Loes score; posterior lesion',...
    'Slow progression',...
    'Rapid progression',...
    'BMT day')
set(gca,'FontSize',18,'LineWidth',2)
axis([6 12 5 10])
axis off
pause(0.15)
print(fullfile(save_path,['00000_legend2020']),'-dpng','-r300')
pause(0.15)
close(h(1).fig)
pause(0.1)



function [vec1,vec1_time,vec1_slope,vec1_stat] = extract_measures(vec,type2020,selection,grp,bmttime)
    vec1(:,1) = vec(type2020==grp & selection==1);
    vec1(:,2) = vec(type2020==grp & selection==2);
    vec1_time(:,1) = bmttime(type2020==grp & selection==1);
    vec1_time(:,2) = bmttime(type2020==grp & selection==2);
    vec1_slope = zeros(size(vec1,1),1);
    for psx = 1:size(vec1,1)
        kk = polyfit(vec1_time(psx,:),vec1(psx,:),1);
        vec1_slope(psx,1)=kk(1);
    end
    
    vec1_stat = mean(vec1,'omitnan')';
    vec1_stat(:,2) = std(vec1,'omitnan')';
    vec1_stat(3,1) = mean(vec1_slope,'omitnan');
    vec1_stat(3,2) = std(vec1_slope,'omitnan');
end


function slope = reorder_slope(slope,vec_slope,subnum,selection,type,grp,idx,sess_pos)
    type_pos = subnum(selection==1 & type==grp);
    for sbx = 1:size(type_pos,1)
        rx = sess_pos==type_pos(sbx,1);
        slope(rx,idx) = vec_slope(sbx,1);
    end
end