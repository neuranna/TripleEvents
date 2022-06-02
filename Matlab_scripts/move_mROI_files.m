
filename = 'spm_ss_mROI_data.csv';
date = '20220601';
rootpath = '/om2/user/annaiv/TripleEvents';
basename = 'mROI_';
output_dir = fullfile(rootpath, 'results_mROI');

networks = {'events', 'language', 'MD', 'DMN'};
network_loc_tasks = {{'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'},...
    {'SWNlocIPS168_3runs', 'langlocSN'},...
    {'spatialFIN'}, {'spatialFIN'}};
main_tasks = {'spatialFIN', 'SWNlocIPS168_3runs', 'langlocSN', ...
    'EventsOrig_instrsep_2runs', 'events2move_instrsep', 'EventsRev_instrsep',...
    'Categorization', 'Categorization_v2'};

for i=1:length(networks)
    network = networks{i};
    loc_tasks = network_loc_tasks{i};
    for j=1:length(loc_tasks)
        loc_task = loc_tasks{j};
        for k=1:length(main_tasks)
            main_task = main_tasks{k};
            output_dir = fullfile(output_dir, expt);
            mkdir(output_dir);
            copyfile(fullfile(rootpath, [basename network], [loc_task '_' main_task '_' date],  filename),...
             fullfile(output_dir, [network '_' loc_task '_' main_task '.csv']));
        end
    end
end
