session = 14;

lfp_i = 1;

clear betaDir lfpDir ch_label file beta_data lfp_data betaOutput morletLFP

betaDir = 'D:\projectCode\project_stoppingLFP\data\lfp\betaBurst\target\';
lfpDir = 'D:\projectCode\project_stoppingLFP\data\lfp\LFP\target\';

ch_label = corticalLFPmap.channelNames(corticalLFPmap.session == session);
ch_label = ch_label{1};

file = ['lfp_session' int2str(session) '_' ch_label '_betaOutput_target'];

beta_data = load(fullfile(betaDir,file));
lfp_data = load(fullfile(lfpDir,file));


[betaOutput] = thresholdBursts(beta_data.betaOutput, beta_data.betaOutput.medianLFPpower*burstThreshold);
[morletLFP] = convMorletWaveform(lfp_data.filteredLFP.beta,morletParameters);


for ii = 1:20
    try
        
        trl_i = executiveBeh.ttx.GO{session}(ii);
        
        trl_burst_times = []; trl_burst_times = betaOutput.burstData.burstTime{trl_i};
        trl_burst_on = []; trl_burst_on = betaOutput.burstData.burstOnset{trl_i}+betaOutput.burstData.burstTime{trl_i};
        trl_burst_off = []; trl_burst_off = betaOutput.burstData.burstOffset{trl_i}+betaOutput.burstData.burstTime{trl_i};
        trl_burst_freq = []; trl_burst_freq = betaOutput.burstData.burstFrequency{trl_i};
        
        figure;
        subplot(2,1,1)
        plot(-999:2000,lfp_data.filteredLFP.beta(trl_i,:))
        vline(trl_burst_times,'r')
        vline(trl_burst_on,'g--')
        vline(trl_burst_off,'b--')
        
        subplot(2,1,2); hold on
        imagesc(-999:2000,morletParameters.frequencies,squeeze(morletLFP(trl_i,:,:)))
        xlim([-999 2000]); ylim([min(morletParameters.frequencies) max(morletParameters.frequencies)])
        scatter(trl_burst_times,trl_burst_freq,'ro')
                
    catch
        continue
    end
end
