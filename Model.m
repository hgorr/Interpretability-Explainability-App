classdef Model < handle
    
    properties (Constant)
        INPUT  string = ["DataTrain", "DataTest", "Mdl"]
        OUTPUT string = []
    end
    
    properties (Dependent)
        DataTrain   (:,:) {mustBeA(DataTrain, ["table", "double"])}
        DataTest    (:,:) {mustBeA(DataTest,  ["table", "double"])}
        Mdl         (1,1)
    end
    
    properties (Dependent)
        InputData
        OutputData
    end
    
    properties (Access = private)
        datatest_
        datatrain_
        mdl_
    end
    
    %% CONSTRUCTOR
    methods
        function obj = Model(options)
            arguments
                options.dataTrain   {mustBeA(options.dataTrain, ["table", "double"])}
                options.dataTest    {mustBeA(options.dataTest,  ["table", "double"])}
                options.Mdl
            end
            obj.datatrain_  = options.dataTrain;
            obj.datatest_   = options.dataTest;
            obj.mdl_        = options.Mdl;
        end
    end
    
    %% ACCESSORS
    methods
        function mdl = get.Mdl(obj)
            mdl = obj.mdl_;
        end
        function datatrain = get.DataTrain(obj)
            datatrain = obj.datatrain_;
        end
        function datatest = get.DataTest(obj)
            datatest = obj.datatest_;
        end
    end
    
    %% MUTATORS
    methods
        function set.DataTrain(obj, datatrain)
            obj.datatrain_ = datatrain;
        end
        function set.DataTest(obj, datatest)
            obj.datatest_ = datatest;
        end
        function set.Mdl(obj, mdl)
            obj.mdl_ = mdl;
        end
    end
    
    %% PUBLIC METHODS
    %% MODELS
    methods (Access = {?View})
        function results = isCompatible(obj)
            results.PDP                 = true;
            results.PredictorImportance = ismember(class(obj.mdl_), enumExplainerModels.predictorImportance);
            results.OOB                 = ismember(class(obj.mdl_), enumExplainerModels.OOB) && ismember(obj.mdl_.Method, enumExplainerModels.OOBMethods);
            results.LIME                = true;
            results.Shapley             = true;
        end
        function [pd,x,y] = modelPDP2D(obj, predictor1, predictor2, ptX, ptY)
           [pd,x,y] = partialDependence(obj.mdl_,{predictor1,predictor2},'QueryPoints',[ptX ptY]); 
        end
        function imp = modelPredictorImportance(obj)
            assert(ismember(class(obj.mdl_), enumExplainerModels.predictorImportance), "Check for missing argument or incorrect argument data type in call to function 'predictorImportance'.")
            imp = predictorImportance(obj.mdl_);
        end
        function imp = modelOOB(obj)
            assert(ismember(class(obj.mdl_), enumExplainerModels.OOB) && ismember(obj.mdl_.Method, enumExplainerModels.OOBMethods), ...
                   "Check for missing argument or incorrect argument data type in call to function 'oobPermutedPredictorImportance'.")
            imp = oobPermutedPredictorImportance(obj.mdl_);
        end        
        function results = modelLime(obj, queryPoint, numPredictors)
            results = lime(obj.mdl_, "QueryPoint", queryPoint, "NumImportantPredictors", numPredictors);
            results = fit(results, queryPoint, numPredictors);
        end
        function results = modelShapley(obj, data, predictor, simulations, useParallel)
            [shapley, meanScore, x_predictor_values]    = obj.computeShapley(obj.mdl_, data, find(obj.Mdl.PredictorNames == predictor), simulations, useParallel);
            results.shapley                             = shapley;
            results.meanScore                           = meanScore;
            results.xpredictors                         = x_predictor_values;
        end
        
    end
    
    %% PRIVATE METHODS
    methods (Access = private)
        function [shapley, meanScore, x_predictor_values] = computeShapley(obj, mdl, data, instID, maxSamples, useParallel)
            % Inputs:
            %
            % mdl: Model to explain, can be any regression object ot struct output from
            % Regression Learner App
            %
            % data: The data alongside which to compute coalitions
            %
            % instID: The instance to explain
            %
            % maxSamples: Maximum number of simulations to run to compute SHAPley
            % Values
            %
            % useParallel: True to use parallel resources, false otherwsie
            %
            %
            % Outputs:
            %
            % shapley: Array of SHAPley Values
            %
            % meanScore: mean score predicted on new data by the model
            
            numInstances  = size(data,1);   % number of customers/instances
            
            % Default parameter values
            if nargin<5
                useParallel = true;
            end
            if nargin<4
                maxSamples = numInstances;
            end
            
            predictorNames  = mdl.PredictorNames;         % names of predictor variables in the data set
            numPredictors   = numel(predictorNames);
            
            % pre-allocation
            contribution = zeros(maxSamples,numPredictors);
            shapley      = zeros(1,numPredictors);
            
            % Filter data down to only predictors
            predictorNamesArray = string(predictorNames);
            variableNamesArray 	= string(data.Properties.VariableNames);
            isPredictor         = ismember(variableNamesArray,predictorNamesArray); % Find which columns of data are predictor variables
            dataFiltered        = data(:,isPredictor); % Create version of data with non-predictor columns omitted
            
            x = dataFiltered(instID,:);      % instance of interest
            
            for indj = 1:numPredictors
                
                % loop over coalition combinations from 1 to maximum samples
                if useParallel
                    parfor indm = 1:maxSamples
                        [xPlusj,xMinusj] = obj.computeCoalitions(x,dataFiltered,indj,numPredictors,numInstances);
                        contribution(indm,indj) = predict(mdl,xPlusj) - predict(mdl,xMinusj);
                    end
                else
                    for indm = 1:maxSamples
                        [xPlusj,xMinusj] = obj.computeCoalitions(x,dataFiltered,indj,numPredictors,numInstances);
                        contribution(indm,indj) = predict(mdl,xPlusj) - predict(mdl,xMinusj);
                    end
                end
                
                shapley(indj) = mean(contribution(:,indj));
                
            end
            
            
            meanScore = mean(predict(mdl,data)); % Calculate what the mean score is for the data
            x_predictor_values = x;
            
            
            
            
        end
        
        
