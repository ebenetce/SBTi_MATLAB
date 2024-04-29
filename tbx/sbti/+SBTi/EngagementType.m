classdef EngagementType < double
    % An engagement type defines how the companies will be engaged.
    enumeration
        SET_TARGETS (1)
        SET_SBTi_TARGETS (2)
    end
    
    methods (Static)
        function type = from_int(value)
            % Convert an integer to an engagement type.
            % :param value: The value to convert
            % :return: 
            switch value
                case 0
                    type = SBTi.EngagementType.SET_TARGETS;
                case 1
                    type = SBTi.EngagementType.SET_SBTi_TARGETS;
                otherwise 
                    type = SBTi.EngagementType.SET_TARGETS;
            end
        end
        
        function type = from_string(value)
            % Convert an integer to an engagement type.
            % :param value: The value to convert
            % :return:
            
            switch value
                case 'SET_TARGETS'
                    type = SBTi.EngagementType.SET_TARGETS;
                case 'SET_SBTi_TARGETS'
                    type = SBTi.EngagementType.SET_SBTi_TARGETS;
                otherwise 
                    type = SBTi.EngagementType.SET_TARGETS;
            end
        end
        
    end
end