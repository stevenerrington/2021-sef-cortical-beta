
monkey = {'eu','x'};

yAxis = {[0.0005 0.0045], [0.0000 0.0025], [0.0005 0.0020], [0.0005 0.0030], [0.0000 0.0040], [0.0000 0.0040];...
    [0.0010 0.0020], [0.0005 0.0020], [0.0005 0.0020], [0.0005 0.0020], [0.0005 0.0020], [0.0005 0.0030]};

%% Generate Figure
for monkeyIdx = 1:2
    
    inputContacts = [];
    inputContacts = corticalLFPcontacts.subset.(monkey{monkeyIdx});
    
    clear testfigure
    time = [-1000:2000];
    ssrt_time = [-500:1000];

    % Fixation aligned
    testfigure(1,1)=gramm('x',time,'y',[bbdf_canceled_fixation(inputContacts);...
        bbdf_nostop_fixation(inputContacts);bbdf_noncanceled_fixation(inputContacts)],...
        'color',[repmat({'Canceled'},length(bbdf_canceled_fixation(inputContacts)),1);...
        repmat({'No-stop'},length(bbdf_nostop_fixation(inputContacts)),1);...
        repmat({'Non-canceled'},length(bbdf_noncanceled_fixation(inputContacts)),1)]);
    
    % Target aligned
    testfigure(1,2)=gramm('x',time,'y',[bbdf_canceled_target(inputContacts);...
        bbdf_nostop_target(inputContacts);bbdf_noncanceled_target(inputContacts)],...
        'color',[repmat({'Canceled'},length(bbdf_canceled_target(inputContacts)),1);...
        repmat({'No-stop'},length(bbdf_nostop_target(inputContacts)),1);...
        repmat({'Non-canceled'},length(bbdf_noncanceled_target(inputContacts)),1)]);
    
    % Stop-Signal aligned
    testfigure(1,3)=gramm('x',time,'y',[bbdf_canceled_stopSignal(inputContacts);...
        bbdf_nostop_stopSignal(inputContacts);bbdf_noncanceled_stopSignal(inputContacts)],...
        'color',[repmat({'Canceled'},length(bbdf_canceled_stopSignal(inputContacts)),1);...
        repmat({'No-stop'},length(bbdf_nostop_stopSignal(inputContacts)),1);...
        repmat({'Non-canceled'},length(bbdf_noncanceled_stopSignal(inputContacts)),1)]);
    
    % SSRT aligned
    testfigure(2,1)=gramm('x',ssrt_time,'y',[bbdf_canceled_ssrt(inputContacts);...
        bbdf_nostop_ssrt(inputContacts)],...
        'color',[repmat({'Canceled'},length(bbdf_canceled_ssrt(inputContacts)),1);...
        repmat({'No-stop'},length(bbdf_nostop_ssrt(inputContacts)),1)]);
    
    % Saccade aligned
    testfigure(2,2)=gramm('x',time,'y',[bbdf_noncanceled_saccade(inputContacts);...
        bbdf_nostop_saccade(inputContacts)],'color',...
        [repmat({'Non-canceled'},length(bbdf_noncanceled_saccade(inputContacts)),1);...
        repmat({'No-stop'},length(bbdf_nostop_saccade(inputContacts)),1)]);
    
    % Tone aligned
    testfigure(2,3)=gramm('x',time,'y',[bbdf_canceled_tone(inputContacts);...
        bbdf_nostop_tone(inputContacts);bbdf_noncanceled_tone(inputContacts)],...
        'color',[repmat({'Canceled'},length(bbdf_canceled_tone(inputContacts)),1);...
        repmat({'No-stop'},length(bbdf_nostop_tone(inputContacts)),1);...
        repmat({'Non-canceled'},length(bbdf_noncanceled_tone(inputContacts)),1)]);
    
    % GRAMM Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    testfigure(1,1).stat_summary();
    testfigure(1,1).axe_property('XLim',[-800 800]);
    testfigure(1,1).geom_vline('xintercept',0,'style','k-');
    testfigure(1,1).axe_property('YLim',yAxis{monkeyIdx,1});
    testfigure(1,1).no_legend();
    
    testfigure(1,2).stat_summary();
    testfigure(1,2).axe_property('XLim',[-200 600]);
    testfigure(1,2).geom_vline('xintercept',0,'style','k-');
    testfigure(1,2).axe_property('YLim',yAxis{monkeyIdx,2});
    testfigure(1,2).no_legend();
    
    testfigure(1,3).stat_summary();
    testfigure(1,3).axe_property('XLim',[-200 200]);
    testfigure(1,3).geom_vline('xintercept',0,'style','k-');
    testfigure(1,3).axe_property('YLim',yAxis{monkeyIdx,3});
    testfigure(1,3).no_legend();
    
    testfigure(2,1).stat_summary();
    testfigure(2,1).axe_property('XLim',[-200 800]);
    testfigure(2,1).geom_vline('xintercept',0,'style','k-');
    testfigure(2,1).axe_property('YLim',yAxis{monkeyIdx,4});
    testfigure(2,1).no_legend();
    
    testfigure(2,2).stat_summary();
    testfigure(2,2).axe_property('XLim',[-200 600]);
    testfigure(2,2).geom_vline('xintercept',0,'style','k-');
    testfigure(2,2).axe_property('YLim',yAxis{monkeyIdx,5});
    testfigure(2,2).no_legend();
    
    testfigure(2,3).stat_summary();
    testfigure(2,3).axe_property('XLim',[-600 200]);
    testfigure(2,3).geom_vline('xintercept',0,'style','k-');
    testfigure(2,3).axe_property('YLim',yAxis{monkeyIdx,6});
    testfigure(2,3).no_legend();
    
    testfigure.set_names('y','');
    testfigure(1,1).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);
    testfigure(1,2).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);
    testfigure(1,3).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);
    testfigure(2,1).set_color_options('map',[colors.canceled;colors.nostop]);
    testfigure(2,2).set_color_options('map',[colors.nostop;colors.noncanc]);
    testfigure(2,3).set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);
    
    figure('Renderer', 'painters', 'Position', [100 100 800 600]);
    testfigure.draw();
end
