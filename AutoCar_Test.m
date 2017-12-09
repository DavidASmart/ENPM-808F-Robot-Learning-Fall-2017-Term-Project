%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Smart
% 12/1/2017
% University of Maryland, College Park
% ENPM 808F - Robot Learning
% Term Project: Autonomous Car Tought by Q-Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AutoCar_Test: 
% tests Q-learner by counting crashes,  goals reached, and timeouts
% STATE:
%    % distance(+/-) to goal in x and y position ("dgx","dgy") 
%    % going to crash into wall or car ? ("c")
%        % 1x4 vector of 0 or 1 for crash resulting from action i
%        % cIndex = c * [2^0;2^1;2^2;2^3] + 1; 
%    % occilation detected ? ("ocd")
%        % 1 - up-down, 2 - down-up, 3 - right-left, 4 - left-right, 5 - nope
% ACTIONS:
%    % 1 - up
%    % 2 - down
%    % 3 - right
%    % 4 - left
%    % 5 - stop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear
clc

pause(0.01);
% start a timer
tic

numrc = 10; % Size of world

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET UP Q-learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load Q-learner
% load('Q.mat');
% QInit_ca; % avoid collisions
% QInit_ca_dg2; % avoid collisions & move toward goal
% QInit_ca_dg_ocd; % avoid collisions & move toward goal ...
                 % ... try moving "inteligently" if oscillating 
                 % (direction to goal considered, but direction of ocd not considered)
load('Q2.mat')      
                 
% max time per episode
maxt = 100;

% number of testing episoides
numepisodes = numrc*10;

% some stats
timeouts = 0;
numcrashes = 0;
goalsreached = 0;
EvalErr = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TESTING LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for episode = 1:numepisodes
    
    % initialize world (seperate script)
    worldtype = 2; % mod(episode,4)-1; % 0 = grid, 1 = maze, 2 = grid-maze
    InitWorld
    % initalize result
    goalreached = 0;
    crashed = 0;
    timeout = 0;
    % initalize time
    t = 1; 
    dt = 1;
    % initialize occilation detection
    ocd = 5;
    A = zeros(1,maxt);
    T = t+5;
    
    make_animated_gif('clear')
    
    % time loop for episode
    while (timeout ~= 1) && (goalreached ~= 1) && (crashed ~= 1)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % control for Cars
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        CARScontroler  
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % control for agent
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % distance to goal
        dgx = agent.x - goalx;
        dgy = agent.y - goaly;
        % is there an iminent crash ?
        ca = CrashEval_agent(agent,Walls,nWalls,Cars,nCars);
        % convert to index-value
        cIndex = ca*[2^0;2^1;2^2;2^3]+1;
        epsilon = 0;
        AGENTcontroler

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % update world display
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        t = t + dt;
        if (t >= maxt)
            timeout = 1;
            timeouts = timeouts+1;
        end
        cla; % clear old plot
        for n = 1:nWalls
            patch(Walls(n).X,Walls(n).Y,'r');
        end
        for n = 1:nCars
            patch(Cars(n).X,Cars(n).Y,'b');
        end
        patch(agent.X,agent.Y,'g');
        plot(goalx,goaly,'.','color','g','markersize',24);  
        pause(0.001); % pause(0.01); % pause(1);
        make_animated_gif('snap')
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Update State
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % check if crashed into walls
        for n = 1:nWalls
            if ((agent.x - Walls(n).x)^2 +(agent.y - Walls(n).y)^2 < 1)
                crashed = 1;
                numcrashes = numcrashes+1;
                if (a ~= 5)
                    if (ca(a) == 0) % check if CrashEval_agent works perfectly
                        EvalErr = EvalErr+1; 
                    end
                end
            end
        end
        % check if crashed into cars
        for n = 1:nCars
            if ((agent.x - Cars(n).x)^2 +(agent.y - Cars(n).y)^2 < 1)
                crashed = 1;
                numcrashes = numcrashes+1;
                if (a ~= 5)
                    if (ca(a) == 0) % check if CrashEval_agent works perfectly
                        EvalErr = EvalErr+1; 
                    end
                end
            end
        end
        
        % check if reached goal
        if (dgx^2 + dgy^2 == 0)
            goalreached = 1;
            goalsreached = goalsreached+1;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % print out some info
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clc
    fprintf('\n\n ... TESTING ... ');
    fprintf('\n\n size of world: \t %i x %i ',numrc,numrc);
    fprintf('\n no. episodes:  \t %g ',numepisodes);
    fprintf('\n max time/episode: \t %g sec',maxt);
    
    fprintf('\n\n episode: \t\t\t %g ',episode);
    fprintf('\n no. crashes: \t\t %g ',numcrashes);
    fprintf('\n no. goals reached:  %g ',goalsreached);
    fprintf('\n no. timeouts: \t\t %g ',timeouts);
    if (EvalErr > 0)
        fprintf('\n\n CrashEval Error: \t %g ',EvalErr)
    end
    
    % keep track of training time
    elapsedTime = toc;
    hms = fix(mod(elapsedTime, [0, 3600, 60])./[3600, 60, 1]);
    days = floor(hms(1)/24);
    hrs = mod(hms(1)-days,24);
    fprintf('\n\n elapsed time: \t\t %g days %g hrs %g min %g sec ', days, hrs,hms(2),hms(3));
    timetotal = elapsedTime*numepisodes/episode;
    hmstotal = fix(mod(timetotal, [0, 3600, 60])./[3600, 60, 1]);
    daystotal = floor(hmstotal(1)/24);
    hrstotal = mod(hmstotal(1)-days,24);
    fprintf('\n est. time total: \t %g days %g hrs %g min %g sec ',daystotal,hrstotal,hmstotal(2),hmstotal(3));
    timeleft = timetotal - elapsedTime;
    hmsleft = fix(mod(timeleft, [0, 3600, 60])./[3600, 60, 1]);
    daysleft = floor(hmsleft(1)/24);
    hrsleft = mod(hmsleft(1)-days,24);
    fprintf('\n est. time left: \t %g days %g hrs %g min %g sec ',daysleft,hrsleft,hmsleft(2),hmsleft(3));

    
    if (episode > 1)
        make_animated_gif('write',strcat('Q_test',num2str(episode)),0.1,10)
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
