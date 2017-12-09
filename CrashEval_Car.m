%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Smart
% 12/1/2017
% University of Maryland, College Park
% ENPM 808F - Robot Learning
% Term Project: Autonomous Car Tought by Q-Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Smart
% 12/1/2017
% University of Maryland, College Park
% ENPM 808F - Robot Learning
% Term Project: Autonomous Car Tought by Q-Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cc =  CrashEval_Car(m,Walls,nWalls,Cars,nCars,agent)
% CrashEval_Car:
% evaluates if Car(m) will crash in the next time step if it takes a
% particular action
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialize evaluation (not going to crash)
    cc = zeros(1,4);

    for n = 1:nWalls % for all walls
        % 1 - up
        if (Cars(m).x - Walls(n).x == 0) && (Cars(m).y+1 - Walls(n).y == 0)
            cc(1) = 1;
        end

        % 2 - down
        if (Cars(m).x - Walls(n).x == 0) && (Cars(m).y-1 - Walls(n).y == 0)
            cc(2) = 1;
        end

        % 3 - right
        if (Cars(m).x+1 - Walls(n).x == 0) && (Cars(m).y - Walls(n).y == 0)
            cc(3) = 1;
        end

        % 4 - left
        if (Cars(m).x-1 - Walls(n).x == 0) && (Cars(m).y - Walls(n).y == 0)
            cc(4) = 1;
        end
    end

    for n = 1:nCars % for all Cars
        if (n ~= m)
            % 1 - up
            if (Cars(m).x - Cars(n).x == 0) && (Cars(m).y+1 - Cars(n).y == 0)
                cc(1) = 1;
            end

            % 2 - down
            if (Cars(m).x - Cars(n).x == 0) && (Cars(m).y-1 - Cars(n).y == 0)
                cc(2) = 1;
            end

            % 3 - right
            if (Cars(m).x+1 - Cars(n).x == 0) && (Cars(m).y - Cars(n).y == 0)
                cc(3) = 1;
            end

            % 4 - left
            if (Cars(m).x-1 - Cars(n).x == 0) && (Cars(m).y - Cars(n).y == 0)
                cc(4) = 1;
            end
        end
    end
    
    % for agent 
    % 1 - up
    if (Cars(m).x - agent.x == 0) && (Cars(m).y+1 - agent.y == 0)
        cc(1) = 1;
    end
    % 2 - down
    if (Cars(m).x - agent.x == 0) && (Cars(m).y-1 - agent.y == 0)
        cc(2) = 1;
    end
    % 3 - right
    if (Cars(m).x+1 - agent.x == 0) && (Cars(m).y - agent.y == 0)
        cc(3) = 1;
    end
    % 4 - left
    if (Cars(m).x-1 - agent.x == 0) && (Cars(m).y - agent.y == 0)
        cc(4) = 1;
    end
    
end
