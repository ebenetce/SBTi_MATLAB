function updateCompaniesTakingAction(nvp)

arguments
    nvp.path = SBTiroot;
    nvp.name = 'current-Companies-Taking-Action-191.xlsx'
end

websave(fullfile(nvp.path, "+SBTi/+configs/inputs", nvp.name), 'https://sciencebasedtargets.org/download/excel')