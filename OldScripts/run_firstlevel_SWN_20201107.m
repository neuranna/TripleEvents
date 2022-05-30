function [] = run_firstlevel_SWN_20201107(sub_index)

%expt = 'SWNlocIPS168_2runs';
expt = 'SWNlocIPS168_3runs';

subIDs = {'040_KAN_langevents_01_PL2017',...
    '057_KAN_langevents_02_PL2017',...
    '059_KAN_langevents_04_PL2017',...
    '056_KAN_langevents_05_PL2017',...
    '067_KAN_langevents_06_PL2017',...
    '068_KAN_langevents_07_PL2017',...
    '019_KAN_langevents_08_PL2017',...
    '069_KAN_langevents_10_PL2017',...
    '070_KAN_langevents_11_PL2017',...
    '087_KAN_langevents_12_PL2017',...
    '078_KAN_langevents_13_PL2017',...
    '088_KAN_langevents_14_PL2017',...
    '089_KAN_langevents_15_PL2017',...
    '076_KAN_langevents_16_PL2017'};

subject = subIDs{sub_index};

%cd /mindhive/evlab/u/Shared/ANALYSIS/
%firstlevel_PL2017(subject, expt);

cd /om/group/evlab/software/evlab17/
evlab17_run_model(['/mindhive/evlab/u/Shared/SUBJECTS/' subject '/modelfiles_' expt '.cfg'],...
'/mindhive/evlab/u/annaiv/pipeline_model_Default_hpf200.cfg')

end

