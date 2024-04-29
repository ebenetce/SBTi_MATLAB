function [scores, aggregations] = calculate(portfolio_data, fallback_score, aggregation_method, ...
              grouping, scenario, time_frames, scopes, anonymize, aggregate)
          
    % Calculate the different parts of the temperature score (actual scores, aggregations, column distribution).

    % :param portfolio_data: The portfolio data, already processed by the target validation module
    % :param fallback_score: The fallback score to use while calculating the temperature score
    % :param aggregation_method: The aggregation method to use
    % :param time_frames: The time frames that the temperature scores should be calculated for  (None to calculate all)
    % :param scopes: The scopes that the temperature scores should be calculated for (None to calculate all)
    % :param grouping: The names of the columns to group on
    % :param scenario: The scenario to play
    % :param anonymize: Whether to anonymize the resulting data set or not
    % :param aggregate: Whether to aggregate the scores or not
    % :return: The scores, the aggregations and the column distribution (if a
    
    ts = sbti.TemperatureScore(time_frames, scopes, fallback_score, scenario, aggregation_method, grouping);
    
    scores = ts.calculate(portfolio_data);
    aggregations = [];
    
    if aggregate
        aggregations = ts.aggregate_scores(scores);
    end
    
    if anonymize
        scores = ts.anonymize_data_dump(scores);
    end
end
