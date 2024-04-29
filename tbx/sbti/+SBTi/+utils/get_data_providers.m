function selected_data_providers = get_data_providers(data_providers_configs, data_providers_input)
    
    % Determines which data provider and in which order should be used.

    % :param data_providers_configs: A list of data provider configurations
    % :param data_providers_input: A list of data provider names
    % :return: a list of data providers in order.
    
    logger = logging.getLogger(__name__)
    data_providers = [];
    for data_provider_config in data_providers_configs:
        data_provider_config["class"] = DATA_PROVIDER_MAP[data_provider_config["type"]](**data_provider_config["parameters"])
        data_providers.append(data_provider_config)
    end
    selected_data_providers = []
    for data_provider_name in data_providers_input:
        found = False
        for data_provider_config in data_providers:
            if data_provider_config["name"] == data_provider_name:
                selected_data_providers.append(data_provider_config["class"])
                found = True
                break
            end
        end
        if not found:
            logger.warning("The following data provider could not be found: {}".format(data_provider_name))
        end
    end

    if len(selected_data_providers) == 0:
        raise ValueError("None of the selected data providers are available. The following data providers are valid "
                         "options: " + ", ".join(data_provider["name"] for data_provider in data_providers_configs))
                         end
    end