classdef (ConstructOnLoad) newQueryPoint < event.EventData
   properties
      row (1,1) double = 0
   end
   methods
      function eventData = newQueryPoint(value)
         eventData.row = value;
      end
   end
end