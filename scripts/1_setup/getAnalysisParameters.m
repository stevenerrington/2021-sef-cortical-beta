morletParameters.samplingFreq = 1000;
morletParameters.frequencies = 15:29;
morletParameters.cycle = 7;

ephysParameters.samplingFreq = 1000;

alignmentParameters.eventN = 3; % Align on stop-signal
alignmentParameters.alignWin = [-1000 2000];
alignmentParameters.time = alignmentParameters.alignWin(1):...
    alignmentParameters.alignWin(end)-1;

filterBands.all = [1 120];
filterBands.delta = [1 4];
filterBands.theta = [4 9];
filterBands.alpha = [9 15];
filterBands.beta = [15 30];
filterBands.lowGamma = [30 60];
filterBands.highGamma = [60 120];
filterBands.allGamma = [30 120];

filterNames = fieldnames(filterBands);

eventNames = {'fixate','target','stopSignal','saccade','sacc_end','tone','reward','sec_sacc'};

mapLFPtoChannel

load(fullfile(dataDir,'baselineLFPpower.mat'));

for session = 1:29
    sessionBLpower(session) = ...
        nanmedian(lfpPowerSession_baseline{session}...
        (LFPRange(session,1):LFPRange(session,2)));
end

burstThreshold = 6;

sessionThreshold = sessionBLpower * burstThreshold;
rng(1)

