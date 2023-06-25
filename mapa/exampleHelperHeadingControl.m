% Esta función calcula el ángulo de balanceo, en respuesta a un encabezado deseado y otras condiciones del vuelo

function rollAngle = exampleHelperHeadingControl(flightState,desiredHeading, environment, PHeadingAngle,rollAngleLimit)
    
    %   Copyright 2019 The MathWorks, Inc.
    
    % Toma la velocidad del estado de vuelo
    Va =    flightState(4);

    % Toma el ángulo de orientación del estado de vuelo
    headingAngle =  flightState(5);

    % Toma el ángulo de trayectoria del estado de vuelo
    flightPathAngle =flightState(6);
    
    % A continuación, se calcula el yaw, teniendo en cuenta el efecto del viento y utilizando una relación 
    % trigonométrica de aproximación basada en consideraciones aerodinámicas y la interacción del viento con 
    % la aeronave, entre el ángulo de orientación, la velocidad y el vector de viento en la dirección norte y este. 
    % También se considera el componente vertical del viento.
    YawAngle = headingAngle - asin((1/Va)*[environment.WindNorth, environment.WindEast]*[-sin(headingAngle); cos(headingAngle)]);
    b = [cos(headingAngle)*cos(flightPathAngle), sin(headingAngle)*cos(flightPathAngle), -sin(flightPathAngle)]*[environment.WindNorth; environment.WindEast; environment.WindDown];
    c = [environment.WindNorth, environment.WindEast, environment.WindDown]*[environment.WindNorth; environment.WindEast; environment.WindDown]- Va^2;
   
    % Se calcula la velocidad relativa al suelo (Vg) teniendo en cuenta la velocidad del viento y la velocidad 
    % del dron en el aire. 
    Vg = -b+sqrt(b^2-c);
    
    % Finalmente, se calcula el ángulo de balanceo utilizando una fórmula:
    rollAngle = atan2(PHeadingAngle*angdiff(headingAngle,desiredHeading)*Vg,environment.Gravity*cos(headingAngle-YawAngle));
    
    % Y se aplica una limitación para asegurarse de que el ángulo de balanceo no exceda los límites establecidos. 
    % Si el ángulo de balanceo calculado es mayor que el límite, se ajusta al límite. 
    % Lo mismo se aplica si el ángulo de balanceo es menor que el límite negativo.
    if(rollAngle>abs(rollAngleLimit))
       rollAngle=abs(rollAngleLimit);
    end
    if(rollAngle<-abs(rollAngleLimit))
       rollAngle=-abs(rollAngleLimit);
    end
end
