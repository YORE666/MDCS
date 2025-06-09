function [CA,Fit] = UpdateCA(CA,New,MaxSize)
% Update CA
    CA = [CA,New];
    %ND = NDSort(CA.objs,1);
    %CA = CA(ND == 1);
    N  = length(CA);
    if N < MaxSize
        return;
    end
    
    % selection
    CAObj = CA.objs;
    Choose = false(1,N);
    ddC = Calculate_DDC(CAObj,N);
    [~,index] = sort(ddC,'ascend');
    Choose(index(1:MaxSize)) = true;
    CA = CA(Choose);
    Fit = ddC(Choose);
end