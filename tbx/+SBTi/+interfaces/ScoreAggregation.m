classdef ScoreAggregation
    
    properties
        all SBTi.interfaces.Aggregation = SBTi.interfaces.Aggregation.empty()
        influence_percentage (1,1) double
        grouped containers.Map
    end
    
    methods
        function obj = ScoreAggregation(grouped, all, influence_percentage)
            
            obj.all = all;
            obj.influence_percentage = influence_percentage;
            
            if grouped.Count == 0
                obj.grouped = containers.Map;
            else
                obj.grouped = grouped;
            end
            
        end
    end
end