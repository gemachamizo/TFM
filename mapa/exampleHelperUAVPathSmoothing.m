% Estan función suaviza la trayectoria de Dubins de manera iterativa
% Se eliminan los puntos intermedios entre dos poses distantes
% si esto no resulta en una colisión con el entorno.

function [smoothWaypointsObj] = exampleHelperUAVPathSmoothing(ss,sv,pthObj)

%   Copyright 2019 The MathWorks, Inc.

% Se extraen los waypoints de la trayectoria original no suavizada y se
% inicializa un contador para realizar el seguimiento de los waypoints
% suavizados
nonSmoothWaypoints=pthObj.States(:,1:4);
counter=1;

% El primer punto de la trayectoria no suavizada se copia en la matriz 
% de puntos optimizados, en la primera fila.
optimizedWaypoints(counter,:)=nonSmoothWaypoints(1,:);
startNode=1;
endNode=startNode+1;

% Se incrementa el contador en preparación para el siguiente waypoint suavizado.
counter=counter+1;
lastNonCollisionNode=endNode;

% Se inicia un bucle que se ejecutará hasta que el índice del nodo de fin sea 
% mayor que la cantidad de waypoints no suavizados.
while(endNode<=length(nonSmoothWaypoints))

    % Se verifica si el movimiento entre el nodo de inicio y el nodo de fin es válido 
    MotionValid=isMotionValid(sv,nonSmoothWaypoints(startNode,:),nonSmoothWaypoints(endNode,:));

    % Se asigna true a la variable collide si hay una colisión (el
    % movimiento no es válido)
    collide=~MotionValid;
    if(~collide)
        % si no hay colisión, se copia el waypoint de fin en la matriz optimizedWaypoints
        optimizedWaypoints(counter,:)=nonSmoothWaypoints(endNode,:);
        lastNonCollisionNode=endNode;
        endNode=endNode+1;
    end
    if(collide)
        % si hay colisión, se copia el último waypoint sin colisión
        % encontrado
        optimizedWaypoints(counter,:)=nonSmoothWaypoints(lastNonCollisionNode,:);
        counter=counter+1;
        startNode=lastNonCollisionNode;
        endNode=startNode+1;
    end
end


% Define un objeto navPath vacío.
smoothWaypointsObj = navPath(ss);

% Agrega los waypoints suavizados al objeto.
append(smoothWaypointsObj, optimizedWaypoints(:,1:4));

end

