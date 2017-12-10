%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Smart
% 12/1/2017
% University of Maryland, College Park
% ENPM 808F - Robot Learning
% Term Project: Autonomous Car Tought by Q-Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% InitWorld:
% creates simple grid world 
% creates red wall-maze at random (stationary obsitcals)
% creates blue cars with handmade controls (moving obsitcals)
% creates green car 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure(1);
% cla;
% axis([0 numrc 0 numrc]);
% grid on;
% hold on;

% establish world object shape
block_X = [-0.5,-0.5,0.5,0.5,-0.5];
block_Y = [-0.5,0.5,0.5,-0.5,-0.5];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize boundary Walls
nboundaryWalls = 4*numrc; % number of walls needed for boundary
for n = 1:numrc
    % bottom boundary
    Walls(n).x = (n-1);
    Walls(n).y = 0;
    Walls_x(n) = Walls(n).x; % vector of all Wall x-pos
    Walls_y(n) = Walls(n).y; % vector of all Wall y-pos
    % set boundary of walls
    Walls(n).X = block_X + Walls(n).x;
    Walls(n).Y = block_Y + Walls(n).y;
end
for n = numrc+1:numrc*2
    % top boundary
    Walls(n).x = n-(numrc);
    Walls(n).y = numrc;
    Walls_x(n) = Walls(n).x; % vector of all Wall x-pos
    Walls_y(n) = Walls(n).y; % vector of all Wall y-pos
    % set boundary of walls
    Walls(n).X = block_X + Walls(n).x;
    Walls(n).Y = block_Y + Walls(n).y;
end
for n = numrc*2+1:numrc*3
    % left boundary
    Walls(n).x = 0;
    Walls(n).y = n-(numrc*2);
    Walls_x(n) = Walls(n).x; % vector of all Wall x-pos
    Walls_y(n) = Walls(n).y; % vector of all Wall y-pos
    % set boundary of walls
    Walls(n).X = block_X + Walls(n).x;
    Walls(n).Y = block_Y + Walls(n).y;
end
for n = numrc*3+1:numrc*4
    % right boundary
    Walls(n).x = numrc;
    Walls(n).y = n-(numrc*3+1);
    Walls_x(n) = Walls(n).x; % vector of all Wall x-pos
    Walls_y(n) = Walls(n).y; % vector of all Wall y-pos
    % set boundary of walls
    Walls(n).X = block_X + Walls(n).x;
    Walls(n).Y = block_Y + Walls(n).y;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize interior Walls
if (worldtype == 0) % grid
    nWalls = (nboundaryWalls+1)+((numrc-4)/2+1)^2+1; % number of walls
    for n = (nboundaryWalls+1):nWalls
        if (n == nboundaryWalls+1) % fist row
            row = n;
            Walls(n).x = 2; % x-pos
            Walls(n).y = 2; % y-pos
            rowold = n;
        elseif (mod(n-row,(numrc-4)/2+1)==0) % other rows
            row = n;
            Walls(row).x = Walls(rowold).x; % x-pos
            Walls(row).y = Walls(rowold).y + 2; % y-pos
            Walls_x(n-1) = Walls(n-1).x; % vector of all Wall x-pos
            Walls_y(n-1) = Walls(n-1).y; % vector of all Wall y-pos
            rowold = n;
        else % each column
            Walls(n).x = Walls(n-1).x + 2; % x-pos
            Walls(n).y = Walls(n-1).y; % y-pos
            Walls_x(n-1) = Walls(n-1).x; % vector of all Wall x-pos
            Walls_y(n-1) = Walls(n-1).y; % vector of all Wall y-pos
        end
        % set boundary of walls
        Walls(n).X = block_X + Walls(n).x;
        Walls(n).Y = block_Y + Walls(n).y;
    end
    Walls_x(n) = Walls(n).x; % vector of all Wall x-pos
    Walls_y(n) = Walls(n).y; % vector of all Wall y-pos
    
elseif (worldtype == 1) % maze
    nWalls = round(0.4*numrc)^2 + nboundaryWalls; % number of walls
    for n = nboundaryWalls+1:nWalls
        % random initialization of center position
        Walls(n).x = randi([2,numrc-1]); % x-pos
        Walls(n).y = randi([2,numrc-1]); % y-pos
        % makes sure they do not overlap
        if n > nboundaryWalls % after the first wall is made
            Walls_x(n-1) = Walls(n-1).x; % vector of all Wall x-pos
            Walls_y(n-1) = Walls(n-1).y; % vector of all Wall y-pos
            for i = 1:nWalls*2 % check&try "nWalls" times
                if (min((Walls(n).x - Walls_x).^2 +(Walls(n).y - Walls_y).^2) == 0)
                    % random initialization of center position
                    Walls(n).x = randi([2,numrc-1]); % x-pos
                    Walls(n).y = randi([2,numrc-1]); % y-pos
                end
            end
        end
        % set boundary of walls
        Walls(n).X = block_X + Walls(n).x;
        Walls(n).Y = block_Y + Walls(n).y;
    end
    Walls_x(nWalls) = Walls(nWalls).x; % vector of all Wall x-pos
    Walls_y(nWalls) = Walls(nWalls).y; % vector of all Wall y-pos
    
