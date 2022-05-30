function [] = compile_voxel_data_Events2move_20220529(subject_index)
%% Compile data from fROIs
% (to be used with a job array)

date = '20220529';

fROI_name = 'locT_0140_percentile-ROI-level0.1_max_0136_percentile-ROI-level0.1_0bbff2e5767928cd53f26fd8ee742200.ROIs.nii';
task = 'events2move_instrsep';

sub_dir = '/mindhive/evlab/u/Shared/SUBJECTS/';
subIDs = {'199_FED_20160711c_3T1_PL2017',...
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
    '778_FED_20190614b_3T2_PL2017'};
        
sub = subIDs{subject_index}
% get info on relevant beta files 
con_indices = retrieve_con_indices(sub, sub_dir, task);
[~, trial_number] = sort(con_indices);

% get fROIs 
fROIs = get_fROI(sub, sub_dir, task, fROI_name);
fROI_indices = unique(fROIs(:))

N_conditions = length(con_indices);
data = cell(length(fROI_indices)-1, N_conditions);

% get the data
for (i=1:length(con_indices))
    index = con_indices(i);
    filename = ['con_' num2str(index,'%04d') '.nii'];
    header = spm_vol(fullfile(sub_dir, sub, ...
        ['firstlevel_' task], filename));
    con = spm_read_vols(header);
    con = con(:);
    for (j=2:length(fROI_indices))    % ignore index 0
        mask = (fROIs==fROI_indices(j));
        mask = mask(:);
        con_fROI = con(mask);
        data{j-1, i} = con_fROI;
    end
end

% save
output_dir = ['voxel_data_' task '_' date];
if ~exist(output_dir, 'dir')
   mkdir(output_dir)
end
save(fullfile(output_dir, sub(1:3)), 'data');
end



%% FUNCTIONS

% Read SPM.mat file for firstlevel_brainCode_singleblock 
% return indices of con files corresponding to each condition
function [con_indices] = retrieve_con_indices(sub, sub_dir, task)

load(fullfile(sub_dir, sub, ['firstlevel_' task], 'SPM.mat'));

%conditions = {'Pic_Sem','Pic_Perc','Sent_Sem','Sent_Perc'};
conditions = {'Sent_Sem-Perc', 'Pic_Sem-Perc'};

% get con indices corresponding to each problem 
con_indices = [];
for i=1:length(conditions)
    condition = conditions{i};
    con_indices = [con_indices, ...
        find(strcmp({SPM.xCon.name}, condition))];
        %find(~cellfun(@isempty, strfind(SPM.xCon.name, condition)))];
end
end


%% load subject-level fROI mask 
function [fROI_mask]  = get_fROI(sub, sub_dir, task, fROI_filename)

fROI_file = fullfile(sub_dir, sub, ['firstlevel_' task],...
    fROI_filename);
header = spm_vol(fROI_file);
fROI_mask = spm_read_vols(header);

end

