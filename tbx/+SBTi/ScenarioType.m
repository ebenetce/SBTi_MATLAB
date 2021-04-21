classdef ScenarioType < double
    % A scenario defines which scenario should be run.
    
   enumeration
       TARGETS (1)
       APPROVED_TARGETS (2)
       HIGHEST_CONTRIBUTORS (3)
       HIGHEST_CONTRIBUTORS_APPROVED (4)
   end
   
   methods (Static)
       
       function type = from_int(value)
           
           switch value
               case 1
                   type = SBTi.ScenarioType.TARGETS;
               case 2
                   type = SBTi.ScenarioType.APPROVED_TARGETS;
               case 3
                   type = SBTi.ScenarioType.HIGHEST_CONTRIBUTORS;
               case 4
                   type = SBTi.ScenarioType.HIGHEST_CONTRIBUTORS_APPROVED;
               otherwise 
                   type = [];
           end
       end
   end
   
end