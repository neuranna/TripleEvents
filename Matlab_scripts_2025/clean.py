import pandas as pd
import os

data_dir = '../data_extra_parcels/results_mROI'
for filename in os.listdir(data_dir):
    if filename.endswith('.csv'):
        file_path = os.path.join(data_dir, filename)
        df = pd.read_csv(file_path)
        # rows that EffectSize is NaN, print index and remove
        nan_rows = df[df['EffectSize'].isna()]
        if not nan_rows.empty:
            print(f"File: {filename}, NaN rows: {nan_rows.index.tolist()}")
            df = df.dropna(subset=['EffectSize'])
            df.to_csv(file_path, index=False)
        else:
            print(f"File: {filename}, no NaN rows found.")

