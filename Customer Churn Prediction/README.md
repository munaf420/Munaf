
## Customer Churn Prediction

Built a predictive model to identify customers at high risk of churning from an ecommerce company


## Data

The dataset contains customer profiles, including demographics, churn flag (1 means churned) and purchase history.

CustomerID : Unique customer ID

Churn: Churn Flag

Tenure : Tenure of customer in organization

PreferredLoginDevice : Preferred login device of customer

CityTier : City tier

WarehouseToHome : Distance in between warehouse to home of customer

PreferredPaymentMode : Preferred payment method of customer

Gender : Gender of customer

HourSpendOnApp : Number of hours spend on mobile application or website

NumberOfDeviceRegistered : Total number of deceives is registered on particular customer

PreferedOrderCat : Preferred order category of customer in last month

SatisfactionScore : Satisfactory score of customer on service

MaritalStatus : Marital status of customer

NumberOfAddress : Total number of added added on particular customer

Complain : Any complaint has been raised in last month

OrderAmountHikeFromlastYear: Percentage increases in order from last year

CouponUsed : Total number of coupon has been used in last month

OrderCount : Total number of orders has been places in last month

DaySinceLastOrder : Day Since last order by customer

CashbackAmount : Average cashback in last month
## Models

1) Imbalanced dataset - Build Models (Logistic Regression, KNN, Decision Trees, Random Forest and XG Boost) on the balanced training data using Random Oversampling. Hyper parameters tuning is done using cross-validation (Stratified Kfold). Models using hyper parameters with best roc-auc score is selected.

2) SMOTE - Build Models (Logistic Regression, KNN, Decision Trees Random Forest and XG Boost) on the balanced training data using SMOTE. Hyper parameters tuning is done using cross-validation (Stratified Kfold). Models using hyper parameters with best roc-auc score is selected.

## Model Selection

The better data sample (Imbalanced data or data with SMOTE done n it) is selected and the best model with the hyperparameters is used to predict on the test dataset. The roc-auc score along with accuracy, precision,and  recall is calculated. 
XG Boost with SMOTE performed the best and gave the highest accuracy.