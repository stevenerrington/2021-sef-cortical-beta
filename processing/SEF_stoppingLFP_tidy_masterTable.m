% Combine all data tables for outside analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Requires following scripts to be run:
%   - SEF_stoppingLFP_stopping_baseline
%   - SEF_stoppingLFP_stopping_pBurst
%   - SEF_stoppingLFP_stopping_ssrtCorr
%   - SEF_stoppingLFP_stopping_neurometric
%   - SEF_stoppingLFP_action_error

if ismac
    dataDir = '/Users/stevenerrington/Desktop/Projects/2021-sef-cortical-beta/data/exportJASP/';
else
    dataDir = 'D:\projectCode\project_stoppingLFP\data\exportJASP\';
end

lfpN = table([1:509]','VariableNames',{'LFPidx'});

% Get the main "mapping" of electrodes to sessions, monkeys, etc...
a = corticalLFPmap;
% Get the baseline [-200 0] and post-target [0 200] pBursts
b = table(betaBaseline_LFP_all, targetBaseline_LFP_all,'VariableNames',{'baseline_200_pBurst','target_200_pBurst'});
% Get the baseline [-200-ssrt -200] and stopping [ssd ssrt] pBursts
c = readtable([dataDir 'LFP_pBurst_trial.csv']);
% Get the parameters (i.e. timing, variation, volume) of bursting during stopping
d = readtable([dataDir 'LFP_meanburstTime.csv']');
% Get the parameters (i.e. timing, variation, volume) of bursting during errors
e = readtable([dataDir 'LFP_errorBurstProperties_300_600.csv']);
% Get the neurometric measures
% f = table(testRaw, testRaw_shuffled,'VariableNames',{'neurometric_raw','neurometric_shuffled'});

% Amend variable names for easier reference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = length(c.Properties.VariableNames); varNames = cell(1,N);
for i=1:N; varNames{i} = ['stopping_' c.Properties.VariableNames{i}]; end
c.Properties.VariableNames = varNames;

N = length(d.Properties.VariableNames); varNames = cell(1,N);
for i=1:N; varNames{i} = ['stopping_' d.Properties.VariableNames{i}]; end
d.Properties.VariableNames = varNames;

N = length(e.Properties.VariableNames); varNames = cell(1,N);
for i=1:N; varNames{i} = ['error_' e.Properties.VariableNames{i}]; end
e.Properties.VariableNames = varNames;

% Combine tables, removing repeating variable names
beta_postOut = [lfpN, a,b,c(:,3:end),d(:,1:end-1),e(:,1:end-1)];


tempTable = table();

periodList = {'baseline_target','baseline_stopping','target','stopping','error'};
trialList = {'nostop','canceled','noncanceled'};

for lfpIdx = 1:509   
    for periodIdx = 1:length(periodList)
        for trialIdx = 1:length(trialList)
            
            x = regexp([beta_postOut.Properties.VariableNames],'error','match');
            Index = find(not(cellfun('isempty',x)));

            beta_postOut.Properties.VariableNames(Index)
            
            
            table(periodList(periodIdx),trialList(trialIdx), pBurst)
            
            a(lfpIdx,:) 
            
            
        end   
    end
end






% Output new master table into a CSV file.
writetable(beta_postOut,...
    [dataDir 'beta_postOut.csv'],...
    'WriteRowNames',true);


%% 

for i = 1:509
    
    baseline_canceled = beta_postOut(:,[1,2,3,4,5,6,7,8,9,10,11]);
    baseline_noncanceled = beta_postOut(:,[1,2,3,4,5,6,7,8,9,10,11]);
    baseline_nostop = beta_postOut(:,[1,2,3,4,5,6,7,8,9,10,11]);




















end


