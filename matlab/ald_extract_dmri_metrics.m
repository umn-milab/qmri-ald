clear all; clc;
data_folder='/home/range1-raid1/labounek/data-on-porto';
project_folder=fullfile(data_folder,'ALD');
xls_file = fullfile(project_folder,'results','ALD_20230207.xlsx');

addpath('/home/range1-raid1/labounek/toolbox/matlab/spm12');

[num, txt, raw] = xlsread(xls_file);

cols = size(raw,2);
FA12_mat = zeros(size(raw,1)-1,113);
MD12_mat = zeros(size(raw,1)-1,113);

fslbls=[2;3;4;5;7;8;10;11;12;13;14;15;16;17;18;24;26;28;31;41;42;43;44;46;47;49;50;51;52;53;54;58;60;63;77;85;251;252;253;254;255];

for ind = 2:size(raw,1)
% for ind = 2:2
        if raw{ind,10} == 0
                project_folder=fullfile(data_folder,'controls','brain_ALD');
        else
                project_folder=fullfile(data_folder,'ALD');
        end
        if ~ischar(raw{ind,1})
            raw{ind,1} = num2str(raw{ind,1},'%03.f');
        end
        result_folder = fullfile(project_folder,'results','dmri',raw{ind,1},raw{ind,2});
        FA12_file = fullfile(result_folder,'dti12_FA');
        jhu_file =  fullfile(result_folder,'jhu_labels');
        MD12_file = fullfile(result_folder,'dti12_MD');
        aseg_file = fullfile(result_folder,'dmri_aseg');
        lesion_file = fullfile(result_folder,'dmri_lesion');
        dmrires=0;
        asegres=0;
        if isfile([FA12_file '.nii.gz'])
                gunzip([FA12_file '.nii.gz']);
                FA12_file_hdr = spm_vol([FA12_file '.nii']);
                FA12 = spm_read_vols(FA12_file_hdr);
                delete([FA12_file '.nii']);
                
                gunzip([ jhu_file '.nii.gz']);
                jhu_file_hdr = spm_vol([ jhu_file '.nii']);
                jhu = spm_read_vols( jhu_file_hdr);
                delete( [jhu_file '.nii']);
                
                gunzip([MD12_file '.nii.gz']);
                MD12_file_hdr = spm_vol([MD12_file '.nii']);
                MD12 = spm_read_vols(MD12_file_hdr);
                delete([MD12_file '.nii']);
                
                dmrires=1;
        elseif isfile([FA12_file '.img'])
                FA12_file_hdr = spm_vol([FA12_file '.img']);
                FA12 = spm_read_vols(FA12_file_hdr);
                
                jhu_file_hdr = spm_vol([ jhu_file '.img']);
                jhu = spm_read_vols( jhu_file_hdr);
                 
                MD12_file_hdr = spm_vol([MD12_file '.img']);
                MD12 = spm_read_vols(MD12_file_hdr);
                
                dmrires=1;
        elseif isfile([FA12_file '.nii'])
                FA12_file_hdr = spm_vol([FA12_file '.nii']);
                FA12 = spm_read_vols(FA12_file_hdr);
                
                jhu_file_hdr = spm_vol([ jhu_file '.nii']);
                jhu = spm_read_vols( jhu_file_hdr);
                 
                MD12_file_hdr = spm_vol([MD12_file '.nii']);
                MD12 = spm_read_vols(MD12_file_hdr);
                
                dmrires=1;
        end
        if isfile([aseg_file '.nii.gz'])
                gunzip([aseg_file '.nii.gz']);
                aseg_file_hdr = spm_vol([aseg_file '.nii']);
                aseg = spm_read_vols(aseg_file_hdr);
                delete([aseg_file '.nii']);
                
                asegres=1;
        end
        if isfile([lesion_file '.nii.gz'])
                gunzip([lesion_file '.nii.gz']);
                lesion_file_hdr = spm_vol([lesion_file '.nii']);
                lesion = spm_read_vols(lesion_file_hdr);
                delete([lesion_file '.nii']);
        elseif asegres==1
                lesion=zeros(size(aseg));
        end
        if isfile([FA12_file '.nii.gz']) || isfile([FA12_file '.img']) || isfile([FA12_file '.nii'])
                lbls = unique(jhu(:));
                lbls=lbls(2:end);
                
                % JHU white matter extraction
                FA12_vec = FA12(jhu>0);
                MD12_vec = MD12(jhu>0).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                MD12_mat(ind-1,1) = mean(MD12_vec);
                FA12_mat(ind-1,1) = mean(FA12_vec);
