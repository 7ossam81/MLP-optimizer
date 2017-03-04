function [cmTraining, cmTesting,convergence]  = optimizeMVO(dataset,NumberOfNeurons)


%load bank-direct-marketing-small;
load(dataset);
%load blood;
%load spamsetv3-filtered;


inputs=xtrain;
targets=ytrain;

[k,l] = size(xtrain);
n=l*2+1; % number of hidden neurons equals to 2*(number of features) +1 
%n=NumberOfNeurons;


xtest=xtest';
ytest=ytest';


inputs =inputs';
targets=targets';

% Number of neruons in the hidden layer
%n = 10;

%%%%%%%%%%%%%%
% find number of rows in the dataset
[k,l] = size(inputs);

% create a neural network
%net = feedforwardnet(n);
%net = newff(n,inputs, targets);
net = newpr(inputs,targets,n);


[x_ga_opt,convergence]= MVO(k*n+2*n+1,net,inputs,targets); % k*n+2*n+1 is  the total numebr of weights in the network


net = setx(net, x_ga_opt');
%y = sim(net,inputs);

% training results
predictionTraining = sim(net,inputs);
%plotconfusion(targets,predictionTraining)
[ct,cmt,indt,pert] = confusion(targets,predictionTraining);
cmTraining=cmt

% testing results
prediction = sim(net,xtest);
%plotconfusion(ytest,prediction)
[c,cm,ind,per] = confusion(ytest,prediction);
cmTesting=cm