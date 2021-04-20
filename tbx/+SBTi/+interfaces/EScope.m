classdef EScope < SBTi.interfaces.SortableEnum
    
    properties (Constant)
        S1     = "S1"
        S2     = "S2"
        S3     = "S3"
        S1S2   = "S1+S2"
        S1S2S3 = "S1+S2+S3"
    end

    methods
        function scopeList = get_result_scopes(obj)
            % Get a list of scopes that should be calculated if the user leaves it open.
            % return: A list of EScope objects
            
            scopeList = [obj.S1S2, obj.S3, obj.S1S2S3];
        end
    end
end