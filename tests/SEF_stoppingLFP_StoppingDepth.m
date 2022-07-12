monkeyList = {'all','eu','x'};

for monkeyIdx = 1:length(monkeyList)
    monkeyID = monkeyList{monkeyIdx};
    
    clear laminarContacts session depth
    laminarContacts = corticalLFPcontacts.all(corticalLFPcontacts.subset.laminar.(monkeyID));
    
    
    session = sessionLFPmap.session(laminarContacts);
    depth = sessionLFPmap.depth(laminarContacts);
    
    
    clear lfpIdx
    lfpIdx.upperContacts = ismember(depth,[1:8]); lfpIdx.lowerContacts = ismember(depth,[9:17]);
    lfpIdx.outerContacts = ismember(depth,[1:4,13:17]); lfpIdx.middleContacts = ismember(depth,[5:12]);
    
    
    laminar_pBurst.(monkeyID).upper = stoppingBeta.laminar.all(lfpIdx.upperContacts,:);
    laminar_pBurst.(monkeyID).lower = stoppingBeta.laminar.all(lfpIdx.lowerContacts,:);
    laminar_pBurst.(monkeyID).outer = stoppingBeta.laminar.all(lfpIdx.outerContacts,:);
    laminar_pBurst.(monkeyID).middle = stoppingBeta.laminar.all(lfpIdx.middleContacts,:);    
    
end

% clear testfigure inputLFP groupLabels epochLabels burstData
% monkeyID = 'all'; section1 = 'upper'; section2 = 'lower';
% 
% groupLabels = [repmat({section1},size(laminar_pBurst.(monkeyID).(section1),1),1);...
%     repmat({section2},size(laminar_pBurst.(monkeyID).(section2),1),1)];
% epochLabels = groupLabels;
% burstData = [laminar_pBurst.(monkeyID).(section1).pTrials_burst; laminar_pBurst.(monkeyID).(section2).pTrials_burst];
% 
% testfigure(1,1)= gramm('x',groupLabels,'y',burstData,'color',epochLabels);
% testfigure(1,1).stat_summary('geom',{'bar','black_errorbar'},'type','sem');
% % testfigure(1,1).geom_jitter('alpha',0.1,'dodge',0.75);
% testfigure(1,1).no_legend(); 
% testfigure(1,1).axe_property('YLim',[0 0.15]);
% 
% % Figure parameters & settings
% testfigure.set_names('y','');
% testfigure.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);
% 
% figure('Position',[100 100 350 350]);
% testfigure.draw();
% 
% 
% 
% 
% 


%%

laminarContacts = corticalLFPcontacts.all(corticalLFPcontacts.subset.laminar.x);
depth = sessionLFPmap.depth(laminarContacts);

normStopSignal_power = nan(length(1:17),2,length([14:29]));

for session = 14:29
    sessionLFP = find(sessionLFPmap.session(laminarContacts) == session);
    
    normStopSignal_power(1:max(sessionLFPmap.depth(laminarContacts(sessionLFP))), :,session-13) = ...
        [sessionLFPmap.depth(laminarContacts(sessionLFP)),...
        stopSignal_power(sessionLFP)./max(stopSignal_power(sessionLFP))];
    
end

normStopSignal_powerMean = nanmean(normStopSignal_power,3);

plot(normStopSignal_powerMean(:,2),normStopSignal_powerMean(:,1))
set(gca,'YDir','Reverse')














