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
            obj.view_   = options.view;
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
            % Explainer Tab
                        
                % Buttons
                obj.view_.hRUNALLButton.ButtonPushedFcn                 = @(~,~) hRUNALLButtonButtonPushedFcn(obj);
                obj.view_.hGenerateReportButton.ButtonPushedFcn         = @(~,~) hGenerateReportButtonButtonPushedFcn(obj);
                obj.view_.hClearFiguresButton.ButtonPushedFcn           = @(~,~) hClearFiguresButtonButtonPushedFcn(obj);
                obj.view_.hRUNButtonPDP.ButtonPushedFcn                 = @(~,~) hRUNButtonPDPButtonPushedFcn(obj);
                obj.view_.hRUNButtonPredictorImportance.ButtonPushedFcn = @(~,~) hRUNButtonPredictorImportanceButtonPushedFcn(obj);
                obj.view_.hRUNButtonOOB.ButtonPushedFcn                 = @(~,~) hRUNButtonOOBButtonPushedFcn(obj);
                obj.view_.hRUNButtonLIME.ButtonPushedFcn                = @(~,~) hRUNButtonLIMEButtonPushedFcn(obj);
                obj.view_.hRUNButtonShapley.ButtonPushedFcn             = @(~,~) hRUNButtonShapleyButtonPushedFcn(obj);
                
                % Check boxes
                obj.view_.hUseParallelCheckBox.ValueChangedFcn  = @(evt,src) hUseParallelCheckBoxValueChangedFcn(obj,evt,src);

                % Lists
                obj.view_.hPredictor1DropDown.ValueChangedFcn               = @(evt,src) hPredictor1DropDownValueChangedFcn(obj,src,evt);
                obj.view_.hPredictor2DropDown.ValueChangedFcn               = @(evt,src) hPredictor2DropDownValueChangedFcn(obj,src,evt);
                obj.view_.hDistancemeasureDropDown.ValueChangedFcn          = @(evt,src) hDistancemeasureDropDownValueChangedFcn(obj,src,evt);
                
                % Spinner
                obj.view_.hPredictorsSpinner.ValueChangedFcn                = @(evt,src) hPredictorsSpinnerValueChangedFcn(obj,src,evt);
                
                % Edit Field
                obj.view_.hObservationtoExplainEditField.ValueChangedFcn    = @(evt,src) hObservationtoExplainEditFieldValueChangedFcn(obj,evt,src);
                obj.view_.hSimulationsEditField.ValueChangedFcn             = @(evt,src) hSimulationsEditFieldValueChangedFcn(obj,evt,src);

                % Switch
                obj.view_.hSwitch.ValueChangedFcn                           = @(evt,src) hSwitchValueChangedFcn(obj, evt, src);
                
                % Button Group (Radio)
                obj.view_.hDataButtonGroup.SelectionChangedFcn              = @(evt, src) hDataButtonGroupSelectionChangedFcn(obj, evt, src);
        end
    end
    
    %%
    methods (Access = private)
        % RUN Buttons
        function hRUNALLButtonButtonPushedFcn(obj)
            run(obj.view_)
        end        
        function hRUNButtonPDPButtonPushedFcn(obj)
            runPDP(obj.view_);
        end
        function hRUNButtonPredictorImportanceButtonPushedFcn(obj)
            runPredictorImportance(obj.view_);
        end
        function hRUNButtonOOBButtonPushedFcn(obj)
            runOOB(obj.view_);
        end        
        function hRUNButtonLIMEButtonPushedFcn(obj)
            runLIME(obj.view_);
        end
        function hRUNButtonShapleyButtonPushedFcn(obj)
            runShapley(obj.view_);
        end
        function hActivationsCheckBoxValueChangedFcn(obj,evt,src)
            obj.view_.hActivations = evt.Value;
        end
        function hTSNECheckBoxValueChangedFcn(obj,evt,src)
            obj.view_.hTSNE = evt.Value;
        end
        function hImageLIMECheckBoxValueChangedFcn(obj,evt,src)
            obj.view_.hImageLIME = evt.Value;
        end
        function hUseParallelCheckBoxValueChangedFcn(obj,evt,src)
            obj.view_.hUseParallel = evt.Value;
        end

        % LISTS
        function hPredictor1DropDownValueChangedFcn(obj,evt,src)
            obj.view_.hPredictor1 = evt.Value;
        end
        function hPredictor2DropDownValueChangedFcn(obj,evt,src)
            obj.view_.hPredictor2 = evt.Value;
        end
        function hDistancemeasureDropDownValueChangedFcn(obj,evt,src)
            obj.view_.hDistancemeasure = evt.Value;
        end
        
        % SPINNER
        function hPredictorsSpinnerValueChangedFcn(obj,evt,src)
            obj.view_.hSpinner = evt.Value;
        end

        % EDIT FIELDS
        function hObservationtoExplainEditFieldValueChangedFcn(obj,evt,src)
            obj.view_.hObservationtoExplain = evt.Value;
        end
        function hSimulationsEditFieldValueChangedFcn(obj,evt,src)
            obj.view_.hSimulations = evt.Value;
        end

        % SWITCH
        function hSwitchValueChangedFcn(obj, evt, src)
            obj.view_.hSwitch = evt.Value;
        end
        
        % BUTTON GROUP
        function hDataButtonGroupSelectionChangedFcn(obj, evt, src)
            obj.view_.hDataBG = evt.SelectedObject.Text;
        end

    end
              
        
end

