%% Estimate lang effects within fROIs from langloc task
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

parcel = 'MDparcels';
parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_MD_LHRH_HE197';
parcel_file = fullfile(parcel_filepath, 'MDfuncparcels_Apr2017.img');  
% parcel = 'langparcels';
% parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_Lang_LHRH_SN220';
% parcel_file = fullfile(parcel_filepath, 'allParcels_language.nii');  

loc_task = 'spatialFIN';
loc_contrast = 'H-E';

main_tasks = {'spatialFIN', 'langlocSN', 'events2move_instrsep'};
main_contrasts_all = {{'H', 'E'}, {'S', 'N'}, {'Pic_Sem','Pic_Perc','Sent_Sem','Sent_Perc'}};

for j=1:length(main_tasks)
    main_task = main_tasks{j}
    main_contrasts = main_contrasts_all{j};

	experiments=struct(...
            'name', main_task, ...
            'pwd1','/mindhive/evlab/u/Shared/SUBJECTS/',...
            'pwd2_loc', ['firstlevel_' loc_task],...
            'pwd2_main', ['firstlevel_' main_task],...
            'data', {{'199_KAN_parametric_20_PL2017',...
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
    for nsub=1:length(experiments.data)
        spmfiles_loc{nsub}=fullfile(experiments.pwd1,experiments.data{nsub},experiments.pwd2_loc,'SPM.mat');
        spmfiles_main{nsub}=fullfile(experiments.pwd1,experiments.data{nsub},experiments.pwd2_main,'SPM.mat');
    end
    
    % Events are in a different session for 199
    if strcmp(main_task, 'events2move_instrsep')
        spmfiles_main{1}=fullfile(experiments.pwd1,'199_FED_20160711c_3T1_PL2017',experiments.pwd2_main,'SPM.mat');
    end
    
    % 199 only has one run of spatialFIN, cannot estimate those effects
    if strcmp(main_task, 'spatialFIN')
        spmfiles_loc(1) = [];
        spmfiles_main(1) = [];
    end
    
	ss=struct(...
            'swd', ['/home/annaiv/annaiv/TripleEvents/mROI_' parcel '_' loc_task '_Events2move/' main_task '_' date],...   % output directory
            'EffectOfInterest_spm',{spmfiles_main},...                      % first-level SPM.mat files
            'Localizer_spm', {spmfiles_loc},...
            'EffectOfInterest_contrasts',{main_contrasts},...    % contrasts of interest
            'Localizer_contrasts',{{loc_contrast}},...         % localizer contrast (note: if these contrasts are not orthogonal the toolbox will automatically partition theses contrasts by sessions and perform cross-validation) 
            'Localizer_thr_type',{{'percentile-ROI-level'}},...
            'Localizer_thr_p',[.1],... 
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

