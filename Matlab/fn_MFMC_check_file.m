function [errors, extra_datafields] = fn_MFMC_check_file(fname, varargin)
%SUMMARY
%   Checks MFMC file against template (e.g. from json file)

if isempty(varargin)
    display_results = 'verbose';
else
    display_results = varargin{1};
end

if ~fn_MFMC_prepare_to_write_or_read_file(fname)
    errors{1} = 'Failed to open file';
    return
end

%Stage 1 - identify any fields in file that are not in template -
%these throw warnings but no errors

extra_datafields = fn_MFMC_check_for_extra_fields(fname);

%Stage 2 - go through template and check for missing mandatory fields or
%errors in any field
errors = fn_MFMC_recursive_error_check_against_template(fname);

%Stage 3 - TODO - check all content is present (e.g. probes referenced are
%present in file, element numbers referenced to not exceed physical element
%numbers etc. Need language to describe these checks in json file.
errors2 = fn_MFMC_check_numerical_values(fname);


switch display_results
    case 'verbose'
        fprintf('Errors\n');
        if isempty(errors)
            fprintf('     None\n');
        else
            for ii = 1:length(errors)
                fprintf(['%3i. ', errors{ii}, '\n'], ii);
            end
        end
        fprintf('Datafields not part of MFMC specification\n');
        if isempty(extra_datafields)
            fprintf('     None\n');
        else
            for ii = 1:length(extra_datafields)
                fprintf(['%3i. ', extra_datafields{ii}, '\n'], ii);
            end
        end
       
    case 'terse'
        if isempty(errors) && isempty(extra_datafields)
            fprintf('File OK\n');
        else
            fprintf([str, 'File has %i rrrors and %i extra datafields\n'], length(errors), length(extra_datafields));
        end
end

end

