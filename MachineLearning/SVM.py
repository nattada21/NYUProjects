import pandas as pd
from sklearn.model_selection import cross_val_score
from sklearn.svm import SVC

# Load the RNASeqData.xlsx file
file_path = 'RNASeqData.xlsx'  # Load the file
data_df = pd.read_excel(file_path) # Read the data from file into a dataframe

# Filter to get the last 60 columns that start with "Raw" and set "ID" as the index
raw_data = data_df.filter(regex="^Raw").copy()  # Select columns that start with "Raw"
raw_data.index = data_df['ID']  # Set "ID" column as the index

# Save "ID" column as gene_ids for potential future use
gene_ids = data_df['ID']

# Calculate the sum of each column
raw_cols_sums = raw_data.sum()

# Normalize each value by the column sum and multiply by 1,000,000 to get CPM
norm_cpm_df = raw_data.div(raw_cols_sums) * 1_000_000

# Set the gene_ids as the index of the dataframe
norm_cpm_df.set_index(gene_ids, inplace=True)

# Set the top 10 genes
top10_ci_genes = ['LOC105372578', 'MCEMP1', 'MMP9', 'SOCS3', 'ANXA3',
                  'G0S2', 'IL1R2', 'PFKFB3', 'OSM', 'SEMA6B']

# Filter norm_cpm_df to only contain the top 10 genes
norm_cpm_df_top10 = norm_cpm_df.loc[top10_ci_genes]

# Split into healthy and CF dataframes based on column names
hc_top10 = norm_cpm_df_top10.filter(like='HC', axis=1)
cf_top10 = norm_cpm_df_top10.filter(like='Base', axis=1)

# Transpose the dataframes
hc_top10_t = hc_top10.T
cf_top10_t = cf_top10.T

# Add the label columns
hc_top10_t['Y'] = 0  # Healthy samples labeled as 0
cf_top10_t['Y'] = 1  # CF samples labeled as 1

# Merge the two dataframes
hc_cf_top10 = pd.concat([hc_top10_t, cf_top10_t])

# Split hc_cf_top10 into X (features) and Y (labels)
X = hc_cf_top10.drop('Y', axis=1)
Y = hc_cf_top10['Y']

# Perform 5x cross-validation with different C values and kernels
svm_results = [] 
for C_value in [0.1, 1, 10]:  # Trying different values for C
    for kernel_type in ['linear', 'rbf']:  # Trying different kernel types
        svm = SVC(C=C_value, kernel=kernel_type, random_state=1)
        scores = cross_val_score(svm, X, Y, cv=5)
        svm_results.append((C_value, kernel_type, scores.mean()))

# Report the best combination
best_svm = max(svm_results, key=lambda item: item[2])
print(f'Best combination: C={best_svm[0]}, kernel={best_svm[1]}, score={best_svm[2]}')
