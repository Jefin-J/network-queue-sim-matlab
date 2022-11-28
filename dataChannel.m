classdef dataChannel < handle
    properties (Constant)
        packetRate = 10; %packet rate, bytes/iteration
    end
    properties    
        channelData = [];
    end

    methods
        function status = receiveData(obj, data)
            if(numel(data)+numel(obj.channelData ) <= obj.packetRate*8)
                obj.channelData = [obj.channelData, data];
                fprintf(['\nChannel data ' repmat('%d',1,numel(obj.channelData)) '\n'],obj.channelData); % displaying channel data
                status = true;
            else
                status = false;
            end
        end

        function transmitted = transmitData(obj)
            transmitted = obj.channelData;
            obj.channelData = [];
        end
    end
end