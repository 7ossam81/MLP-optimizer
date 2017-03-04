function [Best]=Conclude(DisplayFlag, OPTIONS, Population, nLegal, MinCost)

% Output results of population-based optimization algorithm.

if DisplayFlag
    % Count the number of duplicates
    NumDups = 0;
    for i = 1 : OPTIONS.popsize
        Chrom1 = sort(Population(i).chrom);
        for j = i+1 : OPTIONS.popsize
            Chrom2 = sort(Population(j).chrom);
            if isequal(Chrom1, Chrom2)
                NumDups = NumDups + 1;
            end
        end
    end  
    disp([num2str(NumDups), ' duplicates in final population.']);
    disp([num2str(nLegal), ' legal individuals in final population.']);
    % Display the best solution
    Chrom = (Population(1).chrom);
    Best=Chrom;
    disp(['Best chromosome = ', num2str(Chrom)]); 
    % Plot some results
    %close all;
    %plot([0:OPTIONS.Maxgen], MinCost, 'r');
    %xlabel('Generation');
    %ylabel('Minimum Cost');
end
return;