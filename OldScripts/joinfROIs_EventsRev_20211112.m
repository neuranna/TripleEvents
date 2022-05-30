addpath(genpath('/om/group/evlab/software/spm12'))

% define which files to join
filepath = '/home/annaiv/annaiv/TripleEvents/GSS_EventsRev/Sent_Sem-Perc_Pic_Sem-Perc_20210919/';
filenames = {'part001_fROIs.nii', 'part002_fROIs.nii',...
    'part004_fROIs.nii', 'part005_fROIs.nii',...
    'part012_fROIs.nii', 'part015_fROIs.nii'};
num_files = length(filenames);

% join with imcalc (simple add)
spm_jobman('initcfg');
matlabbatch{1}.spm.util.imcalc.input = cell(num_files,1);
for i=1:num_files
    matlabbatch{1}.spm.util.imcalc.input{i} = fullfile(filepath, filenames{i});
end

matlabbatch{1}.spm.util.imcalc.output = fullfile(filepath, 'fROIs_filtered.nii');
matlabbatch{1}.spm.util.imcalc.outdir = [];
% ok I'm just gonna hardcode 6 for now
matlabbatch{1}.spm.util.imcalc.expression = 'i1 + 2 * i2 + 3 * i3 + 4 * i4 + 5 * i5 + 6 * i6';   
spm_jobman('run',matlabbatch);