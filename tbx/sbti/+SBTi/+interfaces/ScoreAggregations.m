classdef ScoreAggregations
    
    properties
        short (:,1) SBTi.interfaces.ScoreAggregationScopes = SBTi.interfaces.ScoreAggregationScopes.empty()
        mid   (:,1) SBTi.interfaces.ScoreAggregationScopes = SBTi.interfaces.ScoreAggregationScopes.empty()
        long  (:,1) SBTi.interfaces.ScoreAggregationScopes = SBTi.interfaces.ScoreAggregationScopes.empty()
    end
    
    methods
        function tb = summary(obj)
            tb = table([obj.short.S1S2.all.score; obj.short.S3.all.score; obj.short.S1S2S3.all.score], ...
                [obj.mid.S1S2.all.score; obj.mid.S3.all.score; obj.mid.S1S2S3.all.score], ...
                [obj.long.S1S2.all.score; obj.long.S3.all.score; obj.long.S1S2S3.all.score], VariableNames = ["SHORT", "MID", "LONG"], RowNames = {'S1S2', 'S3', 'S1S2S3'});

            tb = round(tb, 2);

        end
    end
end