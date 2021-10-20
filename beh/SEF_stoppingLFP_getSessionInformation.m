function [sessionInformation] = SEF_stoppingLFP_getSessionInformation

session = [14:29]';

DepthInfo =  [...
    1;      % 1
    1;      % 2
    1;      % 3
    3;      % 4
    2;      % 5
    2;      % 6
    3;      % 7
    2;      % 8
    4;      % 9
    3;      % 10
    4;      % 11
    5;      % 12
    4;      % 13
    4;      % 14
    6;      % 15
    6;...   % 16
    ];    % This is the depth of the 1st channel relative to a fixed reference, alignment based on Godlove 2014

FileNames = {
    'eulsef20120910c-01';    % 1  % note: David's notes suggests that this one may not be useable! It wasn't listed as the 6 sessions!  This may explain the poor correlation between sessions in Euler.
    'eulsef20120911c-01';     % 2
    'eulsef20120912c-01';     % 3
    'eulsef20120913c-01';     % 4
    'eulsef20120914c-01';     % 5
    'eulsef20120915c-01';     % 6
    'xensef20120420a-01';     % 7
    'xensef20120423b-final';  % 8
    'xensef20120424c-final';  % 9
    'xensef20120425c-final';  % 10
    'xensef20120426c-01';     % 11
    'xensef20120427c-01';     % 12
    'xensef20120514d-final';  % 13
    'xensef20120515c-final';  % 14
    'xensef20120516c-final';  % 15
    'xensef20120517d-final';  % 16
    
    };  % This is the list of files we have from all perpendicular sessions

site = [...    % This is the current site used:
    1;
    1;
    1;
    1;
    1;
    1;
    2;
    2;
    2;
    2;
    2;
    2;
    3;
    3;
    3;
    3;...
    ];

LFPRange =  [6 22;    % these are based on Godlove, 2014 figure, 5/6.
    6 22;
    8 24;
    9 24;
    12 24;
    6 22;
    13 24;
    6 22;
    8 24;
    12 24;
    12 24;
    10 24;
    7 22;
    7 22;
    8 24;
    6 21;...
    ];

sessionInformation =  table(session,FileNames,site,DepthInfo,LFPRange);


end