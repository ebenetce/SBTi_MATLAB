function record_dict = flatten_user_fields(portfolio)
    
    % Flatten the user fields in a portfolio company and return it as a dictionary.

    % :param record: The record to flatten
    % :return:
    
    record_dict = portfolio;
    if ismember("user_fields", portfolio.Properties.VariableNames)
        
        userFields = fields(portfolio.user_fields);
        for i = 1 : numel(userFields)
            f = userFields(i);
            record_dict.(f) = [portfolio.user_fields.(f)]';         
        end
        
    end
    record_dict.user_fields = [];
    
end