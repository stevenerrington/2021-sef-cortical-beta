function [stopBeh] = extractStopBehData_betaBurst(executiveBeh,session)

STOPflag = strcmp(executiveBeh.SessionInfo{session}.Trial_type,'STOP');


[LowRew_index, HighRew_index] = RewardIndexer(executiveBeh.SessionInfo{session});
lowRewardTrials = (LowRew_index);
highRewardTrials = (HighRew_index);

rewardFlag = HighRew_index;

STOPoutcome = NaN(length(STOPflag),1);
STOPoutcome(executiveBeh.ttx_canc{session}) = 1;
STOPoutcome(executiveBeh.ttx.NC{session}) = 0;


saccadeTime = executiveBeh.TrialEventTimes_Overall{session}(:,4);
targetTime = executiveBeh.TrialEventTimes_Overall{session}(:,2);

%% Accumulate all the relevant raw data
stopBeh = ...
    [STOPflag,... % No-stop (0) or stop trial (1)
    STOPoutcome,... % Trial outcome
    executiveBeh.SessionInfo{session}.Curr_SSD,... % Stop signal delay
    saccadeTime - targetTime]; % Reaction time

%% Process and clean the data into the required format
stopBeh(stopBeh(:,1) == 0, 3) = -999; % Change no-stop trial SSD's to -999
stopBeh(stopBeh(:,1) == 0, 2) = -999; % Change no-stop trial C/NC binary value to -999

stopBeh(stopBeh(:,2) == 4, 2) = 1;    % Code C/NC as a binary value (0 = NC /1 = C)
stopBeh(stopBeh(:,2) == 8, 2) = 0;    % Code C/NC as a binary value (0 = NC /1 = C)
stopBeh(stopBeh(:,2) == 1, 4) = -999;    % Set RT on C trials to -999

stopBeh(find(isnan(stopBeh(:, 4))),:) = -999; % Change no-stop trial C/NC binary value to -999
stopBeh(find(isnan(stopBeh(:, 2))),:) = -999; % Remove other trial outcomes

stopBeh(stopBeh(:,4) < 100 & stopBeh(:,4) > -998, :) = []; % Change no-stop trial SSD's to -999
stopBeh(stopBeh(:,4) > 1000, :) = -999; % Change no-stop trial SSD's to -999
stopBeh(stopBeh(:,3) > 750, :) = -999; % Change no-stop trial SSD's to -999
% stopBeh(stopBeh(:,1) == -999, :) = []; % Change no-stop trial SSD's to -999

%% Label each column as an independent variable


trialN = [1:length(stopBeh(:,1))]';
ss_presented = stopBeh(:,1);
inhibited = stopBeh(:,2);
ssd = stopBeh(:,3);
rt = stopBeh(:,4);
subj_idx = repmat(session,length(rt),1);

%% Compile this into a table format
stopBeh = table(trialN,ss_presented,inhibited,ssd,rt);

%% Export the table into CSV file for importing into the BEEST code
%     writetable(stopDataBEESTS,['T:\Users\Steven\matlabRepo\project_motivationStopping\BEESTextraction\SEF_BEESTanalysis_' datestr(now, 'dd-mmm-yyyy') '.csv'],'WriteRowNames',true)

end
