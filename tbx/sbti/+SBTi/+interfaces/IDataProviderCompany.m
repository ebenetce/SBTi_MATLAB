classdef IDataProviderCompany
    
    properties
        company_name (1,1) string
        company_id (1,1) string
        isic (1,1) string
        ghg_s1s2 (1,1) double
        ghg_s3 (1,1) double
        
        country          (1,1) string
        region           (1,1) string
        sector           (1,1) string
        industry_level_1 (1,1) string
        industry_level_2 (1,1) string
        industry_level_3 (1,1) string
        industry_level_4 (1,1) string
        
        company_revenue          (1,1) double
        company_market_cap       (1,1) double
        company_enterprise_value (1,1) double
        company_total_assets     (1,1) double
        company_cash_equivalents (1,1) double
        
        sbti_validated (1,1) logical = false; % 'True if the SBTi target status is "Target set", false otherwise'
    end
    
    methods
        
        function obj = IDataProviderCompany(varargin)

            if nargin > 0

                if nargin == 1 && istable(varargin{1})

                    tb = varargin{1};

                else

                    tb = table(varargin{2:2:end}, 'VariableNames', string(varargin(1:2:end)));

                end

                obj(height(tb),1) = obj;
                vars = tb.Properties.VariableNames;

                for i = 1 : height(tb)
                    obj(i).company_name  = tb{i,'company_name'};
                    obj(i).company_id    = tb{i,'company_id'};
                    obj(i).isic          = tb{i,'isic'};
                    obj(i).ghg_s1s2      = tb{i,'ghg_s1s2'};
                    obj(i).ghg_s3        = tb{i,'ghg_s3'};

                    obj = addOptionalProp(obj, i, 'country', tb, vars);
                    obj = addOptionalProp(obj, i, 'region', tb, vars);
                    obj = addOptionalProp(obj, i, 'sector', tb, vars);
                    obj = addOptionalProp(obj, i, 'industry_level_1', tb, vars);
                    obj = addOptionalProp(obj, i, 'industry_level_2', tb, vars);
                    obj = addOptionalProp(obj, i, 'industry_level_3', tb, vars);
                    obj = addOptionalProp(obj, i, 'industry_level_4', tb, vars);

                    obj = addOptionalProp(obj, i, 'company_revenue', tb, vars);
                    obj = addOptionalProp(obj, i, 'company_market_cap', tb, vars);
                    obj = addOptionalProp(obj, i, 'company_enterprise_value', tb, vars);
                    obj = addOptionalProp(obj, i, 'company_total_assets', tb, vars);
                    obj = addOptionalProp(obj, i, 'company_cash_equivalents', tb, vars);

                end

            end
            
        end
        
        function value = toTable(obj)
            
            value = table([obj.company_name]', [obj.company_id]', [obj.isic]', [obj.ghg_s1s2]', [obj.ghg_s3]', [obj.country]',...
                [obj.region]', [obj.sector]', [obj.industry_level_1]', [obj.industry_level_2]', [obj.industry_level_3]', ...
                [obj.industry_level_4]', [obj.company_revenue]', [obj.company_market_cap]', [obj.company_enterprise_value]', [obj.company_total_assets]', ...
                [obj.company_cash_equivalents]', [obj.sbti_validated]', 'VariableNames', string(properties(obj))');
        end
        
    end
    
    methods (Access = private)
        function obj = addOptionalProp(obj, i, name, tb, vars)
            if ismember(name, vars)
                obj(i).(name)   = tb{i,name};
            end
        end
    end
    
end