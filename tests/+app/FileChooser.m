classdef FileChooser
    methods
        function [file,folder,status] = chooseFile(~,varargin)
            [file,folder,status] = uigetfile(varargin{:});
        end
    end
end