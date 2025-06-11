% === 基本設定 ===
input_folder = 'subjects_set1';
output_folder = 'subjects_filtered';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 取得所有 .set 檔案
files = dir(fullfile(input_folder, '*.set'));

% === 處理每一個檔案 ===
for i = 1:length(files)
    file = files(i).name;
    filepath = fullfile(input_folder, file);

    % 讀取 .set 檔案
    EEG = pop_loadset('filename', file, 'filepath', input_folder);
    EEG = eeg_checkset(EEG);

    % 套用 Bandpass filter（1–40 Hz）
    EEG = pop_eegfiltnew(EEG, 1, 40);  % 下限 1 Hz, 上限 40 Hz
    EEG = eeg_checkset(EEG);

    % 產生新檔名（加 _Filtered）
    [~, name, ~] = fileparts(file);
    new_filename = [name '_Filtered.set'];

    % 儲存新檔案
    pop_saveset(EEG, 'filename', new_filename, 'filepath', output_folder);
    fprintf("已儲存：%s\n", new_filename);
end

disp("所有檔案 Bandpass filter 完成！");
