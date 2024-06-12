classdef PortfolioCoverageTVPConfig < SBTi.configs.PortfolioAggregationConfig
    
    properties
        FILE_TARGETS = fullfile( fileparts(mfilename('fullpath')), "inputs", "current-Companies-Taking-Action.xlsx")
        CTA_FILE_URL = "https://cdn.sciencebasedtargets.org/download/target-dashboard"
        OUTPUT_TARGET_STATUS = "sbti_target_status"
        OUTPUT_WEIGHTED_TARGET_STATUS = "weighted_sbti_target_status"
        VALUE_TARGET_NO = "No target"
        VALUE_TARGET_SET = "Near-term"
        VALUE_TARGET_COMMITTED = "Commitment"
        VALUE_ACTION_TARGET = "Target"
        
        TARGET_SCORE_MAP = struct(...
            'VALUE_TARGET_NO', 0, ...
            'VALUE_TARGET_COMMITTED', 0,...
            'VALUE_TARGET_SET', 100)
        
        % SBTi targets overview (TVP coverage)
        COL_COMPANY_NAME = "Company Name"
        COL_COMPANY_ISIN = "ISIN"
        COL_COMPANY_LEI = "LEI"
        COL_ACTION = "Action"
        COL_TARGET = "Target"
    end
end