%         %Function to create graphics - not used in App version
%         function [axHandle,prediction,expected] = createFigure(mdl, shapley, x, predictorNames, numPredictors, meanScore)
%             
%             
%             fHandle = figure('visible','off');
%             label = cell(numPredictors,1);
%             
%             for indj = 1:numPredictors
%                 
%                 label{indj} = convertStringsToChars(strcat(predictorNames{indj},'=',string(x{:,indj})));
%                 
%             end
%             
%             % com
%             prediction = predict(mdl,x);   % prediction
%             expected = meanScore + sum(shapley);  % sum of all contributions + mean score value
%             difference = prediction - expected; % difference between contributions and predicted score
%             
%             categoricalNames = categorical(label);
%             barh(categoricalNames,shapley);
%             grid on
%             
%             title('Shapley Value')
%             xlabel({'Feature value contribution','',...
%                 strcat('Score: ',string(prediction)), ...
%                 strcat('Expected score: ',string(expected)),...
%                 strcat('Difference: ',string(difference))},'HorizontalAlignment', 'left','VerticalAlignment', 'top')
%             
%             axHandle = fHandle.Children;
%             resetPosition = axHandle.Position;
%             
%             axHandle.XLabel.Position(1) = axHandle.XLim(1);
%             axHandle.Position([2,4]) = resetPosition([2,4]);
%             
%         end
        
        
        
        
        % App to compute coalitions among shapley data
        function [xPlusj,xMinusj] = computeCoalitions(obj, x, data, indj, numPredictors, numInstances)
            
            randomPermutation = randperm(numPredictors); %Cutoff for random permutation of predictors
            
            randomPosition = find(randomPermutation == indj); % find the position of the j-predictor
            
            randmInstanceID = randi([1,numInstances],1); % choose a random instance ID
            z = data(randmInstanceID,:);  % extract a random instance based on randmInstanceID
            
            xPermutated = x(:,randomPermutation); % x is the value to explain
            zPermutated = z(:,randomPermutation); % z is the value (other random data point) that will determine perturbations
            
            % Cases to handle boundaries of array
            if randomPosition == numPredictors
                
                xPlusj  =  xPermutated;
                xMinusj = [xPermutated(:,1:end-1),zPermutated(:,end)];
                
            elseif randomPosition == 1
                
                xPlusj  = [xPermutated(:,1),zPermutated(:,2:end)];
                xMinusj = zPermutated;
                
            else % General case
                xPlusj  = [xPermutated(:,1:randomPosition),zPermutated(:,randomPosition+1:end)]; %This includes the variable to explain
                xMinusj = [xPermutated(:,1:randomPosition-1),zPermutated(:,randomPosition:end)]; %This does not include the variable to explain (position cutoff)
            end
        end
    end
    
end
