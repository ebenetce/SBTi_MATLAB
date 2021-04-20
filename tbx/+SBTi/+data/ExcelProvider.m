classdef ExcelProvider <  SBTi.data.DataProvider
    
    properties
        data (1,1) string
        c (1,1) SBTi.configs.ColumnsConfig
    end
    methods 
        
        function obj = ExcelProvider(path, varargin)
            % Data provider skeleton for CSV files. This class serves primarily for testing purposes only!
            %
            % :param config: A dictionary containing a "path" field that leads to the path of the CSV file
            
            narginchk(1,2)
            
            obj = obj@SBTi.data.DataProvider;
            obj.data = path;
            if nargin > 1
                obj.c = config;
            end
        end
        
        function model_targets = get_targets(obj, company_ids)
            % Get all relevant targets for a list of company ids (ISIN). This method should return a list of
            % IDataProviderTarget instances.
            %
            % :param company_ids: A list of company IDs (ISINs)
            % :return: A list containing the targets
            opts = detectImportOptions(obj.data,'Sheet', 'target_data', 'TextType','string');
            
            target_data = readtable(obj.data, opts);
            model_targets = obj.target_tb_to_model(target_data);
            model_targets = model_targets(ismember([model_targets.company_id], company_ids));            
        end
        
        function model_companies = get_company_data(obj, company_ids)
            % Get all relevant data for a list of company ids (ISIN). This method should return a list of IDataProviderCompany
            % instances.
            %
            % :param company_ids: A list of company IDs (ISINs)
            % :return: A list containing the company data
            
            opts = detectImportOptions(obj.data,'Sheet', 'fundamental_data', 'TextType','string');
            model_companies = readtable(obj.data, opts);
            model_companies = SBTi.interfaces.IDataProviderCompany(model_companies);
            model_companies = model_companies(ismember([model_companies.company_id], company_ids));
            
        end
        
        function companyList = get_sbti_targets(obj, companies)
            % For each of the companies, get the status of their target (Target set, Committed or No target) as it's known to
            % the SBTi.
            %
            % :param companies: A list of companies. Each company should be a dict with a "company_name" and "company_id"
            %         field.
            % :return: The original list, enriched with a field called "sbti_target_status"
            
            error('Not yet implemented');
        end
        
    end
    
    methods (Access = private)
        function targets = target_tb_to_model(obj, tb_targets)
            % transforms target Dataframe into list of IDataProviderTarget instances
            %
            % :param df_targets: pandas Dataframe with targets
            % :return: A list containing the targets
            
%             targets = SBTi.interfaces.IDataProviderTarget(tb_targets);
            targets = [];
            for i = 1 : height(tb_targets)
                try
                    targets = [targets; SBTi.interfaces.IDataProviderTarget(tb_targets(i,:))];
                catch
                    warning('(one of) the target(s) of company %s is invalid and will be skipped', tb_targets{i,obj.c.COMPANY_NAME})
                end
            end
        end
    end
    
end

