

output_dir = '/om2/user/annaiv/TripleEvents/data/fROI_files';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

networks = {'language', 'MD', 'DMN', 'events'};

for i=1:length(networks)
    network = networks{i};
    [parcel_hashname, loc_tasks, contrast_nums_all] = define_network_params(network);
    for j=1:length(loc_tasks)
        loc_task = loc_tasks{j};

        % select participants
        session_info_thisanalysis = get_sessions(session_info, loc_task);
        if height(session_info_thisanalysis)==0
            continue
        end

        % define fROI paths
        subject_info = [rowfun(@(x) sprintf('%03d', x), session_info_thisanalysis(:,"UID")),...
            session_info_thisanalysis(:,loc_task)];
        subjects = rowfun(@(uid, session) make_fROI_path(data_dir, task1, uid, session, contrast_nums1, parcel_hashname1),... 
            subject_info, "OutputVariableNames", "fROIpath");
        fROIfiles = cellstr(subjects.fROIpath');

        % move
        for nsub=1:length(fROIfiles1)
            UID = session_info_thisanalysis.UID{nsub}
            copyfile(fROIfiles{nsub},...
                 fullfile(output_dir, [UID '_' network '_' loc_task '_fROIs.csv']));
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


function [output_table] = get_sessions(input_table, loc_task)

output_table = input_table(~strcmp(input_table{:,loc_task}, 'NA'),:);

end


function [fROI_path] = make_fROI_path(data_dir, expt, uid, session, contrast_nums, parcel_hashname)

session = strcat(uid, '_', session{:}, '_PL2017');
fROI_path = fullfile(data_dir, session, ['firstlevel_' expt], ...
    get_fROI_name(contrast_nums, parcel_hashname));
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