figure; hold on

trialType_list = {'nostop','noncanceled','nostop'};
measure_list = {'burstOnset','burstTimes','burstOffset'};
count = 0;




for trialtype_i = 1:length(trialType_list)
    trialType = trialType_list{trialtype_i};
    
    for measure_i = 1:length(measure_list)
        measureType = measure_list{measure_i};
        
        n_lfp = size(fixationBeta.timing.(trialType),1);
        count = count+1;
        
        clear ibi_array ibi_array_all
        ibi_array_all = [];
        
        for lfp_i = 1:n_lfp
            
            clear A ibi_all burst_trials
            ibi = cellfun(@diff,fixationBeta.timing.(trialType).(measureType){lfp_i},'uniform', false);
            burst_trials = find(~cellfun(@isempty,ibi));
            
            ibi_array{lfp_i} = [];
            
            for burst_i = 1:length(burst_trials)
                
                ibi_array{lfp_i} = [ibi_array{lfp_i}; ibi{burst_trials(burst_i)}];
                ibi_array_all = [ibi_array_all; ibi{burst_trials(burst_i)}];
            end
        end
        
        subplot(length(measure_list),length(trialType_list),count)
        histogram(ibi_array_all,1:1:100,'LineStyle','None')
        ylabel(trialType)
    end
end