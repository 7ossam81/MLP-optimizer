function [cmTraining, cmTesting,auctrain,auctest,convergence]   = optimizeall(algorithm,dataset)


%load dataset
load(dataset);
inputs=xtrain';
targets=ytrain';
xtest=xtest';
ytest=ytest';

% Find number of features in the dataset
[k,l] = size(xtrain);




NumberOfNeurons=l*2+1; % number of hidden neurons equals to 2*(number of features) +1 
dim=l*NumberOfNeurons+2*NumberOfNeurons+1; % Total number of weights and biases to optimize (dimensions of the problem)


%%%%%%%%%%%%%%
net = newpr(inputs,targets,NumberOfNeurons); % Create Net structure
%%%%%%%%%%%%%%%%%%%%%

  if (algorithm==1)
     [x_ga_opt, convergence] =MVO(dim,net,inputs,targets);
  elseif (algorithm==2)
     [x_ga_opt, convergence] =GA(dim,net,inputs,targets);
  elseif (algorithm==3)
     [x_ga_opt, convergence] =PSO(dim,net,inputs,targets);    
  elseif (algorithm==4)
     [x_ga_opt, convergence] =BBO(dim,net,inputs,targets);
  end


net = setx(net, x_ga_opt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% training results
predictionTraining = sim(net,inputs);
[ct,cmt,indt,pert] = confusion(targets,predictionTraining);
cmTraining=cmt
auctrain = colAUC(predictionTraining', targets','ROC');


% testing results
prediction = sim(net,xtest);
[c,cm,ind,per] = confusion(ytest,prediction);
cmTesting=cm
auctest = colAUC(prediction', ytest','ROC');

  