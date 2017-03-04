function [Best MinCost] = PSO(dim,net,inputs,targets)

% Particle swarm optimization for optimizing a general function.

% INPUTS: ProblemFunction is the handle of the function that returns 
%         the handles of the initialization, cost, and feasibility functions.
%         DisplayFlag says whether or not to display information during iterations and plot results.
ProblemFunction= @MLP_Iris;
if ~exist('DisplayFlag', 'var')
    DisplayFlag = true;
end


if ~exist('RandSeed', 'var')
    RandSeed = round(sum(100*clock));
end

[OPTIONS, MinCost, AvgCost, InitFunction, CostFunction, FeasibleFunction, ...
    MaxParValue, MinParValue, Population] = Init(DisplayFlag, ProblemFunction,RandSeed,net,inputs,targets,dim);

OPTIONS.Keep = 2; % elitism parameter: how many of the best particles to keep from one iteration to the next
OPTIONS.neighbors = 0; % size of particle swarm neighborhood
OPTIONS.w = 0.3; % inertial constant
OPTIONS.c1 = 1; % cognitive constant
OPTIONS.c2 = 1; % social constant for swarm interaction
OPTIONS.c3 = 1; % social constant for neighborhood interaction

% PSO initialization
vel = zeros(OPTIONS.popsize, OPTIONS.numVar); % velocities
pbest = Population; % personal best of each particle
nbest = Population; % neighborhood best of each particle
gbest = Population(1); % global best

% Begin the optimization loop
for GenIndex = 1 : OPTIONS.Maxgen
    if ~OPTIONS.OrderDependent
        % Sort position and velocity data of each particle
        for i = 1 : OPTIONS.popsize
            [chrom, indices] = sort(Population(i).chrom);
            Population(i).chrom = chrom;
            VelTemp = vel(i, :);
            for j = 1 : OPTIONS.numVar
                vel(i, j) = VelTemp(indices(j));
            end
        end
    end
    % Update the global best if needed
    if Population(1).cost < gbest.cost
        gbest = Population(1);
    end
    % Update personal best and neighborhood best for each particle
    for i = 1 : OPTIONS.popsize 
        % Update each personal best if needed
        if Population(i).cost < pbest(i).cost
            pbest(i) = Population(i);
        end
        % Update each neighborhood best if needed
        Distance = zeros(OPTIONS.popsize, 1);
        for j = 1 : OPTIONS.popsize 
            Distance(j) = norm(Population(i).chrom-Population(j).chrom);
        end
        [Distance, indices] = sort(Distance);
        nbest(i).cost = inf;
        for j = 2 : OPTIONS.neighbors+1
            nindex = indices(j);
            if Population(nindex).cost < nbest(i).cost
                nbest(i) = Population(nindex);
            end
        end
    end
    % Update the position and velocity of each particle (except the elites)
    for i = OPTIONS.Keep+1 : OPTIONS.popsize
        r = rand(3, OPTIONS.numVar);
        x = Population(i).chrom;
        deltaVpersonal = OPTIONS.c1 * r(1,:) .* (pbest(i).chrom - x);
        deltaVswarm = OPTIONS.c2 * r(2,:) .* (gbest.chrom - x);
        deltaVneighborhood = OPTIONS.c3 * r(3,:) .* (nbest(i).chrom - x);
        vel(i,:) = OPTIONS.w * vel(i,:) + deltaVpersonal + deltaVswarm + deltaVneighborhood;
        Population(i).chrom = x + vel(i,:);
    end 
    % Make sure the population does not have duplicates. 
    Population = ClearDups(Population, MaxParValue, MinParValue);
    % Make sure each individual is legal.
    Population = FeasibleFunction(OPTIONS, Population);
    % Calculate cost
    Population = CostFunction(OPTIONS, Population,net,inputs,targets);
    % Sort from best to worst
    Population = PopSort(Population);
    % Compute the average cost of the valid individuals
    [AverageCost, nLegal] = ComputeAveCost(Population);
    % Display info to screen
    MinCost = [MinCost Population(1).cost];
    AvgCost = [AvgCost AverageCost];
    if DisplayFlag
        disp(['The best and mean of Generation # ', num2str(GenIndex), ' are ',...
            num2str(MinCost(end)), ' and ', num2str(AvgCost(end))]);
    end
end
Best=Conclude(DisplayFlag, OPTIONS, Population, nLegal, MinCost);
return;
