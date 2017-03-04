function out = costALL(in, net, inputs, targets)
% 


net = setx(net, in');
%net = setwb(net, x'); new version
% To evaluate the ouputs based on the given
% weights and biases vector
%y = net(inputs);

%  X = size(getx(net))
% 
%  
%  b = net.b
%  size(b)
% iw = net.IW
%  size(iw)
% lw = net.LW
%  size(lw)
%  net.numInputs
%  pause;

y = sim(net,inputs);



%%%%%%%%%%%MSE cost function%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mse_calc= sum((y-targets).^2)/length(y);
out=mse_calc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [c,cm,ind,per] = confusion(targets,y);
% Acc= 1- (cm(1,1)+cm(2,2))/(cm(1,1)+cm(1,2)+cm(2,1)+cm(2,2));
% out=Acc;



%[X,Y,T,AUC] = perfcurve(targets,y,'1');

%%%%%%%%%%%AUC cost function%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%k=round(y');
%[AUC2] = 1-colAUC(k,targets','1' ,'abs', false);
%out = 1-AUC2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%k=round(y');
%[AUC] = fastAUC(targets',k,1);

%out = 1- colAUC(k, targets');
%out = 1-colAUC( k, targets','Wilcoxon', 'abs', false);



%out=mse_calc;