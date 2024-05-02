classdef tAggrMethods < matlab.unittest.TestCase

    properties
        Scores_collection
    end

     methods (TestClassSetup)
        function getData(tc)
            websave("data/data_provider_example.xlsx", "https://github.com/ScienceBasedTargets/SBTi-finance-tool/raw/main/examples/data/data_provider_example.xlsx");
            websave("data/example_portfolio.csv", "https://github.com/ScienceBasedTargets/SBTi-finance-tool/raw/main/examples/data/example_portfolio.csv");

            pd = py.importlib.import_module('pandas');
            SBTi = py.importlib.import_module('SBTi');
            SBTi = py.importlib.reload(SBTi);

            provider = SBTi.data.excel.ExcelProvider(path="data/data_provider_example.xlsx");
            df_portfolio = pd.read_csv("data/example_portfolio.csv", encoding="iso-8859-1");
            companies = SBTi.utils.dataframe_to_portfolio(df_portfolio);
            
            tc.Scores_collection = dictionary();

            time_frames = py.list(SBTi.interfaces.ETimeFrames);
            scopes =  py.list({SBTi.interfaces.EScope.S1S2, SBTi.interfaces.EScope.S3, SBTi.interfaces.EScope.S1S2S3});

            temperature_score = SBTi.temperature_score.TemperatureScore( ...                  % all available options:
                time_frames= time_frames, ...   % ETimeFrames: SHORT MID and LONG
                scopes=scopes);

            amended_portfolio = temperature_score.calculate(data_providers=py.list({provider}), portfolio=companies);

            temperature_score.aggregation_method = SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            df_wats = pyrun("df_wats = pd.DataFrame(aggregated_scores.dict()).applymap(lambda x: round(x['all']['score'], 2))", 'df_wats', aggregated_scores = aggregated_scores, pd = pd);
            tc.Scores_collection('WATS') = {table(df_wats)};

            temperature_score.aggregation_method = SBTi.portfolio_aggregation.PortfolioAggregationMethod.TETS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            df = pyrun("df = pd.DataFrame(aggregated_scores.dict()).applymap(lambda x: round(x['all']['score'], 2))", 'df', aggregated_scores = aggregated_scores, pd = pd);
            tc.Scores_collection('TETS') = {table(df)};

            temperature_score.aggregation_method = SBTi.portfolio_aggregation.PortfolioAggregationMethod.MOTS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            df = pyrun("df = pd.DataFrame(aggregated_scores.dict()).applymap(lambda x: round(x['all']['score'], 2))", 'df', aggregated_scores = aggregated_scores, pd = pd);
            tc.Scores_collection('MOTS') = {table(df)};

            temperature_score.aggregation_method = SBTi.portfolio_aggregation.PortfolioAggregationMethod.EOTS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            df = pyrun("df = pd.DataFrame(aggregated_scores.dict()).applymap(lambda x: round(x['all']['score'], 2))", 'df', aggregated_scores = aggregated_scores, pd = pd);
            tc.Scores_collection('EOTS') = {table(df)};

            temperature_score.aggregation_method = SBTi.portfolio_aggregation.PortfolioAggregationMethod.ECOTS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            df = pyrun("df = pd.DataFrame(aggregated_scores.dict()).applymap(lambda x: round(x['all']['score'], 2))", 'df', aggregated_scores = aggregated_scores, pd = pd);
            tc.Scores_collection('ECOTS') = {table(df)};

            temperature_score.aggregation_method = SBTi.portfolio_aggregation.PortfolioAggregationMethod.AOTS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            df = pyrun("df = pd.DataFrame(aggregated_scores.dict()).applymap(lambda x: round(x['all']['score'], 2))", 'df', aggregated_scores = aggregated_scores, pd = pd);
            tc.Scores_collection('AOTS') = {table(df)};

            temperature_score.aggregation_method = SBTi.portfolio_aggregation.PortfolioAggregationMethod.ROTS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            df = pyrun("df = pd.DataFrame(aggregated_scores.dict()).applymap(lambda x: round(x['all']['score'], 2))", 'df', aggregated_scores = aggregated_scores, pd = pd);
            tc.Scores_collection('ROTS') = {table(df)};

        end
    end

    methods (Test)
        function tAggregationMethods(tc)

            provider = SBTi.data.ExcelProvider("data/data_provider_example.xlsx");

            examplePortfoliofile = "data/example_portfolio.csv";
            opts = detectImportOptions(examplePortfoliofile);
            opts.Encoding = 'ISO-8859-15';
            opts = setvartype(opts, 'engagement_target', 'logical');

            portfolio = readtable(examplePortfoliofile, opts);

            companies = SBTi.utils.table_to_portfolio(portfolio);

            temperature_score = SBTi.TemperatureScore(time_frames=[SBTi.ETimeFrames.SHORT, SBTi.ETimeFrames.MID, SBTi.ETimeFrames.LONG], ...
                scopes=[SBTi.EScope.S1S2, SBTi.EScope.S3, SBTi.EScope.S1S2S3]);
            amended_portfolio = temperature_score.calculate(data_providers=provider, portfolio=companies);

            temperature_score.aggregation_method = SBTi.PortfolioAggregationMethod.WATS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            t = aggregated_scores.summary();
            tc.verifyEqual(t{:,:}, tc.Scores_collection{'WATS'}{:,2:end}, AbsTol = 1e-14)

            temperature_score.aggregation_method = SBTi.PortfolioAggregationMethod.TETS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            t = aggregated_scores.summary();
            tc.verifyEqual(t{:,:}, tc.Scores_collection{'TETS'}{:,2:end}, AbsTol = 1e-14)

            temperature_score.aggregation_method = SBTi.PortfolioAggregationMethod.MOTS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            t = aggregated_scores.summary();
            tc.verifyEqual(t{:,:}, tc.Scores_collection{'MOTS'}{:,2:end}, AbsTol = 1e-14)

            temperature_score.aggregation_method = SBTi.PortfolioAggregationMethod.EOTS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            t = aggregated_scores.summary();
            tc.verifyEqual(t{:,:}, tc.Scores_collection{'EOTS'}{:,2:end}, AbsTol = 1e-14)

            temperature_score.aggregation_method = SBTi.PortfolioAggregationMethod.ECOTS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            t = aggregated_scores.summary();
            tc.verifyEqual(t{:,:}, tc.Scores_collection{'ECOTS'}{:,2:end}, AbsTol = 1e-14)

            temperature_score.aggregation_method = SBTi.PortfolioAggregationMethod.AOTS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            t = aggregated_scores.summary();
            tc.verifyEqual(t{:,:}, tc.Scores_collection{'AOTS'}{:,2:end}, AbsTol = 1e-14)

            temperature_score.aggregation_method = SBTi.PortfolioAggregationMethod.ROTS;
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            t = aggregated_scores.summary();
            tc.verifyEqual(t{:,:}, tc.Scores_collection{'ROTS'}{:,2:end}, AbsTol = 1e-14)
        end
    end

end