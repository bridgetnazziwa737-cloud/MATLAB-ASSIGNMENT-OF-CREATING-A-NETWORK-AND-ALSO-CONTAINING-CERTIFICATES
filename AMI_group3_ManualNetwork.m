clear; close('all'); clc;
start_toolkit;

d = epanet('Manual.inp');
d.plot;
d.plot('nodes', 'yes', 'fontsize', 12)
d.plot('links', 'yes', 'fontsize', 12)
d.plot('linksindex', 'yes', 'fontsize',8);
d.plot('nodesindex', 'yes', 'fontsize',14);
d.plot('links', 'yes', 'highlightlink',{'10'}, 'fontsize',8); 
d.plot('highlightnode',{'10', '32'});
d.plot('point', 'no');
d.plot('line', 'no');
linkSet1 = d.getLinkNameID(1:4);
colorLinkSet1 = repmat({'r'},1,length(linkSet1));
linkSet2 = d.getLinkNameID([5,6,7,8]);
colorLinkSet2=repmat({'g'},1,length(linkSet2));
d.plot('highlightlink',[linkSet1 linkSet2],'colorlink',[colorLinkSet1 colorLinkSet2])
nodeSet1 = d.getNodeNameID(1:4);
colorLinkSet1 = repmat({'y'},1,length(nodeSet1));
nodeSet2 = d.getNodeNameID([5,6,7,8]);
colorLinkSet2=repmat({'g'},1,length(nodeSet2));
d.plot('highlightnode',[nodeSet1 nodeSet2],'colornode',[colorLinkSet1 colorLinkSet2])
d.plot('legend', 'hide')
d.plot('extend', 'yes')
d.plot('legendposition', 'EastOutside')
h = figure;
d.plot('axes', h)

% Plot for matlab apps (GUIs)
%d.plot('uifigure', app.UIFigure, 'axes', app.UIAxes,'legend','hide');
h = d.plotGraph
title('Network Graph');
d.plotGraph('nodes', 'yes'); % Show ID of nodes
title('Network Graph with node IDs');
d.unload
%% 

d = epanet('Manual.inp', 'loadfile');
hrs = 100;
d.setTimeSimulationDuration(hrs*3600);
tic;
hyd_res_1 = d.getComputedTimeSeries
time_1 = toc;
tic;
hyd_res_2 = d.getComputedTimeSeries_ENepanet
time_2 = toc;
tic;
hyd_res_3 = d.getComputedHydraulicTimeSeries('time', 'flow', 'pressure'); 
time_3 = toc;
% etstep = 3600;
% d.setTimeReportingStep(etstep);
% d.setTimeHydraulicStep(etstep);
% d.setTimeQualityStep(etstep);
tic;
d.openHydraulicAnalysis;
d.initializeHydraulicAnalysis;
tstep=1;P=[];T_H=[];
while (tstep>0)
    t=d.runHydraulicAnalysis;
    P=[P; d.getNodePressure];
    T_H=[T_H; t];
    tstep=d.nextHydraulicAnalysisStep;
end
d.closeHydraulicAnalysis;
time_4 = toc;
d.unload

disp(['Elapsed time for the function `getComputedTimeSeries` is: ' num2str(time_1)])
disp(['Elapsed time for the function `getComputedTimeSeries_ENepanet` is: ' num2str(time_2)])
disp(['Elapsed time for the function `getComputedHydraulicTimeSeries` is: ' num2str(time_3)])
disp(['Elapsed time for the function `step-by-step` is: ' num2str(time_4)])
%% 

d = epanet('Manual.inp', 'loadfile')
hyd_res = d.getComputedHydraulicTimeSeries('time', 'pressure', 'flow', 'velocity');
hrs_time = hyd_res.Time/3600;
node_indices = [1, 3, 4];
node_names = d.getNodeNameID(node_indices);
units = d.getUnits;
for i=node_indices
    figure;
    plot(hrs_time, hyd_res .Pressure(:,i));
    title(['Pressure for the node id "', d.getNodeNameID{i},'"']);
    xlabel('Time (hrs)'); 
    ylabel(['Pressure (', units.NodePressureUnits,')'])
end
link_indices = [2,3,4];
link_names = d.getNodeNameID(link_indices);
for i=link_indices
    figure;
     plot(hrs_time, hyd_res.Velocity(:, i));
    title(['Velocity for the link id ', d.getLinkNameID{i}]);
    xlabel('Time (hrs)'); 
    ylabel(['Velocity (', units.LinkVelocityUnits,')'])
end
link_indices = [1,2,3];
for i=link_indices
    figure;
    plot(hrs_time, hyd_res.Flow(:,i));
    title(['Flow for the link id "', d.getLinkNameID{i},'"']);
    xlabel('Time (hrs)'); 
    ylabel(['Flow (', units.LinkFlowUnits,')'])
end
d.unload
%% 
d = epanet('Manual.inp')
hyd_res = d.getComputedTimeSeries
times = hyd_res.Time;  % get time stamps
color = 'g';  % choose color
nodenameid = d.getNodeNameID;  % get node IDs
linknameid = d.getLinkNameID;  % get link IDs
nodesconnlinks = d.getNodesConnectingLinksID;  % get node connectivity
nodecoords = d.getNodeCoordinates;  % get node coordinates
x = nodecoords{1};
y = nodecoords{2};
min_coorx = min(x);
min_coory = min(y);
max_coorx = max(x);
max_coory = max(y);
xsenoff = (max_coorx - min_coorx) * 0.075;
ysenoff = (max_coory - min_coory) * 0.03;
fig = d.plot('legend', 'hide');
format long g
time_step = 22;
flow = hyd_res.Flow(time_step,:);
fontweight = 'bold';
fontsize = 10;
for i = d.getLinkIndex
    value = flow(i);    
    FromNode=strfind(strcmp(nodesconnlinks(i, 1), nodenameid), 1);
    ToNode=strfind(strcmp(nodesconnlinks(i, 2), nodenameid), 1);

    if FromNode
        x1 = double(nodecoords{1}(FromNode));
        y1 = double(nodecoords{2}(FromNode));
    end
    if ToNode
        x2 = double(nodecoords{1}(ToNode));
        y2 = double(nodecoords{2}(ToNode));
    end
    F = line([x1 nodecoords{3}{i} x2], [y1 nodecoords{4}{i} y2], 'LineWidth', 1, 'Color', color, 'Parent', fig);
    text((x1+x2)/2-xsenoff, (y1+y2)/2+ysenoff, num2str(value, '%.5f'), 'FontWeight', fontweight, 'Fontsize', fontsize, 'color', color)
end
time_step = 22;
pressure = hyd_res.Pressure(time_step,:);
ysenoff = (max_coory - min_coory) * (-0.04);
color = 'b';
fontweight = 'bold';
fontsize = 10;
for i = d.getNodeIndex
    value = pressure(i);
    coor = d.getNodeCoordinates(i);
    x = coor(1); 
    y = coor(2);
    P = plot(x, y, 'o', 'LineWidth', 2, 'MarkerEdgeColor', color, 'MarkerFaceColor', color, 'MarkerSize', 5);
    text(x-xsenoff, y+ysenoff, num2str(value, '%.2f'), 'FontWeight', fontweight, 'Fontsize', fontsize, 'color', color)
end
legend([F,P], {'Flows', 'Pressures'})
d.unload
