function SessionBDF = BetaBurstConvolver (betaBurstTimes, window)

if nargin < 2
   window = [-1000:2000];
end

% Parameters
sd = 22.5; N = sd*5; t=-N:N;
R2use = (1/sqrt(2*pi*sd.^2))*exp(-t.^2/(2*sd.^2));

S2 = zeros(length(betaBurstTimes), length(window));

for trl = 1:length(betaBurstTimes)
   
    betaBurstIdx = betaBurstTimes{trl} + find(window == 0);
    
    if ~isempty(betaBurstIdx)
        S2(trl,betaBurstIdx) = 1;
    end
    
    SessionBDF(trl,:) = conv(S2(trl,:), R2use, 'same');
    SessionBDF(trl,:) = SessionBDF(trl,:);
end

