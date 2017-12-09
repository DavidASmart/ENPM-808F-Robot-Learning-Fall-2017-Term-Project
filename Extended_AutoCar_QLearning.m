%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Smart
% 12/8/2017
% University of Maryland, College Park
% ENPM 808F - Robot Learning
% Term Project: Autonomous Car Tought by Q-Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extended_AutoCar_QLearning: 
% uses Q-Learning method to teach a car how to navigate to a goal without
% crashing into stationary walls or moving cars
% STATE:
%    % distance(+/-) to goal in x and y position ("dgx","dgy") 
%    % going to crash into wall or car ? ("ca")
%        % 1x4 vector of 0 or 1 for crash resulting from action i
%        % 2^4 possibile permuations of that vector
%        % cIndex = ca * [2^0;2^1;2^2;2^3] + 1; 
%    % occilation detected ? ("ocd")
%        % 1 - up-down, 2 - down-up, 3 - right-left, 4 - left-right, 5 - nope
% ACTIONS:
%    % 1 - up
%    % 2 - down
%    % 3 - right
%    % 4 - left
%    % 5 - stop
% REWARDS:
%    % Reached Goal = 2
%    % Collision with Wall or Car = -2
%    % Other = 0 (or -0.01 to discurage wandering ?)
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
% load backed up training data
load('Q_b.mat')
                    
% extend the number of training episoides
numepisodes_old = numepisodes;
numepisodes = numepisodes_old + ((numrc*2)*(numrc*2)*(2^4)*(5)*(5))/2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRAINING LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for episode = numepisodes_old:numepisodes
    
    % initialize world (seperate script)
    worldtype = 2; %mod(episode,4)-1; % 0 = grid, 1 = maze, 2 = grid-maze
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
    T = t+10;

    
    % keep track of some stats
    Qsum(episode) = sum(sum(sum(sum(sum(Q)))));
    saCountavg(episode) = mean(mean(mean(mean(mean(saCounter)))));
    saCountavg(episode) = saCountavg(episode)-saCountavg(1);
    
    % epsilon = 0.75 + (0.01 - 0.75)*(episode/numepisodes);
    % reduced epsilon...but not just continuing lower
    epsilon = 0.75/2 + (0.01/2 - 0.75/2)*(episode/numepisodes);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % periodic episode-gif creation & Q-matrix backups
    if (mod(episode,numepisodes/50) == 1)
%         make_animated_gif('clear')
        save('Q_b2.mat');
