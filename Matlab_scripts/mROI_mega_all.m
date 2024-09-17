%% MEGA MROI SCRIPT - DEFINE fROIs AND ESTIMATE EFFECTS OF INTEREST
%
% localizer_task: 'language', 'MD', 'DMN', 'events'
% main_task_index: currently 1-7
%
% 2022-06-01: created by Anna Ivanova

function [] = mROI_mega_all(network, main_task_index)

%% setup
addpath(genpath('/om/group/evlab/software/spm12'))
addpath(genpath('/om/group/evlab/software/spm_ss'))
addpath /om/group/evlab/software/conn
conn_module el init

%% specify params
date = '20240917';
[parcel_file, loc_tasks, loc_contrasts] = define_network_params(network);

main_tasks = {'spatialFIN', 'SWNlocIPS168_3runs', 'langlocSN', ...
    'EventsOrig_instrsep_2runs', 'events2move_instrsep', 'EventsRev_instrsep',...
    'Categorization', 'Categorization_v2', 'Categorization_semperc'};
main_contrasts_all = {{'H', 'E'}, {'S', 'W', 'N'}, {'S', 'N'}, ...
    {'Sem_photo' 'Perc_photo' 'Sem_sent' 'Perc_sent'},...
    {'Sem-photo','Perc-photo','Sem-sent','Perc-sent'},...
    {'Pic_Sem','Pic_Perc','Sent_Sem','Sent_Perc'},...
    {'LD', 'HD'}, {'LD', 'HD'},{'SEM', 'PERC'}};
main_task = main_tasks{main_task_index}
main_contrasts = main_contrasts_all{main_task_index};


%% get SPM files for all relevant participants
data_dir = "/mindhive/evlab/u/Shared/SUBJECTS";

session_file = '../Participant_info/TripleEvents_sessions_clean.csv';
session_info = readtable(session_file);

