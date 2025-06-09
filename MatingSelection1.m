function [ParentC,ParentM] = MatingSelection(CA,DA,N)
% 匹配算子选择
    CAParent1 = randi(length(CA),1,ceil(N/2));
    CAParent2 = randi(length(CA),1,ceil(N/2));
    temp1 = any(CA(CAParent1).objs<CA(CAParent2).objs,2);
    temp2 = any(CA(CAParent1).objs>CA(CAParent2).objs,2);
    Dominate  = any(CA(CAParent1).objs<CA(CAParent2).objs,2) - any(CA(CAParent1).objs>CA(CAParent2).objs,2);  
    %从收敛性档案中选择N/2个非支配个体，从DA档案中选择N/2个个体
    ParentC   = [CA([CAParent1(Dominate==1),CAParent2(Dominate~=1)]),...
                 DA(randi(length(DA),1,ceil(N/2)))];
    %随机打乱收敛性档案内的个体
    ParentM   = CA(randi(length(CA),1,N));
end