%     elseif (mod(episode,numepisodes/50) == 2)
%         make_animated_gif('write',strcat('Q_e',num2str(episode)),0.1,10)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % time loop for episode
    while (timeout ~= 1) && (goalreached ~= 1) && (crashed ~= 1)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % control for Cars
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        CARScontroler
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % control for agent
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        AGENTcontroler
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % State Update
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % recalculate distance to goal
        dgx_next = agent.x - goalx;
        dgy_next = agent.y - goaly;
        % recalculate is there an iminent crash ?
        ca_next = CrashEval_agent(agent,Walls,nWalls,Cars,nCars);
        % convert to index-value
        cIndex_next = ca_next*[2^0;2^1;2^2;2^3]+1;
        
        % check if crashed into walls
        for n = 1:nWalls
            if ((agent.x - Walls(n).x)^2 +(agent.y - Walls(n).y)^2 == 0)
                crashed = 1;
                if (a ~= 5)
                    if (ca(a) == 0) % check if CrashEval_agent works perfectly
                        EvalErr = EvalErr+1; 
                    end
                end
            end
        end
        
        % check if crashed into cars
        for n = 1:nCars
            if ((agent.x - Cars(n).x)^2 +(agent.y - Cars(n).y)^2 == 0)
                crashed = 1;
                if (a ~= 5)
                    if (ca(a) == 0) % check if CrashEval_agent works perfectly
                        EvalErr = EvalErr+1; 
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Q-learning
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % evaluate reward
        if (crashed == 1)
            r = -2;
        elseif (dgx_next^2 + dgy_next^2 == 0)
            r = 2;
            goalreached = 1;
        else
            r = 0; % -0.01;
        end
        
        % update alpha
        saCounter(dgx+numrc,dgy+numrc,cIndex,ocd_old, a) = saCounter(dgx+numrc,dgy+numrc,cIndex,ocd_old, a) + 1;
        alpha = 1 / saCounter(dgx+numrc,dgy+numrc,cIndex,ocd_old,a);
        
        % update Q-value
        Q_current = Q(dgx+numrc, dgy+numrc, cIndex, ocd_old, a);
        Q_next = max(Q(dgx_next+numrc, dgy_next+numrc, cIndex_next, ocd, :));
        Q(dgx+numrc, dgy+numrc, cIndex, ocd_old, a) = (1-alpha)*Q_current + alpha*(r + gamma*Q_next);
        % so that we don't calculate the same thing twice...
        dgx = dgx_next;
        dgy = dgy_next;
        ca = ca_next;
        cIndex = cIndex_next;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % update time
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        t = t + dt;
        if (t >= maxt)
            timeout = 1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % update world display
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         cla; % clear old plot
%         for n = 1:nWalls
%             patch(Walls(n).X,Walls(n).Y,'r');
%         end
%         for n = 1:nCars
%             patch(Cars(n).X,Cars(n).Y,'b');
%         end
%         patch(agent.X,agent.Y,'g');
%         plot(goalx,goaly,'.','color','g','markersize',24);  
%         pause(0.001); % pause(0.01); % pause(1);
%         if (mod(episode,numepisodes/50) == 1)
%             make_animated_gif('snap')
%         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % keep track of stats
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (episode > 1)
            
            if (timeout == 1)
                timeouts(episode) = timeouts(episode-1)+1;
            else
                timeouts(episode) = timeouts(episode-1);
            end
            if (goalreached == 1)
                goalsreached(episode) = goalsreached(episode-1)+1;
            else
                goalsreached(episode) = goalsreached(episode-1);
            end
            if (crashed == 1)
                numcrashes(episode) = numcrashes(episode-1)+1;
            else
                numcrashes(episode) = numcrashes(episode-1);
            end
        else
            if (timeout == 1)
                timeouts(episode) = timeouts(episode)+1;
            end
            if (goalreached == 1)
                goalsreached(episode) = goalsreached(episode)+1;
            end
            if (crashed == 1)
                numcrashes(episode) = numcrashes(episode)+1;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % print out some info
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clc
        fprintf('\n\n ... TRAINING ... ');
        fprintf('\n\n size of world: \t %g x %g ',numrc,numrc);
        fprintf('\n dimensions of Q: \t %g x %g x %g x %g x %g ',size(Q,1),size(Q,2),size(Q,3),size(Q,4),size(Q,5));
        
        fprintf('\n\n no. episodes: \t\t %g ',numepisodes)
        fprintf('\n max time/episode: \t %g ',maxt);

        fprintf('\n\n episode: \t\t\t %g ',episode);
        fprintf('\n Q-sum: \t\t\t %g ',round(Qsum(episode)));
        fprintf('\n avg. (s,a)count: \t %g ',round(saCountavg(episode)));
        fprintf('\n epsilon: \t\t\t %g ',round(epsilon,4));

        fprintf('\n\n crashes: \t\t %g \t\t (%g %%) ',numcrashes(episode),round(100*(numcrashes(episode)/episode)));
        fprintf('\n goals reached:  %g \t\t (%g %%) ',goalsreached(episode),round(100*(goalsreached(episode)/episode)));
        fprintf('\n timeouts: \t\t %g \t\t (%g %%) ',timeouts(episode),round(100*(timeouts(episode)/episode)));
        
        if (episode > 1000)
            fprintf('\n\n crash rate: \t %g ',(numcrashes(episode)-numcrashes(episode-1000))/1000);
            fprintf('\n goal rate: \t %g ',(goalsreached(episode)-goalsreached(episode-1000))/1000);
            fprintf('\n timeout rate: \t %g ',(timeouts(episode)-timeouts(episode-1000))/1000);
        end
        
        if (EvalErr > 0)
            fprintf('\n\n CrashEval Error?: \t %g ',EvalErr)
        end
        
        % keep track of training time
        elapsedTime = toc;
        hms = fix(mod(elapsedTime, [0, 3600, 60])./[3600, 60, 1]);
        days = floor(hms(1)/24);
        hrs = mod(hms(1)-days,24);
        fprintf('\n\n elapsed time: \t\t %g days %g hrs %g min %g sec ', days, hrs,hms(2),hms(3));
        timetotal = elapsedTime*(numepisodes-numepisodes_old)/(episode-numepisodes_old);
        hmstotal = fix(mod(timetotal, [0, 3600, 60])./[3600, 60, 1]);
        daystotal = floor(hmstotal(1)/24);
        hrstotal = mod(hmstotal(1)-days,24);
        fprintf('\n est. time total: \t %g days %g hrs %g min %g sec ',daystotal,hrstotal,hmstotal(2),hmstotal(3));
        timeleft = timetotal - elapsedTime;
        hmsleft = fix(mod(timeleft, [0, 3600, 60])./[3600, 60, 1]);
        daysleft = floor(hmsleft(1)/24);
        hrsleft = mod(hmsleft(1)-days,24);
        fprintf('\n est. time left: \t %g days %g hrs %g min %g sec ',daysleft,hrsleft,hmsleft(2),hmsleft(3));
    
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save trained Q-matrix
save('Q_extended.mat','Q');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate the rates for the training stats
episodes = 1:1:numepisodes;
n = 2;
Q_rate(1) = 0;
crash_rate(1) = 0;
goal_rate(1) = 0;
timeout_rate(1) = 0;
while n <= numepisodes
    if (mod(n,1000) == 1) && (n > 1)
        Q_rate(n) = (Qsum(n)-Qsum(n-1000))/1000;
        crash_rate(n) = (numcrashes(n)-numcrashes(n-1000))/1000;
        goal_rate(n) = (goalsreached(n)-goalsreached(n-1000))/1000;
        timeout_rate(n) = (timeouts(n)-timeouts(n-1000))/1000;
    else
        Q_rate(n) = Q_rate(n-1);
        crash_rate(n) = crash_rate(n-1);
        goal_rate(n) = goal_rate(n-1);
        timeout_rate(n) = timeout_rate(n-1);
        
    end
    n = n + 1;