for i=1:length(loc_tasks)
    loc_task = loc_tasks{i}

    % define SPM paths
    session_info_thisanalysis = get_sessions(session_info, loc_task, main_task);
    if height(session_info_thisanalysis)==0
        continue
    end

    subject_info_loc = [rowfun(@(x) sprintf("%03d", x), session_info_thisanalysis(:,"UID")),...
        session_info_thisanalysis(:,loc_task)];
    subjects_loc = rowfun(@(uid, session) make_spm_paths(data_dir, loc_task, uid, session),... 
        subject_info_loc, "OutputVariableNames", "SPMpath");
    spmfiles_loc = cellstr(subjects_loc.SPMpath');

    subject_info_main = [rowfun(@(x) sprintf("%03d", x), session_info_thisanalysis(:,"UID")),...
        session_info_thisanalysis(:,main_task)];
    subjects_main = rowfun(@(uid, session) make_spm_paths(data_dir, main_task, uid, session),... 
        subject_info_main, "OutputVariableNames", "SPMpath");
    spmfiles_main = cellstr(subjects_main.SPMpath');
    
    % run the analysis
    ss=struct(...
            'swd', ['/home/ruiminga/TripleEvents_data/mROI_' network '/' loc_task '_' main_task '_' date],...   % output directory
            'EffectOfInterest_spm',{spmfiles_main},...                      % first-level SPM.mat files
            'Localizer_spm', {spmfiles_loc},...
            'EffectOfInterest_contrasts',{main_contrasts},...    % contrasts of interest
            'Localizer_contrasts',{loc_contrasts},...         % localizer contrast (note: if these contrasts are not orthogonal the toolbox will automatically partition theses contrasts by sessions and perform cross-validation) 
            'Localizer_thr_type',{{'percentile-ROI-level'}},...
            'Localizer_thr_p',[.1],... 
            'type','mROI',...                                       % can be 'GcSS' (for automatically defined ROIs), 'mROI' (for manually defined ROIs), or 'voxel' (for voxe$
            'ManualROIs', parcel_file,...
            'overwrite', 1, ...
            'model',1,...                                           % can be 1 (one-sample t-test), 2 (two-sample t-test), or 3 (multiple regression)
            'ExplicitMasking', '', ...
            'estimation','OLS',...
            'ask','none');                                     % can be 'none' (any missing information is assumed to take default values), 'missing' (any missing informat$
    if length(loc_contrasts)>1
        ss.Localizer_conjunction_type = 'max';
    end

    ss=spm_ss_design(ss);                                          % see help spm_ss_design for additional information
    ss=spm_ss_estimate(ss);
end
end



%% SUPPORTING FUNCTIONS

function [parcel_file, loc_tasks, loc_contrasts] = define_network_params(network)

if strcmp(network, 'events')
    parcel_filepath = '/home/ruiminga/TripleEvents/new_parcels/';
    parcel_file = fullfile(parcel_filepath, 'fROIs_filtered_overlap60_minsize200_relabeled.nii');  
    loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
    loc_contrasts = {'Sent_Sem-Perc', 'Pic_Sem-Perc'};
elseif strcmp(network, 'language')
    parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_Lang_LHRH_SN220';
    parcel_file = fullfile(parcel_filepath, 'allParcels_language.nii');  
    loc_tasks = {'SWNlocIPS168_3runs', 'langlocSN'};
    loc_contrasts = {'S-N'};
elseif strcmp(network, 'MD') 
    parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_MD_LHRH_HE197';
    parcel_file = fullfile(parcel_filepath, 'MDfuncparcels_Apr2017.img');  
    loc_tasks = {'spatialFIN'};
    loc_contrasts = {'H-E'};
elseif strcmp(network, 'DMN')
    parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_DMN_LHRH_EH197';
    parcel_file = fullfile(parcel_filepath, 'allParcels_DMN.img');
    loc_tasks = {'spatialFIN'};
    loc_contrasts = {'E-H'};

elseif strcmp(network, 'events_flipped')
    parcel_filepath = '/home/ruiminga/TripleEvents/new_parcels/';
    parcel_file = fullfile(parcel_filepath, 'fROIs_filtered_overlap60_minsize200_relabeled_flipped.nii');  
    loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
    loc_contrasts = {'Sent_Sem-Perc', 'Pic_Sem-Perc'};
elseif strcmp(network, 'events_picContrast')
    parcel_filepath = '/home/ruiminga/TripleEvents/new_parcels/';
    parcel_file = fullfile(parcel_filepath, 'fROIs_filtered_overlap60_minsize200_relabeled.nii');  
    loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
    loc_contrasts = {'Pic_Sem-Perc'};
elseif strcmp(network, 'events_flipped_picContrast')
    parcel_filepath = '/home/ruiminga/TripleEvents/new_parcels/';
    parcel_file = fullfile(parcel_filepath, 'fROIs_filtered_overlap60_minsize200_relabeled_flipped.nii');  
    loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
    loc_contrasts = {'Pic_Sem-Perc'};
elseif strcmp(network, 'events_sentContrast')
    parcel_filepath = '/home/ruiminga/TripleEvents/new_parcels/';
    parcel_file = fullfile(parcel_filepath, 'fROIs_filtered_overlap60_minsize200_relabeled.nii');  
    loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
    loc_contrasts = {'Sent_Sem-Perc'};
elseif strcmp(network, 'events_flipped_sentContrast')
    parcel_filepath = '/home/ruiminga/TripleEvents/new_parcels/';
    parcel_file = fullfile(parcel_filepath, 'fROIs_filtered_overlap60_minsize200_relabeled_flipped.nii');  
    loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
    loc_contrasts = {'Sent_Sem-Perc'};
else
    
    error('No such network: %s', network)
end
end


function [spm_path] = make_spm_paths(data_dir, expt, uid, session)

session = strcat(uid, '_', session{:}, '_PL2017');
spm_path = fullfile(data_dir, session, ['firstlevel_' expt], 'SPM.mat');
end


function [output_table] = get_sessions(input_table, loc_task, main_task)

output_table = input_table(~strcmp(input_table{:,loc_task}, 'NA'),:);
output_table = output_table(~strcmp(output_table{:,main_task}, 'NA'),:);

% 199 only did one spatialFIN run
if (strcmp(loc_task, 'spatialFIN') && strcmp(main_task, 'spatialFIN'))
    output_table = output_table(output_table.UID~=199,:);
end


end
