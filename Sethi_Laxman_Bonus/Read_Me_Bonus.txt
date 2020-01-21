COP5615 – Fall 2019
Project 2 – Gossip Simulator

Team members: 
•	Ankur Sethi (UFID: 9351-2951)
•	Yogesh Laxman (UFID: 9451-2517)

How to run the application

./project2 num_node topology algorithm failure_percentage
 

What is working?

All the topologies have been successfully implemented on both the algorithms.
Topologies:

•	Full network
•	Line
•	Random 2D Grid
•	3D torus Grid
•	Honeycomb

What is the largest network you managed to deal with for each type of topology and algorithm

		Gossip

		Max Nodes	Time taken
Line		10000		678875
Random 2D	10000		97594
Full		10000		1567448
Torus		10000		6957
Honeycomb	10000		15593
RandHoney	10000		44672

		Push-sum	

		Max Nodes	Time taken
Line		5000		1809174
Random 2D	5000		586422
Full		5000		796515
Torus		5000		46360
Honeycomb	5000		786311
RandHoney	5000		2781

