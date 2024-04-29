classdef tSBTI < matlab.unittest.TestCase

    properties
        AmendedPortfolioPy
        AggregatedScoresPy
        CoveragePy
    end

    methods (TestClassSetup)
        function getData(tc)
            websave("data/data_provider_example.xlsx", "https://github.com/ScienceBasedTargets/SBTi-finance-tool/raw/main/examples/data/data_provider_example.xlsx");
            websave("data/example_portfolio.csv", "https://github.com/ScienceBasedTargets/SBTi-finance-tool/raw/main/examples/data/example_portfolio.csv");

            pd = py.importlib.import_module('pandas');
            SBTi = py.importlib.import_module('SBTi');
            cov = py.importlib.import_module('SBTi.portfolio_coverage_tvp');

            provider = SBTi.data.excel.ExcelProvider(path="data/data_provider_example.xlsx");
            df_portfolio = pd.read_csv("data/example_portfolio.csv", encoding="iso-8859-1");
            companies = SBTi.utils.dataframe_to_portfolio(df_portfolio);

            temperature_score = SBTi.temperature_score.TemperatureScore( ...                  % all available options:
            time_frames= py.list(SBTi.interfaces.ETimeFrames), ...   % ETimeFrames: SHORT MID and LONG
            scopes=py.list({SBTi.interfaces.EScope.S1S2, SBTi.interfaces.EScope.S3, SBTi.interfaces.EScope.S1S2S3}), ...   % EScopes: S3, S1S2 and S1S2S3
            aggregation_method=SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS); % Options for the aggregation method are WATS, TETS, AOTS, MOTS, EOTS, ECOTS, and ROTS.

            amended_portfolio = temperature_score.calculate(data_providers=py.list({provider}), portfolio=companies);
            tc.AmendedPortfolioPy = sortrows(table(amended_portfolio), {'company_id', 'time_frame', 'achieved_reduction'});
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            tc.AggregatedScoresPy = aggregated_scores;

            portfolio_coverage_tvp = cov.PortfolioCoverageTVP();
            tc.CoveragePy = portfolio_coverage_tvp.get_portfolio_coverage(amended_portfolio.copy(), SBTi.portfolio_aggregation.PortfolioAggregationMethod.WATS);
        end
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods

        function tTemp(tc)
            import SBTi.interfaces.*
            provider = SBTi.data.ExcelProvider("data/data_provider_example.xlsx");
            portfolio = readtable('data/example_portfolio.csv', 'FileEncoding','ISO-8859-15');

            companies = SBTi.utils.table_to_portfolio(portfolio);

            scopes = [EScope.S1S2, EScope.S3, EScope.S1S2S3];
            temperature_score = SBTi.TemperatureScore( ...
                time_frames=[ETimeFrames.SHORT, ETimeFrames.MID, ETimeFrames.LONG], ...
                scopes=scopes, ...
                aggregation_method=SBTi.PortfolioAggregationMethod.WATS);

            % Check temperature
            amended_portfolio = temperature_score.calculate(data_providers=provider, portfolio=companies);
            amended_portfolio = sortrows(amended_portfolio, {'company_id', 'time_frame', 'achieved_reduction'});
            tc.verifyEqual(tc.AmendedPortfolioPy.company_id, amended_portfolio.company_id)
            tc.verifyEqual(tc.AmendedPortfolioPy.temperature_score, amended_portfolio.temperature_score)
            tc.verifyEqual(tc.AmendedPortfolioPy.temperature_results, amended_portfolio.temperature_results)
            tc.verifyEqual(tc.AmendedPortfolioPy.sbti_validated, amended_portfolio.sbti_validated)
 
            % Check aggregated Scores
            aggregated_scores = temperature_score.aggregate_scores(amended_portfolio);
            tc.verifyEqual(tc.AggregatedScoresPy.mid.S1S2.all.score, aggregated_scores.mid.S1S2.all.score)
            tc.verifyEqual(tc.AggregatedScoresPy.mid.S3.all.score, aggregated_scores.mid.S3.all.score, AbsTol = 1e-14)
            tc.verifyEqual(tc.AggregatedScoresPy.long.S1S2.all.score, aggregated_scores.long.S1S2.all.score, AbsTol = 1e-14)

            % Check coverage
            portfolio_coverage_tvp = SBTi.PortfolioCoverageTVP();
            coverage = portfolio_coverage_tvp.get_portfolio_coverage(amended_portfolio, SBTi.PortfolioAggregationMethod.WATS);

            tc.verifyEqual(tc.CoveragePy, coverage, AbsTol = 1e-13)
        end
    end

end