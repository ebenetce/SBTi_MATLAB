% from abc import ABC
% from enum import Enum
% from typing import Type
% 
% import pandas as pd
% from .configs import PortfolioAggregationConfig, ColumnsConfig
% from .interfaces import EScope

classdef PortfolioAggregationMethod
    % The portfolio aggregation method determines how the temperature scores for the individual companies are aggregated
    % into a single portfolio score.
    
    properties (Constant)
        WATS = "WATS"
        TETS = "TETS"
        MOTS = "MOTS"
        EOTS = "EOTS"
        ECOTS = "ECOTS"
        AOTS = "AOTS"
        ROTS = "ROTS"
    end
    
    methods (Static)
        
        function value = is_emissions_based(method)
            % Check whether a given method is emissions-based (i.e. it uses the emissions to calculate the aggregation).
            % :param method: The method to check
            % :return:
            
            arguments
               method (1,1) string = 'PortfolioAggregationMethod'
            end
            
            value = method == sbti.PortfolioAggregationMethod.MOTS | method == sbti.PortfolioAggregationMethod.EOTS ...
                  | method == sbti.PortfolioAggregationMethod.ECOTS | method == sbti.PortfolioAggregationMethod.AOTS ...
                  | method == sbti.PortfolioAggregationMethod.ROTS;
            
        end
        
        function value = get_value_column(method, column_config)
            
            arguments
                method (1,1) string
                column_config (1,1) sbti.ColumnsConfig
            end
           
            map_value_column = struct( ...
                sbti.PortfolioAggregationMethod.MOTS, column_config.MARKET_CAP,  ...
                sbti.PortfolioAggregationMethod.EOTS, column_config.COMPANY_ENTERPRISE_VALUE, ...
                sbti.PortfolioAggregationMethod.ECOTS, column_config.COMPANY_EV_PLUS_CASH, ...
                sbti.PortfolioAggregationMethod.AOTS, column_config.COMPANY_TOTAL_ASSETS, ...
                sbti.PortfolioAggregationMethod.ROTS, column_config.COMPANY_REVENUE ...
                );
            
            value = map_value_column.(method);
        end
        
    end
    
end

