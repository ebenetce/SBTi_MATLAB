classdef Scenario
    
    % A scenario functionines the action the portfolio holder will take to improve its temperature score.
    properties
        scenario_type (:,1) SBTi.ScenarioType = SBTi.ScenarioType.empty()
        engagement_type (:,1) SBTi.EngagementType = SBTi.EngagementType.empty()
    end
    
    methods
        
        function value = get_score_cap(obj)
            if obj.engagement_type == EngagementType.SET_TARGETS
                value = 2;
            elseif obj.scenario_type == ScenarioType.APPROVED_TARGETS || obj.engagement_type == EngagementType.SET_SBTI_TARGETS
                value = 1.75;
            else
                value = NaN;
            end
        end
        
        function value = get_fallback_score(obj, fallback_score)
            
            if obj.scenario_type == sbti.ScenarioType.TARGETS
                value = 2.0;
            else
                value = fallback_score;
            end
        end
        
    end
    
    methods (Static)
        
        function scenario = from_dict(scenario_values)
            
            % Convert a dictionary to a scenario. The dictionary should have the following keys:
            
            % * number: The scenario type as an integer
            % * engagement_type: The engagement type as a string
            
            % :param scenario_values: The dictionary to convert
            % :return: A scenario object matching the input values or None, if no scenario could be matched
            
            scenario = SBTi.Scenario;
            try
                val = scenario_values.number;
            catch
                val = -1;
            end
            
            try
                str = scenario_values.engagement_type;
            catch
                str = "";
            end
            scenario.scenario_type = SBTi.ScenarioType.from_int(val);
            scenario.engagement_type = SBTi.EngagementType.from_string(str);
            
            if isempty(scenario.scenario_type)
                scenario = SBTi.Scenario.empty();
            end
            
        end
        
        function scenario = from_interface(scenario_values)
            
            % Convert a scenario interface to a scenario.
            
            % :param scenario_values: The interface model instance to convert
            % :return: A scenario object matching the input values or None, if no scenario could be matched
            
            if nargin < 1 || isempty(scenario_values)
                scenario = SBTi.Scenario.empty();
                return
            end
            
            scenario = SBTi.Scenario;
            scenario.scenario_type   = SBTi.ScenarioType.from_int( double(scenario_values) );
            scenario.engagement_type = SBTi.EngagementType.from_string( string(scenario_values) );
            
            if isempty(scenario.scenario_type)
                scenario = SBTi.Scenario.empty();
            end
        end
    end
    
end