%                 if ind == 2 || ind == 12 || ind == 73 || ind == 71
%                         figure(ind)
%                         subplot(2,2,1)
%                         histogram(FA12_vec,30,'Normalization','probability');ylabel({'JHU white matter';'probability'});set(gca,'FontSize',14);xlim([0 1]);
%                         subplot(2,2,2)
%                         histogram(MD12_vec,30,'Normalization','probability');set(gca,'FontSize',14);xlim([0.5 2.5]);
%                 end

                % Corpus callosum extraction
                FA12_vec = FA12(jhu==3 | jhu==4 | jhu==5);
                MD12_vec = MD12(jhu==3 | jhu==4 | jhu==5).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,2) = mean(FA12_vec);
                MD12_mat(ind-1,2) = mean(MD12_vec);
                
                % CST extraction
                FA12_vec = FA12(jhu==7 | jhu==8 | jhu==15 | jhu==16 | jhu==19 | jhu==20); %| jhu==25 | jhu==26
                MD12_vec = MD12(jhu==7 | jhu==8 | jhu==15 | jhu==16 | jhu==19 | jhu==20).*10^3; %| jhu==25 | jhu==26
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,3) = mean(FA12_vec);
                MD12_mat(ind-1,3) = mean(MD12_vec);
                
                % Cerebral peduncle extraction
                FA12_vec = FA12(jhu==15 | jhu==16);
                MD12_vec = MD12(jhu==15 | jhu==16).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,4) = mean(FA12_vec);
                MD12_mat(ind-1,4) = mean(MD12_vec);
                
                % Anterior limb of internal capsule extraction
                FA12_vec = FA12(jhu==17 | jhu==18);
                MD12_vec = MD12(jhu==17 | jhu==18).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,5) = mean(FA12_vec);
                MD12_mat(ind-1,5) = mean(MD12_vec);
                
                % Posterior limb of internal capsule extraction
                FA12_vec = FA12(jhu==19 | jhu==20);
                MD12_vec = MD12(jhu==19 | jhu==20).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,6) = mean(FA12_vec);
                MD12_mat(ind-1,6) = mean(MD12_vec);
                
                % Retrolenticular part of internal capsule extraction
                FA12_vec = FA12(jhu==21 | jhu==22);
                MD12_vec = MD12(jhu==21 | jhu==22).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,7) = mean(FA12_vec);
                MD12_mat(ind-1,7) = mean(MD12_vec);
                
                % Internal capsule extraction
                FA12_vec = FA12(jhu>=17 & jhu<=22);
                MD12_vec = MD12(jhu>=17 & jhu<=22).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,8) = mean(FA12_vec);
                MD12_mat(ind-1,8) = mean(MD12_vec);
                
                % Anterior corona radiata extraction
                FA12_vec = FA12(jhu==23 | jhu==24);
                MD12_vec = MD12(jhu==23 | jhu==24).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,9) = mean(FA12_vec);
                MD12_mat(ind-1,9) = mean(MD12_vec);
                
                % Superior corona radiata extraction
                FA12_vec = FA12(jhu==25 | jhu==26);
                MD12_vec = MD12(jhu==25 | jhu==26).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,10) = mean(FA12_vec);
                MD12_mat(ind-1,10) = mean(MD12_vec);
                
                % Posterior corona radiata extraction
                FA12_vec = FA12(jhu==27 | jhu==28);
                MD12_vec = MD12(jhu==27 | jhu==28).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,11) = mean(FA12_vec);
                MD12_mat(ind-1,11) = mean(MD12_vec);
                
                % Sagittal stratum extraction
                FA12_vec = FA12(jhu==31 | jhu==32);
                MD12_vec = MD12(jhu==31 | jhu==32).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,12) = mean(FA12_vec);
                MD12_mat(ind-1,12) = mean(MD12_vec);
                
                % Cingulum extraction
                FA12_vec = FA12(jhu>=35 & jhu<=38);
                MD12_vec = MD12(jhu>=35 & jhu<=38).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,13) = mean(FA12_vec);
                MD12_mat(ind-1,13) = mean(MD12_vec);
                
                % Tapetum extraction
                FA12_vec = FA12(jhu==47 | jhu==48);
                MD12_vec = MD12(jhu==47 | jhu==48).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,14) = mean(FA12_vec);
                MD12_mat(ind-1,14) = mean(MD12_vec);
                
                % Corpus callosum + Tapetum extraction
                FA12_vec = FA12(jhu==3 | jhu==4 | jhu==5 | jhu==47 | jhu==48);
                MD12_vec = MD12(jhu==3 | jhu==4 | jhu==5 | jhu==47 | jhu==48).*10^3;
                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                FA12_mat(ind-1,15) = mean(FA12_vec);
                MD12_mat(ind-1,15) = mean(MD12_vec);
                
