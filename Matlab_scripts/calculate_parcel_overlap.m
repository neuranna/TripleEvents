%%% For each parcel in file 1 (marked with its own positive integer ID), calculate
%%% the overlap with each parcel in file 2.
%%% reqs: SPM 
%%%
%%% 2022-04-10 - created by Anna Ivanova (annaiv@mit.edu)
%%% 2022-04-14 - updated to use Dice index 
%%% 2022-06-03 - updated to use overlap index! (can use any but this is easiest for diff sized parcels)


function [] = calculate_parcel_overlap(parcel_path1, parcel_path2, output_path)

% read the data
parcels1 = spm_read_vols(spm_vol(parcel_path1));
parcels2 = spm_read_vols(spm_vol(parcel_path2));

if size(parcels1)~=size(parcels2)
    error('Input file size must match')
end

% get individual parcel info
parcel_ids1 = unique(parcels1(:));
parcel_ids2 = unique(parcels2(:));
num_parcels1 = length(parcel_ids1);
num_parcels2 = length(parcel_ids2);

resultsHdr = {'ROI1', 'ROI2', 'NumVoxelsROI1', 'NumVoxelsROI2', ...
    'NumVoxelsShared', 'Overlap'};
numRows = num_parcels1 * num_parcels2;
r = cell(numRows, length(resultsHdr));
results = cell2table(r, 'VariableNames', resultsHdr);

row = 1;
for i=2:length(parcel_ids1)    % start at index 2 to ignore zero valued voxels
    p1 = parcel_ids1(i);
    disp(['Parcel ' num2str(p1)])
    % select voxels from that parcel
    parcel1 = parcels1(:);
    parcel1 = parcel1==p1;
    for j=2:length(parcel_ids2)
        p2 = parcel_ids2(j);
        % select voxels from that parcel
        parcel2 = parcels2(:);
        parcel2 = parcel2==p2;
        % calculate overlap 
        parcelsum = parcel1 + parcel2; 
        num_voxels_shared = sum(parcelsum==2);
        num_voxels_parcel1 = sum(parcel1);
        num_voxels_parcel2 = sum(parcel2);
        overlap = num_voxels_shared / min(num_voxels_parcel1, num_voxels_parcel2);
        % record
        results.ROI1{row} = p1;
        results.ROI2{row} = p2;
        results.NumVoxelsROI1{row} = num_voxels_parcel1;
        results.NumVoxelsROI2{row} = num_voxels_parcel2;
        results.NumVoxelsShared{row} = num_voxels_shared;
        results.Overlap{row} = overlap;
        row = row+1;
    end
end

writetable(results, output_path);