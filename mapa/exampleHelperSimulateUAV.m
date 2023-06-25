% Esta función simula el vuelo de un UAV siguiendo una serie de waypoints.
% Argumentos de entrada:
%  waypoints: Los puntos de referencia a seguir durante el vuelo.
%  airSpeed: La velocidad del aire del UAV.
%  Tend: Tiempo total de simulación.


function [xENU,yENU,zENU] = exampleHelperSimulateUAV(waypoints,airSpeed,Tend)

%   Copyright 2019 The MathWorks, Inc.

% Definir el modelo (ala fija) y los coeficientes utilizados en los controladores del UAV
model = fixedwing;
model.Configuration.PDRoll = [40 3.9];
model.Configuration.PHeight = 3.9;
model.Configuration.PFlightPathAngle = 39;
model.Configuration.PAirSpeed = 0.39;
model.Configuration.FlightPathAngleLimits = [-0.1 0.1];

% Configurar la estructura de entorno
e = environment(model);

% Configurar los estados iniciales 
y0 = state(model);
y0(1:8)=[waypoints(1,1);waypoints(1,2);waypoints(1,3); airSpeed;waypoints(1,4);0;0;0];

% Configurar el objeto de seguimiento de waypoints
wpFollowerObj = uavWaypointFollower('UAVType','fixed-wing','Waypoints',waypoints(:,1:3),'TransitionRadius',0.05,'StartFrom','First');


PHeadingAngle=2; % controlador de orientación
UAVRollLimit=pi/4; % límite de ángulo de balanceo
lookAheadDist=3; % distancia de anticipación

% Simular el modelo
simOut = ode45(@(t,y)exampleHelperUAVDerivatives(y,wpFollowerObj,lookAheadDist,model,e,PHeadingAngle,airSpeed,UAVRollLimit), linspace(0,Tend,1000),y0);
xENU=simOut.y(1,:);
yENU=simOut.y(2,:);
zENU=simOut.y(3,:);


end


