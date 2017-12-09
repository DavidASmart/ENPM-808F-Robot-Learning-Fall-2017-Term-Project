# ENPM-808F-Robot-Learning-Fall-2017-Term-Project
Autonomous Car in City-Maze (Game) with Q-Learning


Abstract:

		The problem of training an autonomous car to navigate through a city to a destination without crashing or breaking the law was simplified significantly to the point where the challenge was more like a computer game. Two attempts were made at solving the simplified problem using Q-learning. In the future, it is planned to regain some of the complexity of the original problem.
  
  
Intorduction

		The original proposed goal for this term project was to simulate a differential-drive car which would learn by policy iteration how to navigate through a city (set up like a maze) to a set of coordinates without crashing or breaking the law. This city was to have stop signs and traffic lights, two way and one way streets, and other cars. The original proposal also stated that the learning algorithm would be written in MATLAB, but the simulation would be done in the V-REP simulation environment, which is essentially a continuous space, therefore allowing for continuous state values. V-REP also has realistic simulated sensors which would have been used for determining the state.
  
		Some changes were made from the original proposed project. First, after learning about Q-learning and implementing it for homework assignment four on tic-tac-toe, it was decided that Q-learning was to be the learning algorithm of choice. Second, to start, the problem was simplified to the point where it is more like a simple computer game. The V-REP interface was abandoned, and the simulation was done with MATLAB plots. Sensor modeling was abandoned for a direct state omniscience. The space was discretized to a grid, and the differential drive control was abandoned for the 4 basic cardinal movements (up, down, right, and left) and stop. The stop signs, traffic lights, and different streets types were ignored for the time being. The pre-programed cars were kept as a part of the problem. 
	
		Q-Learning is a model free reinforcement learning method which uses a table or matrix to store values for state-action pairs, called Q-values. The Q-values represent, the expected “discounted” reward of taking a certain action. The “Discounted” reward is a time-sequence weighted reward. To be clear, the state which results in a reward may not be attained by the immediate action, but will result in the future from of a series of actions including the immediate one. The action with the highest value for a state is chosen such that the Q-values act as a policy, although the policy is never made explicit (model free). The Q-values are initialized to zero, and learning is achieved by updating the Q-values as the learning agent tries different actions in different states and receives rewards (reinforcement learning). The update equation is:

				Q(s(t-1),a(t-1))  = (1-α)*Q(s(t-1),a(t-1))  +  α*[(r(s(t)) + γ*Q(s(t),a(t))]			                                    (eq. 1)

		Equation 1 can be explained as a weighting of the reward, current Q-value, and previous Q-value. The reward from the current state, r(s(t)), and Q-value of current state-action pair, Q(s(t),a(t)), are weighted together using the discounting factor, γ, and then that value is weighted together with the value of the previous state-action pair, Q(s(t-1),a(t-1)), using the learning rate, α , to update the value of the previous state-action pair, Q(s(t-1),a(t-1)).


Approach:

		The actions available to the agent were up, down, right, left, and stop. 
	
		The state variables chosen were the distance from the agent to the goal in both x and y, and a binary vector indicating if a certain action would result in a crash (0 – no, 1 – yes). After the first training attempt it was decided that the state needed to be expanded to include oscillation detection because the optimal Q-matrix was still prone to oscillate indefinitely. This was done using a single value which represented the sequence of actions taken when oscillating. Instead of having to convert the combination of state variables into a single index value, a separate index (or dimension) was used for each of the state variables. Thus, the Q-value table was a Q-value matrix.
	
  	The rewards were simple. If the learning agent arrived at the goal, it was rewarded with a positive constant. If the learning agent crashed, it was rewarded with a negative constant. Otherwise it received a reward of zero.
	
  	The learning rate, α, was calculated as the inverse to the number of times the state-action pair, for which the Q-value was to be updated, had been seen during training, whereas the discounting factor, 𝛾, was fixed at 0.9. Therefore, the update sizes diminished to ensure convergence, but the weighting of future rewards remained the same throughout for consistency. ε-greedy action selection was used to sufficiently explore the state-action space.
	
		Epsilon, ε, was linearly interpolated between 0.75 and 0.01 based on the episode count so that the amount of exploration done was reduced as training progressed.
  
  
Implementation:
  
		First the “grid-world” was created with buildings, cars, agent, and goal initialized within the “grid-world”. The world was made with three different layouts. A grid, where all the buildings are arranged like a checkerboard, a maze where the buildings are generated randomly, and a combination of the two where random buildings are placed in addition to the grid.

		Second, the cars were given a simple control system to move in a specified sequence without crashing into buildings, such that they would travel in a square half the size of the map if there were no obstacles. All the cars were synchronized in their movements.
Third, a function was written for both the cars as well as for the learning-agent to detect if certain actions would result in a crash. This was determined from the difference in the positions of the objects. For both the cars and the agent, a crash with a wall was said to imminent if the distance in the direction of movement was less than 1 unit. For the cars, the same was done for determining an imminent crash with other cars. This was true because their movements were synchronized. For the agent, however, without giving the agent the knowledge of the direction of their movement the agent would need to be more cautious such that a collision was considered imminent if two units away. Furthermore, if the car was at a diagonal to the learning agent, the agent could not move in either direction toward the car because of the uncertainty about the direction of motion. This was later determined to be inadequate. First, the cars were made to not crash into the agent and the agent’s evaluation for crashing into cars was modified to include knowledge of car movement direction.

		Finally, a script was made to implement the reinforcement learning. Returning to the state matrix of the Q-value matrix, the distance to the goal could be a negative value, so the size of the world was added to ensure the values would always be positive to be used as an index in the Q-value matrix. The binary vector, of length 4, for detecting an imminent crash was binary vector converted to an index value between 1 and 2^4. Therefore, the size of the Q-value matrix was (twice the world size) × (twice the world size) × (2^4) × (5). With the changes made after the first training attempt, the Q-value matrix was expanded to include another dimensions with length 5 for each possibility of oscillation.
  
		The agent was always initialized to the bottom left corner of the world to avoid initializing it on top of walls, whereas the world was cycled through the three different layouts, and the other cars as well as the goal were initialized randomly within the map to ensure exploration of the state-action space. After the first training attempt, only the grid-maze combination world layout was used because it was determined to be the best representation of a real city. 
  
		The number of episodes was set to 10,000 because of the time required to run the simulations. And a time limit was set on each episode to avoid exceedingly long episodes due to perfect collision avoidance but imperfect navigation, particularly oscillations. After the first training attempt, the training duration was extended to 280,000 episodes because more training was required for solution convergence.


Results

    During training, several statistics were recorded. The sum of the Q-values and the number of crashes, goals reached, and time limits exceeded. Based on the graph of the sum of the Q-values against episodes, one can clearly see that the Q-values did not converge despite the asymptotic nature of the learning rate, therefore the training simply needed more time to reach the optimal Q-matrix.

		During the second round of training, for both the Q-values and the episode results, a rate of change was calculated for each 1000 episodes. As before, it was clear from the plot of the absolute value of the sum of the Q-values that the training was not complete. A round of testing with 25 episodes was conducted anyhow and 24% of episodes ended with a collision.

		At this point, the second attempt at training had gone on for more than 21 hours, so extending it another 21 hours would be impractical. An extension of 80,000 episodes (which took about 5 hours) was attempted with reduced epsilon linearly interpolated between 0.375 and 0.005.


Analysis:

		As stated previously in the results section, the optimal Q-value matrix was not achieved during the first training attempt due to a lack of training episodes. Although this is true, the optimal Q-value matrix would still result in an imperfect policy. The best the learning agent can do with the state information supplied to it is to move toward the goal without crashing into buildings, and running away from cars. However, this results in oscillations when there is a building larger than a single unit between the agent and the goal unless it is forced to run away from the cars. Furthermore, because it runs away from the cars it is often unable to bypass them to get to the goal even if it could with crashing. Lastly, running away from the cars can sometimes result in the agent becoming trapped between buildings and cars and then getting hit by a car. To address this, several changes were made, as outlined in the approach and implementation sections.
    
		With the changes, the optimal policy was too complex to produce by hand. The best attempt at hard-coding the optimal policy (via the Q-values) never resulted in crashes, but still resulted in time-outs.
		
		During the second attempt at training a counter was added for crash evaluation errors. In other words, if an action was taken, which result in a crash, despite the vector for imminent crashes indicating that action would not result in a crash there was an evaluation error. An evaluation error indicates imperfect knowledge of the state, which would mess-up the Q-values. During the second round of training 12,400 evaluation errors were detected, which amounted to 5.6 % of crashes, and occurred in 4.4 % of episodes. The error was caught before the 80,000-episode extension to the second round of training, but the damage may already have been done. A complete retraining is likely needed. 

		It appears that more information about the layout of the world is needed to navigate to the goal. It may be better to have a Q-matrix dedicated to collision avoidance based on the binary vector for imminent crashes and another separate Q-matrix dedicated to navigation based on the positions of the buildings.


Conclusions:

		The problem of training an autonomous car to navigate through a city to a destination without crashing or breaking the law was simplified significantly to the point where the challenge is more like a computer game. The simplified problem was essentially to navigate any 10×10 “grid-world” with both stationary and moving obstacles to a goal without crashing. 
    
    Two attempts were made at solving the simplified problem using Q-learning. The first attempt had the learning-agent chose its action before the moving obstacles chose theirs and the moving obstacles could hit the agent. This resulted in avoiding, rather than by-passing the moving obstacles yet ironically allowed for cashes anyhow. Furthermore, in the first attempt, the learner could not detect whether it was stuck oscillating endlessly. In the second attempt these issues were resolved, and training was extended significantly, however, a perfect policy still did not emerge.

    It is believed that this was partially a consequence of evaluation errors, but also an issue with the state information provided to the learning-agent.  In the future, another attempt will be made to solve this problem and to regain some of the complexity of the original problem, as outlined in the following section.


Future Work:

		In the future, another attempt will be made to solve this problem, by eliminating evaluation errors, providing the learning-agent with more complex state information, and possibly using two separate learners.
    
    As stated in the introduction, the problem was simplified greatly, therefore, in the future (i.e. over winter break) the complexity should be ramped back up to the original problem. First, with the simple incorporation of diagonal moves and adding in the features of stop signs and traffic lights. Next making the individual car movements asynchronous and more random. Next, making the space continuous and giving the agent differential drive. And finally distinguishing between one-way and two-way streets. This order was assigned according to the apparent difficulty of code modification, rather than the strain on the learning process.
	
    The discrete to continuous change will likely require significant re-coding as well as a change from a Q-matrix to a Deep-Q Network.
