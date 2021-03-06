# Interpretability-Explainability-App

![image](https://user-images.githubusercontent.com/43175949/133518723-e796047b-278c-4dfc-93be-a3811a5c2bbc.png)

**What**:  
A MATLAB application built with [App Designer](https://se.mathworks.com/products/matlab/app-designer.html) and deployed with the [Web App Server](https://se.mathworks.com/products/matlab-web-app-server.html).
It allows end users to import machine learning model + data (training & test) to run [interpretability/explainability](https://se.mathworks.com/discovery/interpretability.html) functions on the model.
  
**Why**:  
A machine model can be complex and then be difficult to understand its behavior under the hood, thus being able to:
* Understand the impact (positive or negative) of each predictor of the model
* Understand the reason why the model has a good or bad prediction and debug it
* Explain the model and share it with other people who will be more likely to use it
  

**How**:  
You just need to format your input data and then interactively visualize the explainability results.
* Requirements:  
  - You need to save your machine learning model in a .mat file, including the data training and data test. 
  - You must rename the data: dataTraining and dataTest.
  - The data must be table or double

* App process:  
  * You choose a type of model: classification or regression (deep learning will be soon implemented).
  * You can then compute interpretability functions:  
    * Global; PDP, Predictor Importance, MRMR, etc.
    * Local: LIME, Shapley or GAM (for regression for now). You have to select a row from the table.  
  
**Future development**:  
App Testing Framework implemented for Certify AI model with interpretability.
