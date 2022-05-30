
date = '20211113';

% setup
addpath(genpath('/om/group/evlab/software/spm12'))
addpath(genpath('/om/group/evlab/software/spm_ss'))
addpath /om/group/evlab/software/conn
conn_module el init

% specify params
my_contrast = 'Sem-Perc';

parcel_filepath = '/home/annaiv/annaiv/TripleEvents/GSS_EventsRev/Sent_Sem-Perc_Pic_Sem-Perc_20210919/';
parcel_file = fullfile(parcel_filepath, 'fROIs_filtered.nii');   

experiments=struct(...
    'name','events2move_instrsep',...% events subjects
    'pwd1','/mindhive/evlab/u/Shared/SUBJECTS',...
    'pwd2','firstlevel_events2move_instrsep',...
    'data', {{'199_FED_20160711c_3T1_PL2017',...
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
    '778_FED_20190614b_3T2_PL2017'}});
    
spmfiles={};
for nsub=1:length(experiments.data),
    spmfiles{nsub}=fullfile(experiments.pwd1,experiments.data{nsub},experiments.pwd2,'SPM.mat');
end

ss=struct(...
    'swd', ['/home/annaiv/annaiv/TripleEvents/mROI_EventsRevparcels_Events2move/' my_contrast '_' date],...         % output directory
    'files_spm',{spmfiles},...                              % first-level SPM.mat files
    'EffectOfInterest_contrasts',{{'Sem-photo','Perc-photo','Sem-sent','Perc-sent'}},...    % contrasts of interest
    'Localizer_contrasts',{{my_contrast}},...         % localizer contrast (note: if these contrasts are not orthogonal the toolbox will automatically partition theses contrasts by sessions and perform cross-validation) 
    'Localizer_thr_type',{{'percentile-ROI-level'}},...
    'Localizer_thr_p',[.1],... 
    'type','mROI',...                                       % can be 'GcSS' (for automatically defined ROIs), 'mROI' (for manually defined ROIs), or 'voxel' (for voxel-based analyses)
    'ManualROIs', parcel_file,...
    'overwrite', 1, ...
    'model',1,...                                           % can be 1 (one-sample t-test), 2 (two-sample t-test), or 3 (multiple regression)
    'ExplicitMasking', [], ...    
    'estimation','OLS',...
    'ask','none');                                       % can be 'none' (any missing information is assumed to take default values), 'missing' (any missing information will be asked to the user), 'all' (it will ask for confirmation on each parameter)
ss=spm_ss_design(ss);                                          % see help spm_ss_design for additional information
ss=spm_ss_estimate(ss);