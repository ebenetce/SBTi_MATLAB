classdef PortfolioAggregationMethod
    % The portfolio aggregation method determines how the temperature scores for the individual companies are aggregated
    % into a single portfolio score.
    
    enumeration
        WATS
        TETS
        MOTS
        EOTS
        ECOTS
        AOTS
        ROTS
    end
    
    methods (Static)
        
        function value = is_emissions_based(method)
            % Check whether a given method is emissions-based (i.e. it uses the emissions to calculate the aggregation).
            % :param method: The method to check
            % :return:
            
            arguments
               method (1,1) string = 'PortfolioAggregationMethod'
            end
            
            value = method == SBTi.PortfolioAggregationMethod.MOTS | method == SBTi.PortfolioAggregationMethod.EOTS ...
                  | method == SBTi.PortfolioAggregationMethod.ECOTS | method == SBTi.PortfolioAggregationMethod.AOTS ...
                  | method == SBTi.PortfolioAggregationMethod.ROTS;
            
        end
        
        function value = get_value_column(method, column_config)
            
            arguments
                method (1,1) string
                column_config (1,1) SBTi.configs.ColumnsConfig = SBTi.configs.ColumnsConfig;
            end
           
            map_value_column = struct( ...
                string(SBTi.PortfolioAggregationMethod.MOTS),  column_config.MARKET_CAP,  ...
                string(SBTi.PortfolioAggregationMethod.EOTS),  column_config.COMPANY_ENTERPRISE_VALUE, ...
                string(SBTi.PortfolioAggregationMethod.ECOTS), column_config.COMPANY_EV_PLUS_CASH, ...
                string(SBTi.PortfolioAggregationMethod.AOTS),  column_config.COMPANY_TOTAL_ASSETS, ...
                string(SBTi.PortfolioAggregationMethod.ROTS),  column_config.COMPANY_REVENUE ...
                );
            
            try
                value = map_value_column.(method);
            catch
                value = column_config.MARKET_CAP;
            end
        end
        
    end
    
end

