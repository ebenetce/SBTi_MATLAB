function record_dict = flatten_user_fields(PortfolioCompany)
    
    % Flatten the user fields in a portfolio company and return it as a dictionary.

    % :param record: The record to flatten
    % :return:
    
    record_dict = record.dict(exclude_none=True);
    if record.user_fields is not None:
        for key, value in record_dict["user_fields"].items():
            record_dict[key] = value
        del record_dict["user_fields"]
        end
    end
end