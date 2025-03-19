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


% CREATE FULL PATHS TO DATA
function [spm_path] = make_spm_paths(data_dir, expt, uid, session)

session = strcat(uid, '_', session{:}, '_PL2017');
spm_path = fullfile(data_dir, session, ['firstlevel_' expt], 'SPM.mat');

end



