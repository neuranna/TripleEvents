%% MEGA fROI OVERLAP SCRIPT 
%
% networks: 'language', 'MD', 'DMN', 'events'
%
% 2022-06-02: created by Anna Ivanova

function [] = fROI_overlap_mega(network1_index, network2_index)

%% setup
addpath('/om2/user/annaiv/scripts');
addpath(genpath('/om/group/evlab/software/spm12'))
rmpath(genpath('/om/group/evlab/software/spm12/external/fieldtrip/compat'))   % wrong istable function

%% specify params
date = '20220602';

networks = {'language', 'MD', 'DMN', 'events'};
network1 = networks{network1_index};
network2 = networks{network2_index};
[parcel_hashname1, tasks1, contrast_nums_all1] = define_network_params(network1);
[parcel_hashname2, tasks2, contrast_nums_all2] = define_network_params(network2);

output_dir = '/om2/user/annaiv/TripleEvents/data/results_fROI_overlap';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end


%% get SPM files for all relevant participants
data_dir = "/mindhive/evlab/u/Shared/SUBJECTS";

session_file = '../Participant_info/TripleEvents_sessions_clean.csv';
session_info = readtable(session_file);

for i=1:length(tasks1)
    task1 = tasks1{i}
    contrast_nums1 = contrast_nums_all1{i};
    for j=1:length(tasks2)
        task2 = tasks2{j}
        contrast_nums2 = contrast_nums_all2{j};
        if strcmp(task1, task2) && strcmp(network1, network2)
            continue
        end
        % select participants
        session_info_thisanalysis = get_sessions(session_info, task1, task2);
        if height(session_info_thisanalysis)==0
            continue
        end
        % define fROI paths
        subject_info1 = [rowfun(@(x) sprintf('%03d', x), session_info_thisanalysis(:,"UID")),...
            session_info_thisanalysis(:,task1)];
        subjects1 = rowfun(@(uid, session) make_fROI_path(data_dir, task1, uid, session, contrast_nums1, parcel_hashname1),... 
            subject_info1, "OutputVariableNames", "fROIpath");
        fROIfiles1 = cellstr(subjects1.fROIpath');
    
        subject_info2 = [rowfun(@(x) sprintf("%03d", x), session_info_thisanalysis(:,"UID")),...
            session_info_thisanalysis(:,task2)];
        subjects2 = rowfun(@(uid, session) make_fROI_path(data_dir, task2, uid, session, contrast_nums2, parcel_hashname2),... 
            subject_info2, "OutputVariableNames", "fROIpath");
        fROIfiles2 = cellstr(subjects2.fROIpath');
        % compare
        for nsub=1:length(fROIfiles1)
            output_file = fullfile(output_dir,...
                [sprintf('%03d', session_info_thisanalysis.UID(nsub)) '_' network1 '_' task1 '_' network2 '_' task2 '.csv']);
            calculate_parcel_overlap(fROIfiles1{nsub}, fROIfiles2{nsub}, output_file);
        end
    end
        
end
end



%% SUPPORTING FUNCTIONS

function [parcel_hashname, loc_tasks, loc_contrast_nums] = define_network_params(network)

if strcmp(network, 'events')
    parcel_filepath ='/home/annaiv/annaiv/TripleEvents/GSS_EventsAll/Sent_Sem-Perc_Pic_Sem-Perc_n30_20220530/';
    parcel_file = fullfile(parcel_filepath, 'fROIs_filtered_overlap60_minsize200.nii');   
    loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
    loc_contrast_nums = {{104,100}, {140, 136}, {140, 136}};
elseif strcmp(network, 'language')
    parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_Lang_LHRH_SN220';
    parcel_file = fullfile(parcel_filepath, 'allParcels_language.nii');  
    loc_tasks = {'SWNlocIPS168_3runs', 'langlocSN'};
    loc_contrast_nums = {{4},{3}};
elseif strcmp(network, 'MD') 
    parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_MD_LHRH_HE197';
    parcel_file = fullfile(parcel_filepath, 'MDfuncparcels_Apr2017.img');  
    loc_tasks = {'spatialFIN'};
    loc_contrast_nums = {{3}};
elseif strcmp(network, 'DMN')
    parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_DMN_LHRH_EH197';
    parcel_file = fullfile(parcel_filepath, 'allParcels_DMN.img');
    loc_tasks = {'spatialFIN'};
    loc_contrast_nums = {{4}};
else
    error('No such network: %s', network)
end
parcel_hashname = char(mlreportgen.utils.hash(fileread(parcel_file)));

end


function [fROI_path] = make_fROI_path(data_dir, expt, uid, session, contrast_nums, parcel_hashname)

session = strcat(uid, '_', session{:}, '_PL2017');
fROI_path = fullfile(data_dir, session, ['firstlevel_' expt], ...
    get_fROI_name(contrast_nums, parcel_hashname));
end


function [output_table] = get_sessions(input_table, loc_task, main_task)

output_table = input_table(~strcmp(input_table{:,loc_task}, 'NA'),:);
output_table = output_table(~strcmp(output_table{:,main_task}, 'NA'),:);

% 199 only did one spatialFIN run
if (strcmp(loc_task, 'spatialFIN') && strcmp(main_task, 'spatialFIN'))
    output_table = output_table(output_table.UID~=199,:);
end
end

function [fROIname] = get_fROI_name(contrast_nums, parcel_hashname)

if length(contrast_nums)==1
    fROIname = ['locT_' sprintf('%04d', contrast_nums{1}) ...
        '_percentile-ROI-level0.1_' parcel_hashname '.ROIs.nii'];
elseif length(contrast_nums)==2
    fROIname = ['locT_' sprintf('%04d', contrast_nums{1}) ...
        '_percentile-ROI-level0.1_max_' sprintf('%04d', contrast_nums{2}) ...
        '_percentile-ROI-level0.1_' parcel_hashname '.ROIs.nii'];
else
    error('unexpected number of contrasts: should be 1 or 2');
end
end
