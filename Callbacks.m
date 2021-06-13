classdef Callbacks 
  
    properties (Dependent)
        App
        Model
        View
    end
    
    %% IMMUTABLE PROPERTIES
    properties (SetAccess = immutable, GetAccess = private)
        view_
    end
    
    %% CONSTRUCTOR
    methods
        function obj = Callbacks(options)
            arguments
                options.view   {mustBeA(options.view, "View")}         
            end
            obj.view_ = options.view;
            attachCallbacks(obj)
        end
    end
    
    %% ACCESSORS
    methods
        function model = get.Model(obj)
            model = obj.view_.Model;
        end
        function app = get.App(obj)
            app = obj.view_.App;
        end
    end
    
    %% 
    methods
        function attachCallbacks(obj)
            obj.view_.hMachineLearningMenu.MenuSelectedFcn              = @(evt,src) hMachineLearningMenuMenuSelectedFcn(obj,evt,src);
            obj.view_.hDeepLearningMenu.MenuSelectedFcn                 = @(evt,src) hDeepLearningMenuMenuSelectedFcn(obj,evt,src);
            obj.view_.hUseParallelButton.ValueChangedFcn                = @(evt,src) hUseParallelButtonValueChangedFcn(obj,evt,src);
            obj.view_.hPredictor1DropDown.ValueChangedFcn               = @(evt,src) hPredictor1DropDownValueChangedFcn(obj,src,evt);
            obj.view_.hPredictor2DropDown.ValueChangedFcn               = @(evt,src) hPredictor2DropDownValueChangedFcn(obj,src,evt);
            obj.view_.hDistancemeasureDropDown.ValueChangedFcn          = @(evt,src) hDistancemeasureDropDownValueChangedFcn(obj,src,evt);
            obj.view_.hPredictorsSlider.ValueChangedFcn                 = @(evt,src) hPredictorsSliderValueChangedFcn(obj,src,evt);
            obj.view_.hSimulationsSpinner.ValueChangedFcn               = @(evt,src) hSimulationsSpinnerValueChangedFcn(obj,evt,src);
            obj.view_.hSwitch.ValueChangedFcn                           = @(evt,src) hSwitchValueChangedFcn(obj, evt, src);
            obj.view_.hDataTableLocal.CellSelectionCallback             = @(evt,src) hDataTableLocalCellSelectionCallback(obj, evt, src);
            obj.view_.hICEButton.ValueChangedFcn                        = @(evt,src) hICEButtonValueChangedFcn(obj,evt,src);
            obj.view_.hDropDownPI.ValueChangedFcn                       = @(evt,src) hDropDownPIValueChangedFcn(obj,evt,src);
            obj.view_.hDropDownSimpleModelType.ValueChangedFcn          = @(evt,src) hDropDownSimpleModelTypeValueChangedFcn(obj,evt,src);
        end
    end
    
    %% MENU BUTTONS
    methods (Access = private)
        function hMachineLearningMenuMenuSelectedFcn(obj, evt, src) %#ok<*INUSD>
            s = obj.getfile();
            if ~isempty(s)
                m = Model("dataTrain", s.dataTrain, "dataTest", s.dataTest, "Mdl", s.model); %#ok<CPROPLC>
                obj.view_.Model = m;
                obj.runMachineLearning()
            end
        end
        function hDeepLearningMenuMenuSelectedFcn(obj, evt, src)
            
        end
    end
    
    methods (Access = private)
        function runMachineLearning(obj)
            obj.view_.runPDP1()
            obj.view_.runPredictorImportance()     
        end
    end
    
    methods (Static)
        function structOut = getfile()
            [file, path] = uigetfile('*.mat', "Please select a model, training and testing data (or a structure)", "MultiSelect", "on");
            if isequal(file,0)
                structOut = struct.empty();
            else
                if ischar(file)
                    s                       = open(fullfile(path, file));
                    classes                 = string(struct2cell(structfun(@class, s, "un", 0)));
                    [modelIndex, dataIndex] = extractData();
                    fnames                  = string(fieldnames(s));
                    sizes                   = cell2mat(cellfun(@(x) size(x,1),arrayfun(@(x) s.(x), fnames(dataIndex), "un", 0),'UniformOutput',false));
                    structOut.dataTrain     = s.(fnames((max(sizes) == sizes)));
                    structOut.dataTest      = s.(fnames((min(sizes) == sizes)));
                    structOut.model         = s.(fnames(modelIndex));                  
                elseif iscell(file)
                    s                       = cellfun(@(x) open(fullfile(path, x)), file, "un", 0);
                    classes                 = string(cellfun(@(x) class(x.(string(fieldnames(x)))),s,'UniformOutput',false));
                    [modelIndex, dataIndex] = extractData();
                    sizes                   = cell2mat(cellfun(@(x) size(x.(string(fieldnames(x))),1),s(dataIndex),'UniformOutput',false));
                    structOut.dataTrain     = s{(max(sizes) == sizes)}.(string(fieldnames(s{(max(sizes) == sizes)})));
                    structOut.dataTest      = s{(min(sizes) == sizes)}.(string(fieldnames(s{(min(sizes) == sizes)})));
                    structOut.model         = s{modelIndex}.(string(fieldnames(s{modelIndex})));
                end
            end
            function [modelIndex, dataIndex] = extractData()
            	dataIndex   = contains(classes, ["double", "table"]);
                    assert(sum(dataIndex) == 2, "You must have 2 datasets")
                    assert(numel(unique(classes(dataIndex)))==1, "Training and testing data must be same class")
                modelIndex  = startsWith(classes, "classreg.learning.regr") | startsWith(classes, "classreg.learning.classif");
                    assert(all(dataIndex | modelIndex), "You must have 2 datasets & 1 regression or classification model")
            end
        end
    end
    
    methods (Access = private)
        
        % MODEL
        function hSwitchValueChangedFcn(obj, evt, src)
            obj.view_.hSwitch = evt.Value;  
        end
        
        % GLOBAL
        % PDP
        function hPredictor1DropDownValueChangedFcn(obj,evt,src)
            try
                obj.view_.runPDP1()
            catch e
                obj.view_.App.Predictor1DropDown.Value = evt.PreviousValue;
                disp(e.message)
                obj.view_.Pointer = "arrow";
            end
        end
        function hPredictor2DropDownValueChangedFcn(obj,evt,src)
            try
                obj.view_.runPDP2()
            catch e
                obj.view_.App.Predictor2DropDown.Value = evt.PreviousValue;
                disp(e.message)
                obj.view_.Pointer = "arrow";
            end
        end
        function hICEButtonValueChangedFcn(obj,evt,src)
            obj.view_.runPDP1()
        end
        % PI
        function hDropDownPIValueChangedFcn(obj,src,evt)
            obj.view_.runPI(evt.PreviousValue)
        end
        
        % LOCAL
        % LIME
        function hDistancemeasureDropDownValueChangedFcn(obj,evt,src)
            obj.view_.runLIME;
        end
        function hPredictorsSliderValueChangedFcn(obj,evt,src)
            obj.view_.runLIME;
        end
        function hDropDownSimpleModelTypeValueChangedFcn(obj,evt,src)
            obj.view_.runLIME;
        end
        % Shapley
        function hSimulationsSpinnerValueChangedFcn(obj,evt,src)
            obj.view_.runShapley;
        end
        function hUseParallelButtonValueChangedFcn(obj,evt,src)
            obj.view_.runShapley;
        end

        % TABLE
        function hDataTableLocalCellSelectionCallback(obj, ~, evt)
            obj.view_.hQueryPoint = evt.Source.Data(evt.Indices(1),:);
            notify(obj.view_, "newQueryPoint", newQueryPoint(evt.Indices(1)))
            obj.view_.runLIME;
            obj.view_.runShapley;
            obj.view_.runGAM;
        end

    end
              
        
end