end

% plot training stats and save the plots
close all
figure(1);
plot(episodes,Qsum,'color', [0.5 0 1],'LineWidth',2);
title('Q-Learning');
xlabel('episodes');
ylabel('Q-sum');
saveas(gcf,'Q_sum_extended.jpg');

figure(2);
plot(episodes,abs(Qsum),'color', [0.5 0 1],'LineWidth',2);
title('Q-Learning');
xlabel('episodes');
ylabel('Abs(Q-sum)');
saveas(gcf,'Q_sumabs_extended.jpg');

figure(3);
plot(episodes,Q_rate,'color', [0.5 0 1],'LineWidth',2);
title('Q-Learning');
xlabel('episodes');
ylabel('Q-rate');
saveas(gcf,'Q_rate_extended.jpg');

figure(4);
plot(episodes,numcrashes,'r','LineWidth',2);
hold on
plot(episodes,goalsreached,'g','LineWidth',2);
plot(episodes,timeouts,'b','LineWidth',2);
hold off
title('Q-Learning');
xlabel('episodes');
ylabel('No. Events');
legend('crashes', 'goals reached','timeouts')
saveas(gcf,'Stats_extended.jpg');

figure(5);
plot(episodes,crash_rate,'r','LineWidth',2);
hold on
plot(episodes,goal_rate,'g','LineWidth',2);
plot(episodes,timeout_rate,'b','LineWidth',2);
hold off
title('Q-Learning');
xlabel('episodes');
ylabel('Event Rate');
legend('crashes', 'goals reached','timeouts')
saveas(gcf,'Stats_rate_extended.jpg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
