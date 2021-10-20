burstVolumes = [stoppingBeta.timing.canceled.mean_burstVolume;...
stoppingBeta.timing.noncanceled.mean_burstVolume;...
stoppingBeta.timing.nostop.mean_burstVolume];

inputTimes = [burstVolumes];

epochLabels = [repmat({'Volume'},length(burstVolumes),1)];

trlLabels = repmat([repmat({'Canceled'},509,1);...
    repmat({'Noncanceled'},509,1);...
    repmat({'No-Stop'},509,1)],1,1);

clear g
%Averages with confidence interval
g(1,1)= gramm('x',trlLabels,...
    'y',inputTimes,...
    'color',epochLabels);

g(1,1).stat_summary('type','sem','geom',{'point','black_errorbar'});

g(1,1).axe_property('XDir','Reverse');

g.coord_flip();
g(1,1).axe_property('YLim',[0 500000000000]);
% g(1,2).axe_property('YLim',[0.25 1]);
figure('Renderer', 'painters', 'Position', [100 100 500 300]);
g.draw();

