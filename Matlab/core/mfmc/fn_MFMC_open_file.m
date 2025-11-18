function MFMC = fn_MFMC_open_file(fname, varargin)
%SUMMARY
%   Opens MFMC file for reading or writing. If file does not exist it is
%   created. If file exists but non-existent root path is specified, the
%   path is created in the file.
%INPUTS
%   fname - full path and name of file (path is needed to avoid erratic
%   behaviour due to way Matlab HDF5 functions work)
%   [root_path] - optional location of MFMC data in file. Default is root,
%   i.e. '/'
%   [open_file_only] - open file if it exists, don't create a new one if it
%   doesn't and don't check for MFMC data.
%OUTPUTS
%   MFMC - structure for subsequent calls to MFMC functions with fields:
%       .fname - file name
%       .root_path - location of MFMC data in file
%       .TYPE = 'MFMC'
%       .VERSION = '2.0.0'
%       .probe_name_template - template used for automatically generated
%       probe groups
%       .sequence_name_template - template used for automatically generated
%       sequence groups
%       .law_name_template - template used for automatically generated
%       focal law groups
%--------------------------------------------------------------------------

MFMC.fname = fname;
MFMC.probe_name_template = 'PROBE<%i>';
MFMC.sequence_name_template = 'SEQUENCE<%i>';
MFMC.law_name_template = 'LAW<%i>';
MFMC.TYPE = 'MFMC';
MFMC.VERSION = '2.0.0';

if length(varargin) < 1
    MFMC.root_path = '/';
else
    if isempty(varargin{1})
        MFMC.root_path = '/';
    else
        MFMC.root_path = varargin{1};
    end
    if ~strcmp(MFMC.root_path(end), '/')
        MFMC.root_path = [MFMC.root_path, '/'];
    end
end

if length(varargin) < 2
    open_file_only = 0;
else
    open_file_only = varargin{2};
end

%If file does not exist, create it
if ~exist(fname, 'file')
    if open_file_only
        warning('File does not exist.');
        return
    end
    fcpl = H5P.create('H5P_FILE_CREATE');
    fapl = H5P.create('H5P_FILE_ACCESS');
    file_id = H5F.create(MFMC.fname, 'H5F_ACC_TRUNC', fcpl, fapl);

    %Create root attributes
    fn_hdf5_create_entry(MFMC, MFMC.fname, [MFMC.root_path, 'TYPE'],    'M', 'A');
    fn_hdf5_create_entry(MFMC, MFMC.fname, [MFMC.root_path, 'VERSION'], 'M', 'A');
    H5F.close(file_id);
else
    %Throw error if reading non-hdf5 file
    assert(H5F.is_hdf5(fname), "File is not HDF5 encoded."); 
end

%Check for correct attributes signifying mfmc file
if ~open_file_only
    a = fn_hdf5_read_to_matlab(MFMC.fname, MFMC.root_path);
    assert(isfield(a, 'TYPE') && strcmp(a.TYPE, MFMC.TYPE), "Root path exists but does not contain MFMC data");
end

end

