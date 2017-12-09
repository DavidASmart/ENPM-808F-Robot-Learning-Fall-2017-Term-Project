%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Smart
% 12/2/2017
% University of Maryland, College Park
% ENPM 808F - Robot Learning
% Term Project: Autonomous Car Tought by Q-Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% AGENTcontroler
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% distance to goal
dgx = agent.x - goalx;
dgy = agent.y - goaly;
% is there an iminent crash ?
ca = CrashEval_agent(agent,Walls,nWalls,Cars,nCars);
% convert to index-value
cIndex = ca*[2^0;2^1;2^2;2^3]+1;

% epsilon-greedy
if (rand > epsilon) 
    qmax = max(Q(dgx+numrc,dgy+numrc,cIndex,ocd,:)); % exploit
    % in case there is a tie...random tiebreaker
    aindex = find(Q(dgx+numrc,dgy+numrc,cIndex,ocd,:) == qmax);
    a = aindex(randperm(numel(aindex), 1));
else
    a = randi([1, 5]); % explore
end

% make move
if (a == 1)         % 1 - up
    dx = 0; dy = 1;
elseif (a == 2)     % 2 - down  
    dx = 0; dy = -1;
elseif (a == 3)    	% 3 - right
    dx = 1; dy = 0;
elseif (a == 4)    	% 4 - left
    dx = -1; dy = 0;   
else % (a = 5)      % 5 - stop
    dx = 0; dy = 0;
end

A(t) = a; % record actions taken

% Detect Ocilatory Behavior
ocd_old = ocd;
if t > T
    if (A(t-4:t) == [1,2,1,2,1]) % up-down
        ocd = 1;
        T = t+3; % the detection should last more than 1 time step otherwise it will just go right back to occilating...
    elseif (A(t-4:t) == [2,1,2,1,2]) % down-up
        ocd = 2;
        T = t+3;
    elseif (A(t-4:t) == [3,4,3,4,3]) % right-left
        ocd = 3;
        T = t+3;
    elseif (A(t-4:t) == [4,3,4,3,4]) % left-right
        ocd = 4;
        T = t+3;
    else
        ocd = 5;
    end
end

% update possition of agent
agent.x = agent.x + dx;
agent.y = agent.y + dy;

% update boundary of agent
agent.X = agent.x + block_X./2;
agent.Y = agent.y + block_Y./2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
