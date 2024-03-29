% calculate fROI overlap EventsRev
addpath('/om5/group/evlab/u/annaiv/scripts');
addpath(genpath('/om/group/evlab/software/spm12'))

main_task = 'EventsRev_instrsep';
main_label = 'EventsRev';
loc_task = 'langlocSN';
loc_label = 'lang';

main_fROIname = 'locT_0104_percentile-ROI-level0.1_max_0100_percentile-ROI-level0.1_a2b314f1bf0ae6c42dd4acb137923d73.ROIs.nii';
%loc_fROIname = 'locT_0003_percentile-ROI-level0.1_f2f281a0bb9ffa54f781c09b52273cdf.ROIs.nii';
loc_fROIname = 'locT_0003_percentile-ROI-level0.1_a2b314f1bf0ae6c42dd4acb137923d73.ROIs.nii';

experiment = 'EventsRev';

experiments=struct(...
    'name', main_task, ...
    'pwd1','/mindhive/evlab/u/Shared/SUBJECTS/',...
    'pwd2_loc', ['firstlevel_' loc_task],...
    'pwd2_main', ['firstlevel_' main_task],...
    'data', {{'249_FED_20160519a_3T1_PL2017', ...
    '252_FED_20160907b_3T2_PL2017', ...
    '291_FED_20160803c_3T1_PL2017', ...
    '301_FED_20160908b_3T1_PL2017', ...
    '376_FED_20160519b_3T1_PL2017', ...
    '399_FED_20160519d_3T1_PL2017', ...
    '400_FED_20160520a_3T1_PL2017', ...
    '401_FED_20160520d_3T1_PL2017', ...
    '419_FED_20160805a_3T1_PL2017', ...
    '420_FED_20160805b_3T1_PL2017', ...
    '426_FED_20160908d_3T1_PL2017', ...
    '767_FED_20190418b_3T2_PL2017',...
    '769_FED_20190522a_3T2_PL2017',...
    '770_FED_20190523b_3T2_PL2017',...
    '682_FED_20190426a_3T2_PL2017',...
    '773_FED_20190605c_3T2_PL2017',...
    '774_FED_20190605b_3T2_PL2017',...
    '775_FED_20190611a_3T2_PL2017',...
    '778_FED_20190614b_3T2_PL2017'}});


spmfiles_loc={};
spmfiles_main={};
for nsub=1:length(experiments.data)
    spmfiles_loc{nsub}=fullfile(experiments.pwd1,experiments.data{nsub},experiments.pwd2_loc,loc_fROIname);
    spmfiles_main{nsub}=fullfile(experiments.pwd1,experiments.data{nsub},experiments.pwd2_main,main_fROIname);
end

for nsub=1:length(experiments.data)
    output_file = fullfile(['/om5/group/evlab/u/annaiv/TripleEvents/fROI_Overlap_' experiment],...
        [experiments.data{nsub} '_' main_label '_' loc_label '_' experiment '.csv']);
    calculate_parcel_overlap(spmfiles_loc{nsub}, spmfiles_main{nsub}, output_file);
end