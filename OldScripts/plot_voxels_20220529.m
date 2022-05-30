
date = '20220529';
%task = 'events2move_instrsep';
task = 'EventsRev_instrsep';

output_dir = ['voxel_data_' task '_' date];
load(fullfile(output_dir, '778.mat'));

[num_fROIs, num_conds] = size(data);

i = 11;
%plot(data{i,1}, data{i,2}, '.');
%axis equal
%xlim([0,5]);
%ylim([0,5]);

diff_scores = data{i,1} - data{i,2};
histogram(diff_scores)