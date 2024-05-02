function print_aggregations(aggregations)
%PRINT_AGGREGATIONS Summary of this function goes here
%   Detailed explanation goes here

arguments
    aggregations SBTi.interfaces.ScoreAggregations
end

fprintf("%10s %10s %13s\n",'Timeframe', 'Scope', 'Temp score')
for time_frame = string(properties(aggregations))'
    time_frame_values = aggregations.(time_frame);
   if ~isempty(time_frame_values)
       for scope = string(properties(time_frame_values))'
           scope_values = time_frame_values.(scope);
           if ~isempty(scope_values)
               fprintf("%10s %10s %10.2f\n",time_frame, scope, scope_values.all.score)
           end
       end
   end
end
                
end

