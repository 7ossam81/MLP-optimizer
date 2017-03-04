function [MeanMin, MeanMinNorm, BestMin, BestMinNorm, MeanCPU] = Monte

% Monte Carlo execution of population-based optimization software
% OUTPUT MeanMin is the mean of the best solution found. It is a
% nFunction x nBench array, where nFunction is the number of optimization
% functions that are used, and nBench is the number of benchmarks that
% are optimized.
% OUTPUT MeanMinNorm is MeanMin normalized to a minimum of 1 for each benchmark.
% OUTPUT BestMin is the best solution found by each optimization function
% for each benchmark.
% OUTPUT BestMinNorm is BestMin normalized to a minimum of 1 for each benchmark.
% OUTPUT MeanCPU is the mean CPU time required for each optimization function
% normalized to 1.

nMonte = 100; % number of Monte Carlo runs

% Optimization methods
OptFunction = [
'ACO   '; % ant colony optimization
'BBO   '; % biogeography-based optimization
'DE    '; % differential evolution
'ES    '; % evolutionary strategy
'GA    '; % genetic algorithm
'PBIL  '; % probability based incremental learning
'PSO   '; % particle swarm optimization
'StudGA']; % stud genetic algorithm

% Benchmark functions
 Bench = [     %     multimodal? separable?  regular?
 'Ackley    '; %     y           n           y
 'Fletcher  '; %     y           n           n
 'Griewank  '; %     y           n           y
 'Penalty1  '; %     y           n           y
 'Penalty2  '; %     y           n           y
 'Quartic   '; %     n           y           y
 'Rastrigin '; %     y           y           y
 'Rosenbrock'; %     n           n           y
 'Schwefel  '; %     y           y           n
 'Schwefel2 '; %     n           n           y
 'Schwefel3 '; %     y           n           n
 'Schwefel4 '; %     n           n           n
 'Sphere    '; %     n           y           y
 'Step      ']; %    n           y           n

%Bench = ['MAPSS'];

nFunction = size(OptFunction, 1);
nBench = size(Bench, 1);
MeanMin = zeros(nFunction, nBench);
BestMin = inf(nFunction, nBench);
MeanCPU = zeros(nFunction, nBench);
for i = 1 : nFunction
    for j = 1 : nBench
        disp(['Optimization method ', num2str(i), '/', num2str(nFunction), ...
            ', Benchmark function ', num2str(j), '/', num2str(nBench)]);
        for k = 1 : nMonte
            tic;
            [Cost] = eval([OptFunction(i,:), '(@', Bench(j,:), ', false);']);
            MeanCPU(i,j) = ((k - 1) * MeanCPU(i,j) + toc) / k;            
            MeanMin(i,j) = ((k - 1) * MeanMin(i,j) + Cost(end)) / k;
            BestMin(i,j) = min(BestMin(i,j), Cost(end));
        end
    end
end
% Normalize the results
if min(MeanMin) == 0
    MeanMinNorm = [];
else
    MeanMinNorm = MeanMin * diag(1./min(MeanMin));
end
if min(BestMin) == 0
    BestMinNorm = [];
else
    BestMinNorm = BestMin * diag(1./min(BestMin));
end
MeanCPU = min(MeanCPU');
MeanCPU = MeanCPU / min(MeanCPU);