
laminarContacts = corticalLFPcontacts.all(corticalLFPcontacts.subset.laminar.all);
euPerpIdx = 1:6; xPerpIdx = 7:16; 
%% Extract prop(beta-bursts)
stoppingBeta.laminar.all = SEF_stoppingLFP_getAverageBurstTime...
    (laminarContacts,executiveBeh.ttx_canc, bayesianSSRT, sessionLFPmap);


%% Convolve, and create trial specific BBDF
parfor lfpIdx = 1:length(laminarContacts)
    
    lfp = laminarContacts(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of 696. \n',lfp);
    
    % Load in beta output data for session
    loadname = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
    betaOutput = parload([outputDir loadname])
    
    lfp_loadname = ['LFP\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
    lfpOutput = parload([outputDir lfp_loadname])
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    midSSDindex = executiveBeh.midSSDindex(session);
    
    % Calculate p(trials) with burst
    [betaOutput] = thresholdBursts(betaOutput.betaOutput, betaOutput.betaOutput.medianLFPpower*6)
    
    % Convolve and get density function
    SessionBDF = BetaBurstConvolver(betaOutput.burstData.burstTime);
    stopSignal_bbdf_noncanceled{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttm_c.NC{session,midSSDindex}.all, :));
    stopSignal_bbdf_canceled{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttm_c.C{session,midSSDindex}.all, :));
    stopSignal_bbdf_nostop{lfpIdx,1} = nanmean(SessionBDF(executiveBeh.ttm_c.GO_C{session,midSSDindex}.all, :));
    
    % Get power
    stopSignal_power_canceled(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_c.C{session,midSSDindex}.all, [1000:1000+round(ssrt)])));
    stopSignal_power_noncanc(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_c.NC{session,midSSDindex}.all, [1000:1000+round(ssrt)])));
    stopSignal_power_nostop(lfpIdx,1) = bandpower...
        (nanmean(lfpOutput.filteredLFP.beta(executiveBeh.ttm_c.GO_C{session,midSSDindex}.all, [1000:1000+round(ssrt)])));
end


%% Compare power at depths
stoppingPower = nan(length(1:17),3,length([14:29]));

for lfpIdx = 1:length(laminarContacts)
    
    lfp = laminarContacts(lfpIdx);
    session = sessionLFPmap.session(lfp);
    depth = sessionLFPmap.depth(lfp);
    
    stoppingPower(depth,1,session-13) = stopSignal_power_canceled(lfpIdx);
    stoppingPower(depth,2,session-13) = stopSignal_power_noncanc(lfpIdx);
    stoppingPower(depth,3,session-13) = stopSignal_power_nostop(lfpIdx);
end





%% Sort BBDF by depth x time x session for plots
timeWindow = [-100:250]+1000;
clear stoppingLaminarBBDF stoppingLaminarBBDF_norm

stoppingLaminarBBDF.canceled = nan(length(1:17),length(timeWindow),length([14:29]));
stoppingLaminarBBDF.noncanc = nan(length(1:17),length(timeWindow),length([14:29]));
stoppingLaminarBBDF.nostop = nan(length(1:17),length(timeWindow),length([14:29]));

for lfpIdx = 1:length(laminarContacts)
    
    lfp = laminarContacts(lfpIdx);
    session = sessionLFPmap.session(lfp);
    depth = sessionLFPmap.depth(lfp);
    
    stoppingLaminarBBDF.canceled(depth,:,session-13) = (stopSignal_bbdf_canceled{lfpIdx,1}(:,timeWindow)*100);
    stoppingLaminarBBDF.noncanc(depth,:,session-13) = (stopSignal_bbdf_noncanceled{lfpIdx,1}(:,timeWindow)*100);
    stoppingLaminarBBDF.nostop(depth,:,session-13) = (stopSignal_bbdf_nostop{lfpIdx,1}(:,timeWindow)*100);
end

for session = 1:16
    
    normValue = nanmax(nanmax([stoppingLaminarBBDF.canceled(:,:,session); stoppingLaminarBBDF.noncanc(:,:,session); stoppingLaminarBBDF.nostop(:,:,session)]));
    stoppingLaminarBBDF_norm.canceled(:,:,session) = stoppingLaminarBBDF.canceled(:,:,session)./normValue;
    stoppingLaminarBBDF_norm.noncanc(:,:,session) = stoppingLaminarBBDF.noncanc(:,:,session)./normValue;
    stoppingLaminarBBDF_norm.nostop(:,:,session) = stoppingLaminarBBDF.nostop(:,:,session)./normValue;
end

%% Create Figure
colormap_name = 'parula';
trialTypeList = {'canceled','noncanc','nostop'};

clear stopping_laminarMean

