Let a biogeography-based optimizer train your Multi-Layer Perceptron

Seyedali Mirjalili
March 9, 2014


web: http://www.alimirjalili.com
email: ali.mirjalili@gmail.com

The source codes are mostly identical to those of Professor Dan Simon.

The files in this zip archive are Matlab m-files that can be used to study the following optimization methods:

ant colony optimization (ACO)
biogeography-based optimization (BBO)
evolutionary strategy (ES)
genetic algorithm (GA)
probability-based incremental learning (PBIL)
particle swarm optimization (PSO)


The Matlab files and their descriptions are as follows:

ACO.m, BBO.m, ES.m, GA.m, PBIL.m, PSO.m - These are the optimization algorithms compared in the paper. They can be used to optimize some function by typing, for example, the following at the Matlab prompt:
>> ACO(@Step);
This command would run ACO on the Step function (which is codified in Step.m). 

Main.m - This file is the main file to be run. It trains an MLP for classifying the Iris data set by BBO, PSO, ACO, GA, ES, and PBIL algorithms. It also calculates the classification accuracy of each algorithm at the end. 

my_MLP.m - This file defines a three-layer MLP with given number of input, hidden, and output nodes. 

My_Sigmoind.m - This file is the sigmoind funciton.

Init.m - This contains various initialization settings for the optimization methods. You can edit this file to change the population size, the generation count limit, the problem dimension, and the mutation probability of any of the optimization methods that you want to run.

ClearDups.m - This is used by each optimization method to get rid of duplicate population members and replace them with randomly generated individuals.

ComputeAveCost.m - This is used by each optimization method to compute the average cost of the population and to count the number of legal (feasible) individuals.

PopSort.m - This is used by each optimization method to sort population members from most fit to least fit.

Conclude.m - This is concludes the processing of each optimization method. It does common processing like outputting results.

Monte.m - This can be used to obtain Monte Carlo simulation results. The first executable line specifies the number of simulations to run. This is the highest-level program in this archive, and is the one that Dan ran to create the results in the paper that Dan wrote.

Iris.txt - This file includes the Iris dataset. 