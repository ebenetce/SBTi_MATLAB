classdef ScoreAggregation
    
    properties
        all (1,1) SBTi.interfaces.Aggregation
        influence_percentage (1,1) double
        grouped (1,1) struct
    end
    
    methods
        function obj = ScoreAggregation(grouped, all, influence_percentage)
            
            obj.all = all;
            obj.influence_percentage = influence_percentage;
            obj.grouped = grouped;
            
        end
    end
end