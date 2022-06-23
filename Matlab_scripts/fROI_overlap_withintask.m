%% MEGA fROI OVERLAP SCRIPT - odd vs even runs of the same task
%
% networks: 'language', 'MD', 'DMN', 'events'
%
% 2022-06-10: created by Anna Ivanova

function [] = fROI_overlap_withintask(network_index)

%% setup
addpath('/om2/user/annaiv/scripts');
addpath(genpath('/om/group/evlab/software/spm12'))
rmpath(genpath('/om/group/evlab/software/spm12/external/fieldtrip/compat'))   % wrong istable function

%% specify params
date = '20220610';

networks = {'language', 'MD', 'DMN', 'events'};
network = networks{network_index};
[parcel_hashname, tasks, contrast_names] = define_network_params(network);

output_dir = '/om2/user/annaiv/TripleEvents/data/results_fROI_overlap';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end


%% get files for all relevant participants
data_dir = "/mindhive/evlab/u/Shared/SUBJECTS";

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
    fROIfiles1 = cellstr(subjects.fROIpath1');
    fROIfiles2 = cellstr(subjects.fROIpath2');
    % compare
    for nsub=1:length(fROIfiles1)
        output_file = fullfile(output_dir,...
            [sprintf('%03d', session_info_thisanalysis.UID(nsub)) '_' network '_' task '_' task '.csv']);
        calculate_parcel_overlap(fROIfiles1{nsub}, fROIfiles2{nsub}, output_file);
    end
        
end
end



%% SUPPORTING FUNCTIONS

function [parcel_hashname, loc_tasks, loc_contrast_names] = define_network_params(network)

if strcmp(network, 'events')
    parcel_filepath ='/home/annaiv/annaiv/TripleEvents/GSS_EventsAll/Sent_Sem-Perc_Pic_Sem-Perc_n30_20220530/';
    parcel_file = fullfile(parcel_filepath, 'fROIs_filtered_overlap60_minsize200.nii');   
    loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
    loc_contrast_names = {'Sent_Sem-Perc', 'Pic_Sem-Perc'};
elseif strcmp(network, 'language')
    parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_Lang_LHRH_SN220';
    parcel_file = fullfile(parcel_filepath, 'allParcels_language.nii');  
    loc_tasks = {'SWNlocIPS168_3runs', 'langlocSN'};
    loc_contrast_names = {'S-N'};
elseif strcmp(network, 'MD') || strcmp(network, 'DMN')
    parcel_filepath = '/mindhive/evlab/u/Shared/ROIS_Nov2020/Func_MD_LHRH_HE197';
    parcel_file = fullfile(parcel_filepath, 'MDfuncparcels_Apr2017.img');  
    loc_tasks = {'spatialFIN'};
    if strcmp(network, 'MD')
        loc_contrast_names = {'H-E'};
    else
        loc_contrast_names = {'E-H'};
    end
else
    error('No such network: %s', network)
end
parcel_hashname = char(mlreportgen.utils.hash(fileread(parcel_file)));

end



function [output_table] = get_sessions(input_table, task)

output_table = input_table(~strcmp(input_table{:,task}, 'NA'),:);
% 199 only did one spatialFIN run
if (strcmp(task, 'spatialFIN'))
    output_table = output_table(output_table.UID~=199,:);
end
end



function [fROIpath1, fROIpath2] = make_fROI_path(data_dir, task, uid, session, contrast_names, parcel_hashname)

session = strcat(uid, '_', session{:}, '_PL2017');
fROInames = get_fROI_name(data_dir, session, task, contrast_names, parcel_hashname);
fROIpath1 = fullfile(data_dir, session, ['firstlevel_' task], fROInames{1});
fROIpath2 = fullfile(data_dir, session, ['firstlevel_' task], fROInames{2});
end



function [fROInames] = get_fROI_name(data_dir, sub, task, contrast_names, parcel_hashname)

if length(contrast_names)==1
    contrast_nums = retrieve_con_indices(data_dir, sub, task, contrast_names{1});
    fROIname_odd = ['locT_' sprintf('%04d', contrast_nums(1)) ...
        '_percentile-ROI-level0.1_' parcel_hashname '.ROIs.nii'];
    fROIname_even = ['locT_' sprintf('%04d', contrast_nums(2)) ...
        '_percentile-ROI-level0.1_' parcel_hashname '.ROIs.nii'];
elseif length(contrast_names)==2
    contrast_nums_con1 = retrieve_con_indices(data_dir, sub, task, contrast_names{1});
    contrast_nums_con2 = retrieve_con_indices(data_dir, sub, task, contrast_names{2});
    fROIname_odd = ['locT_' sprintf('%04d', contrast_nums_con1(1)) ...
        '_percentile-ROI-level0.1_max_' sprintf('%04d', contrast_nums_con2(1)) ...
        '_percentile-ROI-level0.1_' parcel_hashname '.ROIs.nii'];
    fROIname_even = ['locT_' sprintf('%04d', contrast_nums_con1(2)) ...
        '_percentile-ROI-level0.1_max_' sprintf('%04d', contrast_nums_con2(2)) ...
        '_percentile-ROI-level0.1_' parcel_hashname '.ROIs.nii'];
else
    error('unexpected number of contrasts: should be 1 or 2');
end
fROInames = {fROIname_odd, fROIname_even};
end


% Read SPM.mat file 
% return indices of con files corresponding to contrast estimates for odd
% and even runs
function [con_indices] = retrieve_con_indices(sub_dir, sub, task, contrast_name)

load(fullfile(sub_dir, sub, ['firstlevel_' task], 'SPM.mat'));

% get con indices corresponding to each problem 
con_indices = [];
%prefixes = {'ODD_', 'EVEN_'};
prefixes = {'ORTH_TO_SESSION01_', 'ORTH_TO_SESSION02_'};
for i=1:length(prefixes)
    condition = [prefixes{i} contrast_name];
    con_indices = [con_indices, find(strcmp({SPM.xCon.name}, condition))];
end
end

