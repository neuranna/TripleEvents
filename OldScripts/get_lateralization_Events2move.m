%% Script to get lateralization values from _lat files
%% 2021-07-07 Anna Ivanova (annaiv@mit.edu) based on a prev script by Yotaro Sueoka

clearvars;

subjects = {'777_FED_20190611c_3T2_PL2017',...
    '199_KAN_parametric_20_PL2017',...
    '261_KAN_EvDB_20150304a_PL2017',...
    '291_FED_20150615b_3T2_PL2017',...
    '400_FED_20160520a_3T1_PL2017',...
    '407_FED_20160616a_3T2_PL2017',...
    '419_FED_20160805a_3T1_PL2017',...
    '408_FED_20160617a_3T2_PL2017',...
    '409_FED_20160622a_3T1_PL2017',...
    '410_FED_20160623b_3T2_PL2017',...
    '414_FED_20160711b_3T1_PL2017',...
    '421_FED_20160804b_3T1_PL2017',...
    '730_FED_20190306a_3T2_PL2017',...
    '776_FED_20190611b_3T2_PL2017',...
    '773_FED_20190605c_3T2_PL2017',...
    '774_FED_20190605b_3T2_PL2017',...
    '775_FED_20190611a_3T2_PL2017',...
    '778_FED_20190614b_3T2_PL2017'};
nsub = length(subjects); 
firstSubj = 2;
lastSubj = nsub; % can be adjusted for debugging

subjDir = '/mindhive/evlab/u/Shared/SUBJECTS/';

% outputs
%tables = cell(nsub);

for ss = firstSubj:lastSubj
    
    %Get the id of the subject
    name = split(subjects{ss},'_');
    uid = name{1};
    
    lat_name = [name{2}, '_', name{3}, '_',name{4}, '_lat.csv'];
    
    %Load the lat file
    lat_file = fullfile(subjDir, subjects{ss}, lat_name);
    t = readtable(lat_file);
    disp(t)
    
    % concatenate
    if exist('tables', 'var')
        tables = [tables; t];
    else
        tables = t;
    end
    
    writetable(tables, 'lateralization_Events2move.csv');
end

