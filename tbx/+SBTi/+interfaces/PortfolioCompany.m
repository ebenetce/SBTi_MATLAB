classdef PortfolioCompany
    
    properties
        company_name      (1,1) string
        company_id        (1,1) string
        company_isin      (1,1) string
        investment_value  (1,1) double
        engagement_target (1,1) logical = false
        user_fields       (1,1) struct
    end
    
    methods
        function obj = PortfolioCompany(varargin)
            
            if nargin ~= 0
                
                if nargin == 1 && istable(varargin{1})
                    varargin = namedargs2cell(table2struct(varargin{1},'ToScalar',true));
                end
                
                p = inputParser();
                p.KeepUnmatched = true;
                p.addParameter('company_name', obj.company_name)
                p.addParameter('company_id', obj.company_id)
                p.addParameter('company_isin', obj.company_isin)
                p.addParameter('investment_value', obj.investment_value)
                p.addParameter('engagement_target', obj.engagement_target)
                p.addParameter('user_fields', obj.user_fields)
                
                parse(p, varargin{:});
                
                r = p.Results;
                flds = fields(r);
                
                m = numel(r.company_name);
                obj(m,1) = obj;
                for i = 1:m
                    for f = flds'
                        try
                            if iscell(r.(f{1}))
                                obj(i,1).(f{1}) = r.(f{1}){i};
                            else
                                obj(i,1).(f{1}) = r.(f{1})(i);
                            end
                        catch
                        end
                    end
                end
            end
            
        end
        
        function tb = toTable(obj)
            tb = table([obj.company_name]', [obj.company_id]', [obj.company_isin]', ...
                [obj.investment_value]', [obj.engagement_target ]', [obj.user_fields]', ...
                'VariableNames', string(properties(obj)) );
        end
    end
    
end