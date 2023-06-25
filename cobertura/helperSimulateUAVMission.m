function exampleHelperSimulateUAVMission(m,referenceLocation,TSim)
% Function to create position and rotation table provided as input to
% the drone marking its trajectory.
% Takes in the waypoints in the trajectory and a fixed drone altitude.


figure('Position', [100 100 800 600]); % he cambiado el tamaño de la figura
show(m,ReferenceLocation=referenceLocation); % mostrar el espacio de cobertura
grid on
parser = multirotorMissionParser(TakeoffSpeed=10,TransitionRadius=15); % analizar y procesar los datos que representan la trayectoria 
traj = parse(parser,m,referenceLocation);                              % seguida por el dron durante su vuelo (parsear)
hold on                                                                % se crea una tabla de posición y rotación que representa la trayectoria del dron
show(traj);
% Eliminar etiquetas de "waypoint"
waypointLabels = findobj(gca, 'Type', 'Text', 'String', 'Waypoint');
delete(waypointLabels);
title("Survey Coverage Space Mission")

%%
% simular la escena y el vuelo del dron
s = uavScenario(ReferenceLocation=referenceLocation,UpdateRate=2); % he actualizado la update rate
plat = uavPlatform("UAV",s); % plataforma del dron en la simulación
plat.updateMesh("quadrotor",{20},[1 0 0],eul2tform([0 0 pi])); % actualiza la representación visual del dron en el gráfico


% Simulate through generated flight trajectory
ax = s.show3D(); % figura 3D para mostrar la escena
s.setup();
if(nargin<3)               % Si el número de argumentos de entrada es menor que 3 (es decir, si no se proporciona TSim), 
    TSim=traj.EndTime;     % se establece TSim como el tiempo final de la trayectoria 
end
counter=0;
while s.CurrentTime <= TSim % simula el vuelo del dron mientras el tiempo sea menor o igual a TSim
    plat.move(traj.query(s.CurrentTime));  % se mueve el dron según la posición y rotación correspondiente en la trayectoria en función del tiempo
    %Limit render rate.
    counter=counter+1;
    if(mod(counter,100)==0)  % cada 100 iteraciones de actualiza la posición del dron
        s.show3D(Parent=ax,FastUpdate=true);
        s.advance();
        pause(0.001); % se pausa la ejecución y se dibuja el gráfico. Con esto da la sensación de movimiento
        drawnow;
    end
end

%%
% generar una tabla de posición y rotación 
ts = linspace(traj.StartTime,TSim,50);
motions = query(traj,ts);
ts = seconds(ts);
position = motions(:,1:3);
position = position(:,[2 1 3]);
position(:,3) = -position(:,3);
orientation = motions(:,10:13);
angles = zeros(size(orientation,1),3);
for idx = 1:size(orientation,1)
    rotm = quat2rotm(orientation(idx,:));
    rotm = eul2rotm([pi/2 0 pi])*rotm*eul2rotm([0 0 pi]);
    angles(idx,:) = rotm2eul(rotm);
end

% He añadido esto para ver el tiempo total de vuelo en minutos
totalFlightTime = (s.CurrentTime - traj.StartTime)/60;
disp(['Tiempo total de vuelo: ' num2str(totalFlightTime) ' minutos']);
end