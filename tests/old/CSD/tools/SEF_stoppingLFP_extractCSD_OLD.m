% 3D matrix channel x sample x trial

perpSessions = 14:29;
for sessionIdx = 1:length(perpSessions)
    session = perpSessions(sessionIdx);
    fprintf('Analysing session %d of %d... \n', sessionIdx, length(perpSessions));
    
    
    clear laminarLFPidx
    laminarLFPidx = find(sessionLFPmap.session == session);% & sessionLFPmap.laminarFlag == 1 & sessionLFPmap.cortexFlag == 1);
    %
    %     % Just mid SSD
    %     trials.canceled = executiveBeh.ttm_c.C{session, executiveBeh.midSSDindex(session)}.all;
    %     trials.nostop = executiveBeh.ttm_c.GO_C{session, executiveBeh.midSSDindex(session)}.all;
    %     trials.noncanceled = executiveBeh.ttm_c.NC{session, executiveBeh.midSSDindex(session)}.all;
    %     trials.noncanceled =  trials.noncanceled(...
    %         ismember(trials.noncanceled,executiveBeh.ttx.sNC{session}));
    %
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    nTrials = length(executiveBeh.TrialEventTimes_Overall{session});
    
    parfor lfpIdx = 1:length(laminarLFPidx)
        lfpName = sessionLFPmap.channelNames{laminarLFPidx(lfpIdx)};
        loadname = ['LFP\stopSignal\lfp_session' int2str(session) '_' lfpName '_betaOutput_stopSignal'];
        importLFP = parload([outputDir loadname]);
        test{lfpIdx} = importLFP.filteredLFP.beta;
    end
    
    clear testA
    for lfpIdx = 1:length(laminarLFPidx)
        for trl = 1:nTrials
            testA(lfpIdx,:,trl) = test{lfpIdx}(trl,:,:);
        end
    end
    
    CSDsetup_session{sessionIdx} = testA;
    
end


parfor sessionIdx = 1:length(perpSessions)
    fprintf('Analysing session %d of %d... \n', sessionIdx, length(perpSessions));
    
    CSD_session{sessionIdx} = SUITE_LAM(CSDsetup_session{sessionIdx},'spc',150);
end

clear a
a = nan(20,3000,length(perpSessions));
for sessionIdx = 1:length(perpSessions)

    laminarLFPidxA = find(sessionLFPmap.session == session);
    laminarLFPidxB = find(sessionLFPmap.session == session & sessionLFPmap.laminarFlag == 1 & sessionLFPmap.cortexFlag == 1);
    
    startCortexChannel = find(diff(ismember(laminarLFPidxA,laminarLFPidxB)) == 1)-1;
    endCortexChannel = find(diff(ismember(laminarLFPidxA,laminarLFPidxB)) == -1)+1;
    
    a(1:length(startCortexChannel:endCortexChannel),:,sessionIdx) = ...
        nanmean(CSD_session{sessionIdx}.CSD(startCortexChannel:endCortexChannel,...
        :,executiveBeh.ttx.NC{perpSessions(sessionIdx)}),3);
end


f_h = figure; hold on;
ax1 = subplot(1,1,1)
P_CSD_BASIC(nanmean(a,3), [-1000:2000], [-100 200], f_h, ax1)
vline(0,'k'); vline(mean(bayesianSSRT.ssrt_mean(perpSessions)),'k--')