for trialTypeIdx = 1:length(trialTypeList)
    trialType = trialTypeList{trialTypeIdx};
    
    stopping_laminarMean.(trialType).raw.all = nanmean(stoppingLaminarBBDF_norm.(trialType),3);
    stopping_laminarMean.(trialType).smoothed.all = H_2DSMOOTH(stopping_laminarMean.(trialType).raw.all);
    
    stopping_laminarMean.(trialType).raw.eu = nanmean(stoppingLaminarBBDF.(trialType)(:,:,euPerpIdx),3);
    stopping_laminarMean.(trialType).smoothed.eu = H_2DSMOOTH(stopping_laminarMean.(trialType).raw.eu);
    
    stopping_laminarMean.(trialType).raw.x = nanmean(stoppingLaminarBBDF.(trialType)(:,:,xPerpIdx),3);
    stopping_laminarMean.(trialType).smoothed.x = H_2DSMOOTH(stopping_laminarMean.(trialType).raw.x);
    
end

monkeyList = {'all','eu','x'};
subsetList = {'upper','lower','diff'};

clear bbdfMean
for trialTypeIdx = 1:length(trialTypeList)
    trialType = trialTypeList{trialTypeIdx};
    
    for monkeySelect = 1:length(monkeyList)
        if monkeySelect == 1
            inputBBDF = stoppingLaminarBBDF_norm;
        else
            inputBBDF = stoppingLaminarBBDF;
        end
        
        
        
        if monkeySelect == 1; sessions = 1:size(inputBBDF.(trialType),3); end
        if monkeySelect == 2; sessions = euPerpIdx; end
        if monkeySelect == 3; sessions = xPerpIdx; end
        
        
        for subsetSelect = 1:length(subsetList)
            if subsetSelect == 1 || subsetSelect == 2
                if subsetSelect == 1; depthSubset = 1:8; end
                if subsetSelect == 2; depthSubset = 9:17; end
                
                bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(1,:) =...
                    nanmean(nanmean(inputBBDF.(trialType)(depthSubset,:,sessions),3));
                bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(2,:) =...
                    bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(1,:)-nanstd(nanmean(inputBBDF.(trialType)(depthSubset,:,sessions),3));
                bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(3,:) =...
                    bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(1,:)+nanstd(nanmean(inputBBDF.(trialType)(depthSubset,:,sessions),3));
                
            else
                bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(1,:) =...
                    nanmean(nanmean(inputBBDF.(trialType)(1:8,:,sessions),3))-...
                    nanmean(nanmean(inputBBDF.(trialType)(9:end,:,sessions),3));
                
                bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(2,:) =...
                    bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(1,:)-...
                    nanstd(nanmean(nanmean(inputBBDF.(trialType)(1:8,:,sessions),3))-...
                    nanmean(nanmean(inputBBDF.(trialType)(9:end,:,sessions),3)));
                
                bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(3,:) =...
                    bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(1,:)+...
                    nanstd(nanmean(nanmean(inputBBDF.(trialType)(1:8,:,sessions),3))-...
                    nanmean(nanmean(inputBBDF.(trialType)(9:end,:,sessions),3)));
            end
            
        end
    end
end


plotTime = timeWindow-1000;
subplotCount = 0;

figure('Renderer', 'painters', 'Position', [100 100 900 900]);

for subsetSelect = 1:length(subsetList)
    for monkeySelect = 1:length(monkeyList)
        subplotCount = subplotCount + 1;
        subplot(5, 3, subplotCount)
        
        for trialTypeIdx = 1:length(trialTypeList)
            trialType = trialTypeList{trialTypeIdx};
            
            plot_ci(plotTime,...
                [bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(1,:);...
                bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(2,:);...
                bbdfMean.(subsetList{subsetSelect}).(monkeyList{monkeySelect}).(trialType)(3,:)],...
                'PatchColor', colors.(trialType), 'PatchAlpha', 0.2, 'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', colors.(trialType), ...
                'LineWidth', 0.1, 'LineStyle','-', 'LineColor', colors.(trialType));
            hold on
        end
        xlim([plotTime(1) plotTime(end)])
        
        if subplotCount < 7; ylim([0 0.2]); end
        if subplotCount > 6; ylim([-0.07 0.07]); end
        if subplotCount == 1 || subplotCount == 4; ylim([0.1 0.8]); end
        if subplotCount == 7; ylim([-0.2 0.2]); end
        
        vline(0,'k')
        
    end
end

subplot(5,3,[10 13]);
imagesc(plotTime,1:17,stopping_laminarMean.canceled.smoothed.all);
vline(0,'k'); hline(8.5,'k--'); box off
set(gca,'YDir','reverse'); colormap(colormap_name); colorbar('southoutside')

subplot(5,3,[11 14]);
imagesc(plotTime,1:17,stopping_laminarMean.canceled.smoothed.eu);
vline(0,'k'); hline(8.5,'k--'); box off
set(gca,'YDir','reverse'); colormap(colormap_name); colorbar('southoutside')

subplot(5,3,[12 15]);
imagesc(plotTime,1:17,stopping_laminarMean.canceled.smoothed.x);
vline(0,'k'); hline(8.5,'k--'); box off
set(gca,'YDir','reverse'); colormap(colormap_name); colorbar('southoutside')

