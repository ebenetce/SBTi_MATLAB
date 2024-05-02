function print_grouped_scores(aggregations)

for time_frame = properties(aggregations)'

    time_frame_value = aggregations.(time_frame{1});

    if ~isempty(time_frame_value)

        for scope = properties(time_frame_value)'

            scope_value = time_frame_value.(scope{1});

            if ~isempty(scope_value)

                fprintf('\n')
                fprintf('%25sTemp score\n',' ')
                fprintf('%-s - %s\n', time_frame{1}, scope{1})

                for group  = keys(scope_value.grouped)

                    aggregation = scope_value.grouped(group{1});
                    t = aggregation.score;

                    fprintf("%-25s  %0.2f\n", group{1}, t)

                end

            end

        end

    end

end