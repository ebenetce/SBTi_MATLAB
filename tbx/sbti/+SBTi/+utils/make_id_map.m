function idMap = make_id_map(portfolio)
% Create a mapping from company_id to ISIN and LEI (required for the SBTi matching).

% :param portfolio: The complete portfolio
% :return: A mapping from company_id to (ISIN, LEI) tuple

ColumnsConfig = SBTi.configs.ColumnsConfig;
idMap = dictionary();

ID = ColumnsConfig.COMPANY_ID;
ISIN = ColumnsConfig.COMPANY_ISIN;
LEI = ColumnsConfig.COMPANY_LEI;

for i = 1 : numel(portfolio)        
    idMap(portfolio(i).(ID)) = {[portfolio(i).(ISIN), portfolio(i).(LEI)]};
end