%                 if ind == 2 || ind == 12 || ind == 73 || ind == 71
%                         subplot(2,2,3)
%                         histogram(FA12_vec,30,'Normalization','probability');xlabel('FA');ylabel({'JHU CC';'probability'});set(gca,'FontSize',14);xlim([0 1]);
%                         subplot(2,2,4)
%                         histogram(MD12_vec,30,'Normalization','probability');xlabel('MD');set(gca,'FontSize',14);xlim([0.5 2.5]);
%                         pause(0.75)
%                 end
                
                for roi_ind = 1:size(lbls,1)
                        % JHU atlas single-roi extractions
                        FA12_vec = FA12(jhu==lbls(roi_ind,1));
                        MD12_vec = MD12(jhu==lbls(roi_ind,1)).*10^3;
                        MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_mat(ind-1,roi_ind+15) = mean(FA12_vec);
                        MD12_mat(ind-1,roi_ind+15) = mean(MD12_vec);                   
                end
                if asegres == 1                     
                        for fsroi_ind = 1:size(fslbls,1)
                                % Freesurfer single-roi extractions
                                FA12_vec = FA12(aseg==fslbls(fsroi_ind,1));
                                MD12_vec = MD12(aseg==fslbls(fsroi_ind,1)).*10^3;
                                MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                                FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                                FA12_mat(ind-1,roi_ind+15+fsroi_ind) = mean(FA12_vec);
                                MD12_mat(ind-1,roi_ind+15+fsroi_ind) = mean(MD12_vec);                   
                        end
                        
                        % FREESURFER: WM extraction
                        FA12_vec = FA12(((aseg>=251 & aseg<=255) | aseg==2 | aseg == 41 | aseg == 77 | aseg == 78 | aseg == 79));
                        MD12_vec = MD12(((aseg>=251 & aseg<=255) | aseg==2 | aseg == 41 | aseg == 77 | aseg == 78 | aseg == 79)).*10^3;
                        MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_mat(ind-1,roi_ind+15+fsroi_ind+1) = mean(FA12_vec);
                        MD12_mat(ind-1,roi_ind+15+fsroi_ind+1) = mean(MD12_vec);
                        
                        % FREESURFER: Corpus callosum extraction
                        FA12_vec = FA12(aseg>=251 & aseg<=255);
                        MD12_vec = MD12(aseg>=251 & aseg<=255).*10^3;
                        MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_mat(ind-1,roi_ind+15+fsroi_ind+2) = mean(FA12_vec);
                        MD12_mat(ind-1,roi_ind+15+fsroi_ind+2) = mean(MD12_vec);
                        
                        % FREESURFER: Cerebellum WM extraction
                        FA12_vec = FA12(aseg==46 | aseg==7);
                        MD12_vec = MD12(aseg==46 | aseg==7).*10^3;
                        MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_mat(ind-1,roi_ind+15+fsroi_ind+3) = mean(FA12_vec);
                        MD12_mat(ind-1,roi_ind+15+fsroi_ind+3) = mean(MD12_vec); 
                        
                        % FREESURFER: Splenium without lesion extraction
                        FA12_vec = FA12(aseg == 251 & lesion~=1);
                        MD12_vec = MD12(aseg == 251 & lesion~=1).*10^3;
                        MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_mat(ind-1,roi_ind+15+fsroi_ind+4) = mean(FA12_vec);
                        MD12_mat(ind-1,roi_ind+15+fsroi_ind+4) = mean(MD12_vec);

                        % FREESURFER: Cross-section splenium and lesion extraction
                        FA12_vec = FA12(aseg == 251 & lesion==1);
                        MD12_vec = MD12(aseg == 251 & lesion==1).*10^3;
                        MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_mat(ind-1,roi_ind+15+fsroi_ind+5) = mean(FA12_vec);
                        MD12_mat(ind-1,roi_ind+15+fsroi_ind+5) = mean(MD12_vec);

                        % FREESURFER: Corpus callosum without lesion extraction
                        FA12_vec = FA12(((aseg>=251 & aseg<=255) & lesion~=1));
                        MD12_vec = MD12(((aseg>=251 & aseg<=255) & lesion~=1)).*10^3;
                        MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_mat(ind-1,roi_ind+15+fsroi_ind+6) = mean(FA12_vec);
                        MD12_mat(ind-1,roi_ind+15+fsroi_ind+6) = mean(MD12_vec);
                        
                        % FREESURFER: Corpus callosum & lesion extraction
                        FA12_vec = FA12(((aseg>=251 & aseg<=255) & lesion==1));
                        MD12_vec = MD12(((aseg>=251 & aseg<=255) & lesion==1)).*10^3;
                        MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_mat(ind-1,roi_ind+15+fsroi_ind+7) = mean(FA12_vec);
                        MD12_mat(ind-1,roi_ind+15+fsroi_ind+7) = mean(MD12_vec);

                        % FREESURFER: WM without lesion extraction
                        FA12_vec = FA12( (((aseg>=251 & aseg<=255) | aseg==2 | aseg == 41 | aseg == 77 | aseg == 78 | aseg == 79) & lesion~=1) );
                        MD12_vec = MD12( (((aseg>=251 & aseg<=255) | aseg==2 | aseg == 41 | aseg == 77 | aseg == 78 | aseg == 79) & lesion~=1) ).*10^3;
                        MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_mat(ind-1,roi_ind+15+fsroi_ind+8) = mean(FA12_vec);
                        MD12_mat(ind-1,roi_ind+15+fsroi_ind+8) = mean(MD12_vec);
                        
                        % FREESURFER: Cross-section WM and lesion extraction
                        FA12_vec = FA12( (((aseg>=251 & aseg<=255) | aseg==2 | aseg == 41 | aseg == 77 | aseg == 78 | aseg == 79) & lesion==1) );
                        MD12_vec = MD12( (((aseg>=251 & aseg<=255) | aseg==2 | aseg == 41 | aseg == 77 | aseg == 78 | aseg == 79) & lesion==1) ).*10^3;
                        MD12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_vec(FA12_vec < 0.1 | FA12_vec>1) = [];
                        FA12_mat(ind-1,roi_ind+15+fsroi_ind+9) = mean(FA12_vec);
                        MD12_mat(ind-1,roi_ind+15+fsroi_ind+9) = mean(MD12_vec);
                end             
        end
        disp(['Acquisition n. ' num2str(ind-1) ' processed.'])
