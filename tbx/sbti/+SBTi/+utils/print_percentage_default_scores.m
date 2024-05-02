function print_percentage_default_scores(aggregations)

fprintf("%10s %10s %10s\n", 'Timeframe', 'Scope', '% Default score')
for time_frame = properties(aggregations)'
    time_frame_values = aggregations.(time_frame{1});
    if ~isempty(time_frame_values)
        for scopes = properties(time_frame_values)'
            scope_values = time_frame_values.(scopes{1});
            if ~isempty(scope_values)
                fprintf("%10s %10s %0.2f\n", time_frame{1}, scopes{1}, scope_values.influence_percentage )
            end
        end
    end
end