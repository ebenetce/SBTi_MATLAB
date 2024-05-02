function outfilename = updateCompaniesTakingAction()

c = SBTi.configs.PortfolioCoverageTVPConfig;

try
    outfilename = websave(c.FILE_TARGETS, c.CTA_FILE_URL);
catch
    warning('SBTi:utils:updateCompaniesTakingAction:websaveFailed','Unable to update companies taking action spreadsheet')
    outfilename = '';
end