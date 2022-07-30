% Load in burst data around the time of fixation
load(fullfile(dataDir,'burst','burstData_fixation.mat'))


%% Figure: Inter-burst interval
% Initialise the figure
figure; hold on
count = 0; % for subplot placement

% Define trial types and measures
trialType_list = {'nostop','noncanceled','canceled'};
measure_list = {'burstOnset','burstTimes','burstOffset'};

% For each trial type
for trialtype_i = 1:length(trialType_list)
    trialType = trialType_list{trialtype_i};
    
    % And each beta-measure
    for measure_i = 1:length(measure_list)
        measureType = measure_list{measure_i};
        
        % Get the number of LFP's
        n_lfp = size(fixationBeta.timing.(trialType),1);
        count = count+1;
        
        % Clear loop variables
        clear ibi_array ibi_array_all
        ibi_array_all = [];
        
        % For each LFP
        for lfp_i = 1:n_lfp
            fprintf('Analysing LFP contact %i of %i. \n',lfp_i, n_lfp)
            
            % Clear loop variables to reduce contamination
            clear  ibi burst_trials
            
            % Get the difference between LFP burst times within a trial
            ibi = cellfun(@diff,fixationBeta.timing.(trialType).(measureType){lfp_i},'uniform', false);
            % Find those trials in which a burst occured
            burst_trials = find(~cellfun(@isempty,ibi));
            
            % Initialise the array
            ibi_array{lfp_i} = [];
            
            % For each trial in which a burst occured
            for burst_i = 1:length(burst_trials)
                % Add the diff to a new array for the LFP
                ibi_array{lfp_i} = [ibi_array{lfp_i}; ibi{burst_trials(burst_i)}];
                % And a global array for all contacts
                ibi_array_all = [ibi_array_all; ibi{burst_trials(burst_i)}];
            end
        end
        
        % Then, once we've went through all contacts, plot it!
        subplot(length(trialType_list),length(measure_list),count)
        histogram(ibi_array_all,1:1:100,'LineStyle','None')
        ylabel(trialType)
    end
end



%% Analysis: Poisson inter-burst-interval.
% After looking, the burst times may be Poisson like.
% We can test to see if the inter-burst interval is from a Poisson
% distribution

ibi_array_main = [];
% For each trial type
for trialtype_i = 1:length(trialType_list)
    trialType = trialType_list{trialtype_i};
    
    % And each beta-measure
    measureType = 'burstTimes';
    
    % Get the number of LFP's
    n_lfp = size(fixationBeta.timing.(trialType),1);
    
    % Clear loop variables
    clear ibi_array ibi_array_all

    
    % For each LFP
    for lfp_i = 1:n_lfp
        fprintf('Analysing LFP contact %i of %i. \n',lfp_i, n_lfp)
        
        % Clear loop variables to reduce contamination
        clear ibi burst_trials
        
        % Get the difference between LFP burst times within a trial
        ibi = cellfun(@diff,fixationBeta.timing.(trialType).(measureType){lfp_i},'uniform', false);
        % Find those trials in which a burst occured
        burst_trials = find(~cellfun(@isempty,ibi));

        % For each trial in which a burst occured
        for burst_i = 1:length(burst_trials)
            ibi_array_main = [ibi_array_main; ibi{burst_trials(burst_i)}];
        end
    end

end

% Plot figure to check data
figure;
histogram(ibi_array_main,0:1:100)





