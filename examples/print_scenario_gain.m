function print_scenario_gain(actual_aggregations, scenario_aggregations)
    fprintf("Actual portfolio temperature score\n")
    print_aggregations(actual_aggregations)
    fprintf("\n")
    fprintf("Scenario portfolio temperature score\n")
    print_aggregations(scenario_aggregations)