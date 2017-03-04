function [InitFunction, CostFunction, FeasibleFunction] = MLP_Iris

InitFunction = @MLP_IrisInit;
CostFunction = @MLP_IrisCost;
FeasibleFunction = @MLP_IrisFeasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = MLP_IrisInit(OPTIONS)

global MinParValue MaxParValue
Granularity = 0.1;
[Max_iter,ub,lb,N] = loadParameters();

MinParValue = lb;
MaxParValue = ub;

%MaxParValue = floor(1 + 2 * 2.048 / Granularity);
% Initialize population
for popindex = 1 : OPTIONS.popsize
    chrom = (MinParValue + (MaxParValue - MinParValue) * rand(1,OPTIONS.numVar));
    Population(popindex).chrom = chrom;
end
OPTIONS.OrderDependent = true;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Population] = MLP_IrisCost(OPTIONS, Population,net,inputs,targets)

 
global MinParValue MaxParValue
popsize = OPTIONS.popsize;
for popindex = 1 : popsize
   
        
        Population(popindex).cost=costALL(Population(popindex).chrom, net, inputs, targets);
end
return
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = MLP_IrisFeasible(OPTIONS, Population)

global MinParValue MaxParValue

for i = 1 : OPTIONS.popsize
    for k = 1 : OPTIONS.numVar
        Population(i).chrom(k) = max(Population(i).chrom(k), MinParValue);
        Population(i).chrom(k) = min(Population(i).chrom(k), MaxParValue);
    end
end
return;
        
        
