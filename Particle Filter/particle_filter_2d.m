%% sensor data acquisition
clear all
load('sensorlog_40.4m.mat')
data = xlsread('meen689.xlsx');

%Accelerometer
[Px,Py,Vx,Vy] = Accelero_to_position(Acceleration);
%GPS
[dx,dy]=Gps_to_bodyframe(Position); %GPS position
 Vgy = Position.speed; %GPS speed in y-axis
%Ultrasonic
data(126:150) = 22.31; % Ultrasonic sensor data

%% particle filter script
   
dta=1/50; t=length(Py);
xest=zeros(4,t);
xest(:,1)=[0;1*dta;0;1];   % initializing at first time step
N=100;              % number of particles
Q=0.01*eye(4);           % process noise covariance
Ra=5000*eye(4);           % accelerometer noise covariance
Rgps=0.01*eye(4);      % gps noise covariance
Ru=0.01*eye(4);           % ultrasonic noise covariance

A=[1 0 0 0;0 1 0 0; 0 0 1 0; 0 0 0 1]; H=eye(4); b=[0;dta;0;0];
xp=zeros(4,N);  %xp=array of particles
%initial sampling of particles
for i=1:N
    xp(:,i)=xest(:,1)+ sqrt(Q)*randn(4,1);
end


for k=2:t
    xtemp=zeros(4,N);   %xtemp----> variable to temporarily store the value of sampled particles after propgation
    if rem(k,50) ~= 0
        zm=[Px(k);Py(k);Vx(k);Vy(k)];     %actual measurement from the sensors
    
        w=zeros(4,N);     %weight of particles
        % particles propogation step
        for j=1:N
            xtemp(:,j)=A*xp(:,j) + b + sqrt(Q)*randn(4,1);
            ztemp(:,j)=H*xtemp(:,j)+ sqrt(Ra)*randn(4,1);
            w(:,j) = (1./sqrt(2*pi.*(Ra*[1;1;1;1]))) .*( exp(-((zm - ztemp(:,j)).^2)./(2*Ra*[1;1;1;1])));  %weights of particles in gaussain distribution
        end
    else
        zm=[dx(k/50);dy(k/50);0;Vgy(k/50)];     %actual measurement from the sensors
    
             %weight of particles
        % particles propogation step
        for j=1:N
            xtemp(:,j)=A*xp(:,j)+ b+ sqrt(Q)*randn(4,1);
            ztemp(:,j)=H*xtemp(:,j)+ sqrt(Rgps)*randn(4,1);
            w(:,j) = (1./sqrt(2*pi.*(Rgps*[1;1;1;1]))) .*( exp(-((zm - ztemp(:,j)).^2)./(2*Rgps*[1;1;1;1])));  %weights of particles in gaussain distribution
        end
    end
    if rem(k,16)==0
        if k/16<=15 && data(k/16)<1
            zm=[data(k/16)-0.2; 5.8; 0; 1];
            for j=1:N
            xtemp(:,j)=A*xp(:,j)+ b + sqrt(Q)*randn(4,1);
            ztemp(:,j)=H*xtemp(:,j)+ sqrt(Ru)*randn(4,1);
            w(:,j) = (1./sqrt(2*pi.*(Ru*[1;1;1;1]))) .*( exp(-((zm - ztemp(:,j)).^2)./(2*Ru*[1;1;1;1])));  %weights of particles in gaussain distribution
            end
        elseif k/16>15 && data(k/16)<1 && k/16<=45
            zm=[data(k/16)-0.2; 14.5; 0; 1];;
            for j=1:N
            xtemp(:,j)=A*xp(:,j)+ b + sqrt(Q)*randn(4,1);
            ztemp(:,j)=H*xtemp(:,j)+ sqrt(Ru)*randn(4,1);
            w(:,j) = (1./sqrt(2*pi.*(Ru*[1;1;1;1]))) .*( exp(-((zm - ztemp(:,j)).^2)./(2*Ru*[1;1;1;1])));  %weights of particles in gaussain distribution
            end
        elseif k/16>45 && data(k/16)<1 && k/16<=85
            zm=[data(k/16)-0.2; 23.5; 0; 1];;
            for j=1:N
            xtemp(:,j)=A*xp(:,j)+ b + sqrt(Q)*randn(4,1);
            ztemp(:,j)=H*xtemp(:,j)+ sqrt(Ru)*randn(4,1);
            w(:,j) = (1./sqrt(2*pi.*(Ru*[1;1;1;1]))) .*( exp(-((zm - ztemp(:,j)).^2)./(2*Ru*[1;1;1;1])));  %weights of particles in gaussain distribution
            end
        elseif k/16>85 && data(k/16)<1 && k/16<=135
            zm=[data(k/16)-0.2; 35.1; 0; 1];;
            for j=1:N
            xtemp(:,j)=A*xp(:,j)+ b + sqrt(Q)*randn(4,1);
            ztemp(:,j)=H*xtemp(:,j)+ sqrt(Ru)*randn(4,1);
            w(:,j) = (1./sqrt(2*pi.*(Ru*[1;1;1;1]))) .*( exp(-((zm - ztemp(:,j)).^2)./(2*Ru*[1;1;1;1])));;  %weights of particles in gaussain distribution
            end
        end
    
        
  end          
    

   wn=[w(1,:)./sum(w(1,:)); w(2,:)./sum(w(2,:)); w(3,:)./sum(w(3,:)); w(4,:)./sum(w(4,:))];  %normalize weight for probability function
   
   % resampling based on multinomial method, uncomment the following line
     index=[residual(wn(1,:)); residual(wn(2,:)); residual(wn(3,:)); residual(wn(4,:))];
    % resampling based on residual method, uncomment the following line
%    index=[multinomial(wn(1,:)); multinomial(wn(2,:)); multinomial(wn(3,:)); multinomial(wn(4,:))];
    for i=1:N
        xr(:,i)=[xtemp(1,index(1,i));xtemp(2,index(2,i));xtemp(3,index(3,i));xtemp(4,index(4,i))];
    end
   xest(:,k)=[mean(xr(1,:)); mean(xr(2,:)); mean(xr(3,:)); mean(xr(4,:))];    % final estimate of the position
   
   xp=xr;
   
end

%% plot
figure(1)
dt=1/50:1/50:45.18;
plot(dt,xest(1,:),dt,xest(2,:));
legend('Direction X','Direction Y');
title('Position');
figure(2)
plot(dt,xest(3,:),dt,xest(4,:));
legend('Direction X','Direction Y');
title('Velocity');
