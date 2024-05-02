function company_contributions = collect_company_contributions(aggregated_portfolio, amended_portfolio, analysis_parameters)
    [timeframe, scope, grouping] = deal(analysis_parameters{:});
    scope = strrep(scope(1),  "+", "");
    timeframe = lower(string(timeframe(1)));

    contributions = aggregated_portfolio.(timeframe).(scope).all.contributions;
    company_names = [contributions.company_name];
    relative_contributions = [contributions.contribution_relative];
    temperature_scores = [contributions.temperature_score];

    company_contributions = table(company_names', relative_contributions',temperature_scores', 'VariableNames',["company_name", "contribution", "temperature_score"]);
    additional_columns = ["company_name", "company_id", "company_market_cap", "investment_value", grouping];
    company_contributions = outerjoin(company_contributions,amended_portfolio(:,additional_columns), "Type", "left", "Keys","company_name");
    company_contributions.Properties.VariableNames{1} = 'company_name';
    company_contributions.portfolio_percentage = 100 * company_contributions.investment_value / sum(company_contributions.investment_value);
    company_contributions.ownership_percentage = 100 * company_contributions.investment_value ./ company_contributions.company_market_cap;
    company_contributions = sortrows(company_contributions, 'contribution', 'descend');