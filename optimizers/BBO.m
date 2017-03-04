function [Best,MinCost] = BBO(dim,net,inputs,targets)


ProblemFunction= @MLP_Iris;
DisplayFlag=1;
ProbFlag=1;
%RandSeed=floor(rand(1)*1000);

% Biogeography-based optimization (BBO) software for minimizing a general function

% INPUTS: ProblemFunction is the handle of the function that returns 
%         the handles of the initialization, cost, and feasibility functions.
%         DisplayFlag = true or false, whether or not to display and plot results.
%         ProbFlag = true or false, whether or not to use probabilities to update emigration rates.
%         RandSeed = random number seed
% OUTPUTS: MinCost = array of best solution, one element for each generation
%          Hamming = final Hamming distance between solutions
% CAVEAT: The "ClearDups" function that is called below replaces duplicates with randomly-generated
%         individuals, but it does not then recalculate the cost of the replaced individuals. 
 
if ~exist('DisplayFlag', 'var')
    DisplayFlag = true;
end
if ~exist('ProbFlag', 'var')
    ProbFlag = false;
end
if ~exist('RandSeed', 'var')
    RandSeed = round(sum(100*clock));
end

[OPTIONS, MinCost, AvgCost, InitFunction, CostFunction, FeasibleFunction, ...
    MaxParValue, MinParValue, Population] = Init(DisplayFlag, ProblemFunction,RandSeed,net,inputs,targets,dim);

Population = CostFunction(OPTIONS, Population,net,inputs,targets);

OPTIONS.pmodify = 1; % habitat modification probability
OPTIONS.pmutate = 0.005; % initial mutation probability

Keep = 2; % elitism parameter: how many of the best habitats to keep from one generation to the next
lambdaLower = 0.0; % lower bound for immigration probabilty per gene
lambdaUpper = 1; % upper bound for immigration probabilty per gene
dt = 1; % step size used for numerical integration of probabilities
I = 1; % max immigration rate for each island
E = 1; % max emigration rate, for each island
P = OPTIONS.popsize; % max species count, for each island

% Initialize the species count probability of each habitat
% Later we might want to initialize probabilities based on cost
for j = 1 : length(Population)
    Prob(j) = 1 / length(Population); 
end

% Begin the optimization loop
for GenIndex = 1 : OPTIONS.Maxgen
    % Save the best habitats in a temporary array.
    for j = 1 : Keep
        chromKeep(j,:) = Population(j).chrom;
        costKeep(j) = Population(j).cost;
    end
    % Map cost values to species counts.
    [Population] = GetSpeciesCounts(Population, P);
    % Compute immigration rate and emigration rate for each species count.
    % lambda(i) is the immigration rate for habitat i.
    % mu(i) is the emigration rate for habitat i.
    [lambda, mu] = GetLambdaMu(Population, I, E, P);
    if ProbFlag
        % Compute the time derivative of Prob(i) for each habitat i.
        for j = 1 : length(Population)
            % Compute lambda for one less than the species count of habitat i.
            lambdaMinus = I * (1 - (Population(j).SpeciesCount - 1) / P);
            % Compute mu for one more than the species count of habitat i.
            muPlus = E * (Population(j).SpeciesCount + 1) / P;
            % Compute Prob for one less than and one more than the species count of habitat i.
            % Note that species counts are arranged in an order opposite to that presented in
            % MacArthur and Wilson's book - that is, the most fit
            % habitat has index 1, which has the highest species count.
            if j < length(Population)
                ProbMinus = Prob(j+1);
            else
                ProbMinus = 0;
            end
            if j > 1
                ProbPlus = Prob(j-1);
            else
                ProbPlus = 0;
            end
            ProbDot(j) = -(lambda(j) + mu(j)) * Prob(j) + lambdaMinus * ProbMinus + muPlus * ProbPlus;
        end
        % Compute the new probabilities for each species count.
        Prob = Prob + ProbDot * dt;
        Prob = max(Prob, 0);
        Prob = Prob / sum(Prob); 
    end
    % Now use lambda and mu to decide how much information to share between habitats.
    lambdaMin = min(lambda);
    lambdaMax = max(lambda);
    for k = 1 : length(Population)
        if rand > OPTIONS.pmodify
            continue;
        end
        % Normalize the immigration rate.
        lambdaScale = lambdaLower + (lambdaUpper - lambdaLower) * (lambda(k) - lambdaMin) / (lambdaMax - lambdaMin);
        % Probabilistically input new information into habitat i
        for j = 1 : OPTIONS.numVar
            if rand < lambdaScale
                % Pick a habitat from which to obtain a feature
                RandomNum = rand * sum(mu);
                Select = mu(1);
                SelectIndex = 1;
                while (RandomNum > Select) & (SelectIndex < OPTIONS.popsize)
                    SelectIndex = SelectIndex + 1;
                    Select = Select + mu(SelectIndex);
                end
                Island(k,j) = Population(SelectIndex).chrom(j);
            else
                Island(k,j) = Population(k).chrom(j);
            end
        end
    end
    if ProbFlag
        % Mutation
        Pmax = max(Prob);
        MutationRate = OPTIONS.pmutate * (1 - Prob / Pmax);
        % Mutate only the worst half of the solutions
        Population = PopSort(Population);
        for k = round(length(Population)/2) : length(Population)
            for parnum = 1 : OPTIONS.numVar
                if MutationRate(k) > rand
                    Island(k,parnum) = floor(MinParValue + (MaxParValue - MinParValue + 1) * rand);
                end
            end
        end
    end
    % Replace the habitats with their new versions.
    for k = 1 : length(Population)
        Population(k).chrom = Island(k,:);
    end
    % Make sure each individual is legal.
    Population = FeasibleFunction(OPTIONS, Population);
    % Calculate cost
    Population = CostFunction(OPTIONS, Population,net,inputs,targets);
    % Sort from best to worst
    Population = PopSort(Population);
    % Replace the worst with the previous generation's elites.
    n = length(Population);
    for k = 1 : Keep
        Population(n-k+1).chrom = chromKeep(k,:);
        Population(n-k+1).cost = costKeep(k);
    end
    % Make sure the population does not have duplicates. 
    Population = ClearDups(Population, MaxParValue, MinParValue);
    % Sort from best to worst
    Population = PopSort(Population);
    % Compute the average cost
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
% Obtain a measure of population diversity
% for k = 1 : length(Population)
%     Chrom = Population(k).chrom;
%     for j = MinParValue : MaxParValue
%         indices = find(Chrom == j);
%         CountArr(k,j) = length(indices); % array containing gene counts of each habitat
%     end
% end
Hamming = 0;
% for m = 1 : length(Population)
%     for j = m+1 : length(Population)
%         for k = MinParValue : MaxParValue
%             Hamming = Hamming + abs(CountArr(m,k) - CountArr(j,k));
%         end
%     end
% end  
if DisplayFlag
    disp(['Diversity measure = ', num2str(Hamming)]);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = GetSpeciesCounts(Population, P)

% Map cost values to species counts.

% This loop assumes the population is already sorted from most fit to least fit.
for i = 1 : length(Population)
    if Population(i).cost < inf
        Population(i).SpeciesCount = P - i;
    else
        Population(i).SpeciesCount = 0;
    end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lambda, mu] = GetLambdaMu(Population, I, E, P)

% Compute immigration rate and extinction rate for each species count.
% lambda(i) is the immigration rate for individual i.
% mu(i) is the extinction rate for individual i.

for i = 1 : length(Population)
    lambda(i) = I * (1 - Population(i).SpeciesCount / P);
    mu(i) = E * Population(i).SpeciesCount / P;
end
return;