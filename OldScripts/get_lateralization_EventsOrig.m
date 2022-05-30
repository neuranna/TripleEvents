%% Script to get lateralization values from _lat files
%% 2021-09-15 Anna Ivanova (annaiv@mit.edu) based on a prev script by Yotaro Sueoka

clearvars;

subjects = {'069_KAN_langevents_10_PL2017',...
    '088_KAN_langevents_14_PL2017',...
    '040_KAN_langevents_01_PL2017',...
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
    '076_KAN_langevents_16_PL2017'};
nsub = length(subjects); 
firstSubj = 3;
lastSubj = nsub; % can be adjusted for debugging

subjDir = '/mindhive/evlab/u/Shared/SUBJECTS/';

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
    
    writetable(tables, 'lateralization_EventsOrig.csv');
end

disp(tables)
