%% Estimate lang effects within fROIs from spatialFIN task
%
% my_contrast - localizer contrast
% my_loc_task - defining ROIs
% my_main_task - effect estimation

% setup
addpath(genpath('/om/group/evlab/software/spm12'))
addpath(genpath('/om/group/evlab/software/spm_ss'))
addpath /om/group/evlab/software/conn
conn_module el init

% specify params
date = '20211120';

parcel = 'EventsAllparcels';
parcel_filepath = '/home/annaiv/annaiv/TripleEvents/GSS_EventsAll/Sent_Sem-Perc_Pic_Sem-Perc_20211118/';
parcel_file = fullfile(parcel_filepath, 'fROIs_filtered.nii');  

loc_task = 'events2move_instrsep';
loc_contrast1 = 'Sent_Sem-Perc';
loc_contrast2 = 'Pic_Sem-Perc';

main_tasks = {'spatialFIN', 'langlocSN'};
main_contrasts_all = {{'H', 'E'}, {'S', 'N'}};

for j=1:length(main_tasks)
    main_task = main_tasks{j}
    main_contrasts = main_contrasts_all{j};

	experiments=struct(...
            'name', main_task, ...
            'pwd1','/mindhive/evlab/u/Shared/SUBJECTS/',...
            'pwd2_loc', ['firstlevel_' loc_task],...
            'pwd2_main', ['firstlevel_' main_task],...
            'data_loc', {{'199_FED_20160711c_3T1_PL2017',...
            '261_FED_20160523c_3T2_PL2017',...
            '291_FED_20160803c_3T1_PL2017',...
            '400_FED_20160520a_3T1_PL2017',...
            '407_FED_20160804a_3T1_PL2017',...
            '419_FED_20160805a_3T1_PL2017',...
            '408_FED_20160711a2_3T1_PL2017',...
            '409_FED_20160622a_3T1_PL2017',...
            '410_FED_20160623b_3T2_PL2017',...
            '730_FED_20190306a_3T2_PL2017',...
            '776_FED_20190611b_3T2_PL2017',...
            '773_FED_20190605c_3T2_PL2017',...
            '774_FED_20190605b_3T2_PL2017',...
            '775_FED_20190611a_3T2_PL2017',...
            '778_FED_20190614b_3T2_PL2017'}},...
            'data_main', {{'199_KAN_parametric_20_PL2017',...
            '261_FED_20160523c_3T2_PL2017',...
            '291_FED_20160803c_3T1_PL2017',...
            '400_FED_20160520a_3T1_PL2017',...
            '407_FED_20160804a_3T1_PL2017',...
            '419_FED_20160805a_3T1_PL2017',...
            '408_FED_20160711a2_3T1_PL2017',...
            '409_FED_20160622a_3T1_PL2017',...
            '410_FED_20160623b_3T2_PL2017',...
            '730_FED_20190306a_3T2_PL2017',...
            '776_FED_20190611b_3T2_PL2017',...
            '773_FED_20190605c_3T2_PL2017',...
            '774_FED_20190605b_3T2_PL2017',...
            '775_FED_20190611a_3T2_PL2017',...
            '778_FED_20190614b_3T2_PL2017'}});

    spmfiles_loc={};
    spmfiles_main={};
    for nsub=1:length(experiments.data_loc)
        spmfiles_loc{nsub}=fullfile(experiments.pwd1,experiments.data_loc{nsub},experiments.pwd2_loc,'SPM.mat');
        spmfiles_main{nsub}=fullfile(experiments.pwd1,experiments.data_main{nsub},experiments.pwd2_main,'SPM.mat');
    end
    
    % some subjects did not do spatialFIN
%     if strcmp(main_task, 'spatialFIN')
%         spmfiles_loc(end) = [];
%         spmfiles_main(end) = [];
%     end

	ss=struct(...
            'swd', ['/home/annaiv/annaiv/TripleEvents/mROI_' parcel '_' loc_task '/' main_task '_' date],...   % output directory
            'EffectOfInterest_spm',{spmfiles_main},...                      % first-level SPM.mat files
            'Localizer_spm', {spmfiles_loc},...
            'EffectOfInterest_contrasts',{main_contrasts},...    % contrasts of interest
            'Localizer_contrasts',{{loc_contrast1, loc_contrast2}},...         % localizer contrast (note: if these contrasts are not orthogonal the toolbox will automatically partition theses contrasts by sessions and perform cross-validation) 
            'Localizer_thr_type',{{'percentile-ROI-level'}},...
            'Localizer_thr_p',[.1],... 
            'Localizer_conjunction_type', 'max',...
            'type','mROI',...                                       % can be 'GcSS' (for automatically defined ROIs), 'mROI' (for manually defined ROIs), or 'voxel' (for voxe$
            'ManualROIs', parcel_file,...
            'overwrite', 1, ...
            'model',1,...                                           % can be 1 (one-sample t-test), 2 (two-sample t-test), or 3 (multiple regression)
            'ExplicitMasking', '', ...
            'estimation','OLS',...
            'ask','none');                                     % can be 'none' (any missing information is assumed to take default values), 'missing' (any missing informat$
    ss=spm_ss_design(ss);                                          % see help spm_ss_design for additional information
    ss=spm_ss_estimate(ss);
end

