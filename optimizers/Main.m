%      Biogeography-Based Optimization (BBO) trainer for MLP        %
%                      source codes version 1                       %
%                                                                   %
%  Developed in MATLAB R2011b(7.13)                                 %
%                                                                   %
%  Author and programmer: Seyedali Mirjalili                        %
%                                                                   %
%         e-Mail: ali.mirjalili@gmail.com                           %
%                 seyedali.mirjalili@griffithuni.edu.au             %
%                                                                   %
%       Homepage: http://www.alimirjalili.com                       %
%                                                                   %
%   Main paper: S. Mirjalili, S. M. Mirjalili, A. Lewis             %
%               Let A Biogeography-Based Optimizer Train            %
%               Your Multi-Layer Perceptron, Information Sciences,  %
%               In press, 2014,                                     %
%               DOI: http://dx.doi.org/10.1016/j.ins.2014.01.038    %
%-------------------------------------------------------------------%
% This is a demo of the BBO trainer applying to Iris classification 
%                            dataset

clc
clear all

% For modifying initial parameters please have a look at init.m file 

display('..........................................................................................')
display('BBO is training MLP ...')
display('..........................................................................................')
[cg_curve1,Hamming,best] = BBO(@MLP_Iris, 1, 1, 300); % BBO trainer
Best_W_B(1,:)=best;

display('..........................................................................................')
display('PSO is training MLP ...')
display('..........................................................................................')
[cg_curve2,best]= PSO(@MLP_Iris, 1);  % PSO trainer
Best_W_B(2,:)=best;

display('..........................................................................................')
display('GA is training MLP ...')
display('..........................................................................................')
[cg_curve3,best]= GA(@MLP_Iris, 1); % GA trainer
Best_W_B(3,:)=best;

display('..........................................................................................')
display('ACO is training MLP ...')
display('..........................................................................................')
[cg_curve4,best]= ACO(@MLP_Iris, 1); % ACO trainer
Best_W_B(4,:)=best;

display('..........................................................................................')
display('ES is training MLP ...')
display('..........................................................................................')
[cg_curve5,best]= ES(@MLP_Iris, 1); % ES trainer
Best_W_B(5,:)=best;

display('..........................................................................................')
display('PBIL is training MLP ...')
display('..........................................................................................')
[cg_curve6,best]=PBIL(@MLP_Iris, 1); % PBIL trainer
Best_W_B(6,:)=best;

 % Calculating classification rates
  
 load iris.txt
 x=sortrows(iris,2);
 
 H2=x(1:150,1);
 H3=x(1:150,2);
 H4=x(1:150,3);
 H5=x(1:150,4);
 T=x(1:150,5);
  
 H2=H2';
 [xf,PS] = mapminmax(H2);  % Normalzation of input
 I2(:,1)=xf;
 
 H3=H3';
 [xf,PS2] = mapminmax(H3); % Normalzation of input
 I2(:,2)=xf;
 
 H4=H4';
 [xf,PS3] = mapminmax(H4); % Normalzation of input
 I2(:,3)=xf;
 
 H5=H5';
 [xf,PS4] = mapminmax(H5); % Normalzation of input
 I2(:,4)=xf;
 Thelp=T;
 T=T';
 [yf,PS5]= mapminmax(T);   % Normalzation of output
 T=yf;
 T=T';
 
    for i=1:6
        Rrate=0;
        W=Best_W_B(i,1:63);
        B=Best_W_B(i,64:75);
        for pp=1:150
            actualvalue=my_MLP(4,9,3,W,B,I2(pp,1),I2(pp,2), I2(pp,3),I2(pp,4));
            if(T(pp)==-1)
                if (actualvalue(1)>=0.95 && actualvalue(2)<0.05 && actualvalue(3)<0.05)
                    Rrate=Rrate+1;
                end
            end
            if(T(pp)==0)
                if (actualvalue(1)<0.05 && actualvalue(2)>=0.95 && actualvalue(3)<0.05)
                    Rrate=Rrate+1;
                end  
            end
            if(T(pp)==1)
                if (actualvalue(1)<0.05 && actualvalue(2)<0.05 && actualvalue(3)>=0.95)
                    Rrate=Rrate+1;
                end              
            end
        end
        
        Final_Classification_Rates(1,i)=(Rrate/150)*100;
        
    end
    
 display('--------------------------------------------------------------------------------------------')
 display('Classification rate')
 display('   BBO       PSO       GA       ACO       ES       PBIL')
 display(Final_Classification_Rates(1:6))
 display('--------------------------------------------------------------------------------------------')
 

figure('Position',[500 500 660 290])
%Draw convergence curves
subplot(1,2,1);
hold on
title('Convergence Curves')
semilogy(cg_curve1,'Color','r')
semilogy(cg_curve2,'Color','k')
semilogy(cg_curve3,'Color','b')
semilogy(cg_curve4,'Color','r')
semilogy(cg_curve5,'Color','g')
semilogy(cg_curve6,'Color','c')
xlabel('Generation');
ylabel('MSE');

axis tight
grid on
box on
legend('BBO','PSO', 'GA', 'ACO', 'ES', 'PBIL')

%Draw classification rates
subplot(1,2,2);
hold on
title('Classification Accuracies')
bar(Final_Classification_Rates)
xlabel('Algorithm');
ylabel('Classification rate (%)');

grid on
box on
set(gca,'XTickLabel',{'BBO','PSO', 'GA', 'ACO', 'ES', 'PBIL'});



