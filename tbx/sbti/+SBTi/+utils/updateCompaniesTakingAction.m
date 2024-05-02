function outfilename = updateCompaniesTakingAction(nvp)

arguments
    nvp.path = SBTiroot;
    nvp.name = 'current-Companies-Taking-Action-191.xlsx'
end

try
    outfilename = websave(fullfile(nvp.path, "+SBTi/+configs/inputs", nvp.name), 'https://sciencebasedtargets.org/download/excel');
catch
    warning('SBTi:utils:updateCompaniesTakingAction:websaveFailed','Unable to update companies taking action spreadsheet')
    outfilename = '';
end