%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Smart
% 12/2/2017
% University of Maryland, College Park
% ENPM 808F - Robot Learning
% Term Project: Autonomous Car Tought by Q-Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CARScontroler
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 1:nCars % for all Cars
    % is there an iminent crash ?
    cc = CrashEval_Car(n,Walls,nWalls,Cars,nCars,agent);
    % try to go in a square ... up, right, down, left
    if (1 < mod(t,20) && mod(t,20) < 5)
        % try up first
        if (cc(1) == 0)   	% 1 - up
            dx = 0; dy = 1;
        else            	% 9 - stop
            dx = 0; dy = 0;
        end
    elseif (5 < mod(t,20) &&  mod(t,20) < 10)
        % try right first
        if (cc(3) == 0)    	% 3 - right
            dx = 1; dy = 0;
        else                % 9 - stop
            dx = 0; dy = 0;
        end
    elseif (10 < mod(t,20) && mod(t,20) < 15)
        % try down first
        if (cc(2) == 0)     	% 2 - down
            dx = 0; dy = -1;
        else                % 9 - stop
            dx = 0; dy = 0;
        end
    elseif (15 < mod(t,20) && mod(t,20) < 20)
        % try left first
        if (cc(4) == 0)     	% 4 - left
            dx = -1; dy = 0;
        else                    % 9 - stop
            dx = 0; dy = 0;
        end
    else % pause between directions of movement
        dx = 0; dy = 0;         % 9 - stop
    end
    % update possition of car
    Cars(n).x = Cars(n).x + dx;
    Cars(n).y = Cars(n).y + dy;
    % update boundary of car
    Cars(n).X = Cars(n).x + block_X./2; 
    Cars(n).Y = Cars(n).y + block_Y./2;
end     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
