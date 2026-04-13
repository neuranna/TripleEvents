%% MEGA fROI OVERLAP SCRIPT - odd vs even runs of the same task
%
% networks: 'language', 'MD', 'DMN', 'events'
%
% 2022-06-10: created by Anna Ivanova
% 2022-06-28: fixed DMN parcel

function [] = fROI_overlap_withintask_20260413(network_index)

%% setup
%addpath('/om2/user/annaiv/scripts');
addpath(genpath('/orcd/archive/evelina9/001/SOFTWARE/spm12'))
rmpath(genpath('/orcd/archive/evelina9/001/SOFTWARE/spm12/external/fieldtrip/compat'))   % wrong istable function

%% specify params
networks = {'language', 'MD', 'DMN', 'events'};
network = networks{network_index};
[parcel_hashname, tasks, contrast_names] = define_network_params(network);

output_dir = '/orcd/archive/evelina9/001/u/ruiminga/TripleEventsRerun_20260410/Data_rerun/data/results_fROI_overlap';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end


%% get files for all relevant participants
data_dir = '/orcd/archive/evelina9/001/u/Shared/SUBJECTS';
session_file = '../Participant_info/TripleEvents_sessions_clean.csv';
session_info = readtable(session_file);

for i=1:length(tasks)   
    task = tasks{i}
    % select participants
    session_info_thisanalysis = get_sessions(session_info, task);
    if height(session_info_thisanalysis)==0
        continue
    end
    % define fROI paths
    subject_info = [rowfun(@(x) sprintf('%03d', x), session_info_thisanalysis(:,"UID")),...
        session_info_thisanalysis(:,task)];
    subjects = rowfun(@(uid, session) make_fROI_path(data_dir, task, uid, session, contrast_names, parcel_hashname),... 
        subject_info, 'OutputVariableNames', {'fROIpath1', 'fROIpath2'});
    fROIfiles1 = cellstr(subjects.fROIpath1);
    fROIfiles2 = cellstr(subjects.fROIpath2);
    % compare
    for nsub=1:length(fROIfiles1)
        output_file = fullfile(output_dir,...
            [sprintf('%03d', session_info_thisanalysis.UID(nsub)) '_' network '_' task '_' network '_' task '.csv'])
        calculate_parcel_overlap(fROIfiles1{nsub}, fROIfiles2{nsub}, output_file);
    end
        
end
end



%% SUPPORTING FUNCTIONS

function [parcel_hashname, loc_tasks, loc_contrast_names] = define_network_params(network)

if strcmp(network, 'events')
    parcel_filepath ='/orcd/archive/evelina9/001/u/ruiminga/TripleEventsRerun_20260410/Parcels/Sent_Sem-Perc_Pic_Sem-Perc_n30_20220530/';
    parcel_file = fullfile(parcel_filepath, 'fROIs_filtered_overlap60_minsize200.nii');   
    loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
    loc_contrast_names = {'Sent_Sem-Perc', 'Pic_Sem-Perc'};
elseif strcmp(network, 'language')
    parcel_filepath = '/orcd/archive/evelina9/001/fMRI_ANALYSIS/ROIS_Nov2020/Func_Lang_LHRH_SN220';
    parcel_file = fullfile(parcel_filepath, 'allParcels_language.nii');  
    loc_tasks = {'SWNlocIPS168_3runs', 'langlocSN'};
    loc_contrast_names = {'S-N'};
elseif strcmp(network, 'MD') 
    parcel_filepath = '/orcd/archive/evelina9/001/fMRI_ANALYSIS/ROIS_Nov2020/Func_MD_LHRH_HE197';
    parcel_file = fullfile(parcel_filepath, 'MDfuncparcels_Apr2017.img');  
    loc_tasks = {'spatialFIN'};
    loc_contrast_names = {'H-E'};
elseif strcmp(network, 'DMN')
    parcel_filepath = '/orcd/archive/evelina9/001/fMRI_ANALYSIS/ROIS_Nov2020/Func_DMN_LHRH_EH197';
    parcel_file = fullfile(parcel_filepath, 'allParcels_DMN.img');
    loc_tasks = {'spatialFIN'};
    loc_contrast_names = {'E-H'};
else
    error('No such network: %s', network)
end
parcel_hashname = char(mlreportgen.utils.hash(fileread(parcel_file)));

end



function [fROIpath1, fROIpath2] = make_fROI_path(data_dir, task, uid, session, contrast_names, parcel_hashname)

