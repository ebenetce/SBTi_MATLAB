function company_data = get_company_data(data_providers, company_ids)
    
    % Get the company data in a waterfall method, given a list of companies and a list of data providers. This will go
    % through the list of data providers and retrieve the required info until either there are no companies left or there
    % are no data providers left.

    % :param data_providers: A list of data providers instances
    % :param company_ids: A list of company ids (ISINs)
    % :return: A data frame containing the company data
    
    company_data = [];
    
    for i = 1 : numel(data_providers)
        dp = data_providers(i);
        try
            company_data_provider = dp.get_company_data(company_ids)
            company_data = [company_data; company_data_provider];
%             company_ids = [company for company in company_ids
%                            if company not in [c.company_id for c in company_data_provider]]
%                            end
%             end
%             if len(company_ids) == 0:
%                 break
%             end
        catch
            warning("Not available yet %s", class(dp));
        end
    end
end