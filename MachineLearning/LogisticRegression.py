# Import libraries
from sklearn.datasets import load_iris # Iris Data
from sklearn.linear_model import LogisticRegression # For logistic regression
from sklearn.model_selection import train_test_split # For training and testing
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score 
import numpy as np
import pandas as pd

# Load the iris dataset
iris = load_iris()
X = iris.data
y = iris.target
feature_names = iris.feature_names

# Normalize the features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Define function to train Logistic Regression and evaluate accuracy
def train_logistic_regression(X, y, C=1.0, penalty='l2', solver='lbfgs'):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)
    model = LogisticRegression(C=C, penalty=penalty, solver=solver, max_iter=10000)
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    return accuracy, model.n_iter_

# Case 1: Using 2 features at a time (6 combinations)
combinations_2 = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
results_2_features = []

for combo in combinations_2:
    X_subset = X_scaled[:, combo]
    accuracy, n_iter = train_logistic_regression(X_subset, y)
    results_2_features.append([feature_names[combo[0]], feature_names[combo[1]], accuracy, n_iter[0]])

# Results for 2 features
df_2_features = pd.DataFrame(results_2_features, columns=["Feature 1", "Feature 2", "Accuracy", "Iterations"])
print(df_2_features)

# Case 2: Using 3 features at a time (4 combinations)
combinations_3 = [(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)]
results_3_features = []

for combo in combinations_3:
    X_subset = X_scaled[:, combo]
    accuracy, n_iter = train_logistic_regression(X_subset, y)
    results_3_features.append([feature_names[combo[0]], feature_names[combo[1]], feature_names[combo[2]], accuracy, n_iter[0]])

# Results for 3 features
df_3_features = pd.DataFrame(results_3_features, columns=["Feature 1", "Feature 2", "Feature 3", "Accuracy", "Iterations"])
print(df_3_features)

# Case 3: Using all 4 features
accuracy_all, n_iter_all = train_logistic_regression(X_scaled, y)
results_all_features = ["All Features", accuracy_all, n_iter_all[0]]

# Results for all features
df_all_features = pd.DataFrame([results_all_features], columns=["Features", "Accuracy", "Iterations"])
print(df_all_features)

# L1 vs L2 regularization and regularization parameter C
penalties = ['l1', 'l2']
C_values = [0.01, 0.1, 1, 10, 100]
regularization_results = []

for penalty in penalties:
    for C in C_values:
        accuracy, n_iter = train_logistic_regression(X_scaled, y, C=C, penalty=penalty, solver='saga')
        regularization_results.append([penalty, C, accuracy, n_iter[0]])

# Results for L1 and L2 regularization
df_regularization = pd.DataFrame(regularization_results, columns=["Penalty", "C", "Accuracy", "Iterations"])
print(df_regularization)

'''
Discuss your findings. Does using more dimensions help when trying to classify the data in this dataset? 
How important is regularization in these cases?

We can see that with 2 features there is much more variance in the number of iterations and we can even 
see not all of the combinations have high accuracy. When we compare it with 3 features, there is more 
uniformity across the combinations in terms of iterations and they all have high accuracy. In terms of 
regularization, we can see that accuracy and number of iterations increased as C value increased in both l1 and l2.
This indicates that weaker regularization best fits this dataset since higher C value indicates weaker regularization.
'''