classdef DeepLearningModel < mvc.Model.Model
    
    properties (Constant)
        LISTDATA    = "matlab.io.datastore.ImageDatastore"
        LISTMODELS  = "SeriesNetwork"
    end
    
    properties (Dependent)
        Type1 
        Type2 
    end
    
    %% CONSTRUCTOR
    methods
        function obj = DeepLearningModel(options)
            if nargin == 0
                options = {};
            end            
            obj = obj@mvc.Model.Model(options{:});
            %             if obj.Type1 == "classreg.learning.classif"
            %                 obj.variableToExplain_  = obj.mdl_.ResponseName;
            %                 obj.datatrain_.(obj.variableToExplain_) = categorical(obj.datatrain_.(obj.variableToExplain_));
            %             elseif obj.Type1 == "classreg.learning.regr"
            %                 obj.variableToExplain_  = setdiff(obj.datatrain_.Properties.VariableNames, string(obj.mdl_.ExpandedPredictorNames));
            %             end
        end
    end
    
    %% ACCESSORS
    methods
        function type = get.Type1(obj)
%             type = extract(string(class(obj.mdl_)), lettersPattern + "." + lettersPattern + "." + lettersPattern);
        end
    end
    
    %% PUBLIC METHODS
    %% MODELS
    methods (Access = {?mvc.View})
    end
    
    methods (Static)
    end
    
end
