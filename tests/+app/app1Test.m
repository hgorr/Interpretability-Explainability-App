classdef app1Test < matlab.uitest.TestCase & matlab.mock.TestCase & matlab.unittest.TestCase
    
    properties
        TestFile    = "Data\+machine_learning\+classification\data.mat";
        MLFile      = ["Data\+machine_learning\+classification\data.mat" "Data\+machine_learning\+regression\data.mat"];
        App
    end
    
    methods(TestClassSetup)
        function checkTestFiles(obj)
            import matlab.unittest.constraints.IsFile
            arrayfun(@(x) obj.verifyThat(x,IsFile), obj.TestFile)
        end
    end
    
    methods(TestMethodSetup)
        function launchApp(obj)
            obj.App = app1;
        end
    end
    
    methods (Test)
        function testImportModelButton(obj)
            %import matlab.mock.actions.AssignOutputs
            for f = obj.MLFile
                obj.press(obj.App.MachineLearningMenu)
            end
        end
    end
end


