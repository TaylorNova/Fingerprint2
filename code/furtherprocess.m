function furtherprocess()
%%
%图像读入与二值化
I = imread('r2_5.bmp');
[height,width] = size(I);
Ibw = imbinarize(I,0.5);%图像二值化
Ibw = ~Ibw;
figure(1);
subplot(1,3,1);imshow(Ibw);title("二值化图像");
%%
%形态学处理去噪
%去掉孤岛
CC = bwconncomp(Ibw);%找连通域
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,num] = size(numPixels);
Ifill = false(size(Ibw));
for i = 1:num
    if numPixels(i)>50 %去除连通域小于阈值的部分，即去除孤岛
        Ifill(CC.PixelIdxList{i}) = 1;
    end
end
subplot(1,3,2);imshow(Ifill);title("去除孤岛后");
%填补黑洞，即反色去除孤岛
Ifill = ~Ifill;%反色
CC = bwconncomp(Ifill);%找连通域
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,num] = size(numPixels);
Ifill2 = false(size(Ibw));
for i = 1:num
    if numPixels(i)>200 %去除连通域小于阈值的部分，即去除了反色中的孤岛
        Ifill2(CC.PixelIdxList{i}) = 1;
    end
end
Ifill2 = ~Ifill2;%反色
subplot(1,3,3);imshow(Ifill2);title("去除黑洞后");
%%
%细化
Ithin = bwmorph(Ifill2,'thin',inf);
figure(2);
subplot(1,2,1);imshow(Ithin);title("细化图像");
%后处理
%去除短线
CC = bwconncomp(Ithin);%找连通域
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,num] = size(numPixels);
Ithin2 = false(size(Ibw));
for i = 1:num
    if numPixels(i)>30 %去除连通域小于阈值的部分，即去除孤岛
        Ithin2(CC.PixelIdxList{i}) = 1;
    end
end
% 去除瑕疵，比较特殊，具体去除
interval = [-1 1 1
            1 0 1
            1 1 -1];
bridge = bwhitmiss(Ithin2, interval);
bridge2 = bridge;
for i = 2:height-1
    for j = 2:width-1
        if bridge(i,j) == 1
            point = [i-1,j-1;i-1,j;i-1,j+1;i,j+1;i+1,j+1;i+1,j;i+1,j-1;i,j-1];
            for k = 1:8
                bridge2(point(k,1),point(k,2)) = 1;
            end
        end
    end
end
Ithin2 = Ithin2&~bridge2;
%修剪去除毛刺
Icut = Ithin2;
interval1 = [0 -1 -1
            1 1 -1
            0 -1 -1];
interval2 = [-1 -1 -1
            -1 1 -1
            0 1 0];
interval3 = [-1 -1 0
            -1 1 1
            -1 -1 0];
interval4 = [0 1 0
            -1 1 -1
            -1 -1 -1];
interval5 = [1 -1 -1
            -1 1 -1
            -1 -1 -1];
interval6 = [-1 -1 -1
            -1 1 -1
            1 -1 -1];
interval7 = [-1 -1 -1
            -1 1 -1
            -1 -1 1];
interval8 = [-1 -1 1
            -1 1 -1
            -1 -1 -1];
for k = 1:5
    endp1 = bwhitmiss(Icut, interval1);
    endp2 = bwhitmiss(Icut, interval2);
    endp3 = bwhitmiss(Icut, interval3);
    endp4 = bwhitmiss(Icut, interval4);
    endp5 = bwhitmiss(Icut, interval5);
    endp6 = bwhitmiss(Icut, interval6);
    endp7 = bwhitmiss(Icut, interval7);
    endp8 = bwhitmiss(Icut, interval8);
    %去除毛刺
    Icut = Icut&~endp1;
    Icut = Icut&~endp2;
    Icut = Icut&~endp3;
    Icut = Icut&~endp4;
    Icut = Icut&~endp5;
    Icut = Icut&~endp6;
    Icut = Icut&~endp7;
    Icut = Icut&~endp8;
end
endpoints = Endpoints(Icut);%端点
B = [1 1 1; 1 1 1; 1 1 1];
for k =1:5
endpoints = imdilate(endpoints, B) & Ithin2;%端点条件膨胀
end
Icut = Icut | endpoints;%取得并集
% 去除桥接
% 交叉点识别
intersection = [];%交叉点
intersectionnum = 0;%交叉点数目
for i = 2:height-1
    for j = 2:width-1
        if Icut(i,j) == 1
            point = [i-1,j-1;i-1,j;i-1,j+1;i,j+1;i+1,j+1;i+1,j;i+1,j-1;i,j-1];%周围一圈点的坐标
            count = 0;
            for k = 1:8%计算变化次数
                if k ~= 8
                    if Icut(point(k,1),point(k,2)) ~= Icut(point(k+1,1),point(k+1,2))
                        count = count + 1;
                    end
                else
                    if Icut(point(k,1),point(k,2)) ~= Icut(point(1,1),point(1,2))
                        count = count + 1;
                    end
                end
            end
            resultcount = count/2;%计算cn值
            if resultcount == 3%交叉点
                temppoint = [i,j];
                intersection = [intersection;temppoint];
                intersectionnum = intersectionnum + 1;
            end
        end
    end
