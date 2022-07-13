clear all; clc

%% SETUP ANALYSIS & PARAMETERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup directories, get session information, and import
% pre-processed/pre-extracted behavioral information.

% Load relevant behavioral data
dataDir = 'D:\projectCode\project_stoppingLFP\data\';
outputDir = 'D:\projectCode\project_stoppingLFP\data\monkeyLFP\';

load([dataDir 'behavior\bayesianSSRT']); load([dataDir 'behavior\executiveBeh']); load([dataDir 'behavior\FileNames'])

% Run parameter scripts
getColors; getAnalysisParameters; mapLFPtoChannel


%% LFP PREPROCESSING ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ***  Processing ***********************************************
% Extract neurophysiological data for EEG. Filter data for each session
% into the beta band, find beta bursts, find proportion of trials with burst.
SEF_stoppingLFP_getData
SEF_stoppingLFP_getData_bbdf

%% STOPPING ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ***************************************************************
% Results: Countermanding performance and neural sampling
%           & cortical beta-bursts index response inhibition...
% (a) Get proportion of beta-bursts after SSD
SEF_stoppingLFP_pTrlBetaBurst; SEF_stoppingLFP_restingBetaProportion
SEF_stoppingLFP_BBDFprimary; SEF_stoppingLFP_BBDFmonkeysep

% (b) Get beta-burst metrics (i.e. onset, freq, duration, etc..) and
%      correlations with SSRT metrics. 
SEF_stoppingLFP_ssrtXburst

% (c) Look at the neurometric properties of beta-bursts
SEF_stoppingLFP_Neurometric; SEF_stoppingLFP_NeurometricFig

%% ERROR CONTROL ANALYSIS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ***************************************************************
SEF_stoppingLFP_Error

%% PROACTIVE CONTROL ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ***************************************************************
SEF_stoppingLFP_trialHistory

%% CSD/LAMINAR    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SEF_stoppingLFP_depthPower
SEF_stoppingLFP_extractCSD % CSD and PSD
SEF_stoppingLFP_depthBursts
SEF_stoppingLFP_depthBBDF


%% EEG/LFP COINCIDENCE
SEF_stoppingLFP_EEGxLFPxJPSTH
SEF_stoppingLFP_EEGxLFP_BBDF
SEF_stoppingLFP_EEGxLFP_xCorr



