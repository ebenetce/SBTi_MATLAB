classdef Scenario
    
    % A scenario functionines the action the portfolio holder will take to improve its temperature score.
    properties
        scenario_type (1,1) sbti.ScenarioType
        engagement_type (1,1) sbti.EngagementType
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
        
%         function scenario = from_dict(scenario_values: dict) -> Optional['Scenario']:
%             
%             % Convert a dictionary to a scenario. The dictionary should have the following keys:
%             
%             % * number: The scenario type as an integer
%             % * engagement_type: The engagement type as a string
%             
%             % :param scenario_values: The dictionary to convert
%             % :return: A scenario object matching the input values or None, if no scenario could be matched
%             
%             scenario = sbti.Scenario();
%             scenario.scenario_type = ScenarioType.from_int(scenario_values.get("number", -1));
%             scenario.engagement_type = EngagementType.from_string(scenario_values.get("engagement_type", ""));
%             
%             if scenario.scenario_type is not None:
%                 return scenario
%             else
%                 return None
%             end
%         end
%         
%         function from_interface(scenario_values: Optional[ScenarioInterface]) -> Optional['Scenario']:
%             
%             % Convert a scenario interface to a scenario.
%             
%             % :param scenario_values: The interface model instance to convert
%             % :return: A scenario object matching the input values or None, if no scenario could be matched
%             
%             if scenario_values is None:
%                 return None
%             end
%             scenario = Scenario();
%             scenario.scenario_type = ScenarioType.from_int(scenario_values.number);
%             scenario.engagement_type = EngagementType.from_string(scenario_values.engagement_type);
%             
%             if scenario.scenario_type is not None:
%                 return scenario
%             else
%                 return None
%             end
%         end
%         
    end
    
end


