warning off
dataDir = ['C:\Users\Steven\Desktop\tempTEBA\dataRepo\2015_ChoiceCmand_BrJo\'];

%% Get all session details/names/files
% Get directory where data is stored
load('C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingLFP\processing\betaBurst\FEF\FEF_FileNames.mat')

sessionInformation = table();

% Go through files and get relevant details.
for sessionIdx = 1:length(FEF_FileNames)
    fprintf('Extracting session information from session %i of %i... \n',sessionIdx,length(FEF_FileNames));
    clear sessionName sessionBehData
    
    sessionName = FEF_FileNames{sessionIdx};
    
    try
        sessionBehData = load([dataDir sessionName]);
        sessionInformation.sessionName(sessionIdx,:) = sessionName; % Session name
        sessionInformation.directory(sessionIdx,:) = dataDir; % Directory
        sessionInformation.sessionIdx(sessionIdx,:) = sessionIdx; % Session idx (arbitary)
        sessionInformation.task(sessionIdx,:) = {sessionBehData.SessionData.taskName}; % Task name
        sessionInformation.hemisphere(sessionIdx,:) = {sessionBehData.SessionData.hemisphere}; % Hemisphere of recording
        sessionInformation.date(sessionIdx,:) = sessionBehData.SessionData.date; % Date of recording
        
    catch
        continue
    end
end


% Find countermanding behavior and LFP
countermandingSessions_beh = cellstr(sessionInformation.sessionName(strcmp(sessionInformation.task,'ChoiceCountermanding'),:));
countermandingSessions_LFP = cellfun(@(x) insertAfter(x,8,"_lfp"),countermandingSessions_beh,'UniformOutput',false);


%% Set behavioral parameters/labels/etc for this data set
nostop_trialLabels = {'goCorrectTarget','goCorrectDistractor'};
noncanceled_trialLabels = {'stopIncorrectTarget','stopIncorrectDistractor'};
canceled_trialLabels = {'stopCorrect'};

%% Get behavioral data from this set
clear sessionList
beh_sessionList = countermandingSessions_beh;

for sessionIdx = 1:length(beh_sessionList)
    clear sessionName sessionBehData
    
    sessionName = beh_sessionList{sessionIdx};
    sessionBehData = load([dataDir sessionName]);
    fprintf('Extracting behavior from session %i of %i... \n',sessionIdx,length(beh_sessionList));
    
    if iscell(sessionBehData.rewardOn)
        sessionBehData.rewardOn = cell2mat(sessionBehData.rewardOn);
    end
    
    trialEventTimes_all{sessionIdx} = [sessionBehData.fixWindowEntered, sessionBehData.targOn,...
        sessionBehData.ssd, sessionBehData.responseOnset, NaN(length(sessionBehData.ssd),1),...
        sessionBehData.toneOn, sessionBehData.rewardOn];
    
    ttx{sessionIdx}.canceled = find(cell2mat(cellfun(@(x)...
        ismember(x, lower(canceled_trialLabels)), lower(sessionBehData.trialOutcome), 'UniformOutput', 0)));
    
    ttx{sessionIdx}.noncanceled = find(cell2mat(cellfun(@(x)...
        ismember(x, lower(noncanceled_trialLabels)), lower(sessionBehData.trialOutcome), 'UniformOutput', 0)));
    
    ttx{sessionIdx}.nostop = find(cell2mat(cellfun(@(x)...
        ismember(x, lower(nostop_trialLabels)), lower(sessionBehData.trialOutcome), 'UniformOutput', 0)));
    
end

%% Get stopping behavior

BEESTtable_allSessions = table();

for sessionIdx = 1:length(beh_sessionList)
    clear sessionName sessionBehData
    
    sessionName = beh_sessionList{sessionIdx};
    sessionBehData = load([dataDir sessionName]);
    fprintf('Extracting stopping behavior from session %i of %i... \n',sessionIdx,length(beh_sessionList));
    
    
    % Classic stopping behavior
    inh_data{sessionIdx}.inh_SSD = unique(sessionBehData.ssd(~isnan(sessionBehData.ssd)))';
    
    for ssdIdx = 1:length(inh_data{sessionIdx}.inh_SSD)
        inh_data{sessionIdx}.inh_xTrls{ssdIdx} = find(sessionBehData.ssd == inh_data{sessionIdx}.inh_SSD(ssdIdx));
        inh_data{sessionIdx}.inh_nTrls(ssdIdx) = length(find(sessionBehData.ssd == inh_data{sessionIdx}.inh_SSD(ssdIdx)));
        inh_data{sessionIdx}.inh_nCanc(ssdIdx) = sum(ismember(ttx{sessionIdx}.canceled,find(sessionBehData.ssd == inh_data{sessionIdx}.inh_SSD(ssdIdx))));
        inh_data{sessionIdx}.inh_nNoncanc(ssdIdx) = sum(ismember(ttx{sessionIdx}.noncanceled,find(sessionBehData.ssd == inh_data{sessionIdx}.inh_SSD(ssdIdx))));
        inh_data{sessionIdx}.inh_pNC(ssdIdx) = inh_data{sessionIdx}.inh_nNoncanc(ssdIdx)/...
            inh_data{sessionIdx}.inh_nTrls(ssdIdx);
    end
    
    [inh_data{sessionIdx}.weibullParameters,~,inh_data{sessionIdx}.weibullFit(:,1),inh_data{sessionIdx}.weibullFit(:,2)] =...
        SEF_LFPToolbox_FitWeibull(inh_data{sessionIdx}.inh_SSD, inh_data{sessionIdx}.inh_pNC, inh_data{sessionIdx}.inh_nTrls);
    
    
    % BEESTS stopping behavior
    
    subj_idx = repmat(sessionIdx,length(sessionBehData.trialOnset),1);
    ss_presented = double(~isnan(sessionBehData.ssd));
    inhibited = double([ismember(1:length(sessionBehData.trialOnset),ttx{sessionIdx}.canceled)]');
    ssd = sessionBehData.ssd;
    rt = sessionBehData.rt;
    
    inhibited(ss_presented == 0) = -999;
    ssd(ss_presented == 0) = -999;
    rt(inhibited == 1) = -999;
    
    
    BEESTtable{sessionIdx} = table(subj_idx,ss_presented,inhibited,ssd,rt);
    BEESTtable{sessionIdx}(isnan(BEESTtable{sessionIdx}.rt),:) = [];
    BEESTtable{sessionIdx}(BEESTtable{sessionIdx}.rt > 1500,:) = [];
    
    BEESTtable_allSessions = [BEESTtable_allSessions;BEESTtable{sessionIdx}];
    
end

%
% % Output to BEESTs for analysis
% writetable(BEESTtable_allSessions,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\behavior\BEEST\FEF_JoBeh.csv', 'WriteRowNames',true)
%
% % Get SSRT and trigger failures from BEEST




%% Look at LFP's
lfp_sessionList = countermandingSessions_LFP;

window = [-500 1000];
fefEvents = {'targOn','stopSignalOn','responseOnset'};
transEvents = {'target','stopSignal','saccade'};
count = 0;

for sessionIdx = 1:length(lfp_sessionList)
    
    try
        sessionBehName = beh_sessionList{sessionIdx}; sessionBehData = load([dataDir sessionBehName]);
        sessionLFPName = lfp_sessionList{sessionIdx}; sessionLFPData = load([dataDir sessionLFPName]);
        fprintf('Extracting LFP data from session %i of %i... \n',sessionIdx,length(lfp_sessionList));
        
        lfpChannels = fieldnames(sessionLFPData);
        
        for lfpIdx = 1%:length(lfpChannels)
            lfpChannel = lfpChannels{lfpIdx};
            
            for eventIdx = 2%1:3
                alignEvent = fefEvents{eventIdx};
                eventLabel = transEvents{eventIdx};
                
                clear filteredLFP
                
                for trial = 1:length(sessionBehData.(alignEvent))
                    alignWin = sessionBehData.(alignEvent)(trial);
                    
                    if isnan(alignWin)
                        filteredLFP(trial,:) = nan(1,range(window)+1);
                    else
                        clear inputData
                        inputData = sessionLFPData.(lfpChannel)...
                            {trial, 1}([alignWin + window(1): alignWin + window(2)],1);
                        
                        filter = 'all'; filterFreq = filterBands.(filter);
                        filteredLFP(trial,:) = SEF_LFP_Filter(inputData,...
                            filterFreq(1), filterFreq(2), ephysParameters.samplingFreq);
                    end
                end
                
                [morletLFP] = convMorletWaveform(filteredLFP,morletParameters);
                [betaOutput] = betaBurstCount_LFP(morletLFP, morletParameters);
                
                savename_betaBurst = ['betaBurst\FEF\lfp_session' lfp_sessionList{sessionIdx} '_' lfpChannel '_betaOutput_' eventLabel];
                parsave_betaburst([outputDir savename_betaBurst], betaOutput)
            end
            
        end
        
        
    catch
        count = count+1;
        errorLFPsessions{count} = lfp_sessionList{sessionIdx};
    end
    
end


%% TO BE COMPLETED!
% Get behavioral information
ssrt = bayesianSSRT.ssrt_mean(session);

trials = [];
trials.canceled = executiveBeh.ttx_canc{session};
trials.noncanceled = executiveBeh.ttx.sNC{session};
trials.nostop = executiveBeh.ttx.GO{session};

% Calculate p(trials) with burst
[betaOutput] = thresholdBursts(betaOutput, betaOutput.medianLFPpower*6);
[pTrl_burst] = ssdBurstCount_LFP(betaOutput, ssrt, trials, session, executiveBeh);



