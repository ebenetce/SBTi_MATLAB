function contributions = get_contributions_per_group(aggregations, analysis_parameters, group)
    [timeframe, scope, ~] = deal(analysis_parameters{:});
    scope = strrep(scope(1), "+", "");
    timeframe = lower(string(timeframe(1)));

    contributions = aggregations.(timeframe).(scope).grouped(group).contributions;
    contributions = table(contributions);
    contributions.group = repmat(group, height(contributions), 1);
    contributions = contributions(:,[end,1:end-1]);
    contributions.contribution = [];