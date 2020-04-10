function furtherprocess()
%%
%ͼ��������ֵ��
I = imread('r2_5.bmp');
[height,width] = size(I);
Ibw = imbinarize(I,0.5);%ͼ���ֵ��
Ibw = ~Ibw;
figure(1);
subplot(1,3,1);imshow(Ibw);title("��ֵ��ͼ��");
%%
%��̬ѧ����ȥ��
%ȥ���µ�
CC = bwconncomp(Ibw);%����ͨ��
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,num] = size(numPixels);
Ifill = false(size(Ibw));
for i = 1:num
    if numPixels(i)>50 %ȥ����ͨ��С����ֵ�Ĳ��֣���ȥ���µ�
        Ifill(CC.PixelIdxList{i}) = 1;
    end
end
subplot(1,3,2);imshow(Ifill);title("ȥ���µ���");
%��ڶ�������ɫȥ���µ�
Ifill = ~Ifill;%��ɫ
CC = bwconncomp(Ifill);%����ͨ��
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,num] = size(numPixels);
Ifill2 = false(size(Ibw));
for i = 1:num
    if numPixels(i)>200 %ȥ����ͨ��С����ֵ�Ĳ��֣���ȥ���˷�ɫ�еĹµ�
        Ifill2(CC.PixelIdxList{i}) = 1;
    end
end
Ifill2 = ~Ifill2;%��ɫ
subplot(1,3,3);imshow(Ifill2);title("ȥ���ڶ���");
%%
%ϸ��
Ithin = bwmorph(Ifill2,'thin',inf);
figure(2);
subplot(1,2,1);imshow(Ithin);title("ϸ��ͼ��");
%����
%ȥ������
CC = bwconncomp(Ithin);%����ͨ��
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,num] = size(numPixels);
Ithin2 = false(size(Ibw));
for i = 1:num
    if numPixels(i)>30 %ȥ����ͨ��С����ֵ�Ĳ��֣���ȥ���µ�
        Ithin2(CC.PixelIdxList{i}) = 1;
    end
end
% ȥ��覴ã��Ƚ����⣬����ȥ��
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
%�޼�ȥ��ë��
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
    %ȥ��ë��
    Icut = Icut&~endp1;
    Icut = Icut&~endp2;
    Icut = Icut&~endp3;
    Icut = Icut&~endp4;
    Icut = Icut&~endp5;
    Icut = Icut&~endp6;
    Icut = Icut&~endp7;
    Icut = Icut&~endp8;
end
endpoints = Endpoints(Icut);%�˵�
B = [1 1 1; 1 1 1; 1 1 1];
for k =1:5
endpoints = imdilate(endpoints, B) & Ithin2;%�˵���������
end
Icut = Icut | endpoints;%ȡ�ò���
% ȥ���Ž�
% �����ʶ��
intersection = [];%�����
intersectionnum = 0;%�������Ŀ
for i = 2:height-1
    for j = 2:width-1
        if Icut(i,j) == 1
            point = [i-1,j-1;i-1,j;i-1,j+1;i,j+1;i+1,j+1;i+1,j;i+1,j-1;i,j-1];%��ΧһȦ�������
            count = 0;
            for k = 1:8%����仯����
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
            resultcount = count/2;%����cnֵ
            if resultcount == 3%�����
                temppoint = [i,j];
                intersection = [intersection;temppoint];
                intersectionnum = intersectionnum + 1;
            end
        end
    end
end
% �Žӵ�ʶ��
bridge_point = [];
bridge_point_num = 0;
for i = 1:intersectionnum
    for j = 1:intersectionnum
        if i~= j
            distance = ((intersection(i,1)-intersection(j,1))^2 + (intersection(i,2)-intersection(j,2))^2)^0.5;
            if distance < 5%�������С��ĳһ����ֵ���˴�Ϊ10������Ϊ�Žӵ�
                temppoints = [intersection(i,1),intersection(i,2),intersection(j,1),intersection(j,2)];
                bridge_point = [bridge_point;temppoints];
                bridge_point_num = bridge_point_num + 1;
            end
        end
    end
end
% ȥ���Ž�
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
subplot(1,2,2);imshow(Icut);title("������");
%%
%ϸ�ڵ�ʶ��
intersection = [];%�����
intersectionnum = 0;%�������Ŀ
endpoint = [];%�˵�
endpointnum = 0;%�˵���Ŀ
for i = 2:height-1
    for j = 2:width-1
        if Icut(i,j) == 1
            point = [i-1,j-1;i-1,j;i-1,j+1;i,j+1;i+1,j+1;i+1,j;i+1,j-1;i,j-1];%��ΧһȦ�������
            count = 0;
            for k = 1:8%����仯����
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
            resultcount = count/2;%����cnֵ
            if resultcount == 3%�����
                temppoint = [i,j];
                intersection = [intersection;temppoint];
                intersectionnum = intersectionnum + 1;
            end
            if resultcount == 1%�˵�
                temppoint = [i,j];
                endpoint = [endpoint;temppoint];
                endpointnum = endpointnum + 1;
            end
        end
    end
end
Iprocess = Icut;
%��ʾϸ�ڵ㣬������Χ����һ�����ο�
figure(3);
subplot(1,2,1);imshow(~Iprocess);title("�������ʶ��");
hold on; plot(intersection(:,2),intersection(:,1),'gs','MarkerSize',10);
hold on; plot(endpoint(:,2),endpoint(:,1),'rs','MarkerSize',10);
%��Ե�˵�ȥ��
Iprocess2 = Icut;
sign = zeros(1,endpointnum);
for i = 1:endpointnum
    temppoint = [endpoint(i,1),endpoint(i,2)];%�������
    %��־����ǰ���ĸ��������Ƿ��а�ɫ��
    tempsign1 = 0;%��
    tempsign2 = 0;%��
    tempsign3 = 0;%��
    tempsign4 = 0;%��
    extendlen = 50;%���������̽�����
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
    if tempsign1 == 1 && tempsign2 == 1 && tempsign3 == 1 && tempsign4 == 1%����ĸ������а�ɫ�㣬���Ǳ�Ե�˵�
        sign(i) = 1;
    end
end
%ȥ�����Ѵ��Ķ˵�
for i = 1:endpointnum
    for j = 1:endpointnum
        if sign(i) == 1 && sign(j) == 1 && i~=j
            distance = ((endpoint(i,1)-endpoint(j,1))^2 + (endpoint(i,2)-endpoint(j,2))^2)^0.5;
            if distance < 10%�������С��ĳһ����ֵ���˴�Ϊ10������Ϊ�����γɵĶ˵�
                sign(i) = 0;
                sign(j) = 0;
            end
        end
    end
end
%������ϸ�ڵ�������ʾ
endpoint2 = [];%ȥ����Ե�˵��Ķ˵㼯
endpoint2num = 0;
for i = 1:endpointnum
    if sign(i) == 1
        endpoint2 = [endpoint2;endpoint(i,1),endpoint(i,2)];
        endpoint2num = endpoint2num + 1;
    end
end
subplot(1,2,2);imshow(~Icut);title("������ϸʶ��");
hold on; plot(intersection(:,2),intersection(:,1),'gs','MarkerSize',10);
hold on; plot(endpoint2(:,2),endpoint2(:,1),'rs','MarkerSize',10);
end