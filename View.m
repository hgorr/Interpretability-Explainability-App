classdef View < handle
    %
    % Copyright 2020 The MathWorks, Inc.
    %

    %% DEPENDENT PROPERTIES
    properties (Dependent)
        % MLAPP Components
            
            % GENERAL
            hObservationtoExplainEditField
            hGenerateReportButton
            hClearFiguresButton
            hDataTable        
            hDataButtonGroup
            
            % RUN Buttons
            hRUNButtonPDP
            hRUNButtonPredictorImportance
            hRUNButtonOOB
            hRUNButtonLIME
            hRUNButtonShapley
            hRUNALLButton
        
            % PDP/ICE
            hPredictor1DropDown
            hPredictor2DropDown
            hSwitch
            
            % LIME
            hDistancemeasureDropDown
            hPredictorsSpinner
            
            % Shapley
            hSimulationsEditField
            hUseParallelCheckBox             
        
        % APP Components
        App
        Model
        
    end
    
    %% ONLY BY CALLBACKS
    properties (Access = {?Callbacks})
        
        % CHECK BOX
        hICE
        hPredictorImp
        hLIME
        hShapley
        hUseParallel
        hActivations
        hTSNE
        hImageLIME
        
        % LISTS
        hPredictor1
        hPredictor2
        hDistancemeasure
        
        % SPINNER
        hSpinner
        
        % EDIT FIELDS
        hSimulations
        
        % SWITCH
        hSwitchPDPICE = "PDP"
        
        currentData_
    end
    
    properties (SetObservable = true)
       hObservationtoExplain    double
       hScoreLIME               double
       hExpectedLIME            double
       hScoreShapley            double
       hExpectedShapley         double
       hDataBG              
    end
    
    properties (SetAccess = immutable, GetAccess = private)
        app_
        model_
    end

    %% CONSTRUCTOR
    methods
        function obj = View(options)
            arguments
                options.app   (1,1) 
                options.model (1,1) {mustBeA(options.model,  "Model")}      
            end           
            obj.app_                            = options.app;
            obj.model_                          = options.model;
            obj.initializaDataApp()
            obj.initializeDataView()
            obj.initializeListeners()
            obj.initializeTabs()
            obj.update()
        end
        function initializaDataApp(obj)
            obj.app_.DataTable.Data             = obj.model_.DataTrain;
            obj.app_.DataTable.ColumnName       = obj.model_.DataTrain.Properties.VariableNames;
            obj.app_.Predictor1DropDown.Items   = obj.model_.DataTrain.Properties.VariableNames;
            obj.app_.Predictor2DropDown.Items   = ["" obj.model_.DataTrain.Properties.VariableNames];
        end
        function initializeDataView(obj)
            obj.hPredictor1                     = obj.app_.Predictor1DropDown.Value;
            obj.hSimulations                    = obj.app_.SimulationsEditField.Value;
            obj.hObservationtoExplain           = obj.app_.ObservationtoExplainEditField.Value;
            obj.currentData_                    = obj.model_.(obj.app_.DataButtonGroup.SelectedObject.Text);
        end
        function initializeListeners(obj)
            addlistener(obj, 'hObservationtoExplain',   'PostSet', @(~,~)update(obj));
            addlistener(obj, 'hScoreLIME',              'PostSet', @(~,~)updateLIMEScore(obj));
            addlistener(obj, 'hExpectedLIME',           'PostSet', @(~,~)updateLIMEExpected(obj));
            addlistener(obj, 'hScoreShapley',           'PostSet', @(~,~)updateShapleyScore(obj));
            addlistener(obj, 'hExpectedShapley',        'PostSet', @(~,~)updateShapleyExpected(obj));
            addlistener(obj, 'hDataBG',                 'PostSet', @(evt,src)updateData(obj,evt,src));
        end
        function initializeTabs(obj)
            results = obj.model_.isCompatible();
            fn      = string(fieldnames(results));
            for i = 1 : numel(fn)
                if results.(fn(i)) == 0
                    obj.app_.(["RUNButton" + fn(i)]).Enable     = false;
                    obj.app_.(["RUNButton" + fn(i)]).Tooltip    = "Model is not compatible.";
                end
            end
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
        function v = get.hRUNALLButton(obj)
            v = obj.app_.RUNALLButton;
        end          
        function v = get.hRUNButtonPDP(obj)
            v = obj.app_.RUNButtonPDP;
        end
        function v = get.hRUNButtonPredictorImportance(obj)
            v = obj.app_.RUNButtonPredictorImportance;
        end
        function v = get.hRUNButtonOOB(obj)
            v = obj.app_.RUNButtonOOB;
        end        
        function v = get.hRUNButtonLIME(obj)
            v = obj.app_.RUNButtonLIME;
        end
        function v = get.hRUNButtonShapley(obj)
            v = obj.app_.RUNButtonShapley;
        end
        function v = get.hUseParallelCheckBox(obj)
            v = obj.app_.UseParallelCheckBox;
        end
        function v = get.hPredictor1DropDown(obj)
            v = obj.app_.Predictor1DropDown;
        end  
        function v = get.hPredictor2DropDown(obj)
            v = obj.app_.Predictor2DropDown;
        end          
        function v = get.hDistancemeasureDropDown(obj)
            v = obj.app_.DistancemeasureDropDown;
        end  
        function v = get.hPredictorsSpinner(obj)
            v = obj.app_.PredictorsSpinner;
        end  
        function v = get.hObservationtoExplainEditField(obj)
            v = obj.app_.ObservationtoExplainEditField;
        end  
        function v = get.hSimulationsEditField(obj)
            v = obj.app_.SimulationsEditField;
        end  
        function v = get.hGenerateReportButton(obj)
            v = obj.app_.GenerateReportButton;
        end  
        function v = get.hClearFiguresButton(obj)
            v = obj.app_.ClearFiguresButton;
        end  
        function hdatatable = get.hDataTable(obj)
            hdatatable = obj.app_.DataTable;
        end
        function switchpdpice = get.hSwitch(obj)
            switchpdpice = obj.app_.Switch;
        end
        function v = get.hDataButtonGroup(obj)
            v = obj.app_.DataButtonGroup;
        end
    end
    
    %% MUTATORS
    methods 
        function set.hSwitch(obj, v)
            obj.hSwitchPDPICE = v;
        end
    end
    
    %% PRIVATE
    methods (Access = {?Callbacks})
        
        function runALL(obj)
            obj.runPDP()
            obj.runPredictorImportance()
            obj.runLIME()
            obj.runShapley()
        end
        
        function runPDP(obj)
            obj.app_.UIFigure.Pointer = "watch";
            drawnow
            delete(obj.app_.GridLayout.Children)
            if obj.hSwitchPDPICE == "PDP"
                
                if isempty(obj.hPredictor2)
                    axes = uiaxes("Parent", obj.app_.GridLayout);
                    obj.plotPDP1(obj.model_.Mdl, find(obj.model_.Mdl.PredictorNames == string(obj.hPredictor1)), axes)
                else
                    numPoints   = 10;
                    ptX         = linspace(min(obj.currentData_.(obj.hPredictor1)),max(obj.currentData_.(obj.hPredictor1)),numPoints)';
                    ptY         = linspace(min(obj.currentData_.(obj.hPredictor2)),max(obj.currentData_.(obj.hPredictor2)),numPoints)';
                    [pd,x,y]    = obj.model_.modelPDP2D(obj.hPredictor1, obj.hPredictor2, ptX, ptY);
                    obj.plotPDP2(obj.app_.GridLayout, x, y, pd, ptX, ptY, obj.currentData_.(obj.hPredictor1), obj.currentData_.(obj.hPredictor2), ...
                                 obj.hPredictor1, obj.hPredictor2)
                end
                
            elseif obj.hSwitchPDPICE == "ICE"
                
                assert(isempty(obj.hPredictor2), "Please choose only Predictor 1")
                axes = uiaxes("Parent", obj.app_.GridLayout);                
                obj.plotPDP1(obj.model_.Mdl, find(obj.model_.Mdl.PredictorNames == string(obj.hPredictor1)), axes, "absolute")
                
            end
            obj.app_.UIFigure.Pointer = "arrow";
        end
        
        function runPredictorImportance(obj)
            obj.app_.UIFigure.Pointer = "watch";
            drawnow            
            imp = obj.model_.modelPredictorImportance();
            obj.plotPredictorImportance(obj.app_.PredictorImportanceAxes, imp, obj.model_.Mdl.PredictorNames)
            obj.app_.UIFigure.Pointer = "arrow";
        end
        
        function runOOB(obj)
            obj.app_.UIFigure.Pointer = "watch";
            drawnow            
            imp = obj.model_.modelOOB();
            obj.plotPredictorImportance(obj.app_.OOBAxes, imp, obj.model_.Mdl.PredictorNames)
            obj.app_.UIFigure.Pointer = "arrow";
        end
        
        function runLIME(obj)
            obj.app_.UIFigure.Pointer = "watch";
            drawnow            
            queryPoint                  = obj.model_.DataTrain(obj.hObservationtoExplain, 1:end-1);
            numPredictors               = obj.app_.PredictorsSpinner.Value;
            results                     = obj.model_.modelLime(queryPoint, numPredictors);
            obj.plotLIME(obj.app_.LIMEAxes, results)
            obj.hScoreLIME              = results.SimpleModelFitted;
            obj.hExpectedLIME           = results.BlackboxFitted;
            obj.app_.UIFigure.Pointer   = "arrow";
        end
        
        function runShapley(obj)
            obj.app_.UIFigure.Pointer = "watch";
            drawnow            
            results                     = obj.model_.modelShapley(obj.currentData_, string(obj.hPredictor1), obj.hSimulations, obj.hUseParallel);
            [prediction, expected]      = obj.plotShapley(obj.model_.Mdl, results.shapley, results.xpredictors, obj.model_.Mdl.PredictorNames, ...
                                                          width(results.xpredictors), results.meanScore, obj.app_.ShapleyAxes);
            obj.hScoreShapley           = prediction;
            obj.hExpectedShapley        = expected;
            obj.app_.UIFigure.Pointer   = "arrow";
        end

    end
    
    %% PLOT
    methods (Access = private)
        function plotPDP1(~, mdl, ind, axes, varargin)
            if ~isempty(varargin)
                plotPartialDependence(mdl, ind, "Parent", axes, "Conditional", varargin{:});
            else
                plotPartialDependence(mdl, ind, "Parent", axes);
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
        end
        function plotLIME(~, axes, results)
            b                       = barh(axes, results.SimpleModel.Beta);
            b.Parent.YTickLabel     = string(results.SimpleModel.PredictorNames)';
            b.Parent.XLabel.String  = "Coefficients";
            b.Parent.YLabel.String  = "";
        end
        function [prediction, expected] = plotShapley(~, mdl, shapley, x, predictorNames, numPredictors, meanScore, plotAxes)
            label = cell(numPredictors,1);
            for indj = 1:numPredictors
                label{indj} = convertStringsToChars(strcat(predictorNames{indj},'=',string(x{:,indj})));
            end
            prediction          = predict(mdl,x);
            expected            = meanScore + sum(shapley);  % sum of all contributions + mean score value
            categoricalNames    = categorical(label);
            barh(plotAxes,categoricalNames,shapley);
            grid(plotAxes,"on")
            plotAxes.YLabel.String = "";
            plotAxes.XLabel.String = 'Feature Value Contribution';
        end
    end
    
    %% EVENTS
    methods (Access = private)
        % UDPATE OBSERVATION
        function update(obj)
            obj.updateLabels()
            obj.updateTables()
        end
        function updateLabels(obj)
            obj.app_.ObservationtoExplainLabelICE.Text                  = "Observation " + num2str(obj.hObservationtoExplain);
            obj.app_.ObservationtoExplainLabelPredictorImportance.Text  = "Observation " + num2str(obj.hObservationtoExplain);
            obj.app_.ObservationtoExplainLabelOOB.Text                  = "Observation " + num2str(obj.hObservationtoExplain);
            obj.app_.ObservationtoExplainLabelLIME.Text                 = "Observation " + num2str(obj.hObservationtoExplain);
            obj.app_.ObservationtoExplainLabelShapley.Text              = "Observation " + num2str(obj.hObservationtoExplain);
        end
        function updateTables(obj)
            obj.app_.ObservationTablePDP.Data                       = obj.currentData_(obj.hObservationtoExplain,:);
            obj.app_.ObservationTablePDP.ColumnName                 = obj.currentData_.Properties.VariableNames;
            obj.app_.ObservationTablePredictorImportance.Data       = obj.currentData_(obj.hObservationtoExplain,:);
            obj.app_.ObservationTablePredictorImportance.ColumnName = obj.currentData_.Properties.VariableNames;
            obj.app_.ObservationTableOOB.Data                       = obj.currentData_(obj.hObservationtoExplain,:);
            obj.app_.ObservationTableOOB.ColumnName                 = obj.currentData_.Properties.VariableNames;            
            obj.app_.ObservationTableLIME.Data                      = obj.currentData_(obj.hObservationtoExplain,:);
            obj.app_.ObservationTableLIME.ColumnName                = obj.currentData_.Properties.VariableNames;
            obj.app_.ObservationTableShapley.Data                   = obj.currentData_(obj.hObservationtoExplain,:);
            obj.app_.ObservationTableShapley.ColumnName             = obj.currentData_.Properties.VariableNames; 
        end
        
        % UPDATE Fields
        function updateLIMEScore(obj)
        	obj.app_.ScoreEditFieldLIME.Value       = obj.hScoreLIME;            
        end
        function updateLIMEExpected(obj)
            obj.app_.ExpectedEditFieldLIME.Value    = obj.hExpectedLIME;
        end
        function updateShapleyScore(obj)
            obj.app_.ScoreEditFieldShapley.Value    = obj.hScoreShapley;
        end
        function updateShapleyExpected(obj)
            obj.app_.ExpectedEditFieldShapley.Value = obj.hExpectedShapley;
        end
        
        % Update Data
        function updateData(obj, evt, src)  %#ok<INUSL>
            obj.currentData_ = obj.model_.(src.AffectedObject.hDataBG);
        end
    end
end