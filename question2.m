
% 创建优化变量
istest_part12 = optimvar("istest_part1","Type","integer","LowerBound",0,...
    "UpperBound",1);
istest_part22 = optimvar("istest_part2","Type","integer","LowerBound",0,...
    "UpperBound",1);
istest_product2 = optimvar("istest_product","Type","integer","LowerBound",0,...
    "UpperBound",1);
istear2 = optimvar("istear","Type","integer","LowerBound",0,"UpperBound",1);

% 设置求解器的初始起点
initialPoint.istest_part1 = zeros(size(istest_part12));
initialPoint.istest_part2 = zeros(size(istest_part22));
initialPoint.istest_product = zeros(size(istest_product2));
initialPoint.istear = zeros(size(istear2));

% 创建问题
problem3 = optimproblem;

% 定义问题目标
problem3.Objective = fcn2optimexpr(@objectiveFcn,istest_part12,istest_part22,...
    istest_product2,istear2);

% 设置非默认求解器选项
options = optimoptions("ga","Display","iter");

% 显示问题信息
show(problem3);

% 求解问题
[solution2,objectiveValue,reasonSolverStopped] = solve(problem3,initialPoint,...
    "Solver","ga","Options",options);

% 显示结果
solution2
reasonSolverStopped
objectiveValue

% 清除变量
clearvars istest_part12 istest_part22 istest_product2 istear2 initialPoint...
    options reasonSolverStopped objectiveValue


%%
function objective = objectiveFcn(istest_part1,istest_part2,istest_product,istear)
% 此函数应返回一个表示优化目标的标量。

% 示例: 小吃摊位利润
% revenue = 3*soda + 5*popcorn + 2*candy;
% cost = 1*soda + 2*popcorn + 0.75*candy;
% objective = revenue - cost; % profit

% 编辑以下行以添加您的计算方法。

% %1
% part_error_original=[0.1 0.1];
% part_fee_original=[4 18];
% testfee_part=[2 3];
% errorrate_construct=0.1;
% partfee_construct=6;
% testfee_product=3;
% changefee=6;
% tearfee=5;

% 2
% part_error_original=[0.2 0.2];
% part_fee_original=[4 18];
% testfee_part=[2 3];
% errorrate_construct=0.2;
% partfee_construct=6;
% testfee_product=3;
% changefee=6;
% tearfee=5;

% 3
% part_error_original=[0.1 0.1];
% part_fee_original=[4 18];
% testfee_part=[2 3];
% errorrate_construct=0.1;
% partfee_construct=6;
% testfee_product=3;
% changefee=30;
% tearfee=5;

% 4
part_error_original=[0.2 0.2];
part_fee_original=[4 18];
testfee_part=[1 1];
errorrate_construct=0.2;
partfee_construct=6;
testfee_product=2;
changefee=30;
tearfee=5;

% %5
% part_error_original=[0.1 0.2];
% part_fee_original=[4 18];
% testfee_part=[8 1];
% errorrate_construct=0.1;
% partfee_construct=6;
% testfee_product=2;
% changefee=10;
% tearfee=5;

% %6
% part_error_original=[0.05 0.05];
% part_fee_original=[4 18];
% testfee_part=[2 3];
% errorrate_construct=0.05;
% partfee_construct=6;
% testfee_product=3;
% changefee=10;
% tearfee=40;

if(istest_part1)
    part_error1=0;
else
    part_error1=part_error_original(1);
end
if(istest_part2)
    part_error2=0;
else
    part_error2=part_error_original(2);
end

part_fee_sub1=part_fee_original(1)+istest_part1*(part_error1/(1-part_error1))*(part_fee_original(1)+testfee_part(1));
part_fee_sub2=part_fee_original(2)+istest_part2*(part_error2/(1-part_error2))*(part_fee_original(2)+testfee_part(2));
part_fee1=part_fee_sub1+istest_part1*testfee_part(1);
part_fee2=part_fee_sub2+istest_part2*testfee_part(2);

errorrate_product=1-(1-part_error1)*(1-part_error2)*(1-errorrate_construct);

cover_fee=(errorrate_product/(1-errorrate_product))*(part_fee1+part_fee2+partfee_construct+testfee_product+istear*(tearfee-part_fee_sub1-part_fee_sub2))+(1-istest_product)*changefee;

partfee_product=partfee_construct+istest_product*testfee_product+cover_fee;

objective = part_fee1+part_fee2+partfee_product;

end

function constraints = constraintFcn(istest_part1,istest_part2,istest_product,istear)
% 此函数应返回由优化约束组成的向量。
% 约束是由一个比较运算符(<=、>=、==)分隔的两个表达式。

% 请注意，同一个约束向量中的所有比较运算符必须相同。
% 要使用不同比较运算符，请为每个运算符单独创建一个函数。

% 示例: 工厂生产能力约束
% factory1Cap =  500*x + 200*y + 100*z;
% factory2Cap = 1000*x + 100*y + 400*z;
% constraints(1) = factory1Cap + factory1Cap <= 500;

% 编辑以下行以添加您的计算方法。
result=objectiveFcn(istest_part1,istest_part2,istest_product,istear);
constraints(1) = result <= 56;
end