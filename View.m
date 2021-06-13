classdef View < handle
    %
    % Copyright 2020 The MathWorks, Inc.
    %
    %% CONSTANT
    properties (Constant)
        hSwitchLabel            = ["Training", "Testing"]
        hPIList                 = ["Predictor_Importance", "OOB_Permuted", "MRMR", "NCA"]
        hRowColorTable          = [1 1 0];
        hVariableToPredictLabel = "Variable to predict:"
    end
    
    events
        newQueryPoint
    end
    
    %% DEPENDENT PROPERTIES
    properties (Dependent)
        % MLAPP Components
            
            % GENERAL
            hMachineLearningMenu
            hDeepLearningMenu
            hDataTable        
            hDataButtonGroup
            
            % Global
            % PDP/ICE
            hPredictor1DropDown
            hPredictor2DropDown
            hPredictor1
            hPredictor2            
            hICEButton
            % Predictor Importance & CIE
            hDropDownPI
            hPI
            
            % Local
            % Data
            hDataTableLocal
            % LIME
            hDistancemeasureDropDown
            hDistancemeasure
            hPredictorsSlider
            hPredictors
            hDropDownSimpleModelType
            hSimpleModelType
            % Shapley
            hSimulationsSpinner
            hSimulations
            hUseParallelButton             
            hUseParallel
            
        % APP Components
        App
        Model
        
    end
    
    properties (Dependent)
        Pointer
    end
    
    properties (SetObservable = true)
       hObservationtoExplain    double
       hScoreLIME               double
       hExpectedLIME            double
       hScoreShapley            double
       hExpectedShapley         double 
       hSwitch  
       hQueryPoint              {mustBeA(hQueryPoint, ["double", "table"])} = double.empty()
    end

    properties (SetObservable = true, Access = {?Callbacks})
        app_
        model_
        currentData_
        currentDataType_
        iscompatible_
    end
    
    
    %% CONSTRUCTOR
    methods
        function obj = View(options)
            arguments
                options.app   (1,1) 
                options.model (0,1) {mustBeA(options.model,  "Model")} = Model.empty()      
            end           
            obj.app_   = options.app;
            obj.initializeListeners()
            if ~isempty(options.model) 
                obj.model_ = options.model;
                obj.initializeDataApp()
                obj.runPDP1()
            end
        end
    end
    
    methods (Access = {?Callbacks})
        
        % Add listeners
        function initializeListeners(obj)
            addlistener(obj, 'hObservationtoExplain',   'PostSet', @(~,~)update(obj));
            addlistener(obj, 'hScoreLIME',              'PostSet', @(~,~)updateLIMEScore(obj));
            addlistener(obj, 'hExpectedLIME',           'PostSet', @(~,~)updateLIMEExpected(obj));
            addlistener(obj, 'hScoreShapley',           'PostSet', @(~,~)updateShapleyScore(obj));
            addlistener(obj, 'hExpectedShapley',        'PostSet', @(~,~)updateShapleyExpected(obj));
            addlistener(obj, 'model_',                  'PostSet', @(~,~)updateCurrentData(obj));
            addlistener(obj, 'hSwitch',                 'PostSet', @(~,~)updateCurrentData(obj));
            addlistener(obj, 'newQueryPoint',                      @obj.updateTable);
        end  
        
        % Update Data
        function updateCurrentData(obj)  
            if matches(obj.hSwitch.Value, obj.hSwitchLabel(1), "IgnoreCase", true)
                obj.currentData_        = obj.model_.DataTrain;
                obj.currentDataType_    = "Training";
            elseif matches(obj.hSwitch.Value, obj.hSwitchLabel(2), "IgnoreCase", true)
                obj.currentData_        = obj.model_.DataTest;
                obj.currentDataType_    = "Testing"; 
            end
            obj.initializeDataApp()
            removeStyle(obj.hDataTableLocal)
            cla(obj.app_.LIMEAxes)
            cla(obj.app_.ShapleyAxes)
            cla(obj.app_.GAMAxes)
        end
        
        % Update Table local
        function updateTable(obj,src,evt)
            removeStyle(obj.hDataTableLocal)
            s = uistyle('BackgroundColor', obj.hRowColorTable);
            addStyle(obj.hDataTableLocal,s,'row',evt.row)
        end

        function initializeDataApp(obj)
            obj.hDataTable.Data                 = obj.currentData_;
            obj.hDataTable.ColumnName           = obj.currentData_.Properties.VariableNames;
            obj.hPredictor1DropDown.Items       = obj.currentData_.Properties.VariableNames;
            obj.hPredictor2DropDown.Items       = ["" obj.currentData_.Properties.VariableNames];
            obj.hDataTableLocal.Data            = obj.currentData_;
            obj.hDataTableLocal.ColumnName      = obj.currentData_.Properties.VariableNames;
            obj.hPredictorsSlider.Limits        = [1 numel(obj.currentData_.Properties.VariableNames)-1];
            obj.hPredictorsSlider.MajorTicks    = 1:1:numel(obj.currentData_.Properties.VariableNames)-1;
        end
        
    end
    
   
    %% ACCESSORS
    methods
        function app = get.App(obj)
            app = obj.app_;
        end
        function model = get.Model(obj)
            model = obj.model_;
        end
        function v = get.hMachineLearningMenu(obj)
            v = obj.app_.MachineLearningMenu;
        end
        function v = get.hDeepLearningMenu(obj)
            v = obj.app_.DeepLearningMenu;
        end        
        function v = get.hICEButton(obj)
            v = obj.app_.ICEButton;
        end
        function v = get.hUseParallelButton(obj)
            v = obj.app_.UseParallelButton;
        end
        function v = get.hUseParallel(obj)
            v = obj.hUseParallelButton.Value;
        end
        function v = get.hPredictor1DropDown(obj)
            v = obj.app_.Predictor1DropDown;
        end  
        function v = get.hPredictor1(obj)
            v = obj.app_.Predictor1DropDown.Value;
        end
        function v = get.hPredictor2DropDown(obj)
            v = obj.app_.Predictor2DropDown;
        end 
        function v = get.hPredictor2(obj)
            v = obj.app_.Predictor2DropDown.Value;
        end        
        function v = get.hDropDownPI(obj)
            v = obj.app_.DropDownPI;
        end
        function v = get.hPI(obj)
            v = obj.app_.DropDownPI.Value;
        end
        function v = get.hDistancemeasureDropDown(obj)
            v = obj.app_.DistancemeasureDropDown;
        end  
        function v = get.hDistancemeasure(obj)
            v = obj.app_.DistancemeasureDropDown.Value;
        end
        function v = get.hPredictorsSlider(obj)
            v = obj.app_.PredictorsSlider;
        end  
        function v = get.hPredictors(obj)
            v = obj.app_.PredictorsSlider.Value;
        end
        function v = get.hDropDownSimpleModelType(obj)
            v = obj.app_.DropDownSimpleModelType;
        end
        function v = get.hSimpleModelType(obj)
            v = obj.app_.DropDownSimpleModelType.Value;
        end        
        function v = get.hSimulationsSpinner(obj)
            v = obj.app_.SimulationsSpinner;
        end   
        function v = get.hSimulations(obj)
            v = obj.app_.SimulationsSpinner.Value;
        end
        function hdatatable = get.hDataTable(obj)
            hdatatable = obj.app_.DataTable;
        end
        function v = get.hDataTableLocal(obj)
            v = obj.app_.DataTableLocal;
        end
        function switchpdpice = get.hSwitch(obj)
            switchpdpice = obj.app_.Switch;
        end
        function v = get.Pointer(obj)
            v = obj.app_.UIFigure.Pointer;
        end
    end
    
    %% MUTATORS
    methods 
        function set.Model(obj, m)
            obj.model_                              = m;
            obj.iscompatible_                       = obj.isCompatible();
            obj.app_.VariabletopredictLabel.Text    = obj.hVariableToPredictLabel + " " + m.VariableToExplain;
        end
        function set.Pointer(obj, pointer)
            obj.app_.UIFigure.Pointer = pointer;
            drawnow
        end
    end
    
    %% PRIVATE
    methods (Access = {?Callbacks})
        
        function iscompatible = isCompatible(obj)
            iscompatible.PDP                 = true;
            iscompatible.PredictorImportance = ismember(class(obj.model_.Mdl), enumExplainerModels.predictorImportance);
            iscompatible.OOB                 = ismember(class(obj.model_.Mdl), enumExplainerModels.OOB) && ismember(obj.model_.Mdl.Method, enumExplainerModels.OOBMethods);
            iscompatible.MRMR                = any(string(obj.currentData_.Properties.VariableNames) == string(obj.model_.VariableToExplain));
            X                                = obj.currentData_(:,obj.model_.Mdl.PredictorNames);
            iscompatible.NCA                 = all(size(X(:, vartype("numeric"))) == size(X));
            iscompatible.LIME                = true;
            iscompatible.Shapley             = true;
            iscompatible.GAM                 = obj.model_.Type1 == "classreg.learning.regr";
        end
 
        function runPDP1(obj)
            obj.Pointer = "watch";
            if ~obj.hICEButton.Value  
                obj.plotPDP1(obj.model_.Mdl, find(obj.model_.Mdl.PredictorNames == string(obj.hPredictor1)), obj.app_.PDPAxes)
            elseif obj.hICEButton.Value           
                obj.plotPDP1(obj.model_.Mdl, find(obj.model_.Mdl.PredictorNames == string(obj.hPredictor1)), obj.app_.PDPAxes, "absolute")
            end
            obj.Pointer = "arrow";
        end
        function runPDP2(obj)
            obj.Pointer = "watch";
            numPoints   = width(obj.currentData_)-1;
            ptX         = linspace(min(obj.currentData_.(obj.hPredictor1)),max(obj.currentData_.(obj.hPredictor1)),numPoints)';
            ptY         = linspace(min(obj.currentData_.(obj.hPredictor2)),max(obj.currentData_.(obj.hPredictor2)),numPoints)';
            [pd,x,y]    = obj.model_.modelPDP2D(obj.hPredictor1, obj.hPredictor2, ptX, ptY);
            obj.plotPDP2(obj.app_.PDP2, x, y, pd, ptX, ptY, obj.currentData_.(obj.hPredictor1), obj.currentData_.(obj.hPredictor2), ...
                         obj.hPredictor1, obj.hPredictor2)
            obj.Pointer = "arrow";
        end
        function runPI(obj, varargin)
            assert(any(ismember(obj.hPIList, obj.hPI)))
            obj.Pointer = "watch";
            drawnow                     
            switch obj.hPI
                case "Predictor_Importance"
                    if obj.iscompatible_.PredictorImportance
                        obj.runPredictorImportance()
                    else
                        uialert(obj.app_.UIFigure, "Not compatible with " + obj.hPI, "Warning", "Icon", "warning")
                        if ~isempty(varargin)
                            obj.app_.DropDownPI.Value = varargin{:};
                        end                         
                    end
                case "OOB_Permuted"
                    if obj.iscompatible_.OOB
                        obj.runOOBPermutedPredictorImportance()
                    else 
                        uialert(obj.app_.UIFigure,  "The method of the current model " + class(obj.model_) + " has to be member of " + enumExplainerModels.OOBMethods + " to use oobPermutedPredictorImportance function .", "Warning", "Icon", "warning")
                        if ~isempty(varargin)
                            obj.app_.DropDownPI.Value = varargin{:};
                        end
                    end
                case "MRMR"
                    if obj.iscompatible_.MRMR
                        obj.runMRMR()
                    else 
                        uialert(obj.app_.UIFigure, "Data does not contain the Response variable.", "Warning", "Icon", "warning")
                        if ~isempty(varargin)
                            obj.app_.DropDownPI.Value = varargin{:};
                        end
                    end
                case "NCA"
                    if obj.iscompatible_.NCA
                        obj.runNCA()
                    else 
                        uialert(obj.app_.UIFigure, "All predictors have to be numeric.", "Warning", "Icon", "warning")
                        if ~isempty(varargin)
                            obj.app_.DropDownPI.Value = varargin{:};
                        end 
                    end
            end
            obj.Pointer = "arrow";
        end
            function runPredictorImportance(obj)
                imp = obj.model_.modelPredictorImportance();
                obj.plotPredictorImportance(obj.app_.PredictorImportanceAxes, imp, obj.model_.Mdl.PredictorNames)
            end
            function runOOBPermutedPredictorImportance(obj)
                imp = obj.model_.modelOOB();
                obj.plotPredictorImportance(obj.app_.PredictorImportanceAxes, imp, obj.model_.Mdl.PredictorNames)
            end
            function runMRMR(obj)
                [idx,scores] = obj.model_.modelMRMR(obj.currentData_);
                obj.plotPredictorImportance(obj.app_.PredictorImportanceAxes, scores(idx), obj.model_.Mdl.PredictorNames)
            end
            function runNCA(obj)
                mdl = obj.model_.modelNCA(obj.currentData_);
                obj.plotPredictorImportance(obj.app_.PredictorImportanceAxes, mdl.FeatureWeights, obj.model_.Mdl.PredictorNames)
            end
            
        function runOOB(obj)
            obj.Pointer = "watch";
            drawnow            
            imp = obj.model_.modelOOB();
            obj.plotPredictorImportance(obj.app_.OOBAxes, imp, obj.model_.Mdl.PredictorNames)
            obj.Pointer = "arrow";
        end
        
        function runLIME(obj)
            if ~isempty(obj.hQueryPoint)
                obj.Pointer = "watch";
                drawnow            
                results     = obj.model_.modelLime(removevars(obj.hQueryPoint, obj.model_.VariableToExplain), round(obj.hPredictors), obj.hSimpleModelType);
                obj.plotLIME(obj.app_.LIMEAxes, results)
                obj.Pointer = "arrow";
            end
        end
        
        function runShapley(obj)
            if ~isempty(obj.hQueryPoint)
                obj.Pointer = "watch";
                drawnow            
                explainer            = obj.model_.modelShapley(obj.hQueryPoint, string(obj.hPredictor1), round(obj.hSimulations), obj.hUseParallel);
                obj.plotShapley(obj.app_.ShapleyAxes, explainer);
                obj.Pointer   = "arrow";
            end
        end
        
        function runGAM(obj)
            if ~isempty(obj.hQueryPoint) && obj.iscompatible_.GAM
                obj.Pointer = "watch";
                drawnow        
                mdl = obj.model_.modelGAM(obj.currentData_);
                [~, ylabels, valEta] = obj.model_.localEffectsGAM(mdl, obj.hQueryPoint);
                obj.plotGAM(obj.app_.GAMAxes, string(ylabels), valEta);
                obj.Pointer   = "arrow";
            end
        end

    end
    
    %% PLOT
    methods (Access = private)
        function plotPDP1(~, mdl, ind, axes, varargin)
            if ~isempty(varargin)
                if string(metaclass(mdl).ContainingPackage.Name) == "classreg.learning.classif"
                    plotPartialDependence(mdl, ind, mdl.ClassNames(1), "Parent", axes, "Conditional", varargin{:});
                else
                    plotPartialDependence(mdl, ind, "Parent", axes, "Conditional", varargin{:});
                end
            else
                if string(metaclass(mdl).ContainingPackage.Name) == "classreg.learning.classif"
                    plotPartialDependence(mdl, ind, mdl.ClassNames(1), "Parent", axes);
                else
                    plotPartialDependence(mdl, ind, "Parent", axes);
                end                
            end
        end
        function plotPDP2(~, parent, x, y, pd, ptX, ptY, predictor1, predictor2, predictor1name, predictor2name)
            t                   = tiledlayout(parent, 5, 5, 'TileSpacing', 'compact');
            ax1                 = nexttile(t, 2,[4,4]);
            imagesc(ax1, x, y, pd)
            title(ax1, 'Partial Dependence Plot')
            colorbar(ax1, 'eastoutside')
            ax1.YDir            = 'normal';
            ax2                 = nexttile(t, 22,[1,4]);
            dX                  = diff(ptX(1:2));
            edgeX               = [ptX-dX/2;ptX(end)+dX];
            histogram(ax2, predictor1, edgeX);
            ax2.XLabel.String   = predictor1name;
            ax2.XLim            = ax1.XLim;
            ax3                 = nexttile(t, 1,[4,1]);
            dY                  = diff(ptY(1:2));
            edgeY               = [ptY-dY/2;ptY(end)+dY];
            histogram(ax3, predictor2, edgeY)
            ax3.XLabel.String   = predictor2name;
            ax3.XDir            = 'reverse';
            camroll(ax3,-90)
        end
        function plotPredictorImportance(~, parent, imp, names)
            b                               = bar(parent, imp);
            b.Parent.XTickLabel             = names;
            b.Parent.XTickLabelRotation     = 45;
            b.Parent.TickLabelInterpreter   = 'none';
            b.Parent.XLabel.String          = [];
            b.Parent.YLabel.String          = [];
            b.Parent.Title.String           = "Predictor Importance";
        end
        function plotLIME(obj, axes, results)
            if isa(results.SimpleModel,'ClassificationTree') || isa(results.SimpleModel,'RegressionTree')
                predImp     = predictorImportance(results.SimpleModel);
                [~,idx]     = sort(predImp);
                idx         = idx(end-sum(predImp>0)+1:end);
                values      = predImp(idx);
            elseif ~isa(results.SimpleModel,'ClassificationTree') || isa(results.SimpleModel,'RegressionTree')
                values  = results.SimpleModel.Beta;
                if ~(numel(values) == numel(results.ImportantPredictors))
                    values = values(2:end);
                end
            end
            ylabels = string(results.SimpleModel.PredictorNames)';
            xlabel  = "Coefficients";
            obj.plotContributions(axes, values, ylabels, xlabel)
        end
        function plotShapley(obj, plotAxes, explainer)
            if obj.model_.Type1 == enumExplainerModels.classif
                shapley             = explainer.ShapleyValues.(string(explainer.ShapleyValues.Properties.VariableNames(2)));
            else
                shapley             = explainer.ShapleyValues.ShapleyValue;
            end
            predictorNames          = explainer.ShapleyValues.Predictor;
            categoricalNames        = categorical(predictorNames);
            xlabel = 'Feature Value Contribution';
            obj.plotContributions(plotAxes, shapley, categoricalNames, xlabel)
        end
        function plotGAM(obj, plotAxes, ylabels, valEta)
            xlabel = "Local Effects";
            obj.plotContributions(plotAxes, valEta, ylabels, xlabel)       
        end
        
            function plotContributions(~, plotAxes, values, ylabels, xlabel)
                [ylabels, idx] = sort(ylabels, "ascend");
                b       = barh(plotAxes, values(idx));
                nidx    = values(idx) < 0;
                fnidx   = b.XEndPoints(nidx);
                for i   = 1:length(fnidx)
                    b.FaceColor = "flat";
                    b.CData(fnidx(i),:) = [0.8500 0.3250 0.0980];
                end          
                plotAxes.YTickLabels    = ylabels;          
                plotAxes.YLabel.String  = "";
                plotAxes.XLabel.String  = xlabel;
                plotAxes.XMinorGrid     = "on";
            end
    end
    
    %% EVENTS
    methods (Access = private)

        % UPDATE Fields
        function updateLIMEScore(obj)
        	obj.app_.ScoreEditFieldLIME.Text        = num2str(obj.hScoreLIME);            
        end
        function updateLIMEExpected(obj)
            obj.app_.ExpectedEditFieldLIME.Text     = num2str(obj.hExpectedLIME);
        end
        function updateShapleyScore(obj)
            obj.app_.ScoreEditFieldShapley.Text     = num2str(obj.hScoreShapley);
        end
        function updateShapleyExpected(obj)
            obj.app_.ExpectedEditFieldShapley.Text  = num2str(obj.hExpectedShapley);
        end
        
    end
end