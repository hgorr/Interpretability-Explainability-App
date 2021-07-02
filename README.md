# interpretabilityExplainabilityApp

**What**:  
A MATLAB application built with App Designer and deployed with the Web App Server.
It allows end users to import machine learning model + data (training & test) to run interpretability/explainability functions on the model.

#**Why**:  
A machine/deep leaning model can be complex and then be difficult to understand its behavior under the hood, thus being able to:
- Understand the impact (positive or negative) of each predictor of the model
- Understand the reason why the model has a good or bad prediction and debug it
- Explain the model and share it with other people who will be more likely to use it

#**How**:  
- Requirements:  
  - You need to save your machine learning model in a .mat file, including the data training and data test. 
  - You must rename the data: dataTraining and dataTest.
  - The data must be table or double

- App process:  
  - You choose a type of model: classification or regression (deep learning will be soon implemented).
  - You can then compute interpretability functions:  
        - Global; PDP, Predictor Importance, MRMR, etc.
        - Local: LIME, Shapley or GAM (for regression for now). You have to select a row from the table.  

#**Future development**:
Deep Learning models and interpretability methods.
