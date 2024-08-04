import h5py
import numpy as np
import pandas as pd
import nibabel as nib
from scipy.stats import pearsonr
import nilearn.surface as surface
import nilearn.datasets as datasets
from nilearn import datasets, plotting, surface
import matplotlib.pyplot as plt
import nilearn.plotting as plotting
from os.path import join, exists, split
import os
from tqdm import tqdm


SUBJECTS = '/nese/mit/group/evlab/u/Shared/SUBJECTS/'
ANALYSIS_PATH = '/nese/mit/group/evlab/u/jshe/TripleEvents/tsnr_analysis'
SUBJECT_INFO_PATH = '/nese/mit/group/evlab/u/jshe/TripleEvents/Participant_info/TripleEvents_sessions_clean.csv'


def get_unique(matrix):
    return np.unique(matrix.reshape(-1))

def calculate_tsnr(data, save_path):
    '''
    calcuate tsnr matrix and save the matrix to desired directory
    '''
    mean_signal = np.mean(data, axis=-1)
    std_signal = np.std(data, axis=-1)

    tsnr = np.divide(mean_signal, std_signal, where=std_signal != 0)
    tsnr[std_signal == 0] = 0

    # Adding a small constant (e.g., 1e-10) to avoid log(0) which is undefined
    tsnr += 1e-10
    tsnr = np.log(tsnr)

    np.save(save_path, tsnr)
    return tsnr


def assert_shape(matrix):
    '''
    Asserts that the first three elements of the brain matrix match the MNI space
    '''
    expected_shape = (91,109,91)
    assert matrix.shape[:3] == expected_shape, f"Shape mismatch: expected {expected_shape}, got {matrix.shape[:3]}"


def load_img(file_path):
    img = nib.load(file_path)
    data = img.get_fdata()
    affine, header = img.affine, img.header
    assert_shape(data)
    return data, affine, header


def plot_tsnr(brain_matrix, affine, header, save_path):
    '''
    input: np array of 3d matrix
    plot six views of brain tsnr results
    '''
    tsnr = brain_matrix

    # Convert to nifti image
    tsnr_img = nib.Nifti1Image(tsnr, affine, header)

    # Load a surface mesh (fsaverage)
    fsaverage = datasets.fetch_surf_fsaverage()

    # Project the 3D volume onto the fsaverage surface for both hemispheres
    texture_left = surface.vol_to_surf(tsnr_img, fsaverage.pial_left)
    texture_right = surface.vol_to_surf(tsnr_img, fsaverage.pial_right)

    # Create a figure with subplots in a single row
    fig, axes = plt.subplots(1, 6, subplot_kw={'projection': '3d'}, figsize=(30, 5))

    # Adjust the spacing of subplots
    fig.subplots_adjust(right=0.5)

    # Plot left hemisphere lateral view
    plotting.plot_surf_stat_map(
        fsaverage.infl_left, texture_left,
        hemi='left',
        view='lateral',
        axes=axes[0],
        title='Left Hemisphere - Lateral View',
        threshold=0.2,
        colorbar=False
    )

    # Plot right hemisphere lateral view
    plotting.plot_surf_stat_map(
        fsaverage.infl_right, texture_right,
        hemi='right',
        view='lateral',
        axes=axes[1],
        title='Right Hemisphere - Lateral View',
        threshold=0.2,
        colorbar=False
    )

    # Plot left hemisphere medial view
    plotting.plot_surf_stat_map(
        fsaverage.infl_left, texture_left,
        hemi='left',
        view='medial',
        axes=axes[2],
        title='Left Hemisphere - Medial View',
        threshold=0.2,
        colorbar=False
    )

    # Plot right hemisphere medial view
    plotting.plot_surf_stat_map(
        fsaverage.infl_right, texture_right,
        hemi='right',
        view='medial',
        axes=axes[3],
        title='Right Hemisphere - Medial View',
        threshold=0.2,
        colorbar=False
    )

    # Plot left hemisphere ventral view
    plotting.plot_surf_stat_map(
        fsaverage.infl_left, texture_left,
        hemi='left',
        view='ventral',
        axes=axes[4],
        title='Left Hemisphere - Ventral View',
        threshold=0.2,
        colorbar=False
    )

    # Plot right hemisphere ventral view
    plotting.plot_surf_stat_map(
        fsaverage.infl_right, texture_right,
        hemi='right',
        view='ventral',
        axes=axes[5],
        title='Right Hemisphere - Ventral View',
        threshold=0.2,
        colorbar=True
    )

    plt.tight_layout()

    # Save the plot
    plt.savefig(save_path, bbox_inches='tight')
    plt.close()


# getting a list of subject IDs
subject_df = pd.read_csv(SUBJECT_INFO_PATH)

session_id_list = []
for i in range(len(subject_df)):
    if not pd.isna(subject_df['EventsOrig_instrsep_2runs'][i]):
        session_id = subject_df['EventsOrig_instrsep_2runs'][i]
    elif not pd.isna(subject_df['events2move_instrsep'][i]):
        session_id = subject_df['events2move_instrsep'][i]
    elif not pd.isna(subject_df['EventsRev_instrsep'][i]):
        session_id = subject_df['EventsRev_instrsep'][i]
    else:
        raise ValueError('Session ID not found')

    uid = str(subject_df['UID'][i])

    # handling cases where double digit uids have 0 added in front of them
    if len(uid) == 2:
        uid = '0' + uid
        
    session_id_list.append(uid + '_'+ session_id+'_PL2017')



for session_id in tqdm(session_id_list, desc="Processing sessions"):
    data_path = join(SUBJECTS, session_id, 'nii')
    save_matrix_dir = join(ANALYSIS_PATH, 'tsnr_matrices', session_id)
    save_plot_dir = join(ANALYSIS_PATH, 'tsnr_plots', session_id)

    if not exists(save_matrix_dir):
        os.makedirs(save_matrix_dir)

    if not exists(save_plot_dir):
        os.makedirs(save_plot_dir)

    for file in os.listdir(data_path):
        if file.startswith('swr') and file.endswith('.nii'):
            filepath = f'{data_path}/{file}'
            save_file_name = file.strip('.nii')

            data, affine, header = load_img(filepath)
            
            tsnr_matrix = calculate_tsnr(data, f'{save_matrix_dir}/{save_file_name}.npy')
            plot_tsnr(tsnr_matrix, affine=affine, header=header, save_path=f'{save_plot_dir}/{save_file_name}.png')