end

metrics = [FA12_mat MD12_mat];
metrics(metrics==0) = NaN;

var_name1=cell(0,0);
var_name2=cell(0,0);
for roi_ind = 1:size(lbls,1)
        var_name1{1,roi_ind} = ['FA12_jhu_' num2str(lbls(roi_ind,1))];
        var_name2{1,roi_ind} = ['MD12_jhu_' num2str(lbls(roi_ind,1))];
end
var_name3=cell(0,0);
var_name4=cell(0,0);
for fsroi_ind = 1:size(fslbls,1)
        var_name3{1,fsroi_ind} = ['FA12_fs_' num2str(fslbls(fsroi_ind,1))];
        var_name4{1,fsroi_ind} = ['MD12_fs_' num2str(fslbls(fsroi_ind,1))];
end
var_name = [ {'FA12_jhu_wm' 'FA12_jhu_cc' 'FA12_jhu_cst' 'FA12_jhu_CerebrPeduncle' 'FA12_jhu_aIC' 'FA12_jhu_pIC' 'FA12_jhu_retroIC' 'FA12_jhu_IC' 'FA12_jhu_aCR' 'FA12_jhu_sCR' 'FA12_jhu_pCR' 'FA12_jhu_sagStratum' 'FA12_jhu_cing' 'FA12_jhu_tapet' 'FA12_jhu_cc+tapet'} var_name1 var_name3 ...
    {'FA12_fs_wm' 'FA12_fs_cc' 'FA12_fs_crblwm' 'FA12_fs_splNOles' 'FA12_fs_spl&les' 'FA12_fs_ccNOles' 'FA12_fs_cc&les' 'FA12_fs_wmNOles' 'FA12_fs_wm&les'}...
    {'MD12_jhu_wm' 'MD12_jhu_cc' 'MD12_jhu_cst' 'MD12_jhu_CerebrPeduncle' 'MD12_jhu_aIC' 'MD12_jhu_pIC' 'MD12_jhu_retroIC'...
    'MD12_jhu_IC' 'MD12_jhu_aCR' 'MD12_jhu_sCR' 'MD12_jhu_pCR' 'MD12_jhu_sagStratum' 'MD12_jhu_cing' 'MD12_jhu_tapet' 'MD12_jhu_cc+tapet'} var_name2 var_name4 ...
    {'MD12_fs_wm' 'MD12_fs_cc' 'MD12_fs_crblwm' 'MD12_fs_splNOles' 'MD12_fs_spl&les' 'MD12_fs_ccNOles' 'MD12_fs_cc&les' 'MD12_fs_wmNOles' 'MD12_fs_wm&les'}];
clear var_name1 var_name2

% origin=size(raw,2);
% for rw = 1:size(raw,1)
%         for met=1:size(metrics,2)
%                 if rw == 1
%                         raw{rw,origin+met} = var_name{1,met};
%                 else
%                         raw{rw,origin+met} = metrics(rw-1,met);
%                 end
%         end
% end
% xlswrite(fullfile(project_folder,'results','ALD_dmri.xlsx'),raw);