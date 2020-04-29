clear; clc; close all;
data = xlsread('meen689.xlsx');                                            %%Data from Ultrasonic Sensor
load('sensorlog_40.4m.mat');                                               %%Data from IMU and GPS
E_y=0;
E_x=0;
[Px,Py,Vx,Vy]=Accelero_to_position(Acceleration);
[dx,dy]=Gps_to_bodyframe(Position);
Vgy = Position.speed; %GPS speed in y-axis
y1=Py;
y2=dy;
x1=Px;
x2=dx;
y3=[5.8;14.5;23.5;35.1];
Xest4=zeros(1,2250);
p1=1;
p2=50;
y=0:0.01:110;                                                              %%Range of the measurements
x=-55:0.01:55;

for in3=1:1:2
    
   if(in3==2)
    p1=1;
    p2=50;
    y1=Vy;
    x1=Vx;
    y2=Vgy;
   end
   
  for in1=1:1:45
     for in2=p1:1:p2
    
    
        p_y(1,:)=normpdf(y,y1(in2),5000);                                      %%probability of IMU
        p_x(1,:)=normpdf(x,x1(in2),5000);
          if(mod(in2,50)==0)
            p_y(2,:)=normpdf(y,y2(in1),0.01);                                          %%probability of GPS
            p_x(2,:)=normpdf(x,x2(in1),0.01);
          end
    %%probablity of Ultrasonic   
        if(in3==1)
          if in1<=7 && in1>=4  %% First obstacle
            p_y(3,:)=normpdf(y,y3(1),0.01);
          end
          if in1<=15 && in1>=13 %% Second Obstacle
            p_y(3,:)=normpdf(y,y3(2),0.01);
          end
          if in1<=24 && in1>=22 %% Third Obstacle
            p_y(3,:)=normpdf(y,y3(3),0.01);
          end
          if in1==32 || in1==33  %% Fourth Obstacle
            p_y(3,:)=normpdf(y,y3(4),0.01);
          end
        end
    %Recursive Bayesian Estimation
    %-------------------
        [E_y,E_x]=BayesianEstimate(y,p_y,x,p_x);
        Yread(in2)=E_y;                                                    % The estimated output with sensor fusion
        Xread(in2)=E_x;  
      end
 p1=p1+50;
 p2=p2+50;

  end



    if(in3==1)
      plot(Xread)
      hold on
      Xest1=Xread;
      Xest2=Yread;
      plot(Yread);
      legend('Bayes Filter_Px','Bayes Filter_Py');
    end
    if(in3==2)
      Xest3=Xread;
      Xest4(51:2250)=Yread(51:2250);
    end   
end

%%OUTPUT VECTORS
OUTPUT=[Xest1;Xest2;Xest3;Xest4];  %%Positions in X, Y Velocities in X, Y
