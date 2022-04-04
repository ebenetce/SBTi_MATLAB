classdef TemperatureScore < SBTi.PortfolioAggregation

    % This class is provides a temperature score based on the climate goals.

    % :param fallback_score: The temp score if a company is not found
    % :param model: The regression model to use
    % :param config: A class functionining the constants that are used throughout this class. This parameter is only required
    %                 if you'd like to overwrite a constant. This can be done by extending the TemperatureScoreConfig
    %                 class and overwriting one of the parameters.

    properties
        model
        scenario
        fallback_score
        time_frames
        scopes
        aggregation_method
        grouping
        mapping
        regression_model
    end

    methods

        function obj = TemperatureScore(varargin)

            p = inputParser();
            p.addParameter('time_frames', SBTi.interfaces.ETimeFrames)
            p.addParameter('scopes', SBTi.interfaces.EScope)
            p.addParameter('fallback_score', 3.2)
            p.addParameter('model', 4)
            p.addParameter('scenario', [])
            p.addParameter('aggregation_method', SBTi.PortfolioAggregationMethod.WATS)
            p.addParameter('grouping', [])
            p.addParameter('config', SBTi.configs.TemperatureScoreConfig)

            parse(p, varargin{:})

            r = p.Results;

            obj = obj@SBTi.PortfolioAggregation(r.config);

            obj.model = r.model;
            obj.scenario = r.scenario;
            obj.fallback_score = r.fallback_score;

            obj.time_frames = r.time_frames;
            obj.scopes = r.scopes;

            if ~isempty(obj.scenario)
                obj.fallback_score = obj.scenario.get_fallback_score(obj.fallback_score);
            end

            obj.aggregation_method = r.aggregation_method;

            if ~isempty(r.grouping)
                obj.grouping = r.grouping;
            end
            % Load the mappings from industry to SR15 goal
            obj.mapping = readtable(obj.c.FILE_SR15_MAPPING);
            opts = detectImportOptions(obj.c.FILE_REGRESSION_MODEL_SUMMARY,'TextType','string');
            obj.regression_model = readtable(obj.c.FILE_REGRESSION_MODEL_SUMMARY, opts);
            obj.regression_model = obj.regression_model(obj.regression_model.(obj.c.COLS.MODEL) == obj.model, :);

        end

        function sr15target = get_target_mapping(obj, target)

            % Map the target onto an SR15 target (None if not available).

            % :param target: The target as a row of a dataframe
            % :return: The mapped SR15 target

            try
                if startsWith( lower( strip( target.(obj.c.COLS.TARGET_REFERENCE_NUMBER) ) ), obj.c.VALUE_TARGET_REFERENCE_INTENSITY_BASE )

                    dict = obj.c.INTENSITY_MAPPINGS.(target.(obj.c.COLS.INTENSITY_METRIC));
                    sr15target = dict(target.(obj.c.COLS.SCOPE));

                else
                    % Only first 3 characters of ISIC code are relevant for the absolute mappings
                    try
                        isic = char(target.(obj.c.COLS.COMPANY_ISIC));
                        sr15target = obj.c.ABSOLUTE_MAPPINGS.(isic(1:3))(target.(obj.c.COLS.SCOPE));
                    catch
                        sr15target = obj.c.ABSOLUTE_MAPPINGS.("other")(target.(obj.c.COLS.SCOPE));
                    end
                end
            catch
                sr15target = string(missing);
            end

        end

        function tgt = get_annual_reduction_rate(obj, target)

            % Get the annual reduction rate (or None if not available).

            % :param target: The target as a row of a dataframe
            % :return: The annual reduction

            if isnan( target.(obj.c.COLS.REDUCTION_AMBITION) )
                tgt = NaN;
                return
            end

            try
                tgt = target.(obj.c.COLS.REDUCTION_AMBITION) / double(target.(obj.c.COLS.END_YEAR) - target.(obj.c.COLS.BASE_YEAR));
            catch
                error("Couldn't calculate the annual reduction rate because the start and target year are the same")
            end

        end
        %
        %         function get_regression(obj, target: pd.Series) -> Tuple[Optional[float], Optional[float]]:
        %
        %             % Get the regression parameter and intercept from the model's output.
        %
        %             % :param target: The target as a row of a dataframe
        %             % :return: The regression parameter and intercept
        %
        %             if pd.isnull(target[obj.c.COLS.SR15]):
        %                 return None, None
        %             end
        %
        %             regression = obj.regression_model[
        %                 (obj.regression_model[obj.c.COLS.VARIABLE] == target[obj.c.COLS.SR15]) &
        %                 (obj.regression_model[obj.c.COLS.SLOPE] == obj.c.SLOPE_MAP[target[obj.c.COLS.TIME_FRAME]])]
        %             if len(regression) == 0
        %                 return None, None
        %             elseif len(regression) > 1
        %                 % There should never be more than one potential mapping
        %                 raise ValueError("There is more than one potential regression parameter for this SR15 goal.")
        %             else
        %                 return regression.iloc[0][obj.c.COLS.PARAM], regression.iloc[0][obj.c.COLS.INTERCEPT]
        %             end
        %         end

        function [sc,rs] = get_score(obj, target)

            % Get the temperature score for a certain target based on the annual reduction rate and the regression parameters.

            % :param target: The target as a row of a data frame
            % :return: The temperature score

            if isnan(target.(obj.c.COLS.REGRESSION_PARAM)) || isnan(target.(obj.c.COLS.REGRESSION_INTERCEPT)) || ...
                    isnan(target.(obj.c.COLS.ANNUAL_REDUCTION_RATE))
                sc = obj.fallback_score;
                rs = 1;
                return
            end
            ts = max(target.(obj.c.COLS.REGRESSION_PARAM) * target.(obj.c.COLS.ANNUAL_REDUCTION_RATE) * 100 + ...
                target.(obj.c.COLS.REGRESSION_INTERCEPT), 0);
            if target.(obj.c.COLS.SBTI_VALIDATED)
                sc = ts;
                rs = 0;
            else
                sc = ts * obj.c.SBTi_FACTOR + obj.fallback_score * (1 - obj.c.SBTi_FACTOR);
                rs = 0;
            end
        end

        function [sc, rs] = get_ghc_temperature_score(obj, row, company_data)

            % Get the aggregated temperature score and a temperature result, which indicates how much of the score is based on the functionault score for a certain company based on the emissions of company.

            % :param company_data: The original data, grouped by company, time frame and scope category
            % :param row: The row to calculate the temperature score for (if the scope of the row isn't s1s2s3, it will return the original score
            % :return: The aggregated temperature score for a company

            if row.(obj.c.COLS.SCOPE) ~= SBTi.interfaces.EScope.S1S2S3
                sc = row.(obj.c.COLS.TEMPERATURE_SCORE);
                rs = row.(obj.c.TEMPERATURE_RESULTS);
                return
            end
            s1s2 = company_data(company_data.company_id == row.(obj.c.COLS.COMPANY_ID) & company_data.time_frame == row.(obj.c.COLS.TIME_FRAME) & company_data.scope == SBTi.interfaces.EScope.S1S2,:);
            s3   = company_data(company_data.company_id == row.(obj.c.COLS.COMPANY_ID) & company_data.time_frame == row.(obj.c.COLS.TIME_FRAME) & company_data.scope == SBTi.interfaces.EScope.S3,:);

            try
                % If the s3 emissions are less than 40 percent, we'll ignore them altogether, if not, we'll weigh them
                if s3.(obj.c.COLS.GHG_SCOPE3) / (s1s2.(obj.c.COLS.GHG_SCOPE12) + s3.(obj.c.COLS.GHG_SCOPE3)) < 0.4
                    sc = s1s2.(obj.c.COLS.TEMPERATURE_SCORE);
                    rs = s1s2.(obj.c.TEMPERATURE_RESULTS);
                    return
                else
                    company_emissions = s1s2.(obj.c.COLS.GHG_SCOPE12) + s3.(obj.c.COLS.GHG_SCOPE3);
                    sc = (s1s2.(obj.c.COLS.TEMPERATURE_SCORE) * s1s2.(obj.c.COLS.GHG_SCOPE12) + ...
                        s3.(obj.c.COLS.TEMPERATURE_SCORE) * s3.(obj.c.COLS.GHG_SCOPE3)) / company_emissions;
                    rs = (s1s2.(obj.c.TEMPERATURE_RESULTS) * s1s2.(obj.c.COLS.GHG_SCOPE12) + ...
                        s3.(obj.c.TEMPERATURE_RESULTS) * s3.(obj.c.COLS.GHG_SCOPE3)) / company_emissions;
                    return
                end

            catch
                error("The mean of the S1+S2 plus the S3 emissions is zero")
            end
        end

        function value = get_functionault_score(obj, target)

            % Get the temperature score for a certain target based on the annual reduction rate and the regression parameters.

            % :param target: The target as a row of a dataframe
            % :return: The temperature score

            if isnan(target.(obj.c.COLS.REGRESSION_PARAM)) || ...
                    isnan(target.(obj.c.COLS.REGRESSION_INTERCEPT)) || ...
                    isnan(target.(obj.c.COLS.ANNUAL_REDUCTION_RATE))
                value = 1;
            else
                value = 0;
            end
        end

        function data = calculate(obj, data, nvp)
            % Calculate the temperature for a table of company data. The columns in the table should be a combination
            % of IDataProviderTarget and IDataProviderCompany.

            % :param data: The data set (or None if the data should be retrieved)
            % :param data_providers: A list of DataProvider instances. Optional, only required if data is empty.
            % :param portfolio: A list of PortfolioCompany models. Optional, only required if data is empty.
            % :return: A data frame containing all relevant information for the targets and companies

            arguments
                obj
                data = [];
                nvp.data_providers = [];
                nvp.portfolio = [];
            end

            data_providers = nvp.data_providers;
            portfolio = nvp.portfolio;

            if isempty(data)
                if ~isempty(data_providers) && ~isempty(portfolio)
                    data = SBTi.utils.get_data(data_providers, portfolio);
                else
                    error("You need to pass and either a data set or a list of data providers and companies")
                end
            end
            data = obj.prepare_data(data);

            if ismember(SBTi.interfaces.EScope.S1S2S3, obj.scopes)
                obj.check_column(data, obj.c.COLS.GHG_SCOPE12)
                obj.check_column(data, obj.c.COLS.GHG_SCOPE3)
                data = obj.calculate_company_score(data);
            end
            % We need to filter the scopes again, because we might have had to add a scope in te preparation step
            data = data(ismember(data.(obj.c.COLS.SCOPE),obj.scopes),:);
            data.(obj.c.COLS.TEMPERATURE_SCORE) = round(data.(obj.c.COLS.TEMPERATURE_SCORE),2);

        end

        function score_aggregations = aggregate_scores(obj, data)

            % Aggregate scores to create a portfolio score per time_frame (short, mid, long).

            % :param data: The results of the calculate method
            % :return: A weighted temperature score for the portfolio

            score_aggregations = SBTi.interfaces.ScoreAggregations();
            for time_frame = obj.time_frames
                score_aggregation_scopes = SBTi.interfaces.ScoreAggregationScopes();
                for scope = obj.scopes
                    score_aggregation_scopes.(strrep(scope, "+","")) = obj.get_score_aggregation(data, time_frame, scope);
                end
                score_aggregations.(time_frame) = score_aggregation_scopes;
            end

        end

        function scores = cap_scores(obj, scores)

            % Cap the temperature scores in the input data frame to a certain value, based on the scenario that's being used.
            % This can either be for the whole data set, or only for the top X contributors.

            % :param scores: The data set with the temperature scores
            % :return: The input data frame, with capped scores

            if isempty(obj.scenario)
                return
            end

            if obj.scenario.scenario_type == SBTi.ScenarioType.APPROVED_TARGETS
                score_based_on_target = ~ismissing(scores.(obj.c.COLS.TARGET_REFERENCE_NUMBER));
                scores{score_based_on_target, obj.c.COLS.TEMPERATURE_SCORE} = min(scores{score_based_on_target, obj.c.COLS.TEMPERATURE_SCORE}, obj.scenario.get_score_cap);

            elseif obj.scenario.scenario_type == SBTi.ScenarioType.HIGHEST_CONTRIBUTORS
                % Cap scores of 10 highest contributors per time frame-scope combination
                % TODO: Should this actually be per time-frame/scope combi? Aren't you engaging the company as a whole?
                aggregations = obj.aggregate_scores(scores);
                for time_frame = obj.time_frames

                    for scope = obj.scopes
                        sc = strrep(scope, "+", "");
                        number_top_contributors = min(10, ...
                            length(aggregations.(time_frame).(sc).all.contributions));

                        for contributor = 1 : number_top_contributors

                            company_name = aggregations.(time_frame).(sc).all.contributions(contributor);
                            company_name = company_name.(obj.c.COLS.COMPANY_NAME);
                            company_mask = (scores.(obj.c.COLS.COMPANY_NAME) == company_name) & (scores.(obj.c.COLS.SCOPE) == scope) & (scores.(obj.c.COLS.TIME_FRAME) == time_frame);



                            scores{company_mask, obj.c.COLS.TEMPERATURE_SCORE} = ...
                                min(scores{company_mask, obj.c.COLS.TEMPERATURE_SCORE}, obj.scenario.get_score_cap());

                        end
                    end
                end
            elseif obj.scenario.scenario_type == SBTi.ScenarioType.HIGHEST_CONTRIBUTORS_APPROVED
                score_based_on_target = scores.(obj.c.COLS.ENGAGEMENT_TARGET);
                scores{score_based_on_target, obj.c.COLS.TEMPERATURE_SCORE} = min(scores{score_based_on_target, obj.c.COLS.TEMPERATURE_SCORE}, obj.scenario.get_score_cap());
            end

        end

        %         function scores = anonymize_data_dump(obj, scores: pd.DataFrame) -> pd.DataFrame:
        %
        %             % Anonymize the scores by deleting the company IDs, ISIN and renaming the companies.
        %
        %             % :param scores: The data set with the temperature scores
        %             % :return: The input data frame, anonymized
        %
        %             scores.drop(columns=[obj.c.COLS.COMPANY_ID, obj.c.COLS.COMPANY_ISIN], inplace=True)
        %             for index, company_name in enumerate(scores[obj.c.COLS.COMPANY_NAME].unique()):
        %                 scores.loc[scores[obj.c.COLS.COMPANY_NAME] == company_name, obj.c.COLS.COMPANY_NAME] = 'Company' + str(
        %                 index + 1)
        %             end
        %
        %         end
    end

    methods (Access = private)

        function newData = merge_regression(obj, data)

            % Merge the data with the regression parameters from the SBTi model.

            % :param data: The data to merge
            % :return: The data set, amended with the regression parameters

            data.(obj.c.COLS.SLOPE) = repmat(string(missing), height(data),1);
            for i = 1 : height(data)
                try
                    data{i, obj.c.COLS.SLOPE} = obj.c.SLOPE_MAP.(data{i,obj.c.COLS.TIME_FRAME});
                catch
                    data{i, obj.c.COLS.SLOPE} = string(missing);
                end
            end

            newData = outerjoin(data, obj.regression_model, ...
                'LeftKeys', [obj.c.COLS.SLOPE, obj.c.COLS.SR15], ...
                'RightKeys', [obj.c.COLS.SLOPE, obj.c.COLS.VARIABLE], ...
                'Type', 'left', 'MergeKeys', true);
        end

        function data = prepare_data(obj, data)

            % Prepare the data such that it can be used to calculate the temperature score.

            % :param data: The original data set as a pandas data frame
            % :return: The extended data frame

            % If scope S1S2S3 is in the list of scopes to calculate, we need to calculate the other two as well
            sc = obj.scopes;

            if ismember(SBTi.interfaces.EScope.S1S2S3, obj.scopes) && ~ismember(SBTi.interfaces.EScope.S1S2, obj.scopes)
                sc = [sc, SBTi.interfaces.EScope.S1S2];
            end
            if ismember(SBTi.interfaces.EScope.S1S2S3, sc) && ~ismember(SBTi.interfaces.EScope.S3, sc)
                sc = [sc, SBTi.interfaces.EScope.S3];
            end

            data = data(ismember(data.(obj.c.COLS.SCOPE), sc) & ismember(data.(obj.c.COLS.TIME_FRAME), obj.time_frames),:);
            data{ismissing(data.(obj.c.COLS.TARGET_REFERENCE_NUMBER)), obj.c.COLS.TARGET_REFERENCE_NUMBER} = obj.c.VALUE_TARGET_REFERENCE_ABSOLUTE;

            sr15 = strings(height(data), 1);
            for i = 1 : height(data)
                sr15(i) = string(obj.get_target_mapping(data(i,:)));
            end
            data.(obj.c.COLS.SR15) = sr15;

            tgt = zeros(height(data), 1);
            for i = 1 : height(data)
                tgt(i) = obj.get_annual_reduction_rate(data(i,:));
            end

            data.(obj.c.COLS.ANNUAL_REDUCTION_RATE) = tgt;

            data = obj.merge_regression(data);
            % TODO: Move temperature result to cols

            data.(obj.c.COLS.TEMPERATURE_SCORE) = NaN(height(data),1);
            data.(obj.c.TEMPERATURE_RESULTS) = NaN(height(data),1);
            for i = 1 : height(data)
                [sc,rs] = obj.get_score(data(i,:));
                data{i, obj.c.COLS.TEMPERATURE_SCORE} = sc;
                data{i, obj.c.TEMPERATURE_RESULTS} = rs;
            end

            data = obj.cap_scores(data);
        end

        function data = calculate_company_score(obj, data)

            % Calculate the combined s1s2s3 scores for all companies.

            % :param data: The original data set as a pandas data frame
            % :return: The data frame, with an updated s1s2s3 temperature score

            % Calculate the GHC
            company_data = data(:,[obj.c.COLS.COMPANY_ID, obj.c.COLS.TIME_FRAME, ...
                obj.c.COLS.SCOPE, obj.c.COLS.GHG_SCOPE12, obj.c.COLS.GHG_SCOPE3, ...
                obj.c.COLS.TEMPERATURE_SCORE, obj.c.TEMPERATURE_RESULTS]);

            company_data = groupsummary(company_data, [obj.c.COLS.COMPANY_ID, obj.c.COLS.TIME_FRAME, obj.c.COLS.SCOPE], 'mean');
            company_data.Properties.VariableNames = strrep(company_data.Properties.VariableNames,"mean_","");

            for i = 1 : height(data)
                [sc,rs] = obj.get_ghc_temperature_score(data(i,:), company_data);
                data{i, obj.c.COLS.TEMPERATURE_SCORE} = sc;
                data{i, obj.c.TEMPERATURE_RESULTS} = rs;
            end

        end

        function [agg, rc, ac] = get_aggregations(obj, data, total_companies)

            % Get the aggregated score over a certain data set. Also calculate the (relative) contribution of each company

            % :param data: A data set, containing one row per company
            % :return: An aggregated score and the relative and absolute contribution of each company

            weighted_scores = obj.calculate_aggregate_score(data, obj.c.COLS.TEMPERATURE_SCORE, obj.aggregation_method);

            data.(obj.c.COLS.CONTRIBUTION_RELATIVE) = weighted_scores / ( sum(weighted_scores) / 100);
            data.(obj.c.COLS.CONTRIBUTION) = weighted_scores;
            contributions = sortrows(data, obj.c.COLS.CONTRIBUTION_RELATIVE, 'descend');

            %             contributions = data\
            %             .sort_values(obj.c.COLS.CONTRIBUTION_RELATIVE, ascending=False)\
            %             .where(pd.notnull(data), None)\
            %             .to_dict(orient="records")

            %             ctrb = [AggregationContribution.parse_obj(contribution) for contribution in contributions]
            ctrb = SBTi.interfaces.AggregationContribution.parse_obj(contributions);
            agg = SBTi.interfaces.Aggregation( sum(weighted_scores), ...
                length(weighted_scores) / (total_companies / 100.0), ctrb);
            rc = data.(obj.c.COLS.CONTRIBUTION_RELATIVE);
            ac = data.(obj.c.COLS.CONTRIBUTION);

        end

        function score_aggregation = get_score_aggregation(obj, data, time_frame, scope)

            % Get a score aggregation for a certain time frame and scope, for the data set as a whole and for the different
            % groupings.

            % :param data: The whole data set
            % :param time_frame: A time frame
            % :param scope: A scope
            % :return: A score aggregation, containing the aggregations for the whole data set and each individual group

            filtered_data = data( (data.(obj.c.COLS.TIME_FRAME) == time_frame) & (data.(obj.c.COLS.SCOPE) == scope), : );

            if ~isempty(obj.grouping)
                filtered_data(:,obj.grouping) = fillmissing(filtered_data(:,obj.grouping),'constant',"unknown");
            end

            total_companies = height(filtered_data);
            if ~isempty(filtered_data)

                [agg, rc, ab] = obj.get_aggregations(filtered_data, total_companies);

                score_aggregation_all = agg;
                filtered_data.(obj.c.COLS.CONTRIBUTION_RELATIVE) = rc;
                filtered_data.(obj.c.COLS.CONTRIBUTION) = ab;

                ip =  obj.calculate_aggregate_score( filtered_data, obj.c.TEMPERATURE_RESULTS, obj.aggregation_method);
                score_aggregation = SBTi.interfaces.ScoreAggregation( containers.Map, score_aggregation_all, 100*sum( ip ) );

                % If there are grouping column(s) we'll group in pandas and pass the results to the aggregation
                if ~isempty(obj.grouping)

                    [groups,grouped_data] = findgroups(filtered_data(:,obj.grouping));

                    for k = 1 : height(grouped_data)
                        group_name_joined = strjoin(grouped_data{k,:},'-');
                        [agg,~,~] = obj.get_aggregations(filtered_data(groups == k,:), total_companies);
                        score_aggregation.grouped(group_name_joined) = agg;
                    end

                end

            else
                score_aggregation = SBTi.interfaces.ScoreAggregation.empty();
            end
        end
    end
end