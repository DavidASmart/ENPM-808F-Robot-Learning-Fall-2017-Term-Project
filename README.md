# ENPM-808F-Robot-Learning-Fall-2017-Term-Project
Autonomous Car in City-Maze (Game) with Q-Learning



Intorduction:---------------------------------------------------------------------------------------------------------------------------

The problem of training an autonomous car to navigate through a city to a destination without crashing or breaking the law was simplified to a computer game.



Approach:-------------------------------------------------------------------------------------------------------------------------------

Possible agent actions: (1) up, (2) down, (3) right, (4) left, and (5) stop. 

State variables: distance from the agent to the goal in both x and y directions, binary vector indicating if a certain action (1 - 4) would result in a crash converted to index (1 - 2^4), oscillation detection using a single value which represents the sequence of actions when oscillating (1 - 5)

State Representation: Q-value matrix with seperate dimenstion for each state variable

Rewards: If the learning agent arrived at the goal +2, If the learning agent crashed: -2.

Learning Parameters: The learning rate α = inverse to the number of times the state-action pair had been seen during training, The discounting factor 𝛾 = 0.9, ε-greedy action selection was used; ε was linearly interpolated between 0.75 and 0.01 based on the episode count.



Results: -------------------------------------------------------------------------------------------------------------------------------
Trainging attempts failed ... this is a work in progress



Analysis: ------------------------------------------------------------------------------------------------------------------------------

1st attempt had issues with the order of operations and the state was lacking needed information.
2nd attempt had crash evaluation errors. 
3rd attempt still crashed even after extending the training further 
(I was able to write a script to make a Q-table which results in no crashes...so Q-learning should be able to accheive this too)

It seems that more changes in the training are required. It may be best to randomly initialize the agent in the world.

It appears that more information about the layout of the world is needed to navigate to the goal since there are still timeouts. 

It may be better to have a Q-matrix dedicated to collision avoidance based on the binary vector for imminent crashes and another separate Q-matrix dedicated to navigation based on the positions of the buildings.



Future Work: ---------------------------------------------------------------------------------------------------------------------------

Try expanding the state-information.
Try two Q-learners.

Complexity ramped back up to the original problem incorporation of diagonal moves
	stop signs and traffic lights
	car movements asynchronous and more random
	make space continuous and giving the agent differential drive
	one-way and two-way streets
	Q-matrix changed to Deep-Q Network

  
  
Short Description of scripts/functions: ------------------------------------------------------------------------------------------------

**NOTE: currently, the displays and gif creation is disabled because these slow the process significantly. If you want to renable these, just uncomment that portion of the code. They are not too difficult to find. If I have time, I will make this an option determined by a variable set at the beginning of training or testing scripts.**

InitWorld - script to create the environment (requires "numrc" and "worldtype" to be specified)
		numrc - size of world (world is square)
		worldtype - 3 diffrent world layouts (0 - grid, 1 - maze, 2 - combo)

CARScontroler - script which controls all the "cars" in unison
CrashEval_Car - function which creates a vector for each car, which inidicates if certain actions taken by each car will result in a crash (requires the positions of the agent, all buildings/"walls", and all cars)

AGENTcontroler - script which controls the agent
CrashEval_agent - function which creates a vector which inidicates if certain actions taken by the agent will result in a crash (requires the positions of the agent, all buildings, called "walls", and all cars)

make_animated_gif - creates a gif of an episode (three steps: clear data, get frame data, and save file)

AutoCar_QLearning - runs the Q-learner through many episodes and record the results and saves the final Q-matrix as well as backsup the entires workspace of variables throughout the training with the option of makeing gifs everytime it saves a backup

Extending_AutoCar_QLearning - takes the most recent backup from AutoCar_QLearning and continues the training with reduced ε

AutoCar_Test - runs the Q-learner through several episodes (ε=0) and records the results as well as captures gifs of each

QInit_ca - script which initializes a Q-matrix to avoid collisions

QInit_ca_dg2 - script which initializes a Q-matrix to avoid collisions & move toward goal

QInit_ca_dg_ocd - script which initializes a Q-matrix to avoid collisions & move toward goal & try moving "inteligently" if oscillating (direction to goal considered, but direction of oscilation not considered)
