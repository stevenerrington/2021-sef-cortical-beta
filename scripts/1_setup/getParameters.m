% Load relevant behavioral data
if ispc()
    driveDir = 'D:\projects\';
    rootDir = 'D:\projects\2021-sef-cortical-beta\';
    dataDir = fullfile(rootDir,'data');    
else
    driveDir = '/Volumes/Alpha/';
    rootDir = '/Volumes/Alpha/projects/2021-sef-cortical-beta/';
    dataDir = fullfile(rootDir,'data');
end



load(fullfile(dataDir, 'behavior','bayesianSSRT'));  % Bayesian SSRT estimates
load(fullfile(dataDir, 'behavior', 'executiveBeh'));  % Behavioural data
load(fullfile(dataDir, 'behavior', 'FileNames'));    % Filenames

getColors;                               % Get color schemes for figures
mapLFPtoChannel                          % Link LFP to recording channel on probe
getAnalysisParameters;                   % Setup frequencies, channels, site power
getLaminarParameters;                    % Define laminar layers, channels, etc...