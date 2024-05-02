classdef tExamples < matlab.unittest.TestCase
    properties
        Here
    end
    methods (TestClassSetup)
        function moveDir(tc)
            tc.Here = pwd();
            cd(fullfile(SBTiroot,'examples'))
        end            
    end
    methods (TestClassTeardown)
        function moveDirBack(tc)
            cd(tc.Here)
            close all;
        end
    end
    methods (Test)
        function tAllExamples(~)                
            run(fullfile(SBTiroot, 'examples','analysis_example.mlx'))            
            run(fullfile(SBTiroot, 'examples','portfolio_aggregations.mlx'))            
            run(fullfile(SBTiroot, 'examples','quick_temp_score_calculation.mlx'))            
            run(fullfile(SBTiroot, 'examples','Reporting.mlx'))
            run(fullfile(SBTiroot, 'examples','what_if_analysis.mlx'))
        end
    end
end