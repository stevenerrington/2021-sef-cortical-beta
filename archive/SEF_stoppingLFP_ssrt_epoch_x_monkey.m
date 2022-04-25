%% Figure 2: p(Burst) over multiple epochs
clear poststop_Figure
% Generate labels for the conditions
 % - trial labels
groupLabels_nostop = repmat({'No-stop'},length(ssrtBeta.timing.nostop.pTrials_burst)*4,1);
groupLabels_canc = repmat({'Canceled'},length(ssrtBeta.timing.canceled.pTrials_burst)*4,1);
 % - epoch labels
eventLabel_fixation = repmat({'1-Fixation'},length(ssrtBeta.timing.nostop.pTrials_burst),1);
eventLabel_SSRT = repmat({'2-SSRT'},length(ssrtBeta.timing.nostop.pTrials_burst),1);
eventLabel_preTone = repmat({'3-Pre-tone'},length(ssrtBeta.timing.nostop.pTrials_burst),1);
eventLabel_postTone = repmat({'4-Post-tone'},length(ssrtBeta.timing.nostop.pTrials_burst),1);

% Define data to use in the plot, split by trial type, and concatenated
% through epochs
burstDataNoStop = [fixationBeta.timing.nostop.pTrials_burst;...
                   ssrtBeta.timing.nostop.pTrials_burst;...
                   pretoneBeta.timing.nostop.pTrials_burst;...
                   posttoneBeta.timing.nostop.pTrials_burst];
burstDataCanc = [fixationBeta.timing.canceled.pTrials_burst;...
                   ssrtBeta.timing.canceled.pTrials_burst;...
                   pretoneBeta.timing.canceled.pTrials_burst;...
                   posttoneBeta.timing.canceled.pTrials_burst];
               
test_eu = [];
test_x = [];
 
euContacts = find(corticalLFPmap.monkeyFlag == 0);
xContacts = find(corticalLFPmap.monkeyFlag == 1);

for ii = 1:8
    

    
    test_eu = [test_eu; euContacts+(509*(ii-1))];
    test_x = [test_x; xContacts+(509*(ii-1))];
    
end

               
% Define data to use in the plot
trialLabels = [groupLabels_nostop;groupLabels_canc];
eventLabels = repmat([eventLabel_fixation;eventLabel_SSRT;eventLabel_preTone;eventLabel_postTone],2,1);
burstData = [burstDataNoStop; burstDataCanc];

clear poststop_Figure
% Input information into gramm function for:
poststop_Figure(1,1) = gramm('x',eventLabels(test_eu),'y',burstData(test_eu),'color',trialLabels(test_eu));
poststop_Figure(1,2) = gramm('x',eventLabels(test_x),'y',burstData(test_x),'color',trialLabels(test_x));

% Set figure properties
poststop_Figure(1,1).stat_summary('geom',{'point','line','black_errorbar'});
poststop_Figure(1,1).axe_property('YLim',[0.1 0.4]); 
poststop_Figure(1,1).no_legend();

poststop_Figure(1,2).stat_summary('geom',{'point','line','black_errorbar'});
poststop_Figure(1,2).axe_property('YLim',[0.1 0.4]); 
poststop_Figure(1,2).no_legend();

poststop_Figure.set_color_options('map',[colors.canceled; colors.nostop]);
poststop_Figure.set_names('y','');

% Generate figure
figure('Renderer', 'painters', 'Position', [100 100 600 250]);
poststop_Figure.draw();
