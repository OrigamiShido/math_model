istest_init=[1 1 0 1 1 0 1 0 1 1 1 1];
istear_init=[1 1 1 1];

%异常：0 0 0 0 0 0 0 0 0 0 0 0  0 1 0 1
%异常: 0 0 0 0 0 0 0 0 0 0 0 0  0 0 1 1
%最优点：1 1 0 1 1 0 1 0 1 1 1 0  1 1 1 1

% 创建优化变量
istest4 = optimvar("istest",1,12,"Type","integer","LowerBound",0,"UpperBound",...
    1);
istear5 = optimvar("istear",1,4,"Type","integer","LowerBound",0,"UpperBound",...
    1);

% 设置求解器的初始起点
initialPoint4.istest = istest_init;
initialPoint4.istear = istear_init;

% 创建问题
problem = optimproblem;

% 定义问题目标
problem.Objective = fcn2optimexpr(@objectiveFcn,istest4,istear5);

% 显示问题信息
show(problem);

% 求解问题
[solution3,objectiveValue,reasonSolverStopped] = solve(problem,initialPoint4);

% 显示结果
solution3
reasonSolverStopped
objectiveValue

% 清除变量
clearvars istest4 istear5 initialPoint4 reasonSolverStopped objectiveValue
%%

test=objectiveFcn(istest_init,istear_init)

%%
function [after_cost,after_error_rate,after_chip_fee]=node_test(before_cost,before_error_rate,istest,testfee)
    % 测试节点，输入：测试前的成本、次品率、是否测试、测试费用
    % 输出：修正后的成本和次品率，零件费
    if(istest)
        after_cost=before_cost+testfee+(before_error_rate/(1-before_error_rate))*(before_cost+testfee);%成本+测试费+平摊后的次品零件和测试费
        after_chip_fee=before_cost+(before_error_rate/(1-before_error_rate))*(before_cost+testfee);
        after_error_rate=0;
    else% 不测试没有变化
        after_cost=before_cost;
        after_chip_fee=before_cost;
        after_error_rate=before_error_rate;
    end
end

function [after_cost,after_error_rate]=node_error_rate_calc(before_cost,before_error_rate, error_rate_construction,fee_construction)
        % 次品率计算节点，输入：之前的所有成本，之前的所有次品率，装配的次品率，装配费用
        % 输出：之后的成本，次品率
        after_error_rate=(1-error_rate_construction);
        after_cost=0;
    for i=1:numel(before_error_rate)
        after_error_rate=after_error_rate*(1-before_error_rate(i));
        after_cost=after_cost+before_cost(i);% 成本是加总
    end
    after_error_rate=1-after_error_rate;% 次品率计算
    after_cost=after_cost+fee_construction;
end

function final_cost=node_change(before_cost,istest_former,before_error_rate,changefee)
    % 调换节点，输入：之前的成本，之前是否检测，之前的次品率，调换费
    % 输出：最终成本
    if(~istest_former)
        final_cost=before_cost+(before_error_rate/(1-before_error_rate))*(before_cost+changefee);% 平摊调换费
    else% 之前检测过不会产生费用
        final_cost=before_cost;
    end
end

function after_cost=node_tear(before_cost, istear,before_error_rate,tearfee,before_part_fee)
    %拆解节点，输入：之前的成本，是否拆解，之前的次品率（未经过检测修正的），拆解费用，之前的零件费
    if(istear)
        test=(before_error_rate/(1-before_error_rate))*(tearfee-sum(before_part_fee(:)));% 测试行无意义
        after_cost=before_cost+(before_error_rate/(1-before_error_rate))*(tearfee-sum(before_part_fee(:)));% 平摊拆解费，返还零件费
    else% 不拆没有变化
        after_cost=before_cost;
    end
end

function objective = objectiveFcn(istest,istear)
% 基本参数
part_error_original=[0.1038 0.1038 0.1038 0.1038 0.1038 0.1038 0.1038 0.1038];
part_fee_original=[2 8 12 2 8 12 8 12];
testfee_part=[1 1 2 1 1 2 1 2];
errorrate_construct=[0.1038 0.1038 0.1038 0.1038];
partfee_construct=[8 8 8 8];
testfee_product=[4 4 4 6];
changefee=40;
tearfee=[6 6 6 10];
%部分1，所有零件的测试
part_fee=zeros(1,8);
part_error_rate=zeros(1,8);
chip_fee=zeros(1,8);
for i=1:numel(part_fee_original)
    [part_fee(i),part_error_rate(i),chip_fee(i)]=node_test(part_fee_original(i),part_error_original(i),istest(i),testfee_part(i));
end

%部分2 3个装配节点
mid_fee_original=zeros(1,3);
mid_error_rate_original=zeros(1,3);
[mid_fee_original(1),mid_error_rate_original(1)]=node_error_rate_calc(part_fee(1:3),part_error_rate(1:3),errorrate_construct(1),partfee_construct(1));
[mid_fee_original(2),mid_error_rate_original(2)]=node_error_rate_calc(part_fee(4:6),part_error_rate(4:6),errorrate_construct(2),partfee_construct(2));
[mid_fee_original(3),mid_error_rate_original(3)]=node_error_rate_calc(part_fee(7:8),part_error_rate(7:8),errorrate_construct(3),partfee_construct(3));
mid_fee=zeros(1,3);
mid_error_rate=zeros(1,3);
mid_chip_fee=zeros(1,3);

%部分3 装配节点出口的3个半成品测试
for i=1:numel(mid_fee_original)
    [mid_fee(i),mid_error_rate(i),mid_chip_fee(i)]=node_test(mid_fee_original(i),mid_error_rate_original(i),istest(i+8),testfee_product(i));
end

%部分4 装配的拆解
chip_fee_input=[(sum(chip_fee(1:3))),(sum(chip_fee(4:6))),(sum(chip_fee(7:8)))];%将之前的零件费加总
mid_fee_after=zeros(1,3);

% for test表明前3小节应该没有问题
% for i=1:numel(mid_fee)
%     mid_fee_after(i)=node_tear(mid_fee(i), istear(i),mid_error_rate_original(i),tearfee(i),chip_fee_input(i));
% end
% end_cost=node_change(mid_fee_after(1),istest(9),mid_error_rate_original,changefee);
% end_cost=node_change(mid_fee_after(2),istest(10),mid_error_rate_original,changefee);
% end_cost=node_change(mid_fee_after(3),istest(11),mid_error_rate_original,changefee);

%拆解，注意如果没有测试则拆解节点无意义，因此引入istest进行判断
for i=1:numel(mid_fee)
    mid_fee_after(i)=(1-istest(i+8))*mid_fee(i)+istest(i+8)*node_tear(mid_fee(i), istear(i),mid_error_rate_original(i),tearfee(i),chip_fee_input(i));
end

%3个半成品组装成1个成品
[final_fee_original,final_error_rate_original]=node_error_rate_calc(mid_fee_after,mid_error_rate,errorrate_construct(4),partfee_construct(4));
%成品的测试
[final_fee,~,~]=node_test(final_fee_original,final_error_rate_original,istest(12),testfee_product(4));

%零件费更新，（是原来的零件费-中期的拆解费）*是否检测
mid_chip_fee=(chip_fee_input-tearfee(1:3)).*istear(1:3);

%流入市场的次品的调换
final_fee_after=node_change(final_fee,istest(12),final_error_rate_original,changefee);

%成品的拆解（次品流入市场会被退回，因此不需要判断是否检测过
end_cost=node_tear(final_fee_after,istear(4),final_error_rate_original,tearfee(4),mid_chip_fee);

objective = end_cost;

end