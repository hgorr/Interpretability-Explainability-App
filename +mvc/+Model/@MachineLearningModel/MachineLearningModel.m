classdef MachineLearningModel < mvc.Model.Model
    
    properties (Constant)
        LISTMODELS  = "classreg.learning"
        LISTDATA    = ["table", "double"]
    end
    
    properties (Dependent)
        Type1 
        Type2 
    end
    
    %% CONSTRUCTOR
    methods
        function obj = MachineLearningModel(options)
            if nargin == 0
                options = {};
            end
            obj = obj@mvc.Model.Model(options{:});
            if obj.Type1 == "classreg.learning.classif"
                obj.variableToExplain_  = obj.mdl_.ResponseName;
                obj.datatrain_.(obj.variableToExplain_) = categorical(obj.datatrain_.(obj.variableToExplain_));
            elseif obj.Type1 == "classreg.learning.regr"
                obj.variableToExplain_  = setdiff(obj.datatrain_.Properties.VariableNames, string(obj.mdl_.ExpandedPredictorNames));
            end
        end    
    end
    
    %% ACCESSORS
    methods
        function type = get.Type1(obj)
            type = extract(string(class(obj.mdl_)), lettersPattern + "." + lettersPattern + "." + lettersPattern);
        end
    end
        
    %% PUBLIC METHODS
    %% MODELS
    methods (Access = {?mvc.View})
        function [pd,x,y] = modelPDP2D(obj, predictor1, predictor2, ptX, ptY)
            if obj.Type1 == enumExplainerModels.classif
                [pd,x,y] = partialDependence(obj.mdl_,{predictor1,predictor2}, obj.mdl_.ClassNames(1), 'QueryPoints',[ptX ptY]); 
            elseif obj.Type1 == enumExplainerModels.regr
                [pd,x,y] = partialDependence(obj.mdl_,{predictor1,predictor2},'QueryPoints',[ptX ptY]); 
            end
        end
        % Predictors Importance
            function imp = modelPredictorImportance(obj)
                imp = predictorImportance(obj.mdl_);
            end
            function imp = modelOOB(obj)
                imp = oobPermutedPredictorImportance(obj.mdl_);
            end        
            function [idx, scores] = modelMRMR(obj, data)
                [idx,scores] = fscmrmr(data, string(obj.variableToExplain_));
            end
            function mdl = modelNCA(obj, data) 
                if iscategorical(table2array(obj.variableToExplain_)) 
                    mdl = fscnca(removevars(data, obj.variableToExplain_), obj.variableToExplain_); 
                else
                    mdl = fsrnca(removevars(data, obj.variableToExplain_), obj.variableToExplain_); 
                end
            end
        function results = modelLime(obj, queryPoint, numPredictors, simpleModelType)
            results = lime(obj.mdl_, "QueryPoint", queryPoint, "NumImportantPredictors", numPredictors, "SimpleModelType", simpleModelType);
        end
        function results = modelShapley(obj, data, predictor, simulations, useParallel)
            explainer = shapley(obj.mdl_, 'QueryPoint', data, 'MaxNumSubsets', simulations, 'UseParallel', useParallel);
            results   = explainer;
        end
        function mdl = modelGAM(obj, data)
            mdl = fitrgam(data, string(data.Properties.VariableNames(end)));
        end
    end
    
    methods (Static)
        function [ytickidx, ylabels, valEta] = localEffectsGAM(mdl, x, varargin)
            [ytickidx, ylabels, valEta] = localEffectsOverloaded(mdl, x, varargin{:});
        end
    end
    
end
