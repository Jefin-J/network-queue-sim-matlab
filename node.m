

classdef node < handle
    properties
        id;
        nodeDataRate = 4; %in bytes
        queueLength = 10; %queue length in bytes
        queue; %initializing the queue
        nodeType = 1; %initializing node type. Node type determines the rate of data creation by that node
        data; %representing the data collected/ created by the node
        sendReady = false; % is node ready to send data
        nodeDataChannel;
    end

    methods
        function obj = node(channel)
            load("nodeDatas.mat","nodeTypes");
            [maxNodeTypes, ~] = size(nodeTypes); %determines how many node types are defined in the file



            a =[randperm(10,2)+47;randperm(26,2)+96]; %setting a unique id for the node
            obj.id = char(a(:)');

            obj.data = zeros(1,8*obj.nodeDataRate); %representing the data collected/ created by the node

            obj.nodeType = 1; % randi([1,maxNodeTypes]); %assigns a random node type to the node

            obj.queue = zeros(1,obj.queueLength*8);

            obj.nodeDataChannel = channel; % Assigns the data channel
        end

        function changeQueueLength(obj, newQueueLength)
            obj.queueLength = newQueueLength;
            fprintf("Change Queue length %d",[obj.queueLength]);
        end

        % Creating/ collecting data at the node / sensor
        function created = createData(obj)
            load("nodeDatas.mat","nodeTypes");

            obj.sendReady = false; % resetting data sending readyness
            obj.data = [];

            % Data creation according to packet creation probability
            if(rand<=nodeTypes(obj.nodeType,2))
                dataSize = randi([1,32]);
                nBytes = ceil(dataSize/8);
                obj.data = randi([0 1],1,nBytes*8);
                fprintf("\nSensor id#%s :", obj.id);

                obj.sendReady = true; % setting data ready to send

                %displaying the collected/ created data
                for i=1:nBytes
                    fprintf("%d ",obj.data((i-1)*8+1 : i*8));
                    fprintf(" ");
                end

            end

            created = obj.data;


        end

        % Sending data and detecting collision
        function packetDrop = sendData(obj)
            packetDrop = false;
            
            dataToSend = obj.data;
            
%             if(~obj.sendReady)
%                 
%                 if(numel(obj.queue) <= obj.nodeDataRate*8)
%                     dataToSend = obj.queue;
%                     obj.queue = [];
%                 else
%                     dataToSend = obj.queue(1 : obj.nodeDataRate*8);
%                     obj.queue = obj.queue(obj.nodeDataRate*8+1 : end);
%                 end
%             end

            success = obj.nodeDataChannel.receiveData(dataToSend);

            if(success)
                obj.data = [];
            else
                finalQueue = numel(dataToSend) + numel(obj.queue);
                if(finalQueue > obj.queueLength)
                    packetDrop = true;
                else
                    obj.queue = [obj.queue dataToSend];
                end
            end
        end

    end
end
