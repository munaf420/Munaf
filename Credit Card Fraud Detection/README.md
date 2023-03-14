
# Credit Card Fraud Detection

Build a predictive model to recognize fraudulent credit card transactions so that customers are not charged for items that they did not purchase.


## Data

The dataset contains transactions made by credit cards in September 2013 by european cardholders. This dataset presents transactions that occurred in two days, where we have 492 frauds out of 284,807 transactions. The dataset is highly unbalanced, the positive class (frauds) account for 0.172% of all transactions.

Due to confidentiality issues, the input variables are transformed into numerical using PCA transformations.
## Models

1. Random Oversampling - Build Models (Logistic Regression, KNN, Decision Trees, Random Forest and XG Boost) on the balanced training data using Random Oversampling.  Hyper parameters tuning is done using cross-validation (Stratified Kfold). Models using hyper parameters with best roc-auc score is selected.

2. SMOTE • Build Models (Logistic Regression, KNN, Decision Trees Random Forest and XG Boost) on the balanced training data using SMOTE. Hyper parameters tuning is done using cross-validation (Stratified Kfold). Models using hyper parameters with best roc-auc score is selected.
##  Model Selection

The best oversampling method is selected and the best model with the hyperparameters is used to predict on the test dataset. The roc-auc score along with precision, recall and f1 score is calculated. Model with good Recall is selected for the European bank as catching fraud is of paramount importance.