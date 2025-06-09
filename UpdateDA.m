function DA = UpdateDA(DA,New,MaxSize,W)
% Update DA

%------------------------------- Copyright --------------------------------
% Copyright (c) 2024 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Find the non-dominated solutions
    DA = [DA,New];
    ND = NDSort(DA.objs,1); 
    DA = DA(ND==1);  
    N  = length(DA);
    if N <= MaxSize
        return;
    end
    Popobj = DA.objs; 
    
    %% normalization
    Zmin   = min(Popobj,[],1);
    Zmax   = max(Popobj,[],1);
    Popobj = (Popobj-repmat(Zmin,size(Popobj,1),1))./repmat(Zmax-Zmin,size(Popobj,1),1);
    Choose = false(1,N);

    %% Associated reference vector
    NZ = size(W,1);
    Cosine = 1 - pdist2(Popobj,W,'cosine');
    Distance = repmat(sqrt(sum(Popobj.^2,2)),1,NZ).*sqrt(1-Cosine.^2);
    %get d and pi
    [d,pi] = min(Distance',[],1);
    %Obtain the individuals associated with each reference vector
    [~,index] = min(Distance,[],1);
    %set rho =0
    %rho = zeros(1,NZ);
    

    %% Select extreme points
    M = size(Popobj,2);    
    Extreme = zeros(1,M);
    w       = zeros(M)+1e-6+eye(M);
    for i = 1 : M
        objmatrix = DA(~Choose).objs;
        [~,Extreme(i)] = min(max(DA(~Choose).objs./repmat(w(i,:),sum(~Choose),1),[],2)+0.1*objmatrix(:,i)/(1e-6)); 
        Choose(Extreme(i)) = true; 
        %rho(pi(Extreme(i))) = rho(pi(Extreme(i)))+1;
    end

    %Traverse each reference vector
    for i =1:NZ
        Choose(index(i)) = true;
    end

    if sum(Choose) > MaxSize
        %Randomly delete some solutions
        Choosed = find(Choose);
        k = randperm(sum(Choose),sum(Choose)-MaxSize);
        Choose(Choosed(k)) = false;
    elseif sum(Choose) < MaxSize
        %% Calculate population information entropy
        UQpi = unique(pi);
        ConnectZNum = length(UQpi);
        EntropyQ = CalculateEntropy(UQpi,ConnectZNum,pi,N);
        % a = floor(N / ConnectZNum);
        q = floor(N /ConnectZNum* (1-EntropyQ));
        if q < 1
            q =1;
        end
        k = MaxSize- sum(Choose);
        divValue = CalculateDiv_Test(Popobj,q);
        Unselected = find(Choose == 0);
        UnselectedDiv = divValue(Unselected);
        [~,indexDiv] = sort(UnselectedDiv,'descend');
        needSelect = indexDiv(1:k);
        Choose(Unselected(needSelect)) = true;
    end
 
    DA = DA(Choose);
end