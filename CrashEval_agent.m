%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% David Smart
% 12/1/2017
% University of Maryland, College Park
% ENPM 808F - Robot Learning
% Term Project: Autonomous Car Tought by Q-Learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ca =  CrashEval_agent(agent,Walls,nWalls,Cars,nCars)
% CrashEval_agent:
% evaluates if the agent will crash in the next time step if it takes a
% particular action
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialize evaluation (not going to crash)
    ca = zeros(1,4);

    for n = 1:nWalls % for all walls
        % 1 - up
        if (agent.x - Walls(n).x == 0) && (agent.y+1 - Walls(n).y == 0)
            ca(1) = 1;
        end

        % 2 - down
        if (agent.x - Walls(n).x == 0) && (agent.y-1 - Walls(n).y == 0)
            ca(2) = 1;
        end

        % 3 - right
        if (agent.x+1 - Walls(n).x == 0) && (agent.y - Walls(n).y == 0)
            ca(3) = 1;
        end

        % 4 - left
        if (agent.x-1 - Walls(n).x == 0) && (agent.y - Walls(n).y == 0)
            ca(4) = 1;
        end
        
    end

    for n = 1:nCars % for all cars
        % 1 - up
        if(agent.x - Cars(n).x == 0) && (agent.y+1 - Cars(n).y == 0)
            ca(1) = 1;
        end

        % 2 - down
        if (agent.x - Cars(n).x == 0) && (agent.y-1 - Cars(n).y == 0)
            ca(2) = 1;
        end

        % 3 - right
        if (agent.x+1 - Cars(n).x == 0) && (agent.y - Cars(n).y == 0)
            ca(3) = 1;
        end

        % 4 - left
        if (agent.x-1 - Cars(n).x == 0) && (agent.y - Cars(n).y == 0)
            ca(4) = 1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    end
    
end
