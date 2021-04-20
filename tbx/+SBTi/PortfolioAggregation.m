classdef PortfolioAggregation
    % This class is a base class that provides portfolio aggregation calculation.
    %
    % :param config: A class defining the constants that are used throughout this class. This parameter is only required
    %                if you'd like to overwrite a constant. This can be done by extending the PortfolioAggregationConfig
    %                class and overwriting one of the parameters.
    properties
        c
    end
    
    methods
        
        function obj = PortfolioAggregation(config)
            arguments
                config (1,1) SBTi.configs.PortfolioAggregationConfig
            end
            
            obj.c = config;
        end
        
    end
    
    methods (Access = protected)
        
        function check_column(obj, data, column)
            % Check if a certain column is filled for all companies. If not throw an error.
            %
            % :param data: The data to check
            % :param column: The column to check
            % :return:
            missing_data = ismissing(data.(column));
            missing_data = unique(obj.c.COLS.COMPANY_NAME(missing_data));
                        
            if ~isempty(missing_data)
                error("SBTi:PortfolioAggregation:MissingCompanies", "The value for %s is missing for the following companies: %s ", column, strjoin(missing_companies, ',') );
            end
        end
        
        function AggregatesScore = calculate_aggregate_score(obj, data, input_column, portfolio_aggregation_method)
            
            % Aggregate the scores in a given column based on a certain portfolio aggregation method.
            %
            % :param data: The data to run the calculations on
            % :param input_column: The input column (containing the scores)
            % :param portfolio_aggregation_method: The method to use
            % :return: The aggregates score
            
            if portfolio_aggregation_method == SBTi.PortfolioAggregationMethod.WATS
                total_investment_weight = sum(data(obj.c.COLS.INVESTMENT_VALUE));
                try
                    %                 return data.apply(
                    %                     lambda row: (row[obj.c.COLS.INVESTMENT_VALUE] * row[input_column]) / total_investment_weight,
                    %                     axis=1)
                catch
                    error( "SBTi:PortfolioAggregation:ZeroWeight", "The portfolio weight is not allowed to be zero" )
                end
                
                % Total emissions weighted temperature score (TETS)
            elseif portfolio_aggregation_method == SBTi.PortfolioAggregationMethod.TETS
                use_S1S2 = (data.(obj.c.COLS.SCOPE) == EScope.S1S2) | (data.(obj.c.COLS.SCOPE) == EScope.S1S2S3);
                use_S3 = (data(obj.c.COLS.SCOPE) == EScope.S3) | (data.(obj.c.COLS.SCOPE) == EScope.S1S2S3);
                if use_S3.any()
                    obj.check_column(data, obj.c.COLS.GHG_SCOPE3)
                end
                if use_S1S2.any()
                    obj.check_column(data, obj.c.COLS.GHG_SCOPE12)
                end
                % Calculate the total emissions of all companies
                emissions = use_S1S2*sum(data.(obj.c.COLS.GHG_SCOPE12)) + use_S3*sum(data.(obj.c.COLS.GHG_SCOPE3));
                try
                    AggregatesScore = (use_S1S2*data.(obj.c.COLS.GHG_SCOPE12) + use_S3*data.(obj.c.COLS.GHG_SCOPE3)) / emissions * data.(input_column)
                catch
                    error( "SBTi:PortfolioAggregation:TotalEmissionsMustBeGreaterThanZero", "The total emissions should be higher than zero" )                    
                end
                
            elseif PortfolioAggregationMethod.is_emissions_based(portfolio_aggregation_method)
                % These four methods only differ in the way the company is valued.
                if portfolio_aggregation_method == PortfolioAggregationMethod.ECOTS
                    obj.check_column(data, obj.c.COLS.COMPANY_ENTERPRISE_VALUE)
                    obj.check_column(data, obj.c.COLS.CASH_EQUIVALENTS)
                    data.(obj.c.COLS.COMPANY_EV_PLUS_CASH) = data.(obj.c.COLS.COMPANY_ENTERPRISE_VALUE) + data.(obj.c.COLS.CASH_EQUIVALENTS);
                end
                
                value_column = SBTi.PortfolioAggregationMethod.get_value_column(portfolio_aggregation_method, obj.c.COLS);
                
                % Calculate the total owned emissions of all companies
                try
                    obj.check_column(data, obj.c.COLS.INVESTMENT_VALUE)
                    obj.check_column(data, value_column)
                    use_S1S2 = (data.(obj.c.COLS.SCOPE) == EScope.S1S2) | (data.(obj.c.COLS.SCOPE) == EScope.S1S2S3);
                    use_S3 = (data.(obj.c.COLS.SCOPE) == EScope.S3) | (data.(obj.c.COLS.SCOPE) == EScope.S1S2S3);
                    if use_S1S2.any()
                        obj.check_column(data, obj.c.COLS.GHG_SCOPE12)
                    end
                    if use_S3.any()
                        obj.check_column(data, obj.c.COLS.GHG_SCOPE3)
                    end
                    data.(obj.c.COLS.OWNED_EMISSIONS) = (data.(obj.c.COLS.INVESTMENT_VALUE) / data.(value_column)) * (use_S1S2*data.(obj.c.COLS.GHG_SCOPE12) + use_S3*data.(obj.c.COLS.GHG_SCOPE3));
                catch 
                    error( "SBTi:PortfolioAggregation:ColumnIsZero", "To calculate the aggregation, the %s column may not be zero", value_column)
                end
                
                owned_emissions = sum(data.(obj.c.COLS.OWNED_EMISSIONS));
                try
                    % Calculate the MOTS value per company
%                     return data.apply(
%                     lambda row: (row[obj.c.COLS.OWNED_EMISSIONS] / owned_emissions) * row[input_column],
%                     axis=1
%                     )
                catch
                    error( "SBTi:PortfolioAggregation:OwnedEmissionsMustNotBeZero", "The total owned emissions can not be zero" )
                end
            else
                error( "SBTi:PortfolioAggregation:InvalidAggregationMethod", "The specified portfolio aggregation method is invalid" )
            end
        end
    end
    
end