classdef PortfolioCoverageTVP < SBTi.PortfolioAggregation
    % Lookup the companies in the given portfolio and determine whether they have a SBTi approved target.
    % 
    % :param config: A class defining the constants that are used throughout this class. This parameter is only required
    %                if you'd like to overwrite a constant. This can be done by extending the PortfolioCoverageTVPConfig
    %                class and overwriting one of the parameters.
    
    methods
        
        function obj = PortfolioCoverageTVP(config)
            
            arguments
                config (1,1) SBTi.configs.PortfolioCoverageTVPConfig = SBTi.configs.PortfolioCoverageTVPConfig
            end
            
            obj = obj@SBTi.PortfolioAggregation(config);            
            obj.c = config;
        end
        
        function score = get_portfolio_coverage(obj, company_data, portfolio_aggregation_method)
            % portfolio_aggregation_method: PortfolioAggregationMethod) -> Optional[float]:
            % Get the TVP portfolio coverage (i.e. what part of the portfolio has a SBTi validated target).
            %
            % :param company_data: The company as it is returned from the data provider's get_company_data call.
            % :param portfolio_aggregation_method: PortfolioAggregationMethod: The aggregation method to use
            % :return: The aggregated score
            
            idx = company_data.(obj.c.COLS.SBTI_VALIDATED); 
            company_data.(obj.c.OUTPUT_TARGET_STATUS) = zeros(height(company_data),1);
            company_data{idx, obj.c.OUTPUT_TARGET_STATUS} = 100;

            score = sum( obj.calculate_aggregate_score( ...
                company_data, ...
                obj.c.OUTPUT_TARGET_STATUS, ...
                portfolio_aggregation_method) );
            
        end
    end
end
