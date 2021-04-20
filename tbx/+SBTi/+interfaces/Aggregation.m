classdef Aggregation
    
    properties
        score (1,1) double
        proportion (1,1) double
        contributions (1,:) SBTi.interfaces.AggregationContribution
    end
    
end