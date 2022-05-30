addpath(genpath('/om/group/evlab/software/spm12'))
addpath('/om5/group/evlab/u/annaiv/Useful Code');

% define which files to join
filepath = '/home/annaiv/annaiv/TripleEvents/GSS_EventsAll/Sent_Sem-Perc_Pic_Sem-Perc_n30_20220415/';
overlap_threshold = 0.6;    
min_size = 200;
parcels2keep = filter_GSS_parcels(filepath, overlap_threshold, min_size);
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

matlabbatch{1}.spm.util.imcalc.output = fullfile(filepath, sprintf('fROIs_filtered_overlap%d_minsize%d.nii', overlap_threshold*100, min_size));
matlabbatch{1}.spm.util.imcalc.outdir = [];
matlabbatch{1}.spm.util.imcalc.expression = formula;   
spm_jobman('run',matlabbatch);