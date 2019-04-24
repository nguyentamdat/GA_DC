clear;
load('dataSample.mat');
[crom1Len, crom2Len] = size(varibles);%crom 1 chon mau de can chinh va kiem tra crom 2 chon cac diem co the anh huong den duong hoi quy
mutRate = 0.1; %ti le dot bien
popSize = 40;%kich thuoc quan the

pop = round(rand(popSize, crom1Len + crom2Len)); %khoi tao quan the

avg_fitness=zeros; %finess trung binh tung the he
buffer = zeros(1,3); %bo nho tam luu min 3 the he gan nhat
deviation = zeros; %do lech chuan tung the he
n = 50;%so the he toi da

best = [];%mang luu gia tri ff tot nhat moi the he
best_X = [];%mang luu nghiem tot nhat moi the he
bestPop = [];%mang luu cach chon tot nhat moi the he
iter = 0;
while iter < n
    iter = iter + 1;
    f = [];%luu lai gia tri fitness tu ca the
    beta = [];%luu tham so cua tung ca the tinh duoc, la nghiem can tim
    %dong for nay dung de tinh gia tri cua quan the hien tai
    %Tach 7 bit dau la bit chon sample de hieu chinh lai mo hinh
    %533 bit con lai la bit chon varible de quyet dinh coef
    for i=1:popSize
        crom1 = pop(i,1:crom1Len);
        %truong hop ca the chon toan bo cho tap hieu chinh hoac tap kiem
        %tra thi loai bo ca the
        if mean(crom1) == 0 || mean(crom1) == 1
            f = [f; 10];
            beta = [beta zeros(size(crom2,2)+1,1)];
        else
            crom2 = pop(i, crom1Len+1:crom1Len+crom2Len);
            rmsep = [];%mang tinh sai so du doan
            Xbar = [];%mang gia tri X mo rong them cot dau la gia tri tu do bang 1
            y = [];
            %dong for nay dung de tinh lap ma tran cac mau de hieu chinh
            for j=1:crom1Len
                if crom1(j) == 1
                    Xbar = [Xbar; crom2.*varibles(j,:)];
                    y = [y; samples(j)];
                end
            end
            %tinh phuong trinh w = (X_bar.T * X_bar)^-1 * X_bar.T * y voi w
            %la nghiem
            Xbar = [ones(size(Xbar,1),1), Xbar];
            A = Xbar' * Xbar;
            b = Xbar' * y;
            w = lsqminnorm(A, b);%co the dung pinv hoac \
            %dong for dua ra tien doan va tinh sai so
            for j=1:7
                if crom1(j) == 0
                    Temp = [1, crom2.*varibles(j,:)];
                    rmsep = [rmsep; (Temp * w - samples(j))^2];
                end
            end
            f = [f; mean(rmsep)];%sai so trung binh duoc luu lai
            beta = [beta w];%luu lai nghiem tim dc
        end
    end
    %xep lai quan the theo thu tu tot nhat, luu lai cac gia tri tot nhat
    %cua the he hien tai
    [f, ind] = sort(f, 'ascend');
    pop = pop(ind, :);
    beta = beta(:,ind);
    avg_fitness(iter) = mean(f);
    best = [best f(1)];
    best_X = [best_X beta(:,1)];
    bestPop = [bestPop; pop(1,:)];
    %lai tao quan the moi, khoi tao mot chuoi bit neu bit bang 1 thi chon
    %cua bo nguoc lai chon cua me
    %cac phan tu le chon nguoc lai
    dad = round((rand(1,popSize/2))*19)+1;
    mom = round((rand(1,popSize/2))*19)+1;
    bitwise = round(rand(1,crom1Len+crom2Len));
    pop(1:2:popSize,:) = (pop(dad,:) & bitwise) | (pop(mom,:) & ~bitwise);
    pop(2:2:popSize,:) = (pop(dad,:) & ~bitwise) | (pop(mom,:) & bitwise);
    %kien tra sai so trong 3 chu ki gan nhat, neu thoa dieu kien thi dung
    if iter >= 3
        buffer = best(1,iter-2:1:iter);
        deviation(iter-2) = std(buffer, 0, 2);
        clear std;
        if deviation(iter-2) < 0.001
            minn = best(iter)
            x = best_X(:,iter)
            X = bestPop(iter,:)
            break
        end
    end
    %dot bien mot so ca the
    nmut = ceil(popSize*(crom1Len + crom2Len)*mutRate);
    for i=1:nmut
        col = randi(crom1Len+crom2Len);
        row = randi(popSize);
        pop(row, col) = ~pop(row, col);
    end
end
%in ket qua
t=1:iter;
plot(t,best);
if ~exist('X')
    [minn, ind] = min(avg_fitness);
    x = best_X(:,ind);
end
figure;
hold on;
plot([0 18], [0 18]);
for i=1:crom1Len
    disp(["Mau: ", samples(i)]);
    disp(["Tien doan: ", [1, varibles(i,:)] * x]);
    plot(samples(i), [1, varibles(i,:)] * x, 'ro');
end
xlabel("Thuc nghiem");
ylabel("Tien doan");