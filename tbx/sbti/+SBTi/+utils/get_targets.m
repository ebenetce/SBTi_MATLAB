function target_data = get_targets(data_providers, companies)
    
    % Get the targets in a waterfall method, given a list of companies and a list of data providers. This will go through
    % the list of data providers and retrieve the required info until either there are no companies left or there are no
    % data providers left.

    % :param data_providers: A list of data providers instances
    % :param companies: A list of companies. Each company should be a dict and contain a company_name and company_id field
    % :return: A data frame containing the targets
    
    target_data = [];
    
    for i = 1 : numel(data_providers)
        dp = data_providers(i);
        try
            targets_data_provider = dp.get_targets(companies);
            target_data = [target_data, targets_data_provider];
        catch
            warning("%s is not available yet", class(dp))
        end

    end
end