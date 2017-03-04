function evalall


addpath('MVO','datasets','optimizers','colAUC');

A = {'Algorithms','Dataset','Experiment','AUC','TP','FP', 'FN','TN'};

% List of available datasets
Dataset= {'wdbc','diabetes'};
  

% List of available optimizers
algorithm={'MVO','GA','PSO','BBO'};


% Set any optimizer to 1 to include it in your experiment    
GA=1; %
PSO=1;  %  
BBO=1;
MVO=1;  %  %Multiverse Optimizer

% How many times you want to repeat each experiment ?
NoOfExperiments=1;

algo = [MVO GA PSO BBO];



%%%%%%%%% create file name %%%%%%%
x=fix(clock);
str=strtrim(cellstr(num2str(x'))');
strs_spaces = sprintf('-%s' ,str{:});
trimmed = strtrim(strs_spaces);
filename=strcat('Experiments',trimmed);
filename= strcat(filename,'.xlsx');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 


[row col]=size(algo);
ii=1; % Counter for total experiments
for a=1:col %Select algorithms
    if(algo(a)==1) 
    
for d=1:2 % This will pass over the first two datasets
   
xlRange = 'A1';
xlswrite(filename,A,'training',xlRange)
xlswrite(filename,A,'testing',xlRange)
con =1;
for i=1:NoOfExperiments % repeat each algorithm n times 
     
     display(['******* ', algorithm{a}, ' ************']);
     display(['******* ', Dataset{d}, ' ************']);
     fprintf('Experiment ==> %i \r', i); pause(1);
    [x1,x2,auc1,auc2,convergence]=optimizeall(a,Dataset{d});
    
    B= {algorithm{a},Dataset{d},strcat('Experiment',num2str(i)),auc1,x1(1),x1(2),x1(3),x1(4)}; %training results
    C= {algorithm{a},Dataset{d},strcat('Experiment',num2str(i)),auc2,x2(1),x2(2),x2(3),x2(4)}; %testing results

    xlRange = strcat('A',num2str(ii+1));
    xlswrite(filename,B,'training',xlRange);
    xlRange = strcat('A',num2str(ii+1));
    xlswrite(filename,C,'testing',xlRange);

    
   D= {algorithm{a},Dataset{d},strcat('Experiment',num2str(i))};
   xlswrite(filename,D,'convergences',strcat('A',num2str(ii)));
   xlswrite(filename,convergence,'convergences',strcat('D',num2str(ii)));

   con=con+1;

    ii=ii+1;
 

end
end

    end
end



