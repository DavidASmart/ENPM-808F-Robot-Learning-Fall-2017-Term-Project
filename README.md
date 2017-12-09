# ENPM-808F-Robot-Learning-Fall-2017-Term-Project
Autonomous Car in City-Maze (Game) with Q-Learning

Abstract:
	The problem of training an autonomous car to navigate through a city to a destination without crashing or breaking the law was simplified significantly to the point where the challenge was more like a computer game. Two attempts were made at solving the simplified problem using Q-learning but were not sucessfull. These have yet to be fixed. In the future, it is planned to regain some of the complexity of the original problem.
  
Intorduction:
	The original proposed goal for this term project was to simulate a differential-drive car which would learn by policy iteration how to navigate through a city (set up like a maze) to a set of coordinates without crashing or breaking the law. This city was to have stop signs and traffic lights, two way and one way streets, and other cars. The original proposal also stated that the learning algorithm would be written in MATLAB, but the simulation would be done in the V-REP simulation environment, which is essentially a continuous space, therefore allowing for continuous state values. V-REP also has realistic simulated sensors which would have been used for determining the state.
	The problem was simplified to the point where it is more like a simple computer game. The V-REP interface was abandoned, and the simulation was done with MATLAB plots. Sensor modeling was abandoned for a direct state omniscience. The space was discretized to a grid, and the differential drive control was abandoned for the 4 basic cardinal movements (up, down, right, and left) and stop. The stop signs, traffic lights, and different streets types were ignored for the time being. The pre-programed cars were kept as a part of the problem. 

Approach:
	Possible agent actions: 
		(1) up, (2) down, (3) right, (4) left, and (5) stop. 
	State variables: 
		- distance from the agent to the goal in both x and y directions
		- binary vector indicating if a certain action (1 - 4) would result in a crash converted to index (1 - 2^4)
		- oscillation detection using a single value which represents the sequence of actions when oscillating (1 - 5)
	State Representation:
		Q-value matrix with seperate dimenstion for each state variable
  	Rewards: 
		If the learning agent arrived at the goal +2
		If the learning agent crashed: -2.
	Learning Parameters:
  		The learning rate, α, = inverse to the number of times the state-action pair had been seen during training
		The discounting factor, 𝛾 = 0.9. 
		ε-greedy action selection was used; ε was linearly interpolated between 0.75 and 0.01 based on the episode count.
  
Implementation:
	InitWorld - script to create the environment (requires "numrc" and "worldtype" to be specified)
		numrc - size of world (world is square)
		worldtype - 3 diffrent world layouts (0 - grid, 1 - maze, 2 - combo)
	CARScontroler - script which controls all the "cars" in unison
	CrashEval_Car - function which creates a vector for each car, which inidicates if certain actions taken by each car will result in a crash (requires the positions of the agent, all buildings/"walls", and all cars) 
	AGENTcontroler - script which controls the agent
	CrashEval_agent - function which creates a vector which inidicates if certain actions taken by the agent will result in a crash (requires the positions of the agent, all buildings, called "walls", and all cars)
	make_animated_gif - creates a gif of an episode
	AutoCar_QLearning - runs the Q-learner through many episodes and record the results and saves the final Q-matrix as well as backsup the entires workspace of variables throughout the training with the option of makeing gifs everytime it saves a backup
	Extending_AutoCar_QLearning - takes the most recent backup from AutoCar_QLearning and continues the training with reduced ε
	AutoCar_Test - runs the Q-learner through several episodes (ε=0) and records the results as well as captures gifs of each
	QInit_ca - script which initializes a Q-matrix to avoid collisions
	QInit_ca_dg2 - script which initializes a Q-matrix to avoid collisions & move toward goal
	QInit_ca_dg_ocd - script which initializes a Q-matrix to avoid collisions & move toward goal & try moving "inteligently" if oscillating (direction to goal considered, but direction of oscilation not considered)
	
Results + Analysis:
	Trainging attempt failed ... this is a work in progress
	The second training attempt had numerous crash evaluation errors (12,400 ... which amounted to 5.6 % of crashes, and occurred in 4.4 % of episodes). Complete retraining is needed. 
	It appears that more information about the layout of the world is needed to navigate to the goal. 
	It may be better to have a Q-matrix dedicated to collision avoidance based on the binary vector for imminent crashes and another separate Q-matrix dedicated to navigation based on the positions of the buildings.

Future Work:
	Evaluation errors have already been eliminated but retraining has yet to be done. Providing the learning-agent with more complex state information and using two separate learners has yet to be coded.
	As stated in the introduction, the problem was simplified greatly, therefore, in the future (i.e. over winter break) the complexity should be ramped back up to the original problem. First, with the simple incorporation of diagonal moves and adding in the features of stop signs and traffic lights. Next making the individual car movements asynchronous and more random. Next, making the space continuous and giving the agent differential drive. And finally distinguishing between one-way and two-way streets. This order was assigned according to the apparent difficulty of code modification, rather than the strain on the learning process.
	The discrete to continuous change will likely require significant re-coding as well as a change from a Q-matrix to a Deep-Q Network.
