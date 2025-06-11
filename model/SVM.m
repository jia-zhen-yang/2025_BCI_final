
% === Step 1: 讀取資料與特徵工程 ===
filename = 'EEG_spectral_features.csv';
T = readtable(filename);

% 選擇特徵欄位與類別標籤
X = T{:, 2:end-1};
y = double(strcmp(T.Class, 'ADHD'));

% 加入自訂 ratio 特徵

% 標準化（Z-score）
X = T{:, 2:end-1};  % 所有特徵欄位

% === Step 2: 定義核函數與模型儲存 ===
kernels = {'linear','polynomial','rbf'};
results = table('Size',[0 5], ...
    'VariableTypes',{'string','double','double','double','double'}, ...
    'VariableNames',{'Kernel','Accuracy','Sensitivity','Specificity','BestBoxConstraint'});

% === Step 3: 執行每個核函數的調參與 5-fold 交叉驗證 ===
cv = cvpartition(y, 'KFold', 5);

for i = 1:length(kernels)
    accs = zeros(cv.NumTestSets,1);
    sens = zeros(cv.NumTestSets,1);
    spec = zeros(cv.NumTestSets,1);
    best_Cs = zeros(cv.NumTestSets,1);

    fprintf("\n🔍 正在處理 kernel: %s\n", kernels{i});

    for fold = 1:cv.NumTestSets
        fprintf(" → Fold %d/%d ...\n", fold, cv.NumTestSets);

        Xtrain = X(training(cv,fold), :);
        Ytrain = y(training(cv,fold));
        Xtest = X(test(cv,fold), :);
        Ytest = y(test(cv,fold));

        % 自動調參（找 BoxConstraint、KernelScale）
        model = fitcsvm(Xtrain, Ytrain, ...
            'KernelFunction', kernels{i}, ...
            'Standardize', true, ...
            'OptimizeHyperparameters', {'BoxConstraint','KernelScale'}, ...
            'HyperparameterOptimizationOptions', struct('ShowPlots',false,'Verbose',0));

        % === 顯示 Training Accuracy ===
        Ytrain_pred = predict(model, Xtrain);
        train_acc = mean(Ytrain_pred == Ytrain);
        fprintf("   Training Accuracy: %.2f%%\n", train_acc * 100);


        % 預測與統計
        Ypred = predict(model, Xtest);
        conf = confusionmat(Ytest, Ypred, 'Order', [1 0]); % ADHD = 1, Control = 0

        accs(fold) = sum(Ypred == Ytest) / length(Ytest);
        fprintf("   Testing Accuracy: %.2f%%\n", accs(fold) * 100);

        sens(fold) = conf(1,1) / (conf(1,1)+conf(1,2)+eps);
        spec(fold) = conf(2,2) / (conf(2,2)+conf(2,1)+eps);
        best_Cs(fold) = model.BoxConstraints(1);
    end

    % 平均統計加入表格
    results(end+1,:) = {kernels{i}, mean(accs), mean(sens), mean(spec), mean(best_Cs)};
end

% === Step 4: 顯示結果 ===
disp("✅ 各核函數 SVM 效果比較：");
disp(results);
fprintf("SVM 平均準確率：%.2f%%\n", mean(accs)*100);
% 混淆矩陣
figure;
confusionchart(conf_total, {'ADHD','Control'});
title('SVM Confusion Matrix');

% 指標 bar chart
figure;
bar([mean(accs), mean(recalls), mean(specs)]);
ylim([0 1]);
set(gca, 'XTickLabel', {'Accuracy','Recall (ADHD)','Specificity (Control)'});
ylabel('Score');
title('SVM Confusion Matrix');
