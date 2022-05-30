%% Estimate lang effects within fROIs from spatialFIN task
%
% my_contrast - localizer contrast
% my_loc_task - defining ROIs
% my_main_task - effect estimation  (for EventsOrig, there's no spatialFIN)

% setup
addpath(genpath('/om/group/evlab/software/spm12'))
addpath(genpath('/om/group/evlab/software/spm_ss'))
addpath /om/group/evlab/software/conn
conn_module el init

% specify params
date = '20220414';

parcel = 'EventsAllparcels';
parcel_filepath = '/home/annaiv/annaiv/TripleEvents/GSS_EventsAll/ODD_Sent_Sem-Perc_ODD_Pic_Sem-Perc_20220414/';
parcel_file = fullfile(parcel_filepath, 'fROIs_filtered_overlap60_minsize200.nii');  

loc_task = 'EventsOrig_instrsep_2runs';
loc_contrast1 = 'ODD_Sent_Sem-Perc';
loc_contrast2 = 'ODD_Pic_Sem-Perc';

main_tasks = {'SWNlocIPS168_3runs'};
main_contrasts_all = {{'S', 'N', 'W'}};

for j=1:length(main_tasks)
    main_task = main_tasks{j}
    main_contrasts = main_contrasts_all{j};

	experiments=struct(...
            'name', main_task, ...
            'pwd1','/mindhive/evlab/u/Shared/SUBJECTS/',...
            'pwd2_loc', ['firstlevel_' loc_task],...
            'pwd2_main', ['firstlevel_' main_task],...
            'data', {{'040_KAN_langevents_01_PL2017',...
            '057_KAN_langevents_02_PL2017',...
            '059_KAN_langevents_04_PL2017',...
            '056_KAN_langevents_05_PL2017',...
            '067_KAN_langevents_06_PL2017',...
            '068_KAN_langevents_07_PL2017',...
            '019_KAN_langevents_08_PL2017',...
            '070_KAN_langevents_11_PL2017',...
            '087_KAN_langevents_12_PL2017',...
            '078_KAN_langevents_13_PL2017',...
            '089_KAN_langevents_15_PL2017',...
            '076_KAN_langevents_16_PL2017' }});
   

    spmfiles_loc={};
    spmfiles_main={};
    for nsub=1:length(experiments.data)
        spmfiles_loc{nsub}=fullfile(experiments.pwd1,experiments.data{nsub},experiments.pwd2_loc,'SPM.mat');
        spmfiles_main{nsub}=fullfile(experiments.pwd1,experiments.data{nsub},experiments.pwd2_main,'SPM.mat');
    end

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

