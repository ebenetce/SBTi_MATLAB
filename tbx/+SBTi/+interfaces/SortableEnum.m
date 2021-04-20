classdef SortableEnum   
    
    
    
end
% class SortableEnum(Enum):
%     def __str__(self):
%         return self.name
% 
%     def __ge__(self, other):
%         if self.__class__ is other.__class__:
%             order = list(self.__class__)
%             return order.index(self) >= order.index(other)
%         return NotImplemented
% 
%     def __gt__(self, other):
%         if self.__class__ is other.__class__:
%             order = list(self.__class__)
%             return order.index(self) > order.index(other)
%         return NotImplemented
% 
%     def __le__(self, other):
%         if self.__class__ is other.__class__:
%             order = list(self.__class__)
%             return order.index(self) <= order.index(other)
%         return NotImplemented
% 
%     def __lt__(self, other):
%         if self.__class__ is other.__class__:
%             order = list(self.__class__)
%             return order.index(self) < order.index(other)
%         return NotImplemented