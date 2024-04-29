classdef (Abstract) DataProvider < handle
    
    methods
        function obj = DataProvider
            % Create a new data provider instance.
            %
            % :param config: A dictionary containing the configuration parameters for this data provider.
        end
    end
    
    methods (Abstract)
         model_targets = get_targets(obj, company_ids)
         model_companies = get_company_data(obj, company_ids)
         companyList = get_sbti_targets(obj, companies)
    end

end