
% === [1] 基本設定 ===
filename = 'adhdata.csv';        % 你的CSV檔案
srate = 128;                     % 採樣率
output_folder = 'subjects_set1'; % 儲存資料夾

% 建立儲存資料夾（如果不存在）
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% === [2] 讀入資料 ===
opts = detectImportOptions(filename);
opts = setvartype(opts, {'Class', 'ID'}, 'string');  % 確保 ID 和 Class 為字串
T = readtable(filename, opts);

% === [3] 取得通道欄位（從 Fp1 到 Pz，共19個）===
channel_labels = T.Properties.VariableNames(1:19);

% === [4] 取得所有不重複的受試者 ID ===
unique_ids = unique(T.ID);

% === [5] 對每位受試者進行轉換 ===
for i = 1:length(unique_ids)
    id = unique_ids(i);
    rows = T.ID == id;

    % 取出該人資料，轉成 matrix (channel × time)
    data_per_subject = T{rows, 1:19}';
    class_label = T.Class(find(rows, 1));  % 該人是 ADHD 或 Control

    % 建立 EEG 結構
    EEG = pop_importdata('dataformat','array','data','data_per_subject','srate',srate);
    EEG.chanlocs = struct('labels', channel_labels);
    EEG = pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
    EEG.subject = id;
    EEG.group = class_label;
    EEG = eeg_checkset(EEG);

    % 檢查並移除含 NaN 的 channel（保留乾淨通道）
    all_chan = 1:EEG.nbchan;
    nan_chan = find(any(isnan(EEG.data), 2));
    good_chan = setdiff(all_chan, nan_chan);

    EEG = pop_select(EEG, 'channel', good_chan);
    EEG = eeg_checkset(EEG);

    % 儲存 .set 檔案：ADHD_v10p.set 或 Control_v12p.set
    filename_only = class_label + "_" + id + ".set";
    filepath_only = output_folder;

    pop_saveset(EEG, 'filename', char(filename_only), 'filepath', char(filepath_only));
    fprintf("✅ 已儲存 %s (%s)", filename_only, class_label);
end

disp("✅ 全部受試者轉換與清理完成！");