end
% 桥接点识别
bridge_point = [];
bridge_point_num = 0;
for i = 1:intersectionnum
    for j = 1:intersectionnum
        if i~= j
            distance = ((intersection(i,1)-intersection(j,1))^2 + (intersection(i,2)-intersection(j,2))^2)^0.5;
            if distance < 5%如果距离小于某一个阈值，此处为10，则视为桥接点
                temppoints = [intersection(i,1),intersection(i,2),intersection(j,1),intersection(j,2)];
                bridge_point = [bridge_point;temppoints];
                bridge_point_num = bridge_point_num + 1;
            end
        end
    end
end
% 去除桥接
for i = 1:height
    for j = 1:width
        for k = 1:bridge_point_num
            if (i-bridge_point(k,1))*(i-bridge_point(k,3)) <= 0 && (j-bridge_point(k,2))*(j-bridge_point(k,4)) <= 0
                Icut(i,j) = 0;
                tempsign = zeros(1,4);
                tempsign(1) = (i == bridge_point(k,1));
                tempsign(2) = (i == bridge_point(k,3));
                tempsign(3) = (j == bridge_point(k,2));
                tempsign(4) = (j == bridge_point(k,4));
                tempsum = sum(tempsign);
                if tempsum >1
                    Icut(i,j) = 1;
                end
            end
        end
    end
end
subplot(1,2,2);imshow(Icut);title("后处理结果");
%%
%细节点识别
intersection = [];%交叉点
intersectionnum = 0;%交叉点数目
endpoint = [];%端点
endpointnum = 0;%端点数目
for i = 2:height-1
    for j = 2:width-1
        if Icut(i,j) == 1
            point = [i-1,j-1;i-1,j;i-1,j+1;i,j+1;i+1,j+1;i+1,j;i+1,j-1;i,j-1];%周围一圈点的坐标
            count = 0;
            for k = 1:8%计算变化次数
                if k ~= 8
                    if Icut(point(k,1),point(k,2)) ~= Icut(point(k+1,1),point(k+1,2))
                        count = count + 1;
                    end
                else
                    if Icut(point(k,1),point(k,2)) ~= Icut(point(1,1),point(1,2))
                        count = count + 1;
                    end
                end
            end
            resultcount = count/2;%计算cn值
            if resultcount == 3%交叉点
                temppoint = [i,j];
                intersection = [intersection;temppoint];
                intersectionnum = intersectionnum + 1;
            end
            if resultcount == 1%端点
                temppoint = [i,j];
                endpoint = [endpoint;temppoint];
                endpointnum = endpointnum + 1;
            end
        end
    end
end
Iprocess = Icut;
%显示细节点，给其周围套上一个矩形框
figure(3);
subplot(1,2,1);imshow(~Iprocess);title("特征点粗识别");
hold on; plot(intersection(:,2),intersection(:,1),'gs','MarkerSize',10);
hold on; plot(endpoint(:,2),endpoint(:,1),'rs','MarkerSize',10);
%边缘端点去除
Iprocess2 = Icut;
sign = zeros(1,endpointnum);
for i = 1:endpointnum
    temppoint = [endpoint(i,1),endpoint(i,2)];%点的坐标
    %标志，当前点四个方向上是否有白色点
    tempsign1 = 0;%上
    tempsign2 = 0;%下
    tempsign3 = 0;%左
    tempsign4 = 0;%右
    extendlen = 50;%各个方向的探测距离
    for j = 1:extendlen 
        if temppoint(1)-j < 1
            break;
        end
        if Iprocess2(temppoint(1)-j,temppoint(2)) == 1
            tempsign1 = 1;
        end
    end
    for j = 1:extendlen 
        if temppoint(1)+j > height
            break;
        end
        if Iprocess2(temppoint(1)+j,temppoint(2)) == 1
            tempsign2 = 1;
        end
    end
    for j = 1:extendlen 
        if temppoint(2)-j < 1
            break;
        end
        if Iprocess2(temppoint(1),temppoint(2)-j) == 1
            tempsign3 = 1;
        end
    end
    for j = 1:extendlen
        if temppoint(2)+j > width
            break;
        end
        if Iprocess2(temppoint(1),temppoint(2)+j) == 1
            tempsign4 = 1;
        end
    end
    if tempsign1 == 1 && tempsign2 == 1 && tempsign3 == 1 && tempsign4 == 1%如果四个方向都有白色点，则不是边缘端点
        sign(i) = 1;
    end
end
%去除断裂处的端点
for i = 1:endpointnum
    for j = 1:endpointnum
        if sign(i) == 1 && sign(j) == 1 && i~=j
            distance = ((endpoint(i,1)-endpoint(j,1))^2 + (endpoint(i,2)-endpoint(j,2))^2)^0.5;
            if distance < 10%如果距离小于某一个阈值，此处为10，则视为断裂形成的端点
                sign(i) = 0;
                sign(j) = 0;
            end
        end
    end
end
%处理后的细节点重新显示
endpoint2 = [];%去除边缘端点后的端点集
endpoint2num = 0;
for i = 1:endpointnum
    if sign(i) == 1
        endpoint2 = [endpoint2;endpoint(i,1),endpoint(i,2)];
        endpoint2num = endpoint2num + 1;
    end
end
subplot(1,2,2);imshow(~Icut);title("特征点细识别");
hold on; plot(intersection(:,2),intersection(:,1),'gs','MarkerSize',10);
hold on; plot(endpoint2(:,2),endpoint2(:,1),'rs','MarkerSize',10);
end