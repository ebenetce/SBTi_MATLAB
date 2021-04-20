function isinMap = make_isin_map(portfolio)
    
    % Create a mapping from company_id to ISIN (required for the SBTi matching).

    % :param df_portfolio: The complete portfolio
    % :return: A mapping from company_id to ISIN
    isinMap = containers.Map([portfolio.(SBTi.configs.ColumnsConfig.COMPANY_ID)], ...
        [portfolio.(SBTi.configs.ColumnsConfig.COMPANY_ISIN)]);