classdef SBTi
    % Data provider skeleton for SBTi. This class only provides the sbti_validated field for existing companies.
    properties
        c (1,1) SBTi.configs.PortfolioCoverageTVPConfig
        targets
    end
    
    methods 
        function obj = SBTi(config)
            if nargin == 1
                obj.c = config;
            end
            opts = detectImportOptions(obj.c.FILE_TARGETS,'TextType','string');
            opts.VariableNamingRule = 'preserve';
            obj.targets = readtable(obj.c.FILE_TARGETS, opts);
        end
        
        function companies = get_sbti_targets(obj, companies, isin_map)
            %  Check for each company if they have an SBTi validated target.
            %
            % :param companies: A list of IDataProviderCompany instances
            % :param isin_map: A map from company id to ISIN
            % :return: A list of IDataProviderCompany instances, supplemented with the SBTi information
            
            for i = 1 : numel(companies)
                company = companies(i);
                idx = isin_map(company.company_id);
                trgt = obj.targets(obj.targets.(obj.c.COL_COMPANY_ISIN) == idx, :);
                
                if ~isempty(trgt)
                    company.sbti_validated = ismember(obj.c.VALUE_TARGET_SET, trgt.(obj.c.COL_TARGET_STATUS));
                    companies(i) = company;
                end
                
            end

        end
    end
end
% from typing import List, Type
% 
% import pandas as pd
% 
% from SBTi.configs import PortfolioCoverageTVPConfig
% from SBTi.interfaces import IDataProviderCompany
% 
% 
% class SBTi:
%     """
%     %     """
% 
%     def __init__(self, config: Type[PortfolioCoverageTVPConfig] = PortfolioCoverageTVPConfig):
%         self.c = config
%         self.targets = pd.read_excel(self.c.FILE_TARGETS)
% 
%     def get_sbti_targets(self, companies: List[IDataProviderCompany], isin_map: dict) -> List[IDataProviderCompany]:
%         """

%         """
%          
%         return companies
