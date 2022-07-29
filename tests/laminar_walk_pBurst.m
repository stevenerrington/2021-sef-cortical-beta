



%% IN PROGRESS
exitflag = 0; stepSize = 10;
curr_time = 0; count = 0;
clear test
while exitflag ~= 1
    
    count = count + 1;
    curr_time = curr_time+stepSize;
    fprintf('Window size: %i ms \n',curr_time)
    
    preWindow = [-(curr_time) -1];
    postWindow = [1 curr_time];
    
    for session_i = 14:29
        input_diff_times = [];
        input_diff_times = diff_burst_time.obs.(laminarAlignment.compart_label{find_laminar}){session_i - 13};
        input_diff_times_shuffled = diff_burst_time.shuf.(laminarAlignment.compart_label{find_laminar}){session_i - 13};
        
        nBurst_total = length(input_diff_times);
        nBurst_total_shuf = length(input_diff_times_shuffled);
        nBurst_preWindow = length(find(input_diff_times > preWindow(1) & input_diff_times < preWindow(2)));
        nBurst_postWindow = length(find(input_diff_times > postWindow(1) & input_diff_times < postWindow(2)));
        
        
        nBurst_preWindow_shuf = length(find(input_diff_times > preWindow(1) & input_diff_times < preWindow(2)));
        nBurst_postWindow_shuf = length(find(input_diff_times > postWindow(1) & input_diff_times < postWindow(2)));
        
        
        pBurst_pre(session_i-13) = (nBurst_preWindow/nBurst_total);
        pBurst_post(session_i-13) = (nBurst_postWindow/nBurst_total);
        
        pBurst_pre_shuf(session_i-13) = (nBurst_preWindow_shuf/nBurst_total_shuf);
        pBurst_post_shuf(session_i-13) = (nBurst_postWindow_shuf/nBurst_total_shuf);
    end
    
    test(count,:) = [curr_time, mean(pBurst_pre), mean(pBurst_post)];
    test_shuf(count,:) = [curr_time, mean(pBurst_pre_shuf), mean(pBurst_post_shuf)];
    
    if any(pBurst_pre > 0.35); exitflag = 1; end
    if any(pBurst_post > 0.35); exitflag = 1; end
end

figure;
plot(test(:,1),test(:,2));
hold on
plot(test_shuf(:,1),test_shuf(:,2));


