% This script examines the voxel's response (contrast effect size) to the pic_sem - pic_perc and sent_sem - sent_perc 

%% get SPM files for all relevant participants
data_dir = "/mindhive/evlab/u/Shared/SUBJECTS";

% session_file = '../Participant_info/TripleEvents_sessions_clean.csv';
session_file = '~/Downloads/TripleEvents_sessions_clean.csv';
session_info = readtable(session_file);

loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
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

    

end

function [spm_path] = make_spm_paths(data_dir, expt, uid, session)

    session = strcat(uid, '_', session{:}, '_PL2017');
    spm_path = fullfile(data_dir, session, ['firstlevel_' expt], 'SPM.mat');
    end

function [output_table] = get_sessions(input_table, task)

    output_table = input_table(~strcmp(input_table{:,task}, 'NA'),:);
    
end    
