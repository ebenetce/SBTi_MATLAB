classdef EngagementType
    % An engagement type defines how the companies will be engaged.
    properties (Constant)
        SET_TARGETS = 1
        SET_SBTI_TARGETS = 2
    end
    
    methods (Static)
        function type = from_int(value)
            % Convert an integer to an engagement type.
            % :param value: The value to convert
            % :return: 
            switch value
                case 0
                    type = sbti.EngagementType.SET_TARGETS;
                case 1
                    type = sbti.EngagementType.SET_SBTI_TARGETS;
                otherwise 
                    type = sbti.EngagementType.SET_TARGETS;
            end
        end
        
        function type = from_string(value)
            % Convert an integer to an engagement type.
            % :param value: The value to convert
            % :return:
            
            switch value
                case 'SET_TARGETS'
                    type = sbti.EngagementType.SET_TARGETS;
                case 'SET_SBTI_TARGETS'
                    type = sbti.EngagementType.SET_SBTI_TARGETS;
                otherwise 
                    type = sbti.EngagementType.SET_TARGETS;
            end
        end
        
    end
end