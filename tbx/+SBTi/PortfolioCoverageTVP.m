classdef PortfolioCoverageTVP < sbti.PortfolioAggregation
    % Lookup the companies in the given portfolio and determine whether they have a SBTi approved target.
    % 
    % :param config: A class defining the constants that are used throughout this class. This parameter is only required
    %                if you'd like to overwrite a constant. This can be done by extending the PortfolioCoverageTVPConfig
    %                class and overwriting one of the parameters.
    properties
        c
    end
    
    methods
        
        function obj = PortfolioCoverageTVP(config)
            obj = obj@sbti.PortfolioAggregation(config);            
            obj.c = config;
        end
        
        function score = get_portfolio_coverage(obj, company_data)
            %             portfolio_aggregation_method: PortfolioAggregationMethod) -> Optional[float]:
            %             Get the TVP portfolio coverage (i.e. what part of the portfolio has a SBTi validated target).
            %
            %             :param company_data: The company as it is returned from the data provider's get_company_data call.
            %             :param portfolio_aggregation_method: PortfolioAggregationMethod: The aggregation method to use
            %             :return: The aggregated score
            
%             company_data(obj.c.OUTPUT_TARGET_STATUS) = company_data.apply(
%             lambda row: 100 if row[obj.c.COLS.SBTI_VALIDATED] else 0,
%             axis=1
%             )
            
%             return obj._calculate_aggregate_score(company_data, obj.c.OUTPUT_TARGET_STATUS,
%             portfolio_aggregation_method).sum()
        end
    end
end
