classdef AggregationContribution
    
    properties
        company_name (1,1) string
        company_id (1,1) string
        temperature_score (1,1) double
        contribution_relative (1,1) double
        contribution (1,1) double
    end
        
    methods (Static)
        function obj = parse_obj(contributions)
            for i = 1 : height(contributions)
                obj(i) = SBTi.interfaces.AggregationContribution;
                obj(i).company_name = contributions{i,'company_name'};
                obj(i).company_id = contributions{i,'company_id'};
                obj(i).temperature_score = contributions{i,'temperature_score'};
                obj(i).contribution_relative = contributions{i,'contribution_relative'};
                obj(i).contribution = contributions{i,'contribution'};
            end
        end
    end
end


