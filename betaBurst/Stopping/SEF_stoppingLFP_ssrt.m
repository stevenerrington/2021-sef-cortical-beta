%% Calculate proportion of trials with burst
parfor lfpIdx = 1:length(corticalLFPcontacts.all)
    
    lfp = corticalLFPcontacts.all(lfpIdx)
    session = sessionLFPmap.session(lfp);
    
    % Beh extraction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing LFP number %i of %i. \n',lfpIdx, length(corticalLFPcontacts.all));
    
    % Load in beta output data for session
    loadname = ['betaBurst\stopSignal\lfp_session' int2str(session) '_' sessionLFPmap.channelNames{lfp} '_betaOutput_stopSignal'];
    tempIn = parload([outputDir loadname]);
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    nTrls = [];
    for ssdIdx = 1:length(executiveBeh.inh_SSD{session})
        nTrls(session,ssdIdx) = length(executiveBeh.ttm_CGO{session,ssdIdx}.C_unmatched);
    end
    
    % Get behavioral values
    validSSDidx = find(nTrls(session,:) >= 10);
    validSSDvalue = executiveBeh.inh_SSD{session}(validSSDidx);
    validpNCvalue = 1-executiveBeh.inh_pNC{session}(validSSDidx);
    validnTrvalue = executiveBeh.inh_trcount_SSD{session}(validSSDidx);
    nSSDs = length(validSSDvalue);
    
    
    % Ephys extraction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for LFPthreshold = 6
        [betaOutput] = thresholdBursts(tempIn.betaOutput,...
            tempIn.betaOutput.medianLFPpower*LFPthreshold);
        
        for ssdIdx = 1:nSSDs
            ssd = validSSDidx(ssdIdx);
            trials = executiveBeh.ttm_CGO{session,ssd}.C_unmatched;
            
            burstFlag = [];
            for ii = 1:length(trials)
                burstFlag(ii,1) =...
                    sum(betaOutput.burstData.burstTime{trials(ii)} >...
                    bayesianSSRT.ssrt_mean(session) &...
                    betaOutput.burstData.burstTime{trials(ii)} <= ...
                    bayesianSSRT.ssrt_mean(session)+200) > 0 ;
            end
            
            % Find the proportion of bursts observed at a given SSD
            lfp_ssrt_pBurst{lfpIdx,1}(ssdIdx) = mean(burstFlag);
            
        end
        
        % "Export" data used to create Weibull neuro- and psycho- metric
        % function
        lfp_ssrt_SSD{lfpIdx,1} = validSSDvalue;
        lfp_ssrt_pNC{lfpIdx,1} = validpNCvalue;
        lfp_ssrt_nTr{lfpIdx,1} = validnTrvalue;
    end
    
end

ssrt_pnc_all = table();

for lfpIdx = 1:length(corticalLFPcontacts.all)
    clear lfp session pBurst pNC SSD monkey
    
    lfp = repmat(corticalLFPcontacts.all(lfpIdx),length(lfp_ssrt_pBurst{lfpIdx,1}'),1);
    session = repmat(sessionLFPmap.session(corticalLFPcontacts.all(lfpIdx)),length(lfp_ssrt_pBurst{lfpIdx,1}'),1);
    
    pBurst = lfp_ssrt_pBurst{lfpIdx,1}';
    pNC = 1-lfp_ssrt_pNC{lfpIdx,1}';
    SSD = lfp_ssrt_SSD{lfpIdx,1}';
    monkey = repmat({executiveBeh.nhpSessions.monkeyNameLabel{session(1)}},length(lfp_ssrt_pBurst{lfpIdx,1}'),1);
    
    ssrt_pnc_all = [ssrt_pnc_all;  table(lfp, session, pBurst, pNC, SSD, monkey)];
end



%% Set up figure
clear ssrt_pnc_fig sessions
% close all
% Get input data:

%   Mean burst time and SSRT relationship
ssrt_pnc_fig(1,1)=gramm('x',ssrt_pnc_all.pNC(:),'y',ssrt_pnc_all.pBurst(:));
ssrt_pnc_fig(1,2)=gramm('x',ssrt_pnc_all.pNC(strcmp(ssrt_pnc_all.monkey,'Euler')),'y',ssrt_pnc_all.pBurst(strcmp(ssrt_pnc_all.monkey,'Euler')));
ssrt_pnc_fig(1,3)=gramm('x',ssrt_pnc_all.pNC(strcmp(ssrt_pnc_all.monkey,'Xena')),'y',ssrt_pnc_all.pBurst(strcmp(ssrt_pnc_all.monkey,'Xena')));

alphaLevel = 0.1;
%Generalized linear model fit
% ssrt_pnc_fig(1,1).stat_glm('fullrange',true,'disp_fit',true); ssrt_pnc_fig(1,1).geom_point('alpha',alphaLevel); 
% ssrt_pnc_fig(1,2).stat_glm('fullrange',true,'disp_fit',true); ssrt_pnc_fig(1,2).set_color_options('map',colors.euler); ssrt_pnc_fig(1,2).geom_point('alpha',alphaLevel);
% ssrt_pnc_fig(1,3).stat_glm('fullrange',true,'disp_fit',true); ssrt_pnc_fig(1,3).set_color_options('map',colors.xena); ssrt_pnc_fig(1,3).geom_point('alpha',alphaLevel); 

ssrt_pnc_fig(1,1).stat_summary('bin_in',5,'geom',{'line','black_errorbar','point'})
ssrt_pnc_fig(1,2).stat_summary('bin_in',10,'geom',{'line','black_errorbar','point'}); ssrt_pnc_fig(1,2).set_color_options('map',colors.euler)
ssrt_pnc_fig(1,3).stat_summary('bin_in',5,'geom',{'line','black_errorbar','point'}); ssrt_pnc_fig(1,3).set_color_options('map',colors.xena)

ssrt_pnc_fig(1,:).set_names('x','P(Respond | Stop-Signal)','y','P(Bursts)');
ssrt_pnc_fig(1,:).axe_property('XLim',[0 1]); ssrt_pnc_fig(1,:).axe_property('YLim',[0 0.3]);

figure('Renderer', 'painters', 'Position', [100 100 800 300]);
ssrt_pnc_fig.draw();


