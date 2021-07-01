classdef (Abstract, AllowedSubclasses = {?mvc.Model.MachineLearningModel, ?mvc.Model.DeepLearningModel}) Model < handle
    
    properties (Constant)
        INPUT       string = ["DataTrain", "DataTest", "Mdl", "VariableToExplain"]
        OUTPUT      string = []
    end
    
    properties (Abstract = true, Constant)
        LISTMODELS  string
        LISTDATA    string
    end
    properties (Abstract = true, Dependent)
        Type1 (1,1) string {mustBeMember(Type1, ["classreg.learning.classif", "classreg.learning.regr", "SeriesNetwork"])}
        Type2 (1,1) string
    end
    
    properties (Dependent)
        DataTrain           
        DataTest            
        Mdl                 
        VariableToExplain   
        Name                
    end
    
    properties (Access = protected)
        datatrain_  (:,:) {mustBeAData}     = ""
        datatest_   (:,:) {mustBeAData}     = ""       
        mdl_        (1,1) {mustBeAnIAModel} = ""       
    end
    
    properties (Access = protected)
        variableToExplain_  (1,1) string {mustBeNonempty}
        name_               (1,1) string {mustBeNonempty}
    end
    
    %% CONSTRUCTOR
    methods
        function obj = Model(options)
            arguments
                options.dataTrain = []         
                options.dataTest  = []          
                options.mdl       = ""          
                options.name      = ""          
            end
            obj.mdl_        = options.mdl;
            obj.datatrain_  = options.dataTrain;
            obj.datatest_   = options.dataTest;   
            obj.name_       = options.name;
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
   
end


function mustBeAData(data)
if ~isstring(data) && ~isempty(data)
    if ~ismember(class(data), mvc.Model.MachineLearningModel.LISTDATA) && ~ismember(class(data), mvc.Model.DeepLearningModel.LISTDATA)
        eidType = 'mustBeAData:notAnAcceptedData';
        msgType = 'Value assigned to DataTrain/DataTest property is not an accepted data in the app.';
        throwAsCaller(MException(eidType,msgType))
    end
end
end
function mustBeAnIAModel(mdl)
if ~isstring(mdl) && ~isempty(mdl)
    if ~contains(class(mdl), mvc.Model.MachineLearningModel.LISTMODELS) && ~contains(class(mdl), mvc.Model.DeepLearningModel.LISTMODELS)
        eidType = 'mustBeAnAIModel';
        msgType = 'Value assigned to Model property is not classif.learning, reg.learning or series network.';
        throwAsCaller(MException(eidType,msgType))
    end
end
end




