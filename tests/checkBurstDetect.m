clear all; clc
getParameters

% Set directories
betaDir = 'D:\projects\2021-sef-cortical-beta\data\lfp\betaBurst\target\';
lfpDir = 'D:\projects\2021-sef-cortical-beta\data\lfp\LFP\target\';

% Set session
session_i = 14;
sessionName = FileNames{session_i};

% Set alignment
event_i = 2;
eventLabel = eventNames{event_i};
alignmentParameters.eventN = event_i;
eventTimes = executiveBeh.TrialEventTimes_Overall{session_i};
fprintf(['Analysing data aligned on ' eventLabel '. \n']);

%% Local field potential filtering
% Get raw data
inputLFP = load(['D:\data\2012_Cmand_EuX\' sessionName '.mat'],...
    'AD1*','AD2*','AD3*','AD4*');
lfpChannels = fieldnames(inputLFP);
lfp_i = 1;

filter = 'all';
filterFreq = filterBands.(filter);
[~, rawData.filteredLFP.(filter)] = tidyRawSignal(inputLFP.(lfpChannels{lfp_i}), ephysParameters, filterFreq,...
    eventTimes, alignmentParameters);
[morletLFP.raw] = convMorletWaveform(rawData.filteredLFP.all,morletParameters);

% Get processed data
proc_file = ['lfp_session' int2str(session_i) '_' lfpChannels{lfp_i} '_betaOutput_' eventLabel];
proc_data = load(fullfile(lfpDir, eventLabel ,proc_file));
[morletLFP.proc] = convMorletWaveform(proc_data.filteredLFP.all,morletParameters);


%% Extract beta-bursts

burstThreshold_i = sessionBLpower(session_i)*burstThreshold;
% Raw 
[betaOutput.raw] = betaBurstCount_LFP(morletLFP.raw, morletParameters);
[betaOutput.raw] = thresholdBursts(betaOutput.raw, burstThreshold_i);

% Processed 
[betaOutput.proc] = betaBurstCount_LFP(morletLFP.proc, morletParameters);
[betaOutput.proc] = thresholdBursts(betaOutput.proc, burstThreshold_i);

% Load-in
load_data = load(fullfile(betaDir,proc_file));
betaOutput.load = load_data.betaOutput;
[betaOutput.load] = thresholdBursts(betaOutput.load, burstThreshold_i);


%% Troubleshooting w. threshold
betaOutput.load = load_data.betaOutput;
[betaOutput.load] = thresholdBursts(betaOutput.load, sessionBLpower(session_i)*6);

trl_i = 167;

set = 'load';
trl_burst_times = []; trl_burst_times = betaOutput.(set).burstData.burstTime{trl_i};
trl_burst_on = []; trl_burst_on = betaOutput.(set).burstData.burstOnset{trl_i}+betaOutput.(set).burstData.burstTime{trl_i};
trl_burst_off = []; trl_burst_off = betaOutput.(set).burstData.burstOffset{trl_i}+betaOutput.(set).burstData.burstTime{trl_i};
trl_burst_freq = []; trl_burst_freq = betaOutput.(set).burstData.burstFrequency{trl_i};

input_c_data = [];
input_c_data = squeeze(morletLFP.proc(trl_i,:,:));

figure; hold on
imagesc(-999:2000,morletParameters.frequencies,input_c_data')
xlim([-999 2000]); ylim([min(morletParameters.frequencies) max(morletParameters.frequencies)])
scatter(trl_burst_times,trl_burst_freq,'ro')

