
filename = 'spm_ss_mROI_data.csv';
date = '20240917';
rootpath = '../../TripleEvents_data';
basename = 'mROI_';
output_dir = fullfile(rootpath, 'data', 'results_mROI');
if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end

networks = {'events', 'language', 'MD', 'DMN', 'events_flipped', 'events_picContrast', 'events_sentContrast', ...
'events_flipped_picContrast', 'events_flipped_sentContrast'};
network_loc_tasks = {{'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'},...
    {'SWNlocIPS168_3runs', 'langlocSN'},...
    {'spatialFIN'}, {'spatialFIN'},...
    {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'},...
    {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'},...
    {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'},...
    {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'},...
    {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'} };
main_tasks = {'spatialFIN', 'SWNlocIPS168_3runs', 'langlocSN', ...
    'EventsOrig_instrsep_2runs', 'events2move_instrsep', 'EventsRev_instrsep',...
    'Categorization', 'Categorization_v2', 'Categorization_semperc'};

for i=1:length(networks)
    network = networks{i};
    loc_tasks = network_loc_tasks{i};
    for j=1:length(loc_tasks)
        loc_task = loc_tasks{j};
        for k=1:length(main_tasks)
            main_task = main_tasks{k};
            target_dir = fullfile(rootpath, [basename network], [loc_task '_' main_task '_' date]);
            if exist(target_dir, 'dir')
                copyfile(fullfile(target_dir,  filename),...
                 fullfile(output_dir, [network '_' loc_task '_' main_task '.csv']));
            end
        end
    end
end
