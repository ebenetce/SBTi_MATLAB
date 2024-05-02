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
            try
                websave(obj.c.FILE_TARGETS, obj.c.CTA_FILE_URL);
            catch
                warning('Unable to update the SBTi file targets')
            end
            opts = detectImportOptions(obj.c.FILE_TARGETS,'TextType','string');
            opts.VariableNamingRule = 'preserve';
            obj.targets = readtable(obj.c.FILE_TARGETS, opts);
        end
        
        function companies = get_sbti_targets(obj, companies, id_map)
            %  Check for each company if they have an SBTi validated target.
            %
            % :param companies: A list of IDataProviderCompany instances
            % :param isin_map: A map from company id to ISIN
            % :return: A list of IDataProviderCompany instances, supplemented with the SBTi information
            arguments
                obj
                companies
                id_map
            end

            obj.targets = obj.filter_cta_file(obj.targets);

        %     for company in companies:
        %     isin, lei = id_map.get(company.company_id)
        %     # Check lei and length of lei to avoid zeros 
        %     if not lei.lower() == 'nan' and len(lei) > 3:
        %         targets = self.targets[
        %             self.targets[self.c.COL_COMPANY_LEI] == lei
        %         ]
        %     elif not isin.lower() == 'nan':
        %         targets = self.targets[
        %             self.targets[self.c.COL_COMPANY_ISIN] == isin
        %         ]
        %     else:
        %         continue
        %     if len(targets) > 0:
        %         company.sbti_validated = (
        %             self.c.VALUE_TARGET_SET in targets[self.c.COL_TARGET].values
        %         )
        % return companies   
            
            for i = 1 : numel(companies)
                company = companies(i);
                ids = id_map{company.company_id};
                isin = ids(1);
                lei = ids(2);
               
                if ~ismissing(lei)                    
                    trgt = obj.targets(obj.targets.(obj.c.COL_COMPANY_LEI) == lei, :);
                elseif ~ismissing(isin)
                    trgt = obj.targets(obj.targets.(obj.c.COL_COMPANY_ISIN) == isin, :);
                else
                    continue
                end
                
                if ~isempty(trgt)
                    company.sbti_validated = ismember(obj.c.VALUE_TARGET_SET, trgt.(obj.c.COL_TARGET));
                    companies(i) = company;
                end
                
            end
            
        end

        function df_nt_targets = filter_cta_file(obj, targets)
            % Filter the CTA file to create a table that has one row per company
            % with the columns "Action" and "Target".
            % If Action = Target then only keep the rows where Target = Near-term.

            % Create a new dataframe with only the columns "Action" and "Target"
            % and the columns that are needed for identifying the company
            targets = targets(:, ...
                [obj.c.COL_COMPANY_NAME, ...
                obj.c.COL_COMPANY_ISIN, ...
                obj.c.COL_COMPANY_LEI, ...
                obj.c.COL_ACTION, ...
                obj.c.COL_TARGET]);

            % Keep rows where Action = Target and Target = Near-term
            df_nt_targets = targets( ...
                (targets.(obj.c.COL_ACTION) == obj.c.VALUE_ACTION_TARGET) & ...
                (targets.(obj.c.COL_TARGET) == obj.c.VALUE_TARGET_SET), :);

            % Drop duplicates in the dataframe by waterfall.
            % Do company name last due to risk of misspelled names
            % First drop duplicates on LEI, then on ISIN, then on company name
            df_nt_targets = unique(targets, 'rows', 'first');          
        end

    end
end