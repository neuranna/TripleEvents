%% Estimate lang effects within fROIs from spatialFIN task
%
% my_contrast - localizer contrast
% my_loc_task - defining ROIs
% my_main_task - effect estimation

% 768 did not do spatialFIN, removed here

% setup
addpath(genpath('/om/group/evlab/software/spm12'))
addpath(genpath('/om/group/evlab/software/spm_ss'))
addpath /om/group/evlab/software/conn
conn_module el init

% specify params
date = '20211120';

parcel = 'DMNparcels';
parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_DMN_LHRH_EH197';
parcel_file = fullfile(parcel_filepath, 'allParcels_DMN.img');

loc_task = 'spatialFIN';
loc_contrast = 'E-H';

main_tasks = {'spatialFIN', 'langlocSN', 'EventsRev_instrsep'};
main_contrasts_all = {{'H', 'E'}, {'S', 'N'}, {'Pic_Sem','Pic_Perc','Sent_Sem','Sent_Perc'}};

for j=1:length(main_tasks)
    main_task = main_tasks{j}
    main_contrasts = main_contrasts_all{j};

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
        spmfiles_loc{nsub}=fullfile(experiments.pwd1,experiments.data{nsub},experiments.pwd2_loc,'SPM.mat');
        spmfiles_main{nsub}=fullfile(experiments.pwd1,experiments.data{nsub},experiments.pwd2_main,'SPM.mat');
    end
   
	ss=struct(...
            'swd', ['/home/annaiv/annaiv/TripleEvents/mROI_' parcel '_' loc_task '_EventsRev/' main_task '_' date],...   % output directory
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

