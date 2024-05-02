function cm = plot_grouped_heatmap(grouped_aggregations, timeframe, scope, grouping)
%PLOT_GROUPED_HEATMAP Summary of this function goes here
%   Detailed explanation goes here

arguments
    grouped_aggregations
    timeframe
    scope
    grouping (1,2) string
end
    
    scope = strrep(scope, "+", "");
    group_1 = grouping(1);
    group_2 = grouping(2);

    aggregations = grouped_aggregations.(timeframe).(scope).grouped;
    combinations = string(keys(aggregations));

    groups = struct(group_1, string.empty(), group_2, string.empty());
    
    for combination = combinations
        items = split(combination,'-');
        item_group_1 = items(1);
        item_group_2 = items(2);
        if ~ismember(string(item_group_1), groups.(group_1))
            groups.(group_1) = [groups.(group_1), item_group_1];
        end
        if ~ismember(item_group_2, groups.(group_2))
            groups.(group_2) = [groups.(group_2), item_group_2];
        end
    end
    groups.(group_1) = sort(groups.(group_1));
    groups.(group_2) = sort(groups.(group_2), 'descend');
    
    x = length(groups.(group_1));
    y = length(groups.(group_2));
    grid = zeros(y, x);
    for i = 1 : y
       for j = 1 : x       
           g1 = groups.(group_2)(i);
           g2 = groups.(group_1)(j);
           key = g2+'-'+g1;
           if ismember(key, combinations)
               grid(i, j) = aggregations(key).score;
           else
               grid(i, j) = NaN;
           end
       end
    end
    
    cm = heatmap(groups.(group_1),groups.(group_2),grid,'Colormap',flipud(autumn));

end

