load('dataSample.mat');
varibles = varibles.*10;%do so qua nho nen can phai nhan len de tinh toan ma tran
crom1Len = 7; %crom1 la crom chon so luong mau de can chinh model
crom2Len = 533; %crom2 la crom chon so luong bien x co de tinh mau
mutRate = 0.01; %ti le dot bien
popSize = 40;%kich thuoc quan the

pop = round(rand(popSize, crom1Len + crom2Len)); %Init population

avg_fitness=zeros; %finess trung binh tung the he
buffer = zeros(1,20); %bo nho tam luu max 20 the he gan nhat
deviation = zeros; %do lech chuan tung the he
f_tmp = zeros(1,popSize/2); %bo nho tam luu 1/2 quan the sau chon loc
n = 500;%so the he toi da

best = [];%mang luu gia tri tot nhat moi the he
best_X = [];%mang luu nghiem tot nhat moi the he

iter = 0;
while iter < n
    iter = iter + 1;
    f = [];
    %dong for nay dung de tinh gia tri cua quan the hien tai
    %Tach 7 bit dau la bit chon sample de hieu chinh lai mo hinh
    %533 bit con lai la bit chon varible de quyet dinh coef
    for i=1:popSize
        crom1 = pop(i,1:7);
        crom2 = pop(i, 8:crom1Len+crom2Len);
        cnt = 0;%bien dem so luong
        coef = zeros;%coef
        smrep = [];%mang du doan
        %dong for nay dung de tinh coef
        for j=1:7
            if crom1(j) == 1
                Temp = crom2.*varibles(j,:);
                cnt = cnt + 1;
                coef = coef + Temp \ samples(j);
            end
        end
        coef = coef ./ cnt;
        cnt = 0;
        %dong for nay de predict va tinh sai lech cua ham smrep
        for j=1:7
            if crom1(j) == 0
                Temp = crom2.*varibles(j,:);
                cnt = cnt + 1;
                smrep = [smrep abs(Temp * coef - samples(j))];
            end
        end
        smrep = sum(smrep) / cnt;
        f = [f smrep];
    end
    %xep lai quan the theo thu tu nhat dinh
    [f, ind] = sort(f, 'ascend');
    pop = pop(ind, :);
    best = [best f(1)];
    best_X = [best_X;pop(1,:)];
    %lai tao quan the moi, khoi tao mot chuoi bit neu bit bang 1 thi chon
    %cua bo nguoc lai chon cua me
    %cac phan tu le chon nguoc lai
    dad = round((rand(1,popSize/2))*19)+1;
    mom = round((rand(1,popSize/2))*19)+1;
    bitwise = round(rand(1,crom1Len+crom2Len));
    pop(1:2:popSize,:) = (pop(dad,:) & bitwise) | (pop(mom,:) & ~bitwise);
    pop(2:2:popSize,:) = (pop(dad,:) & ~bitwise) | (pop(mom,:) & bitwise);
    if iter >= 20
        buffer = best(1,iter-19:1:iter);
        deviation(iter-19) = std(buffer, 0, 2);
        clear std;
        if deviation(iter-19) < 0.001
            min = best(iter)
            x = best_X(iter,:)
            break
        end
    end
    nmut = ceil(popSize*(crom1Len + crom2Len)*mutRate);
    for i=1:nmut
        col = randi(crom1Len+crom2Len);
        row = randi(popSize);
        pop(row, col) = ~pop(row, col);
    end
end
hold on
t= 1:iter;
plot(t,best);