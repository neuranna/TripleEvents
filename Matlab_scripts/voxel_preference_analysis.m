% This script examines the voxel's response (contrast effect size) to the pic_sem - pic_perc and sent_sem - sent_perc 

%% get SPM files for all relevant participants
data_dir = "/mindhive/evlab/u/Shared/SUBJECTS";

session_file = '../Participant_info/TripleEvents_sessions_clean.csv';
session_info = readtable(session_file);

localizer_location_file = './localizer_location.csv';
localizer_location = readtable(localizer_location_file);

loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
contrasts = {
    {'Sem_photo' 'Perc_photo' 'Sem_sent' 'Perc_sent'},...
    {'Sem-photo','Perc-photo','Sem-sent','Perc-sent'},...
    {'Pic_Sem','Pic_Perc','Sent_Sem','Sent_Perc'}
};

output_dir = './voxel_preference_analysis';
if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end


for i=1:length(loc_tasks)

    loc_task = loc_tasks{i};
    contrasts_thisloc = contrasts{i};

    % define SPM paths
    session_info_thisanalysis = get_sessions(session_info, loc_task);
    if height(session_info_thisanalysis)==0
        continue
    end

    subject_info_loc = [rowfun(@(x) sprintf("%03d", x), session_info_thisanalysis(:,"UID")),...
        session_info_thisanalysis(:,loc_task)];
    subjects_loc = rowfun(@(uid, session) make_spm_paths(data_dir, loc_task, uid, session),... 
        subject_info_loc, "OutputVariableNames", "SPMpath");
    spmfiles_loc = cellstr(subjects_loc.SPMpath');

    for j = 1:length(spmfiles_loc)
        spmfile_loc = spmfiles_loc{j};

        % Get subject
        subject = subject_info_loc(j,1);
        % in the localizer_location table, get the row with UID = subject, get the path in Localizer column
        localizer_path = localizer_location(strcmp(localizer_location.UID, subject),:).Localizer;
        % Read the nii file in Localizer column
        V_localizer = spm_vol(localizer_path);
        data_localizer = spm_read_vols(V_localizer);

        % the different nonzero values in localizer file, as roi label
        roi_labels = unique(data_localizer);
        roi_labels = roi_labels(roi_labels~=0);

        % Load SPM.mat
        load(spmfile_loc);

        % In the table in SPM.xCon (1xn struct), get the row with name = contrasts_thisloc{1} + 'minus' + contrasts_thisloc{2}, get the row number
        contrast_name_photo = strcat(contrasts_thisloc{1}, 'minus', contrasts_thisloc{2});
        contrast_row_photo = find(strcmp({SPM.xCon.name}, contrast_name_photo));
        % In the table in SPM.xCon (1xn struct), get the row with name = contrasts_thisloc{3} + 'minus' + contrasts_thisloc{4}, get the row number
        contrast_name_sent = strcat(contrasts_thisloc{3}, 'minus', contrasts_thisloc{4});
        contrast_row_sent = find(strcmp({SPM.xCon.name}, contrast_name_sent));

        % in the same folder as SPM, find the con_%04d.nii files corresponding to the contrast_row_photo and contrast_row_sent
        con_photo = fullfile(fileparts(spmfile_loc), sprintf('con_%04d.nii', contrast_row_photo));
        con_sent = fullfile(fileparts(spmfile_loc), sprintf('con_%04d.nii', contrast_row_sent));

        % load the con_%04d.nii files
        V_photo = spm_vol(con_photo);
        V_sent = spm_vol(con_sent);

        % get the data from the con_%04d.nii files
        data_photo = spm_read_vols(V_photo);
        data_sent = spm_read_vols(V_sent);

        % for each roi label, get each the voxels with that label in localizer, and get the effect size for photo and sent conditions, save them in a table
        % including the roi label, the 3D location of the voxel, the effect size for photo, the effect size for sent
        for k = 1:length(roi_labels)
            roi_label = roi_labels(k);
            roi_mask = data_localizer == roi_label;
            [x,y,z] = ind2sub(size(roi_mask), find(roi_mask));
            for l = 1:length(x)
                x_coord = x(l);
                y_coord = y(l);
                z_coord = z(l);
                effect_size_photo = data_photo(x_coord, y_coord, z_coord);
                effect_size_sent = data_sent(x_coord, y_coord, z_coord);
                output_table = [output_table; {roi_label, x_coord, y_coord, z_coord, effect_size_photo, effect_size_sent}];
            end
        end

        % Export the table to a csv file in the output directory
        output_file = fullfile(output_dir, strcat(subject, '_', loc_task, '_voxel_preference.csv'));
    end

end

function [spm_path] = make_spm_paths(data_dir, expt, uid, session)

    session = strcat(uid, '_', session{:}, '_PL2017');
    spm_path = fullfile(data_dir, session, ['firstlevel_' expt], 'SPM.mat');
    end

function [output_table] = get_sessions(input_table, task)

    output_table = input_table(~strcmp(input_table{:,task}, 'NA'),:);
    
end    
