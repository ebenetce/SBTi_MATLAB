function list = table_to_portfolio(df_portfolio)
    
    % Convert a table to a list of portfolio company objects.

    % :param df_portfolio: The data frame to parse. The column names should align with the attribute names of the
    % PortfolioCompany model.
    % :return: A list of portfolio companies
    
    values = df_portfolio.(SBTi.configs.ColumnsConfig.ENGAGEMENT_TARGET);
    
    if ~islogical(values)
        values = lower(string(df_portfolio.(SBTi.configs.ColumnsConfig.ENGAGEMENT_TARGET)));
        values(values == "") = "false";
        values = strcmpi(values, "true");
        
        df_portfolio.(SBTi.configs.ColumnsConfig.ENGAGEMENT_TARGET) = values;
    end
    
    list = SBTi.PortfolioCompany(df_portfolio);
    
%     [PortfolioCompany.parse_obj(company) for company in df_portfolio.to_dict(orient="records")]
    
        
%     list = {};
%     for company =  df_portfolio.to_dict("records")
%         list.company = PortfolioCompany.parse_obj(company);
%     end
% 
%     """
%     Convert a data frame to a list of portfolio company objects.
% 
%     :param df_portfolio: The data frame to parse. The column names should align with the attribute names of the
%     PortfolioCompany model.
%     :return: A list of portfolio companies
%     """
%     df_portfolio[ColumnsConfig.ENGAGEMENT_TARGET] = df_portfolio[ColumnsConfig.ENGAGEMENT_TARGET].fillna(False).astype('bool')
%     return [PortfolioCompany.parse_obj(company) for company in df_portfolio.to_dict(orient="records")]
end