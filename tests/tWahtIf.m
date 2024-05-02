classdef tWahtIf < matlab.unittest.TestCase

    properties
        Scenarios
    end

    methods (TestClassSetup)
        function getData(tc)
            % websave("data/data_provider_example.xlsx", "https://github.com/ScienceBasedTargets/SBTi-finance-tool/raw/main/examples/data/data_provider_example.xlsx");
            % websave("data/example_portfolio.csv", "https://github.com/ScienceBasedTargets/SBTi-finance-tool/raw/main/examples/data/example_portfolio.csv");

            pd = py.importlib.import_module('pandas');
            SBTi = py.importlib.import_module('SBTi');
            SBTi = py.importlib.reload(SBTi);

            provider = SBTi.data.excel.ExcelProvider(path="data/data_provider_example.xlsx");
            df_portfolio = pd.read_csv("data/example_portfolio.csv", encoding="iso-8859-1");
            companies = SBTi.utils.dataframe_to_portfolio(df_portfolio);
            portfolio_data = SBTi.utils.get_data(py.list({provider}), companies);
            tc.Scenarios = dictionary();

            time_frames = py.list({SBTi.interfaces.ETimeFrames.MID});
            scopes =  py.list({SBTi.interfaces.EScope.S1S2S3});

            temperature_score = SBTi.temperature_score.TemperatureScore(time_frames=time_frames, scopes=scopes);
            base_scenario = temperature_score.calculate(portfolio_data.copy());
            base_scenario_aggregated = temperature_score.aggregate_scores(base_scenario);
            base_score = base_scenario_aggregated.mid.S1S2S3.all.score;

            tc.Scenarios('Base Scenario') = base_score;

            scenario = SBTi.temperature_score.Scenario();
            py.setattr(scenario, 'scenario_type', SBTi.temperature_score.ScenarioType.TARGETS);
            py.setattr(scenario, 'engagement_type', py.None);
            py.setattr(scenario, 'aggregation_method', SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            py.setattr(scenario, 'grouping', py.None);

            temperature_score = SBTi.temperature_score.TemperatureScore(time_frames=time_frames, ...
                scopes=scopes, scenario=scenario, aggregation_method=SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            scenario_one = temperature_score.calculate(portfolio_data.copy());
            scenario_aggregated = temperature_score.aggregate_scores(scenario_one);
            scenario_1_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.Scenarios('Scenario 1') = scenario_1_score;

            scenario = SBTi.temperature_score.Scenario();
            py.setattr(scenario, 'scenario_type', SBTi.temperature_score.ScenarioType.APPROVED_TARGETS);
            py.setattr(scenario, 'engagement_type', py.None);
            py.setattr(scenario, 'aggregation_method', SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            py.setattr(scenario, 'grouping', py.None);

            temperature_score = SBTi.temperature_score.TemperatureScore(time_frames=time_frames, ...
                scopes=scopes, scenario=scenario, aggregation_method=SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            scenario_one = temperature_score.calculate(portfolio_data.copy());
            scenario_aggregated = temperature_score.aggregate_scores(scenario_one);
            scenario_2_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.Scenarios('Scenario 2') = scenario_2_score;

            scenario = SBTi.temperature_score.Scenario();
            py.setattr(scenario, 'scenario_type', SBTi.temperature_score.ScenarioType.HIGHEST_CONTRIBUTORS);
            py.setattr(scenario, 'engagement_type', SBTi.temperature_score.EngagementType.SET_TARGETS);
            py.setattr(scenario, 'aggregation_method', SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            py.setattr(scenario, 'grouping', py.None);

            temperature_score = SBTi.temperature_score.TemperatureScore(time_frames=time_frames, ...
                scopes=scopes, scenario=scenario, aggregation_method=SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            scenario_one = temperature_score.calculate(portfolio_data.copy());
            scenario_aggregated = temperature_score.aggregate_scores(scenario_one);
            scenario_3a_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.Scenarios('Scenario 3a') = scenario_3a_score;

            scenario = SBTi.temperature_score.Scenario();
            py.setattr(scenario, 'scenario_type', SBTi.temperature_score.ScenarioType.HIGHEST_CONTRIBUTORS);
            py.setattr(scenario, 'engagement_type', SBTi.temperature_score.EngagementType.SET_SBTI_TARGETS);
            py.setattr(scenario, 'aggregation_method', SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            py.setattr(scenario, 'grouping', py.None);

            temperature_score = SBTi.temperature_score.TemperatureScore(time_frames=time_frames, ...
                scopes=scopes, scenario=scenario, aggregation_method=SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            scenario_two = temperature_score.calculate(portfolio_data.copy());
            scenario_aggregated = temperature_score.aggregate_scores(scenario_two);
            scenario_3b_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.Scenarios('Scenario 3b') = scenario_3b_score;

            scenario = SBTi.temperature_score.Scenario();
            py.setattr(scenario, 'scenario_type', SBTi.temperature_score.ScenarioType.HIGHEST_CONTRIBUTORS_APPROVED);
            py.setattr(scenario, 'engagement_type', SBTi.temperature_score.EngagementType.SET_TARGETS);
            py.setattr(scenario, 'aggregation_method', SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            py.setattr(scenario, 'grouping', py.None);

            temperature_score = SBTi.temperature_score.TemperatureScore(time_frames=time_frames, ...
                scopes=scopes, scenario=scenario, aggregation_method=SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            scenario_two = temperature_score.calculate(portfolio_data.copy());
            scenario_aggregated = temperature_score.aggregate_scores(scenario_two);
            scenario_4a_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.Scenarios('Scenario 4a') = scenario_4a_score;

            scenario = SBTi.temperature_score.Scenario();
            py.setattr(scenario, 'scenario_type', SBTi.temperature_score.ScenarioType.HIGHEST_CONTRIBUTORS_APPROVED);
            py.setattr(scenario, 'engagement_type', SBTi.temperature_score.EngagementType.SET_SBTI_TARGETS);
            py.setattr(scenario, 'aggregation_method', SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            py.setattr(scenario, 'grouping', py.None);

            temperature_score = SBTi.temperature_score.TemperatureScore(time_frames=time_frames, ...
                scopes=scopes, scenario=scenario, aggregation_method=SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
            scenario_two = temperature_score.calculate(portfolio_data.copy());
            scenario_aggregated = temperature_score.aggregate_scores(scenario_two);
            scenario_4b_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.Scenarios('Scenario 4b') = scenario_4b_score;
        end
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods

        function tTemp(tc)
            import SBTi.data.*
            import SBTi.*
            import SBTi.interfaces.*

            provider = ExcelProvider("data/data_provider_example.xlsx");
            examplePortfoliofile = "data/example_portfolio.csv";
            opts = detectImportOptions(examplePortfoliofile);
            opts.Encoding = 'ISO-8859-15';
            opts = setvartype(opts, 'engagement_target', 'logical');
            portfolio = readtable("data/example_portfolio.csv", opts);
            companies = utils.table_to_portfolio(portfolio);
            portfolio_data = utils.get_data(provider, companies);

            time_frames = interfaces.ETimeFrames.MID; % ETimeFrames: SHORT MID and LONG
            scopes = EScope.S1S2S3;                       % EScopes: S1, S2, S3, S1S2 and S1S2S3

            temperature_score = TemperatureScore(time_frames=time_frames, scopes=scopes);
            base_scenario = temperature_score.calculate(portfolio_data);
            base_scenario_aggregated = temperature_score.aggregate_scores(base_scenario);
            base_score = base_scenario_aggregated.mid.S1S2S3.all.score;

            tc.verifyEqual(base_score, tc.Scenarios('Base Scenario'), AbsTol = 1e-14)

            scenario = Scenario();
            scenario.scenario_type = ScenarioType.TARGETS;
            temperature_score = TemperatureScore(time_frames=time_frames, scopes=scopes, scenario=scenario, aggregation_method=PortfolioAggregationMethod.WATS);
            scenario_one = temperature_score.calculate(portfolio_data);
            scenario_aggregated = temperature_score.aggregate_scores(scenario_one);
            scenario_1_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.verifyEqual(scenario_1_score, tc.Scenarios('Scenario 1'), AbsTol = 1e-14)

            scenario = Scenario();
            scenario.scenario_type = ScenarioType.APPROVED_TARGETS;
            temperature_score = TemperatureScore(time_frames=time_frames, scopes=scopes, scenario=scenario, aggregation_method=PortfolioAggregationMethod.WATS);

            scenario_two = temperature_score.calculate(portfolio_data);
            scenario_aggregated = temperature_score.aggregate_scores(scenario_two);
            scenario_2_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.verifyEqual(scenario_2_score, tc.Scenarios('Scenario 2'), AbsTol = 1e-14)

            scenario = Scenario();
            scenario.scenario_type = ScenarioType.HIGHEST_CONTRIBUTORS;
            scenario.engagement_type = EngagementType.SET_TARGETS;

            temperature_score = TemperatureScore(time_frames=time_frames, scopes=scopes, scenario=scenario, aggregation_method=PortfolioAggregationMethod.WATS);
            scenario_two = temperature_score.calculate(portfolio_data);
            scenario_aggregated = temperature_score.aggregate_scores(scenario_two);
            scenario_3a_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.verifyEqual(scenario_3a_score, tc.Scenarios('Scenario 3a'), AbsTol = 1e-14)

            scenario = Scenario();
            scenario.scenario_type = ScenarioType.HIGHEST_CONTRIBUTORS;
            scenario.engagement_type = EngagementType.SET_SBTI_TARGETS;
            temperature_score = TemperatureScore(time_frames=time_frames, scopes=scopes, scenario=scenario, aggregation_method=PortfolioAggregationMethod.WATS);
            scenario_two = temperature_score.calculate(portfolio_data);
            scenario_aggregated = temperature_score.aggregate_scores(scenario_two);
            scenario_3b_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.verifyEqual(scenario_3b_score, tc.Scenarios('Scenario 3b'), AbsTol = 1e-14)

            scenario = Scenario();
            scenario.scenario_type = ScenarioType.HIGHEST_CONTRIBUTORS_APPROVED;
            scenario.engagement_type = EngagementType.SET_TARGETS;

            temperature_score = TemperatureScore(time_frames=time_frames, scopes=scopes, scenario=scenario, ...
                aggregation_method=PortfolioAggregationMethod.WATS);
            scenario_two = temperature_score.calculate(portfolio_data);
            scenario_aggregated = temperature_score.aggregate_scores(scenario_two);
            scenario_4a_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.verifyEqual(scenario_4a_score, tc.Scenarios('Scenario 4a'), AbsTol = 1e-14)

            scenario = Scenario();
            scenario.scenario_type = ScenarioType.HIGHEST_CONTRIBUTORS_APPROVED;
            scenario.engagement_type = EngagementType.SET_SBTI_TARGETS;

            temperature_score = TemperatureScore(time_frames=time_frames, scopes=scopes, ...
                scenario=scenario, aggregation_method=PortfolioAggregationMethod.WATS);
            scenario_two = temperature_score.calculate(portfolio_data);
            scenario_aggregated = temperature_score.aggregate_scores(scenario_two);
            scenario_4b_score = scenario_aggregated.mid.S1S2S3.all.score;
            tc.verifyEqual(scenario_4b_score, tc.Scenarios('Scenario 4b'), AbsTol = 1e-14)
        end
    end

end