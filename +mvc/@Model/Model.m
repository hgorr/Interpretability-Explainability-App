classdef Model < handle
    
    properties (Constant)
        INPUT  string = ["DataTrain", "DataTest", "Mdl", "VariableToExplain"]
        OUTPUT string = []
    end
    
    properties (Dependent)
        DataTrain           (:,:) {mustBeA(DataTrain, ["table", "double"])}
        DataTest            (:,:) {mustBeA(DataTest,  ["table", "double"])}
        Mdl                 (1,1) {mustBeAModel}
        VariableToExplain   (1,1) string {mustBeNonempty}
        Name                (1,1) string {mustBeNonempty}
    end
    
    properties (Dependent)
        InputData
        OutputData
        Type1       (1,1) string {mustBeMember(Type1, ["classreg.learning.classif", "classreg.learning.regr"])}
        Type2 
    end
    
    properties (Access = private)
        datatest_
        datatrain_
        mdl_
        variableToExplain_
        name_
    end
    
    %% CONSTRUCTOR
    methods
        function obj = Model(options)
            arguments
                options.dataTrain          
                options.dataTest            
                options.mdl                 
                options.name                
            end
            obj.mdl_        = options.mdl;
            obj.datatrain_  = options.dataTrain;
            obj.datatest_   = options.dataTest;   
            obj.name_       = options.name;
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
        function mdl = get.Mdl(obj)
            mdl = obj.mdl_;
        end
        function name = get.Name(obj)
            name = obj.name_;
        end        
        function datatrain = get.DataTrain(obj)
            datatrain = obj.datatrain_;
        end
        function datatest = get.DataTest(obj)
            datatest = obj.datatest_;
        end
        function v = get.VariableToExplain(obj)
            v = obj.variableToExplain_;
        end        
        function type = get.Type1(obj)
            type = string(metaclass(obj.Mdl).ContainingPackage.Name);
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
        function set.VariableToExplain(obj, v)
            obj.variableToExplain_ = v;
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
        function mustBeAModel(mdl)
            if ~any(ismember(string(superclasses(mdl)), "classreg.learning.Predictor")) && ...
                ~any(ismember(string(superclasses(mdl)), "classreg.learning.Predictor"))
                eidType = 'mustBeAModel:notClassifOrRegression';
                msgType = 'Value assigned to Model property is not classif.learning or reg.learning.';
                throwAsCaller(MException(eidType,msgType))
            end
        end            
    end
    
end
