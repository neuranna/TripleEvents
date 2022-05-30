
filename = 'spm_ss_mROI_data.csv';
date = '20220415';
rootpath = '/om5/group/evlab/u/annaiv/TripleEvents';
basename = 'mROI_EventsAllparcels_';
output_dir_base = fullfile(rootpath, ['mROI_results_' date]);

% events files
expts = {'EventsRev', 'Events2move', 'EventsOrig'};

for i=1:length(expts)
  expt = expts{i};
  output_dir = fullfile(output_dir_base, expt);
  mkdir(output_dir);
  copyfile(fullfile(rootpath, [basename expt], ['Sent_Sem-Perc_Pic_Sem-Perc_' date],  filename),...
     fullfile(output_dir_base, expt, 'EventsAllparcels_events.csv'));
end

% lang 
expts_long = {'EventsRev_instrsep', 'events2move_instrsep', 'EventsOrig_instrsep_2runs'};
lang_expts = {'langlocSN', 'langlocSN', 'SWNlocIPS168_3runs'};

for i=1:length(expts)
  expt = expts{i};
  output_dir = fullfile(output_dir_base, expt);
  copyfile(fullfile(rootpath, [basename expts_long{i}], [lang_expts{i} '_' date], filename),... 
    fullfile(output_dir_base, expt, 'EventsAllparcels_lang.csv'));
end

% MD
for i=1:length(expts)-1
  expt = expts{i};
  output_dir = fullfile(output_dir_base, expt);
  copyfile(fullfile(rootpath, [basename expts_long{i}], ['spatialFIN_' date], filename),... 
    fullfile(output_dir_base, expt, 'EventsAllparcels_spatialFIN.csv'));
end
