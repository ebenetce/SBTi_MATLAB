classdef TargetProtocol < handle
    % This class validates the targets, to make sure that only active, useful targets are considered. It then combines the targets with company-related data into a dataframe where there's one row for each of the nine possible target types (short, mid, long * S1+S2, S3, S1+S2+S3). This class follows the procedures outlined by the target protocol that is a part of the "Temperature Rating Methodology" (2020), which has been created by CDP Worldwide and WWF International.
    %
    % :param config: A Portfolio aggregation config
    properties
        c (1,1) SBTi.configs.PortfolioAggregationConfig
        logger
        s2_targets (:,1) SBTi.interfaces.IDataProviderTarget
        target_data table
        company_data table
        data table
    end
    
    methods
        function obj = TargetProtocol(config)
            if nargin > 1
                obj.c = config;
            end
        end
        
        function data = process(obj, targets, companies)
            % Process the targets and companies, validate all targets and return a data frame that combines all targets and company data into a 9-box grid.
            %
            % :param targets: A list of targets
            % :param companies: A list of companies
            % :return: A data frame that combines the processed data
            
            % Create multiindex on company, timeframe and scope for performance later on
            targets = obj.prepare_targets(targets);
            obj.target_data = sortrows(targets.toTable(), [obj.c.COLS.COMPANY_ID, obj.c.COLS.TIME_FRAME, obj.c.COLS.SCOPE], ["ascend","descend","descend"]);
            
            % Create an indexed DF for performance purposes
            %         obj.target_data.index = obj.target_data.reset_index().set_index(
            %             [obj.c.COLS.COMPANY_ID, obj.c.COLS.TIME_FRAME, obj.c.COLS.SCOPE]).index
            %         obj.target_data = obj.target_data.sort_index()
            %
            obj.company_data = companies.toTable();
            obj.group_targets()
            
            data = outerjoin(obj.data, obj.company_data, 'Keys', 'company_id', 'MergeKeys', true);
            
        end
        
        function value = validate(obj, targets)
            % Validate a target, meaning it should:
            %
            % * Have a valid type
            % * Not be finished
            % * A valid end year
            %
            % :param target: The target to validate
            % :return: True if it's a valid target, false if it isn't
            
            % Only absolute targets or intensity targets with a valid intensity metric are allowed.
            target_type = contains(lower([targets.target_type]),"abs") | ...
                (contains(lower([targets.target_type]),"int") & ...
                ~ismissing([targets.intensity_metric]) & ...
                lower([targets.intensity_metric])~="other");
            
            % The target should not have achieved it's reduction yet.
            target_process = isnan([targets.achieved_reduction]) | ...
                isempty([targets.achieved_reduction]) | ...
                [targets.achieved_reduction] < 1;
            
            % The end year should be greater than the start year.
            idx = isempty([targets.start_year]) | isnan([targets.start_year]);
            [targets(idx).start_year] = [targets(idx).base_year];
            
            target_end_year = [targets.end_year] > [targets.start_year];
            % Delete all S1 or S2 targets we can't combine
            s1 = ([targets.scope] ~= SBTi.interfaces.EScope.S1) | ...
                (~isnan([targets.coverage_s1]) & ~isnan([targets.base_year_ghg_s1]) & ~isnan([targets.base_year_ghg_s2]));
            s2 = ([targets.scope] ~= SBTi.interfaces.EScope.S2) | ...
                (~isnan([targets.coverage_s2]) & ~isnan([targets.base_year_ghg_s1]) & ~isnan([targets.base_year_ghg_s2]));
            
            value = target_type & target_process & target_end_year & s1 & s2;
        end
        
        function group_targets(obj)
        
            % Group the targets and create the 9-box grid (short, mid, long * s1s2, s3, s1s2s3).
            % Group valid targets by category & filter multiple targets%
            % Input: a list of valid targets for each company:
            % For each company:
            %
            % Group all valid targets based on scope (S1+S2 / S3 / S1+S2+S3) and time frame (short / mid / long-term)
            % into 6 categories.
            %
            % For each category: if more than 1 target is available, filter based on the following criteria
            % -- Highest boundary coverage
            % -- Latest base year
            % -- Target type: Absolute over intensity
            % -- If all else is equal: average the ambition of targets

            grid_columns = [obj.c.COLS.COMPANY_ID, obj.c.COLS.TIME_FRAME, obj.c.COLS.SCOPE];
            companies = unique(obj.company_data.(obj.c.COLS.COMPANY_ID));
            scopes = [SBTi.interfaces.EScope.S1S2; SBTi.interfaces.EScope.S3; SBTi.interfaces.EScope.S1S2S3];
            [empty_columns, ec_idx] = setdiff(obj.target_data.Properties.VariableNames, grid_columns);
            varTypes = varfun(@class,obj.target_data,'OutputFormat','cell');
            varTypes = strrep(varTypes(ec_idx),'int64','double');
            
            ma=size(companies,1);
            B = lower(string(properties(SBTi.interfaces.ETimeFrames)));
            mb=size(string(properties(SBTi.interfaces.ETimeFrames)),1);
            mc=size(scopes,1);
            [d,b,a]=ndgrid(1:mc,1:mb,1:ma);
            product = [companies(a,:),B(b,:), scopes(d,:)];
            extended_data = array2table(product, 'VariableNames', grid_columns );
            ed_empty = table('Size', [height(product), length(empty_columns)], ...
                'VariableNames',empty_columns, ...
                'VariableTypes',varTypes);
            
            for i = 1 : width(ed_empty)
                if contains(varTypes{i},'double')
                    ed_empty{:,i} = NaN;
                end
            end
            
            
            extended_data = [extended_data, ed_empty];
            
            target_columns = extended_data.Properties.VariableNames;
            
            obj.data = extended_data;
            isTarget = ismember(extended_data(:, [obj.c.COLS.COMPANY_ID, obj.c.COLS.TIME_FRAME, obj.c.COLS.SCOPE]), obj.target_data(:,["company_id", "time_frame", "scope"]));
            func = @(x) obj.find_target(x, target_columns);
            for i = 1 : height(extended_data)
                if isTarget(i) == 1
                    obj.data(i, :) = func(extended_data(i,:));
                end
            end

        end
        
        function targets = prepare_targets(obj, targets)
            targets = targets(obj.validate(targets));
            
            idx = [targets.scope] == SBTi.interfaces.EScope.S2 & ~isnan([targets.base_year_ghg_s2]) & ...
                ~isnan([targets.coverage_s2]);
            obj.s2_targets = targets(idx);
            
            split123 = SBTi.interfaces.IDataProviderTarget.empty();
            for i = 1 : height(targets)
                split123 = [split123;obj.split_s1s2s3(targets(i,:))]; %#ok<AGROW>
            end

            targets = arrayfun(@(x) obj.prepare_target(x), split123);
        end
    end
    
    methods (Access = private)
        
        function s = split_s1s2s3(obj, target)
            
            % If there is a s1s2s3 scope, split it into two targets with s1s2 and s3
            
            % :param target: The input target
            % :return The split targets or the original target and None
            
            if target.scope == SBTi.interfaces.EScope.S1S2S3
                s1s2 = target;
                s3 = SBTi.interfaces.IDataProviderTarget.empty();
                if (~isnan(target.base_year_ghg_s1)) || (target.coverage_s1 == target.coverage_s2)
                    s1s2.scope = SBTi.interfaces.EScope.S1S2;

                    if ~isnan(target.base_year_ghg_s1) && ~isnan(target.base_year_ghg_s2) && (target.base_year_ghg_s1 + target.base_year_ghg_s2 ~= 0)

                        coverage_percentage = (s1s2.coverage_s1 * s1s2.base_year_ghg_s1 + ...
                            s1s2.coverage_s2 * s1s2.base_year_ghg_s2) / ...
                            (s1s2.base_year_ghg_s1 + s1s2.base_year_ghg_s2);
                        s1s2.coverage_s1 = coverage_percentage;
                        s1s2.coverage_s2 = coverage_percentage;

                    end

                end

                if ~isnan(target.coverage_s3)
                    s3 = target;
                    s3.scope = SBTi.interfaces.EScope.S3;                    
                end 
                s = [s1s2;s3];
            else
                s = target;
            end

        end
       
        function target = combine_s1_s2(obj, target)
            
            % Check if there is an S2 target that matches this target exactly (if this is a S1 target) and combine them into one target.
            %
            % :param target: The input target
            % :return: The combined target (or the original if no combining was required)
            
            if target.scope == SBTi.interfaces.EScope.S1 && ~isnan(target.base_year_ghg_s1)
                t = obj.s2_targets;
                matches = t([t.company_id] == target.company_id & ...
                       [t.base_year] == target.base_year & ...
                       [t.start_year] == target.start_year & ...
                       [t.end_year] == target.end_year & ...
                       [t.target_type] == target.target_type & ...
                       [t.intensity_metric] == target.intensity_metric);
                 
                   if ~isempty(matches)
                       matches.sort; %(key=lambda t: t.coverage_s2, reverse=True)
                       s2 = matches; %[0]
                       combined_coverage = (target.coverage_s1 * target.base_year_ghg_s1 + ...
                           s2.coverage_s2 * s2.base_year_ghg_s2) / ...
                           (target.base_year_ghg_s1 + s2.base_year_ghg_s2);
                       target.reduction_ambition = target.reduction_ambition * target.coverage_s1 * target.base_year_ghg_s1 + ...
                           s2.reduction_ambition * s2.coverage_s1 * s2.base_year_ghg_s2 / ...
                           (target.base_year_ghg_s1 + s2.base_year_ghg_s1) / combined_coverage;
                       target.coverage_s1 = combined_coverage;
                       target.coverage_s2 = combined_coverage;
                       % We don't need to delete the S2 target as it'll be definition have a lower coverage than the combined
                       % target, therefore it won't be picked for our 9-box grid
                   end
                    
            end
            
        end
        
        function target = convert_s1_s2(obj, target) %target: IDataProviderTarget
            % Convert a S1 or S2 target into a S1+S2 target.
            %
            % :param target: The input target
            % :return: The converted target (or the original if no conversion was required)
            
            %         % In both cases the base_year_ghg s1 + s2 should not be zero
            if target.base_year_ghg_s1 + target.base_year_ghg_s2 ~= 0
                if target.scope == SBTi.interfaces.EScope.S1
                    coverage = target.coverage_s1 * target.base_year_ghg_s1 / (target.base_year_ghg_s1 + target.base_year_ghg_s2);
                    target.coverage_s1 = coverage;
                    target.coverage_s2 = coverage;
                    target.scope = SBTi.interfaces.EScope.S1S2;
                elseif target.scope == SBTi.interfaces.EScope.S2
                    coverage = target.coverage_s2 * target.base_year_ghg_s2 / (target.base_year_ghg_s1 + target.base_year_ghg_s2);
                    target.coverage_s1 = coverage;
                    target.coverage_s2 = coverage;
                    target.scope = SBTi.interfaces.EScope.S1S2;
                end
            end
        end
        
        function target = boundary_coverage(obj, target)            
            % Test on boundary coverage:
            % 
            % Option 1: minimal coverage threshold
            % For S1+S2 targets: coverage% must be at or above 95%, for S3 targets coverage must be above 67%
            %  
            % Option 2: weighted coverage
            % Thresholds are still 95% and 67%, target is always valid. Below threshold ambition is scaled.*
            % New target ambition = input target ambition * coverage
            % *either here or in tem score module
            % 
            % Option 3: default coverage
            % Target is always valid, % uncovered is given default score in temperature score module.
            % 
            % :param target: The input target
            % :return: The original target with a weighted reduction ambition, if so required
            if target.scope == SBTi.interfaces.EScope.S1S2
                if target.coverage_s1 < 0.95
                    target.reduction_ambition = target.reduction_ambition * target.coverage_s1;
                end
            elseif target.scope == SBTi.interfaces.EScope.S3
                if target.coverage_s3 < 0.67
                    target.reduction_ambition = target.reduction_ambition * target.coverage_s3;
                end
            end
        end
        
        function target = time_frame(obj, target)
            % Time frame is forward looking: target year - current year. Less than 5y = short, between 5 and 15 is mid, 15 to 30 is long
            %         :param target: The input target
            %         :return: The original target with the time_frame field filled out (if so required)

            now = datetime('now');
            time_frame = target.end_year - year(now);
            if time_frame <= 4
                target.time_frame = SBTi.interfaces.ETimeFrames.SHORT;
            elseif time_frame <= 15
                target.time_frame = SBTi.interfaces.ETimeFrames.MID;
            elseif time_frame <= 30
                target.time_frame = SBTi.interfaces.ETimeFrames.LONG;
            end

        end
       
        function target = prepare_target(obj, target)
            % Prepare a target for usage later on in the process.
            %         :param target:
            %         :return:
            
            target = obj.combine_s1_s2(target);
            target = obj.convert_s1_s2(target);
            target = obj.boundary_coverage(target);
            target = obj.time_frame(target);
            
        end

    

    function series = find_target(obj, row, target_columns)
        % Find the target that corresponds to a given row. If there are multiple targets available, filter them.
        %
        %  :param row: The row from the data set that should be looked for
        %  :param target_columns: The columns that need to be returned
        %  :return: returns records from the input data, which contains company and target information, that meet specific criteria. For example, record of greatest emissions_in_scope

        cols = obj.c.COLS;
        % Find all targets that correspond to the given row
        
        tgt_data = obj.target_data( obj.target_data.company_id == row.(cols.COMPANY_ID) &  ...
            obj.target_data.time_frame == row.(cols.TIME_FRAME) & ...
            obj.target_data.scope == row.(cols.SCOPE), :);
        if isempty(tgt_data)
            % No target found
            series = row;
        elseif height(tgt_data) == 1
            % One match with Target data
            series = tgt_data(:,target_columns);
        else
            if tgt_data.scope(1) == SBTi.interfaces.EScope.S3
                coverage_column = cols.COVERAGE_S3;
            else
                coverage_column = cols.COVERAGE_S1;
            end
            % In case more than one target is available; we prefer targets with higher coverage, later end year, and target type 'absolute'
            series = sortrows(tgt_data, ...
                [coverage_column, cols.END_YEAR, cols.TARGET_REFERENCE_NUMBER], ...
                {'descend','descend','ascend'});

            series = series(1,target_columns);
        end
        
        %         try
%         catch
%             % No target found
%             series = row;
%         end
    end
    
    end
end
