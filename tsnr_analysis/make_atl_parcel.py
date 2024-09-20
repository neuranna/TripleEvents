import nibabel as nib
import numpy as np
import matplotlib.pyplot as plt
from nilearn.plotting import plot_glass_brain
import pandas as pd


def load_atlas(atlas_path='desikan_atlas/Desikan_space-MNI152NLin6_res-2x2x2.nii.gz'):
    '''
    Loads atlas img

    Parameters:
    - atlas_path: path to atlas used, default: Desikan

    Returns:
    - loaded atlas data in an np.array
    '''
    atlas_img = nib.load(atlas_path)
    affine = atlas_img.affine
    atlas_data = atlas_img.get_fdata()  # Load the voxel data (3D array)
    return atlas_data, affine


def get_id_by_region(region_name, atlas_id_file='desikan_atlas/Desikan_with_id.csv'):
    '''
    get region id given region name
    '''
    # load parcel lavel file
    label_file = pd.read_csv(atlas_id_file)

    # Filter the data for the region name
    result = label_file.loc[label_file['region'].str.strip() == region_name, 'id']
    
    # If region is found, return the id, otherwise return a message
    if not result.empty:
        return result.values[0]
    else:
        return "Region not found"


def create_mask(atlas_data, region_labels, anterior=False):
    '''
    Create a binary mask for a given list of region labels.
    
    Parameters:
    - atlas_data: 3D array of atlas voxel data.
    - region_labels: List of region labels to include in the mask.
    - anterior: if True, returns only the anterior portion of mask
    
    Returns:
    - A binary mask where all specified regions are included.
    '''
    # Initialize the mask as all zeros (background)
    mask = np.zeros(atlas_data.shape, dtype=np.int8)
    
    # Add each region to the mask
    for label in region_labels:
        mask |= (atlas_data == label).astype(np.int8)  # Combine regions using logical OR
    
    if anterior == True:
        # Create the y-axis coordinate values based on the shape of the brain_mask
        y_coords = np.arange(mask.shape[1])

        # Set the threshold to half of y-axis
        y_mask = y_coords < max(y_coords)/2

        # Now apply this mask along the y-axis to the brain mask
        mask[:, y_mask, :] = 0

    return mask


def main():
    # Load atlas
    atlas_data, affine = load_atlas()

    ######## define region of interest ########
    regions_of_interest = [
    #  'L_Banks_superior_temporal_sulcus',
    #  'L_inferior_temporal_gyrus',
    #  'L_middle_temporal_gyrus',
    #  'L_superior_temporal_gyrus',
    #  'L_temporal_pole',
    #  'L_transverse_temporal_cortex',
     'R_Banks_superior_temporal_sulcus',
     'R_inferior_temporal_gyrus',
     'R_middle_temporal_gyrus',
     'R_superior_temporal_gyrus',
     'R_temporal_pole',
     'R_transverse_temporal_cortex'
    ]
    ###########################################

    id_list = [get_id_by_region(region) for region in regions_of_interest]
    
    # creates ATL parcel
    mask = create_mask(atlas_data, id_list, anterior=True)
    
    # Exporting nii img
    mask_img = nib.Nifti1Image(mask, affine=affine)
    nib.save(mask_img, 'ATL_parcels/right_full.nii')


if __name__ == '__main__':
    main()