session = strcat(uid, '_', session{:}, '_PL2017');
fROInames = get_fROI_name(data_dir, session, task, contrast_names, parcel_hashname);
if (strcmp(task, 'events2move_instrsep') && ismember(string(uid), ["408","776","775"])) || (strcmp(task, 'EventsRev_instrsep') && ismember(string(uid), ["770", "773", "774", "775"])) || (strcmp(task, 'spatialFIN') && ismember(string(uid), ["419"]))
    fROI_folder1 = fullfile(data_dir, session, 'DefaultMNI_PlusStructural', 'results', 'firstlevel', task);
    fROI_folder2 = fullfile(data_dir, session, 'DefaultMNI_PlusStructural', 'results', 'firstlevel', task);
else
    fROI_folder1 = fullfile(data_dir, session, ['firstlevel_' task]);
    fROI_folder2 = fullfile(data_dir, session, ['firstlevel_' task]);
end

fROIpath1_1 = fullfile(fROI_folder1, [fROInames{1} '.ROIs.nii']);
fROIpath1_2 = fullfile(fROI_folder1, [fROInames{1}(1:28) char(mlreportgen.utils.hash([fROInames{1} '.img'])) '_' parcel_hashname '.ROIs.nii']);
fROIpath2_1 = fullfile(fROI_folder2, [fROInames{2} '.ROIs.nii']);
fROIpath2_2 = fullfile(fROI_folder2, [fROInames{2}(1:28) char(mlreportgen.utils.hash([fROInames{2} '.img'])) '_' parcel_hashname '.ROIs.nii']);

if isfile(fROIpath1_1)
    fROIpath1 = fROIpath1_1;
elseif isfile(fROIpath1_2)
    fROIpath1 = fROIpath1_2;
else    error('fROI file not found for subject %s, task %s: looked for %s and %s', uid, task, fROIpath1_1, fROIpath1_2)
end

if isfile(fROIpath2_1)
    fROIpath2 = fROIpath2_1;
elseif isfile(fROIpath2_2)
    fROIpath2 = fROIpath2_2;
else    error('fROI file not found for subject %s, task %s: looked for %s and %s', uid, task, fROIpath2_1, fROIpath2_2)
end

fROIpath1 = cellstr(fROIpath1);
fROIpath2 = cellstr(fROIpath2);
end


function [output_table] = get_sessions(input_table, task)

output_table = input_table(~strcmp(input_table{:,task}, 'NA'),:);

% 199 only did one spatialFIN run
if (strcmp(task, 'spatialFIN'))
    output_table = output_table(output_table.UID~=199,:);
end
end


function [fROInames] = get_fROI_name(data_dir, sub, task, contrast_names, parcel_hashname)

if length(contrast_names)==1
    contrast_nums = retrieve_con_indices(data_dir, sub, task, contrast_names{1});
    fROIname_odd = ['locT_' sprintf('%04d', contrast_nums(1)) ...
        '_percentile-ROI-level0.1_' parcel_hashname];
    fROIname_even = ['locT_' sprintf('%04d', contrast_nums(2)) ...
        '_percentile-ROI-level0.1_' parcel_hashname];
elseif length(contrast_names)==2
    contrast_nums_con1 = retrieve_con_indices(data_dir, sub, task, contrast_names{1});
    contrast_nums_con2 = retrieve_con_indices(data_dir, sub, task, contrast_names{2});
    fROIname_odd = ['locT_' sprintf('%04d', contrast_nums_con1(1)) ...
        '_percentile-ROI-level0.1_max_' sprintf('%04d', contrast_nums_con2(1)) ...
        '_percentile-ROI-level0.1_' parcel_hashname];
    fROIname_even = ['locT_' sprintf('%04d', contrast_nums_con1(2)) ...
        '_percentile-ROI-level0.1_max_' sprintf('%04d', contrast_nums_con2(2)) ...
        '_percentile-ROI-level0.1_' parcel_hashname];
else
    error('unexpected number of contrasts: should be 1 or 2');
end
fROInames = {fROIname_odd, fROIname_even};
end


% Read SPM.mat file 
% return indices of con files corresponding to contrast estimates for odd
% and even runs
function [con_indices] = retrieve_con_indices(sub_dir, sub, task, contrast_name)
try
    load(fullfile(sub_dir, sub, ['firstlevel_' task], 'SPM.mat'));
catch
    load(fullfile(sub_dir, sub, 'DefaultMNI_PlusStructural', 'results', 'firstlevel', task, 'SPM.mat'));
end

% get con indices corresponding to each problem 
con_indices = [];
%prefixes = {'ODD_', 'EVEN_'};
prefixes = {'ORTH_TO_SESSION01_', 'ORTH_TO_SESSION02_'};
for i=1:length(prefixes)
    condition = [prefixes{i} contrast_name];
    con_indices = [con_indices, find(strcmp({SPM.xCon.name}, condition))];
end
end

