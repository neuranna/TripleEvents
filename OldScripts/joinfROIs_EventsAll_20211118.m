addpath(genpath('/om/group/evlab/software/spm12'))

% define which files to join
filepath = '/home/annaiv/annaiv/TripleEvents/GSS_EventsAll/Sent_Sem-Perc_Pic_Sem-Perc_20211118/';
parcels2keep = [1,2,3,4,5,6,7,8,9,10,11,13,15,18,20];
numParcels = length(parcels2keep);

filenames = {};
formula = {};
for i=1:numParcels
    filenames{i} = ['part' num2str(parcels2keep(i),'%03.f') '_fROIs.nii'];
    formula{i} = [num2str(i) ' * i' num2str(i)];
end

% formula: add but each parcel has its own numeric value (not the same as
% before though, sequential)
formula = strjoin(formula, ' + ')

% join with imcalc 
spm_jobman('initcfg');
matlabbatch{1}.spm.util.imcalc.input = cell(numParcels,1);
for i=1:numParcels
    matlabbatch{1}.spm.util.imcalc.input{i} = fullfile(filepath, filenames{i});
end

matlabbatch{1}.spm.util.imcalc.output = fullfile(filepath, 'fROIs_filtered.nii');
matlabbatch{1}.spm.util.imcalc.outdir = [];
matlabbatch{1}.spm.util.imcalc.expression = formula;   
spm_jobman('run',matlabbatch);