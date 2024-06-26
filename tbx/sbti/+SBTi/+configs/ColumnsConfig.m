classdef ColumnsConfig
    % This file defines the constants used throughout the different classes. In order to redefine these settings whilst using
    % the module, extend the respective config class and pass it to the class as the "constants" parameter.
    properties (Constant)
        % Define a constant for each column used in the
        COMPANY_ID = "company_id"
        COMPANY_ISIN = "company_isin"
        COMPANY_LEI = "company_lei"
        COMPANY_ISIC = "isic"
        REGRESSION_PARAM = "param"
        REGRESSION_INTERCEPT = "intercept"
        MARKET_CAP = "company_market_cap"
        INVESTMENT_VALUE = "investment_value"
        COMPANY_ENTERPRISE_VALUE = "company_enterprise_value"
        COMPANY_EV_PLUS_CASH = "company_ev_plus_cash"
        COMPANY_TOTAL_ASSETS = "company_total_assets"
        TARGET_REFERENCE_NUMBER = "target_type"
        SCOPE = "scope"
        SR15 = "sr15"
        REDUCTION_FROM_BASE_YEAR = "reduction_from_base_year"
        START_YEAR = "start_year"
        VARIABLE = "variable"
        SLOPE = "slope"
        TIME_FRAME = "time_frame"
        MODEL = "model"
        ANNUAL_REDUCTION_RATE = "annual_reduction_rate"
        EMISSIONS_IN_SCOPE = "emissions_in_scope"
        TEMPERATURE_SCORE = "temperature_score"
        COMPANY_NAME = "company_name"
        OWNED_EMISSIONS = "owned_emissions"
        COUNTRY = "country"
        SECTOR = "sector"
        GHG_SCOPE12 = "ghg_s1s2"
        GHG_SCOPE3 = "ghg_s3"
        COMPANY_REVENUE = "company_revenue"
        CASH_EQUIVALENTS = "company_cash_equivalents"
        TARGET_CLASSIFICATION = "target_classification"
        REDUCTION_AMBITION = "reduction_ambition"
        BASE_YEAR = "base_year"
        END_YEAR = "end_year"
        SBTI_VALIDATED = "sbti_validated"
        ACHIEVED_EMISSIONS = "achieved_reduction"
        ISIC = "isic"
        INDUSTRY_LVL1 = "industry_level_1"
        INDUSTRY_LVL2 = "industry_level_2"
        INDUSTRY_LVL3 = "industry_level_3"
        INDUSTRY_LVL4 = "industry_level_4"
        COVERAGE_S1 = "coverage_s1"
        COVERAGE_S2 = "coverage_s2"
        COVERAGE_S3 = "coverage_s3"
        INTENSITY_METRIC = "intensity_metric"
        INTENSITY_METRIC_SR15 = "intensity_metric"
        TARGET_TYPE_SR15 = "target_type"
        SR15_VARIABLE = "sr15_variable"
        REGRESSION_MODEL = "Regression_model"
        BASEYEAR_GHG_S1 = "base_year_ghg_s1"
        BASEYEAR_GHG_S2 = "base_year_ghg_s2"
        BASEYEAR_GHG_S3 = "base_year_ghg_s3"
        REGION = "region"
        ENGAGEMENT_TARGET = "engagement_target"
        
        % SR15 mapping columns
        PARAM = "param"
        INTERCEPT = "intercept"
        
        % Output columns
        WEIGHTED_TEMPERATURE_SCORE = "weighted_temperature_score"
        CONTRIBUTION_RELATIVE = "contribution_relative"
        CONTRIBUTION = "contribution"
    end
    
end