else % (worldtype == 2) % grid-maze
    % create grid
    nWalls = (nboundaryWalls+1)+((numrc-4)/2+1)^2+1; % number of walls
    for n = (nboundaryWalls+1):nWalls
        if (n == nboundaryWalls+1) % fist row
            row = n;
            Walls(n).x = 2; % x-pos
            Walls(n).y = 2; % y-pos
            rowold = n;
        elseif (mod(n-row,(numrc-4)/2+1)==0) % other rows
            row = n;
            Walls(row).x = Walls(rowold).x; % x-pos
            Walls(row).y = Walls(rowold).y + 2; % y-pos
            Walls_x(n-1) = Walls(n-1).x; % vector of all Wall x-pos
            Walls_y(n-1) = Walls(n-1).y; % vector of all Wall y-pos
            rowold = n;
        else % each column
            Walls(n).x = Walls(n-1).x + 2; % x-pos
            Walls(n).y = Walls(n-1).y; % y-pos
            Walls_x(n-1) = Walls(n-1).x; % vector of all Wall x-pos
            Walls_y(n-1) = Walls(n-1).y; % vector of all Wall y-pos
        end
        % set boundary of walls
        Walls(n).X = block_X + Walls(n).x;
        Walls(n).Y = block_Y + Walls(n).y;
    end
    Walls_x(n) = Walls(n).x; % vector of all Wall x-pos
    Walls_y(n) = Walls(n).y; % vector of all Wall y-pos
    % add in "maze"
    nWalls_old = nWalls;
    nWalls = nWalls_old + ceil(2*numrc/4);
    for n = nWalls_old+1:nWalls
        % random initialization of center position
        Walls(n).x = randi([2,numrc-1]); % x-pos
        Walls(n).y = randi([2,numrc-1]); % y-pos
        % makes sure they do not overlap
        if n > nboundaryWalls % after the first wall is made
            Walls_x(n-1) = Walls(n-1).x; % vector of all Wall x-pos
            Walls_y(n-1) = Walls(n-1).y; % vector of all Wall y-pos
            for i = 1:nWalls*2 % check&try "nWalls" times
                if (min((Walls(n).x - Walls_x).^2 +(Walls(n).y - Walls_y).^2) == 0)
                    % random initialization of center position
                    Walls(n).x = randi([2,numrc-1]); % x-pos
                    Walls(n).y = randi([2,numrc-1]); % y-pos
                end
            end
        end
        % set boundary of walls
        Walls(n).X = block_X + Walls(n).x;
        Walls(n).Y = block_Y + Walls(n).y;
    end
    Walls_x(nWalls) = Walls(nWalls).x; % vector of all Wall x-pos
    Walls_y(nWalls) = Walls(nWalls).y; % vector of all Wall y-pos

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Initialize Cars
nCars = round(0.3*numrc); % number of cars
for n = 1:nCars
    % random initialization of center position
    Cars(n).x = randi([2,numrc-1]); % x-pos
    Cars(n).y = randi([2,numrc-1]); % y-pos
    % makes sure they do not overlap with walls
    for i = 1:nWalls*100 % check&try "nWalls" times
        if (min((Cars(n).x - Walls_x).^2 +(Cars(n).y - Walls_y).^2) == 0)
            % random initialization of center position
            Cars(n).x = randi([2,numrc-1]); % x-pos
            Cars(n).y = randi([2,numrc-1]); % y-pos
        end
    end
    % set boundary of cars
    Cars(n).X = block_X./2 + Cars(n).x;
    Cars(n).Y = block_Y./2 + Cars(n).y;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize agent
agent.x = 1; % x-pos
agent.y = 1; % y-pos
% set boundary of agent
agent.X = block_X./2 + agent.x;
agent.Y = block_Y./2 + agent.y;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize goal
goalx = randi([2,numrc-1]); % x-pos
goaly = randi([2,numrc-1]); % y-pos
% makes sure it does not overlap with walls
    for i = 1:nWalls*100 % check&try "nWalls" times
        if (min((goalx - Walls_x).^2 +(goaly - Walls_y).^2) == 0)
            % random initialization of center position
            goalx = randi([2,numrc-1]); % x-pos
            goaly = randi([2,numrc-1]); % y-pos
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % plot walls
% for n = 1:nWalls
%     patch(Walls(n).X,Walls(n).Y,'r');
% end
% % plot cars
% for n = 1:nCars
%     patch(Cars(n).X,Cars(n).Y,'b');
% end
% % plot agent
% patch(agent.X,agent.Y,'g');
% % plot goal
% plot(goalx,goaly,'.','color','g','markersize',24);  
% % pause
% pause(0.001);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
