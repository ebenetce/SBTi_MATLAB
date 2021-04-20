function portfolio_data = get_data(data_providers, portfolio)

% Get the required data from the data provider(s), validate the targets and return a 9-box grid for each company.

% :param data_providers: A list of DataProvider instances
% :param portfolio: A list of PortfolioCompany models
% :return: A data frame containing the relevant company-target data

tb_portfolio = SBTi.utils.flatten_user_fields(portfolio.toTable);
company_data = SBTi.utils.get_company_data(data_providers, tb_portfolio.company_id);
target_data = SBTi.utils.get_targets(data_providers, [portfolio.company_id]);
if isempty(target_data)
    error("None targets found")
end

% Supplement the company data with the SBTi target status
sbti = SBTi.SBTi;
company_data = sbti.get_sbti_targets(company_data, SBTi.utils.make_isin_map(portfolio));

% Prepare the data
tp = SBTi.TargetProtocol();
portfolio_data = tp.process(target_data, company_data);

tb_portfolio.company_name = [];
portfolio_data = outerjoin(portfolio_data, tb_portfolio, ...
    "Type", "left", "Keys", "company_id","MergeKeys",true);

end