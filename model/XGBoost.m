
% === Step 1: 讀取 EEG 特徵資料 ===
T = readtable('EEG_spectral_features.csv');

% === Step 2: 整理特徵與標籤 ===
X = T{:, 2:end-1};

% 類別標籤：ADHD=1, Control=0
labels = double(strcmp(T.Class, 'ADHD'));

% === Step 3: 5-fold 分類與交叉驗證 ===
cv = cvpartition(labels, 'KFold', 5);
accs = zeros(cv.NumTestSets,1);
train_accs = zeros(cv.NumTestSets,1);
test_accs = zeros(cv.NumTestSets,1);
recalls = zeros(cv.NumTestSets,1);
specs = zeros(cv.NumTestSets,1);
conf_total = zeros(2,2);

for i = 1:cv.NumTestSets
    trainIdx = training(cv, i);
    testIdx = test(cv, i);

    Xtrain = features(trainIdx,:);
    Ytrain = labels(trainIdx);
    Xtest = features(testIdx,:);
    Ytest = labels(testIdx);

    % 使用 XGBoost 等效模型（Boosted Trees）
    mdl = fitcensemble(Xtrain, Ytrain, ...
        'Method', 'LogitBoost', ...
        'NumLearningCycles', 20, ...
        'Learners', templateTree('MaxNumSplits', 5));

    Ypred = predict(mdl, Xtest);
    ytrain_pred = predict(mdl, Xtrain);
    train_accs(i) = sum(ytrain_pred == Ytrain) / length(Ytrain);
    test_accs(i) = sum(Ypred == Ytest) / length(Ytest);

    % 混淆矩陣與指標
    cm = confusionmat(Ytest, Ypred, 'Order', [1 0]);
    accs(i) = sum(Ypred == Ytest) / length(Ytest);
    recalls(i) = cm(1,1) / (cm(1,1)+cm(1,2)+eps);  % ADHD recall
    specs(i) = cm(2,2) / (cm(2,2)+cm(2,1)+eps);    % Control recall
    conf_total = conf_total + cm;
end

% === Step 4: 顯示與繪圖 ===
fprintf("XGBoost 平均準確率：%.2f%%\n", mean(accs)*100);
fprintf("Recall ADHD：%.2f%%\n", mean(recalls)*100);
fprintf("pecificity Control：%.2f%%\n", mean(specs)*100);
fprintf("Training Accuracy: %.2f%%\n", mean(train_accs)*100);
fprintf("Testing Accuracy: %.2f%%\n", mean(test_accs)*100);

% 混淆矩陣視覺化
figure;
confusionchart(conf_total, {'ADHD','Control'});
title('XGBoost Confusion Matrix');

% bar chart
figure;
bar([mean(accs), mean(recalls), mean(specs)]);
set(gca, 'XTickLabel', {'Accuracy','Recall (ADHD)','Specificity (Control)'});
ylim([0 1]);
ylabel('Score');
title('XGBoost Confusion Matrix');
