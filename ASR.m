
% === 基本設定 ===
input_folder = 'subjects_filtered';
output_folder = 'subjects_asr';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 取得所有 .set 檔案（從 Filtered 資料夾讀取）
files = dir(fullfile(input_folder, '*_Filtered.set'));

% === 處理每一個檔案（套用 ASR）===
for i = 1:length(files)
    file = files(i).name;
    filepath = fullfile(input_folder, file);

    % 讀取 .set 檔案
    EEG = pop_loadset('filename', file, 'filepath', input_folder);
    EEG = eeg_checkset(EEG);

    % 套用 ASR（使用 clean_rawdata 的參數）
    % 將 Process/remove channels 與 Additional removal of bad data periods 關掉（老師要求）
   EEG = clean_rawdata(EEG, ...
    -1, ...      % FlatlineCriterion (不檢查)
    -1, ...      % ChannelCriterion (不移除通道)
    -1, ...      % Line noise Criterion (不使用)
    -1, ...      % Highpass (預設 off)
    20, ...      % BurstCriterion (ASR threshold = 20)
    -1);         % WindowCriterion (不額外剪段)

    EEG = eeg_checkset(EEG);

    % 產生新檔名（加 _ASR）
    [~, name, ~] = fileparts(file);  % 原為 ADHD_v10p_Filtered
    new_filename = [name '_ASR.set'];  % ADHD_v10p_Filtered_ASR.set

    % 儲存新檔案
    pop_saveset(EEG, 'filename', new_filename, 'filepath', output_folder);
    fprintf("✅ 已完成 ASR 並儲存：%s\%s\n", output_folder, new_filename);
end

disp("✅ 所有檔案 ASR 處理完成！");
