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
                options.view   {mustBeA(options.view, "mvc.View")}         
            end
            obj.view_ = options.view;
            attachCallbacks(obj)
        end
    end
    
    %% TEST METHODS
    methods (Access = private)
       pass = Callbacks_asserts(options)
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
            [s, name]   = obj.getfile();
            if ~isempty(s)
                s.name  = name;
                s       = obj.buildStructModel(s, mvc.Model.MachineLearningModel());
                m       = mvc.Model.MachineLearningModel({"dataTrain",  s.dataTrain, ...
                                                          "dataTest",   s.dataTest,  ...
                                                          "Mdl",        s.model, ...
                                                          "Name",       s.name});
                obj.view_.Model = m;                
                obj.runMachineLearning()
            end
        end
        function hDeepLearningMenuMenuSelectedFcn(obj, evt, src)
            [s, name]   = obj.getfile();
            if ~isempty(s)
                s.name  = name;
                s       = obj.buildStructModel(s, mvc.Model.DeepLearningModel());
                m       = mvc.Model.DeepLearningModel({"dataTrain",     s.dataTrain, ...
                                                       "dataTest",   s.dataTest,  ...
                                                       "Mdl",        s.model, ...
                                                       "Name",       s.name});
                obj.view_.Model = m;                
                %obj.runDeepLearning()
            end          
        end
        function s = buildStructModel(obj, s, className)
            classes                 = string(struct2cell(structfun(@class, s, "un", 0)));
            modelIndex              = contains(classes, className.LISTMODELS);
            dataIndex               = ismember(classes, className.LISTDATA);
            obj.Callbacks_asserts(dataIndex, "Name", "Import:two_datasets")
            obj.Callbacks_asserts(dataIndex, "Name", "Import:same_classes")
            fnames                  = string(fieldnames(s));
            s.model                 = s.(fnames(modelIndex));
        end
    end
    
    methods (Access = private)
        function runMachineLearning(obj)
            obj.view_.runPDP1()
            obj.view_.runPredictorImportance()     
        end
    end
    
    methods (Static)
        function [s, name] = getfile()
            [file, path] = uigetfile('*.mat', "Please select a .mat file with a model, training and testing data", "MultiSelect", "off");
            if isequal(file,0)
                s       = struct.empty();
            else
                
                s       = load(fullfile(path, file));
                name    = string(file);
                
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

