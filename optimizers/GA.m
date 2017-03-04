function [Best,MinCost] = GA(dim,net,inputs,targets)

% Genetic algorithm for optimizing a general function.

% INPUTS: ProblemFunction is the handle of the function that returns 
%         the handles of the initialization, cost, and feasibility functions.
%         DisplayFlag says whether or not to display information during iterations and plot results.
ProblemFunction= @MLP_Iris;
if ~exist('DisplayFlag', 'var')
    DisplayFlag = true;
end

%seed =floor(rand(1)*1000);

if ~exist('RandSeed', 'var')
    RandSeed = round(sum(100*clock));
end

[OPTIONS, MinCost, AvgCost, InitFunction, CostFunction, FeasibleFunction, ...
    MaxParValue, MinParValue, Population] = Init(DisplayFlag, ProblemFunction,RandSeed,net,inputs,targets,dim);

Xover_Type = 1; % crossover type: 1 = single point, 2 = two point, 3 = uniform
OPTIONS.pcross = 1; % crossover probability
OPTIONS.pmutate = 0.01; % initial mutation probability
Keep = 2; % elitism parameter: how many of the best individuals to keep from one generation to the next

% Begin the evolution loop
for GenIndex = 1 : OPTIONS.Maxgen
    % Compute the inverse of the cost. Fitness increases with inverse cost.
    InverseCost = [];
    for i = 1 : OPTIONS.popsize
        InverseCost = [InverseCost, 1 / Population(i).cost];
    end
    for k = Keep+1 : 2 : OPTIONS.popsize % begin selection/crossover loop
        % Select two parents to mate and create two children - roulette wheel selection
        mate = [];
        for selParents = 1 : 2
            Random_Cost = rand * sum(InverseCost);
            Select_Cost = InverseCost(1);
            Select_index = 1;
            while Select_Cost < Random_Cost 
                Select_index = Select_index + 1;
                if Select_index >= OPTIONS.popsize
                    break;
                end
                Select_Cost = Select_Cost + InverseCost(Select_index);
            end
            mate = [mate Select_index];
        end
        Parent(1, :) = Population(mate(1)).chrom;
        Parent(2, :) = Population(mate(2)).chrom;
        % Crossover
        switch Xover_Type
            case 1
                % single point crossover
                if OPTIONS.pcross > rand
                    % crossover the parents
                    Xover_Pt = ceil(rand * OPTIONS.numVar);
                    % x = genes in parent 1 that are not in parent 2 (after crossover point)
                    x = setdiff(Parent(1, Xover_Pt:OPTIONS.numVar), Parent(2, Xover_Pt:OPTIONS.numVar));
                    % y = genes in parent 2 that are not in parent 1 (after crossover point)
                    y = setdiff(Parent(2, Xover_Pt:OPTIONS.numVar), Parent(1, Xover_Pt:OPTIONS.numVar));
                    child(k-Keep, :) = [Parent(1, 1:OPTIONS.numVar-length(y)), y];
                    child(k-Keep+1, :) = [Parent(2, 1:OPTIONS.numVar-length(x)), x];
                else
                    % clone the parents
                    child(k-Keep, :) = Parent(1, :);
                    child(k-Keep+1, :) = Parent(2, :);
                end
            case 2
                % multipoint crossover
                if OPTIONS.pcross > rand
                    Xover_Pt1 = ceil(rand * OPTIONS.numVar);
                    Xover_Pt2 = ceil(rand * OPTIONS.numVar);
                    if Xover_Pt1 > Xover_Pt2
                        temp = Xover_Pt2;
                        Xover_Pt2 = Xover_Pt1;
                        Xover_Pt1 = temp;
                    end
                    child(k-Keep, :) = [Parent(1, 1:Xover_Pt1) Parent(2, Xover_Pt1+1:Xover_Pt2) Parent(1, Xover_Pt2+1:OPTIONS.numVar)];
                    child(k-Keep+1, :) = [Parent(2, 1:Xover_Pt1) Parent(1, Xover_Pt1+1:Xover_Pt2) Parent(2, Xover_Pt2+1:OPTIONS.numVar)];
                else
                    child(k-Keep, :) = Parent(1, :);
                    child(k-Keep+1, :) = Parent(2, :);
                end
            case 3 
                % uniform crossover
                for i = 1 : OPTIONS.numVar
                    if OPTIONS.pcross > rand
                        child(k-Keep, i) = Parent(1, i);
                        child(k-Keep+1, i) = Parent(2, i);
                    else
                        child(k-Keep, i) = Parent(2, i);
                        child(k-Keep+1, i) = Parent(1, i);
                    end
                end
        end
    end % end selection/crossover loop
    % Replace the non-elite population members with the new children
    for k = Keep+1 : 2 : OPTIONS.popsize
        Population(k).chrom = child(k-Keep, :);
        Population(k+1).chrom = child(k-Keep+1, :);
    end
    % Mutation
    for individual = Keep + 1 : OPTIONS.popsize % Don't allow the elites to be mutated
        for parnum = 1 : OPTIONS.numVar
            if OPTIONS.pmutate > rand
                Population(individual).chrom(parnum) = floor(MinParValue + (MaxParValue - MinParValue + 1) * rand);
            end
        end
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
