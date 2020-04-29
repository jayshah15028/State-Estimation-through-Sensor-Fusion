function [E_y,E_x]=BayesianEstimate(y,p_y,x,p_x)

dy=y(2)-y(1); %%Increment in the measurement range                                                   
dx=x(2)-x(1); 
n=size(p_y,1);
p_y_condition=p_y(1,:);                                                     %%Initial assignment
p_x_condition=p_x(1,:);
for i1=2:1:n
    
p_y_condition_i_1=p_y_condition;                                            %%Initialisation
p_conditiony=trapz(p_y(i1,:).*p_y_condition_i_1)*dy;                          %%Prediction
if p_conditiony~=0
  p_y_condition=p_y(i1,:).*p_y_condition_i_1/p_conditiony;                    %%Update
end

end
E_y=trapz(y.*p_y_condition)*dy;                                             %%State Estimation


n=size(p_x,1);
for i1=1:1:n
p_x_condition_i_1=p_x_condition;                                            %%Initialisation
p_conditionx=trapz(p_x(i1,:).*p_x_condition_i_1)*dx;                          %%Prediction
if p_conditionx~=0
  p_x_condition=p_x(i1,:).*p_x_condition_i_1/p_conditionx;                    %%Update
end
E_x=trapz(x.*p_x_condition)*dx;



end





