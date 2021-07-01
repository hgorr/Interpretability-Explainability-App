function Callbacks_asserts(~, varargin, options)

arguments
    ~
end

arguments (Repeating)
    varargin
end

arguments
    options.Name (1,1) string {mustBeMemberList}
end

switch options.Name
    case "Import:two_datasets"
        dataIndex = varargin{:};
        assert(sum(dataIndex) == 2, "You must have 2 datasets")
    case "Import:same_classes"
end


end

function mustBeMemberList(name)
    List = ["Import:two_datasets", ...
            "Import:same_classes"];   
    if ~ismember(name, List)
        eidType = 'mustBeMemberList:notDefinedAssert';
        msgType = 'Assert name is not defined.';
        throwAsCaller(MException(eidType,msgType))
    end 
end
