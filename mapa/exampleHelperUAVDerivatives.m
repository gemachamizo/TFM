% Esta función calcula la derivada de los estados de un UAV 
% Parámetros de entrada:
%  y: vector de estados del UAV
%  wpFollowerObj: objeto que representa al seguidor de waypoints
%  LookAheadDist: distancia de mirada hacia adelante
%  model: modelo de la aeronave
%  e: entorno
%  PHeadingAngle: factor de control del ángulo de encabezado
%  airSpeed: velocidad del aire
%  rollAngleLimit: límite del ángulo de balanceo

function [dydt]=exampleHelperUAVDerivatives(y,wpFollowerObj,LookAheadDist,model,e,PHeadingAngle,airSpeed,rollAngleLimit)

%   Copyright 2019 The MathWorks, Inc.

% Se obtiene el punto de mirada hacia adelante y el ángulo de encabezado deseado
% utilizando el seguidor de waypoints.
[lookAheadPoint,desiredHeading] = wpFollowerObj([y(1) ;y(2) ;y(3); y(5)],LookAheadDist);

% Se obtiene la altura deseada y se calcula el ángulo de balanceo utilizando
% la función exampleHelperHeadingControl.
desiredHeight=-lookAheadPoint(3);
RollAngle=exampleHelperHeadingControl(y,desiredHeading,e,PHeadingAngle,rollAngleLimit);

% Se crea la señal de control utilizando el modelo de la aeronave.
% Se establece el ángulo de balanceo, la altura deseada y la velocidad del aire.
u = control(model);
u.RollAngle=RollAngle;
u.Height=desiredHeight;
u.AirSpeed=airSpeed;

% Se realiza una conversión de sistema de referencia NED a NEH (North East Height). Estos cambios son necesarios 
% para adecuar los cálculos y las señales de control a la configuración específica del UAV y del entorno 
% en el que opera, ya que en el marco NEH la altura es positiva hacia arriba.
% Se calcula la derivada de los estados utilizando el modelo de la aeronave,
% los estados convertidos al marco NEH y la señal de control.
yNEH=y;
yNEH(3)=-y(3);
dydtNEH = derivative(model,yNEH,u,e);

% Se convierten los resultados de la derivada de nuevo al marco NED.
dydt=dydtNEH;
dydt(3)=-dydtNEH(3);

end