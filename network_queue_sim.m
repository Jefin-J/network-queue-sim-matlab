%%% Simulation data
nIters = 200;
nNodes = 10; %number of nodes

%%% Creating channel
sChannel = dataChannel;

%%% Creating a set of nodes
for i=1:nNodes
    n(i) = node(sChannel);
end

packetDropFraction = []; % fraction of packet drop to data created
avgPacketDropFraction = [];

iIters = 1;
while(iIters <= nIters)
    fprintf("\nIteration #%d", iIters);

    packetsDropped = 0;
    packetsCreated = 0;

    nodeOrder = randperm(nNodes); % which node gets to send data first in iteration
    
    droppingIterations = [];
    
    for sNode = nodeOrder
        iPacketsCreated = numel(n(sNode).createData());
        packetsCreated = packetsCreated + iPacketsCreated;
        packetDrop = n(sNode).sendData();
        if(packetDrop)
            droppingIterations = [droppingIterations iIters];
            packetsDropped = packetsDropped + iPacketsCreated;
        end
    end
    
    iPacketDropFraction = 0;
    if(packetsCreated ~= 0)
        iPacketDropFraction = packetsDropped/packetsCreated;
    end

    packetDropFraction = [packetDropFraction iPacketDropFraction];
    avgPacketDropFraction = [avgPacketDropFraction mean(packetDropFraction)];
    
    transmittedData = sChannel.transmitData(); % transmitting data through channel in the simulation time step
    iIters = iIters+1;
end

figure(1);
plot(packetDropFraction,'-x');

figure(2);
plot(avgPacketDropFraction);
%nbvcncv