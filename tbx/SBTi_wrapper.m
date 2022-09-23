classdef SBTi_wrapper

    methods (Static)

        function [amended_portfolio, aggregated_scores, coverage] = calTemperatureScore(SBTi_options)

            provider = SBTi.data.ExcelProvider(SBTi_options.dataProviderXLSX);

            examplePortfoliofile = SBTi_options.portfolioCSV;
            opts = detectImportOptions(examplePortfoliofile);
            opts.Encoding = 'ISO-8859-15';
            opts = setvartype(opts, 'engagement_target', 'logical');
            portfolio = readtable(examplePortfoliofile, opts);
            portfolio.engagement_target = logical(portfolio.engagement_target);

            keys = fields(SBTi_options);
            temperature_score_input_dict = {};

            if ismember('scopes', keys)                
                temperature_score_input_dict = [temperature_score_input_dict, {'scopes', SBTi_options.scopes}];
            end

            if ismember('time_frames', keys)
                temperature_score_input_dict = [temperature_score_input_dict, {'time_frames', SBTi_options.time_frames}];
            end

            if ismember('aggregation_method', keys)
                temperature_score_input_dict = [temperature_score_input_dict, {'aggregation_method', SBTi_options.aggregation_method}];
            end

            if ismember('fallback_score', keys)
                temperature_score_input_dict = [temperature_score_input_dict, {'fallback_score', SBTi_options.fallback_score}];
            end

            if ismember('model', keys)
                temperature_score_input_dict = [temperature_score_input_dict, {'model', SBTi_options.model}];
            end

            if ismember('grouping', keys)
                temperature_score_input_dict = [temperature_score_input_dict, {'grouping', SBTi_options.grouping}];
            end

            if ismember('scenario', keys)
                temperature_score_input_dict = [temperature_score_input_dict, {'scenario', SBTi_options.scenario}];
            end

            companies = SBTi.utils.table_to_portfolio(portfolio);
            temperature_score = SBTi.TemperatureScore( temperature_score_input_dict{:} );
            amended_portfolio = temperature_score.calculate(data_providers=provider, portfolio=companies);

            % Aggregate score
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);

            % portfolio coverage
            portfolio_coverage_tvp = SBTi.PortfolioCoverageTVP();
            coverage = portfolio_coverage_tvp.get_portfolio_coverage(amended_portfolio, temperature_score.aggregation_method);


        end

        function [scope_list,time_frame_list,score_list] = calTemperatureScoreForScenario(scenarioOptions)

            provider = SBTi.data.ExcelProvider(scenarioOptions.dataProviderXLSX);

            examplePortfoliofile = scenarioOptions.portfolioCSV;
            opts = detectImportOptions(examplePortfoliofile);
            opts.Encoding = 'ISO-8859-15';
            opts = setvartype(opts, 'engagement_target', 'logical');
            portfolio = readtable(examplePortfoliofile, opts);

            scopes = [];
            for scope = scenarioOptions.scopes
                scopes = [scopes SBTi.interfaces.EScope.(string(upper(scope)))];
            end
            time_frames = [];
            for time_frame = scenarioOptions.time_frames
                time_frames = [time_frames SBTi.interfaces.ETimeFrames.(string(upper(time_frame)))];
            end

            aggregation_method = scenarioOptions.aggregationMethod;

            fallback_score = scenarioOptions.fallback_score;

            scenario = SBTi.Scenario();

            scenarioType = scenarioOptions.scenarioType; 
            scenario.scenario_type =  SBTi.ScenarioType(scenarioType);

            engagementType = scenarioOptions.engagementType;
            if ~strcmp(engagementType,'None')
                scenario.engagement_type = SBTi.EngagementType.(engagementType);
            end

            companies = SBTi.utils.table_to_portfolio(portfolio);
            temperature_score = SBTi.TemperatureScore(time_frames=time_frames, scopes=scopes, scenario=scenario, aggregation_method=aggregation_method, fallback_score=fallback_score);
            amended_portfolio = temperature_score.calculate(data_providers=provider, portfolio=companies);
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);

            [scope_list,time_frame_list,score_list] = SBTi_wrapper.getScoreForEachTimeFrameAndScope(aggregated_scores,scenarioOptions.scopes,scenarioOptions.time_frames);

        end

        function [scope_list,time_frame_list,score_list] = getScoreForEachTimeFrameAndScope(aggregated_scores,scopes,time_frames)
            scope_list = [];
            time_frame_list = [];
            score_list = [];
            
            for scope = scopes
                for time_frame = time_frames
                    scope_list = [scope_list; scope];
                    time_frame_list = [time_frame_list; time_frame];
                    score_list = [score_list; aggregated_scores.(string(time_frame)).(string(scope)).all.score];
                end
            end
    
        end

        function [groups, Tscore, investmentProportion] = groupScore(aggregationObj, time_frame, scope)

            time_frame = lower(time_frame);

            aggregations = aggregationObj.(time_frame).(scope).grouped;

            Tscore = [];
            investmentProportion = [];
            groups = [];
            for group = keys(aggregations)

                score = aggregations(group).score;
                proportion = aggregations(group).proportion;

                groups = [groups group];
                Tscore = [Tscore score];
                investmentProportion = [investmentProportion proportion];
            end

        end

        function company_contributions = collect_company_contributions(aggregated_portfolio, amended_portfolio, time_frame, scope, grouping)

            company_names = [];
            relative_contributions = [];
            temperature_scores = [];

            for contribution = aggregated_portfolio.(time_frame).(scope).all.contributions
                company_names = [company_names; contribution.company_name];
                relative_contributions = [relative_contributions;contribution.contribution_relative];
                temperature_scores = [temperature_scores; contribution.temperature_score];
            end

            company_contributions = table(company_names, relative_contributions, temperature_scores, 'VariableNames', {'company_name', 'contribution', 'temperature_score'});
            amended_portfolio = amended_portfolio(amended_portfolio.time_frame == time_frame,:);
            amended_portfolio = amended_portfolio(erase(amended_portfolio.scope,"+") == scope,:);
            company_contributions = join(company_contributions, ...
                amended_portfolio(:,[{'company_name', 'company_id', 'company_market_cap', 'investment_value', 'sector'}, grouping]), ...
                'Keys', 'company_name');

            company_contributions.portfolio_percentage = 100 * company_contributions.investment_value / sum(company_contributions.investment_value);
            company_contributions.ownership_percentage = 100 * company_contributions.investment_value / company_contributions.company_market_cap;
            company_contributions = sortrows(company_contributions, 'contribution', 'descend');

        end

        function [sector_temp_scores, sector_names, sector_contributions, sector_investments] = groupStatistics(aggregated_portfolio, company_contributions, time_frame, scope, grouping)

            G = groupsummary(company_contributions, grouping, 'sum', ["investment_value","contribution"]);

            sector_investments = G.sum_investment_value;
            sector_contributions = G.sum_contribution;

            sector_names = categorical(G{:,grouping});
            sector_temp_scores = [aggregated_portfolio.(time_frame).(scope).grouped.values];
            sector_temp_scores = [sector_temp_scores{:}];
            sector_temp_scores = [sector_temp_scores.score];
            [~, iA] = sort(sector_temp_scores, 2, 'descend');
            if length(grouping)>1
                sector_names = G{:,grouping}(iA,:);
            else
                sector_names = reordercats(sector_names, G{:,grouping}(iA,:));
            end
        end

    end

end
