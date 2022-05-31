
%%% Generate GSS parcels by taking 10 sessions from each experiment

%% SETUP

addpath(genpath('/om/group/evlab/software/spm12'))
addpath(genpath('/om/group/evlab/software/spm_ss'))
addpath /om/group/evlab/software/conn
conn_module el init

date = '20220415';

my_contrast1 = 'Sent_Sem-Perc';
my_contrast2 = 'Pic_Sem-Perc';


%% GET SESSION IDs
data_dir = "/mindhive/evlab/u/Shared/SUBJECTS";

session_file = '../Participant_info/TripleEvents_sessions_clean.csv';
session_info = readtable(session_file);

experiments = ["EventsOrig_instrsep_2runs",...
    "events2move_instrsep",...
    "EventsRev_instrsep"];

spmfiles={};

for i=1:length(experiments)
    expt = experiments{i};
    % get sessions to be used for GSS parcel definition 
    session_info_GSS = session_info(strcmp(session_info.use4GSS,expt),:);
    % concatenate to get full session name
    subject_info = [rowfun(@(x) sprintf("%03d", x), session_info_GSS(:,"UID")),...
        session_info_GSS(:,expt)];
    subjects = rowfun(@(uid, session) make_spm_paths(data_dir, expt, uid, session),... 
        subject_info, "OutputVariableNames", "SPMpath");
    spmfiles = [spmfiles; cellstr(subjects.SPMpath)];
end


%% run GSS

ss=struct(...
    'swd',['/home/annaiv/annaiv/TripleEvents/GSS_EventsAll/' my_contrast1 '_' my_contrast2 '_n30_' date],...   % output directory
    'files_spm',{spmfiles},...                              % first-level SPM.mat files
    'EffectOfInterest_contrasts',{{my_contrast1, my_contrast2}},...    % contrasts of interest
    'Localizer_contrasts',{{my_contrast1, my_contrast2}},...         % localizer contrast (note: if these contrasts are not orthogonal the toolbox will automatically partition theses contrasts by sessions and perform cross-validation) 
    'Localizer_thr_type',{{'none', 'none'}},...
    'Localizer_thr_p',[.05, .05],... 
    'overlap_thr_vox',.05,...	 
    'overlap_thr_roi',.5,...   
    'type','GcSS',...                                       % can be 'GcSS' (for automatically defined ROIs), 'mROI' (for manually defined ROIs), or 'voxel' (for voxel-based analyses)
    'smooth',6,...                                          % (FWHM mm)
    'model',1,...                                           % can be 1 (one-sample t-test), 2 (two-sample t-test), or 3 (multiple regression)
    'ExplicitMasking', [], ...
    'estimation','OLS',...
    'ask','none');                                       % can be 'none' (any missing information is assumed to take default values), 'missing' (any missing information will be asked to the user), 'all' (it will ask for confirmation on each parameter)
ss=spm_ss_design(ss);                                          % see help spm_ss_design for additional information
ss=spm_ss_estimate(ss);



%% FUNCTIONS 

% CREATE FULL PATHS TO DATA
function [spm_path] = make_spm_paths(data_dir, expt, uid, session)

session = strcat(uid, '_', session{:}, '_PL2017');
spm_path = fullfile(data_dir, session, ['firstlevel_' expt], 'SPM.mat');

end



