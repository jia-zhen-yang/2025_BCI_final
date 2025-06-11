% === 基本設定 ===
input_folder = 'subjects_asr';          % 來源資料夾（ASR 後）
output_folder = 'subjects_selected';    % 篩選後儲存資料夾
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 指定要保留的 channel 名稱
target_channels = {'Fp1','Fp2','F3','F4','Fz','F7','F8'};

% 取得所有 .set 檔案
files = dir(fullfile(input_folder, '*.set'));

% === 批次處理 ===
for i = 1:length(files)
    file = files(i).name;
    filepath = fullfile(input_folder, file);

    % 載入 EEG 檔案
    EEG = pop_loadset('filename', file, 'filepath', input_folder);
    EEG = eeg_checkset(EEG);

    % 只保留指定的 channels
    EEG = pop_select(EEG, 'channel', target_channels);
    EEG = eeg_checkset(EEG);

    % 建立新檔名（加 _Selected）
    [~, name, ~] = fileparts(file);
    new_filename = [name '_Selected.set'];

    % 儲存新檔
    pop_saveset(EEG, 'filename', new_filename, 'filepath', output_folder);
    fprintf("✅ 已儲存：%s\n", new_filename);
end

disp("✅ 所有檔案已完成通道篩選與另存！");
