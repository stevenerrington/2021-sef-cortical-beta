
%% Load in pre-processed burst information
% Set load directory
loadDir = fullfile(dataDir,'burst');

% Load in all key burst data across all epochs
load(fullfile(loadDir, 'burstData_fixation'),'fixationBeta')
load(fullfile(loadDir, 'burstData_target'),'targetBeta')
load(fullfile(loadDir, 'burstData_stopping'),'stoppingBeta')
load(fullfile(loadDir, 'burstData_ssrt'),'ssrtBeta')
load(fullfile(loadDir, 'burstData_pretone'),'pretoneBeta')
load(fullfile(loadDir, 'burstData_posttone'),'posttoneBeta')
load(fullfile(loadDir, 'burstData_earlyError'),'errorBeta_early')
load(fullfile(loadDir, 'burstData_lateError'),'errorBeta_late')
