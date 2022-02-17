
laminarContacts = corticalLFPcontacts.all(corticalLFPcontacts.subset.laminar.all);
euPerpIdx = 1:6; xPerpIdx = 7:16;

%% Convolve, and create trial specific BBDF
parfor lfpIdx = 1:length(laminarContacts)
    
    lfp = laminarContacts(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 696. \n',lfp);
    
    % Load in beta output data for session
    lfp_loadname = ['LFP\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
    lfpOutput = parload([outputDir lfp_loadname])
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    % Stop-signal (latency matched aligned)
    c_temp = []; nc_temp = []; ns_temp = [];  
    
    
    
    for ii = 1:length(executiveBeh.inh_SSD{session})
        if length(executiveBeh.ttm_CGO{session,ii}.C_matched) >= 10 &&...
                length(executiveBeh.ttm_CGO{session,ii}.GO_matched) >= 10 &&...
                length(executiveBeh.ttm_c.NC{session,ii}.all) && 10
            
            c_temp(ii,:) = nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.C_matched, [1000:1000+round(ssrt)]));
            nc_temp(ii,:) = nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_c.NC{session,ii}.all, [1000:1000+round(ssrt)]));
            ns_temp(ii,:) = nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_CGO{session,ii}.GO_matched, [1000:1000+round(ssrt)]));
            
        else
            c_temp(ii,:) = NaN(1,length([1000:1000+round(ssrt)]));
            nc_temp(ii,:) = NaN(1,length([1000:1000+round(ssrt)]));
            ns_temp(ii,:) = NaN(1,length([1000:1000+round(ssrt)]));
        end
        
    end
    
    stopSignal_power_canceled_unmatched(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttx_canc{session}, [1000:1000+round(ssrt)])));
    stopSignal_power_noncanceled_unmatched(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttx.sNC{session}, [1000:1000+round(ssrt)])));
    stopSignal_power_nostop_unmatched(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttx.GO{session}, [1000:1000+round(ssrt)])));
    
    % Get power
    stopSignal_power_canceled(lfpIdx,1) = bandpower(nanmean(c_temp));
    stopSignal_power_noncanc(lfpIdx,1) = bandpower(nanmean(nc_temp));
    stopSignal_power_nostop(lfpIdx,1) = bandpower(nanmean(ns_temp));

    stopSignal_power_all(lfpIdx,1) = bandpower(nanmean(lfpOutput.filteredLFP.beta(:, [1000:1000+round(ssrt)])));
end



%% Compare power at depths
stoppingPower = nan(length(1:17),3,length([14:29]));
stoppingPower_all = nan(length(1:17),1,length([14:29]));

for lfpIdx = 1:length(laminarContacts)
    
    lfp = laminarContacts(lfpIdx);
    session = sessionLFPmap.session(lfp);
    depth = sessionLFPmap.depth(lfp);
    
    stoppingPower(depth,1,session-13) = stopSignal_power_canceled(lfpIdx);
    stoppingPower(depth,2,session-13) = stopSignal_power_noncanc(lfpIdx);
    stoppingPower(depth,3,session-13) = stopSignal_power_nostop(lfpIdx);
    
    stoppingPower_all(depth,1,session-13) = stopSignal_power_all(lfpIdx);    
    
end


for session = 1:16
    stoppingPower_all_norm(:,session) = ...
        stoppingPower_all(:,:,session)./max(stoppingPower_all(:,:,session));
        
    stoppingPower_norm(:,1,session) = stoppingPower(:,1,session)./max(stoppingPower(:,1,session));
    stoppingPower_norm(:,2,session) = stoppingPower(:,2,session)./max(stoppingPower(:,2,session));
    stoppingPower_norm(:,3,session) = stoppingPower(:,3,session)./max(stoppingPower(:,3,session));   
end






%% Generate figure

allStoppingPower = nanmean(stoppingPower_all_norm(:,:),2);
allStoppingPower_Eu = nanmean(stoppingPower_all_norm(:,euPerpIdx),2);
allStoppingPower_X = nanmean(stoppingPower_all_norm(:,xPerpIdx),2);



figure('Renderer', 'painters', 'Position', [100 100 400 200]);
subplot(1,3,1)
plot(allStoppingPower(:,1),[1:17],'color','k'); hold on
set(gca,'YDir','Reverse'); box off; xlim([0 1])
subplot(1,3,2)
plot(allStoppingPower_Eu(:,1),[1:17],'color','k'); hold on
set(gca,'YDir','Reverse'); box off; xlim([0 1])
subplot(1,3,3)
plot(allStoppingPower_X(:,1),[1:17],'color','k'); hold on
set(gca,'YDir','Reverse'); box off; xlim([0 1])


clear averageStoppingPower averageStoppingPowerEu averageStoppingPowerX
averageStoppingPower = nanmean(stoppingPower_norm,3);
averageStoppingPowerEu = nanmean(stoppingPower_norm(:,:,euPerpIdx),3);
averageStoppingPowerX = nanmean(stoppingPower_norm(:,:,xPerpIdx),3);


figure('Renderer', 'painters', 'Position', [100 100 1000 500]);
subplot(1,3,1)
plot(averageStoppingPower(:,1),[1:17],'color',colors.canceled); hold on
plot(averageStoppingPower(:,2),[1:17],'color',colors.noncanc);
plot(averageStoppingPower(:,3),[1:17],'color',colors.nostop);
set(gca,'YDir','Reverse'); box off
xlim([0.1 0.9]); ylim([1 17])

subplot(1,3,2)
plot(averageStoppingPowerEu(:,1),[1:17],'color',colors.canceled); hold on
plot(averageStoppingPowerEu(:,2),[1:17],'color',colors.noncanc);
plot(averageStoppingPowerEu(:,3),[1:17],'color',colors.nostop);
set(gca,'YDir','Reverse'); box off
xlim([0.1 0.9]); ylim([1 17])

subplot(1,3,3)
plot(averageStoppingPowerX(:,1),[1:17],'color',colors.canceled); hold on
plot(averageStoppingPowerX(:,2),[1:17],'color',colors.noncanc);
plot(averageStoppingPowerX(:,3),[1:17],'color',colors.nostop);
set(gca,'YDir','Reverse'); box off
xlim([0.1 0.9]); ylim([1 17])





