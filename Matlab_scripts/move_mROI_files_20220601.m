
filename = 'spm_ss_mROI_data.csv';
date = '20220601';
rootpath = '/om5/group/evlab/u/annaiv/TripleEvents';
basename = 'mROI_events';
output_dir_base = fullfile(rootpath, ['mROI_results_' date]);

% events files
loc_tasks = {'EventsRev_instrsep', 'events2move_instrsep'};
main_tasks = {'Categorization', 'Categorization_v2'};

for i=1:length(loc_tasks)
    loc_task = loc_tasks{i};
    for j=1:length(main_tasks)
        main_task = main_tasks{j};
        output_dir = fullfile(output_dir_base, expt);
        mkdir(output_dir);
        copyfile(fullfile(rootpath, basename, [loc_task main_task date],  filename),...
         fullfile(output_dir_base, [loc_task '_' main_task '.csv']));
    end
end

% lang 
% expts_long = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
% lang_expts = {'langlocSN', 'langlocSN', 'SWNlocIPS168_3runs'};
% 
% for i=1:length(expts)
%   expt = expts{i};
%   output_dir = fullfile(output_dir_base, expt);
%   copyfile(fullfile(rootpath, [basename expts_long{i}], [lang_expts{i} '_' date], filename),... 
%     fullfile(output_dir_base, expt, 'EventsAllparcels_lang.csv'));
% end
% 
% % MD
% for i=1:length(expts)-1
%   expt = expts{i};
%   output_dir = fullfile(output_dir_base, expt);
%   copyfile(fullfile(rootpath, [basename expts_long{i}], ['spatialFIN_' date], filename),... 
%     fullfile(output_dir_base, expt, 'EventsAllparcels_spatialFIN.csv'));
% end
