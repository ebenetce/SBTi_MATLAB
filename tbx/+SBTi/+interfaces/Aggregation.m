classdef Aggregation
    
    properties
        score (1,1) double
        proportion (1,1) double
        contributions (1,:) SBTi.interfaces.AggregationContribution
    end
    
    methods
        function obj = Aggregation(score, proportion, contributions)
            obj.score = score;
            obj.proportion = proportion;
            obj.contributions = contributions;
        end
    end
    
end