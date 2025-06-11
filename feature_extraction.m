% 取得目前這個 .m 檔案的完整路徑
current_file_path = mfilename('fullpath');
[current_dir, ~, ~] = fileparts(current_file_path);

% 指定 .set 檔案所在資料夾
file_list = dir(fullfile(current_dir, '\data\subjects_selected','*.set'));
folder_path = fullfile(current_dir, '\data\subjects_selected')
% 初始化結果儲存變數
results = table();

for i = 1:length(file_list)   
    EEG = pop_loadset('filename', file_list(i).name, 'filepath', folder_path);

    % 計算功率譜（dB）
    [spec, freqs] = spectopo(EEG.data, 0, EEG.srate);

    % 轉換 spec 成 μV²/Hz（從 dB 回推）
    spec = 10.^(spec / 10);  % spec 是 log10(μV²/Hz)
    
    num_channels = 7;

    theta_idx = find(freqs >= 4 & freqs < 8);
    alpha_idx = find(freqs >= 8 & freqs < 13);
    beta_idx  = find(freqs >= 13 & freqs < 30);
    gamma_idx = find(freqs >= 30 & freqs < 50);
    
    % 計算不同頻段在每個通道的平均功率
    theta_power = mean(spec(:, theta_idx), 2);
    alpha_power = mean(spec(:, alpha_idx), 2);
    beta_power  = mean(spec(:, beta_idx), 2);
    gamma_power = mean(spec(:, gamma_idx), 2);


    % 計算每個通道的總能量（μV²/Hz）
    total_energy = sum(spec, 2);  % 每個通道的總能量
    
    theta_SE = zeros(1, num_channels);
    alpha_SE = zeros(1, num_channels);
    beta_SE  = zeros(1, num_channels);
    gamma_SE = zeros(1, num_channels);

    % 計算每個通道每個頻段的 SE
    for ch = 1:num_channels

        % 計算每個頻段的能量
        theta_energy = sum(spec(ch, theta_idx), 2);  % θ頻段能量
        alpha_energy = sum(spec(ch, alpha_idx), 2);  % α頻段能量
        beta_energy  = sum(spec(ch, beta_idx), 2);   % β頻段能量
        gamma_energy = sum(spec(ch, gamma_idx), 2);  % γ頻段能量

        % 計算每個頻段的相對能量
        theta_p = theta_energy / total_energy(ch);
        alpha_p = alpha_energy / total_energy(ch);
        beta_p  = beta_energy / total_energy(ch);
        gamma_p = gamma_energy / total_energy(ch);

        % 計算每個頻段的頻譜熵 SE
        theta_SE(ch) = -sum(theta_p .* log(theta_p));
        alpha_SE(ch) = -sum(alpha_p .* log(alpha_p));
        beta_SE(ch)  = -sum(beta_p .* log(beta_p));
        gamma_SE(ch) = -sum(gamma_p .* log(gamma_p));

    end

    channel_names = {'Fp1','Fp2','F3','F4','Fz','F7','F8'};

    % 建立 feature array：28 個值
    features = [theta_power(:); alpha_power(:); beta_power(:); gamma_power(:); ...
                theta_SE(:); alpha_SE(:); beta_SE(:); gamma_SE(:)];
    
    % 建立對應的 VariableNames
    var_names = {};
    for b = {'Theta', 'Alpha', 'Beta', 'Gamma'}
        for ch = channel_names
            var_names{end+1} = [b{1} 'Power_' ch{1}];
        end
    end
    for b = {'Theta', 'Alpha', 'Beta', 'Gamma'}
        for ch = channel_names
            var_names{end+1} = [b{1} 'SE_' ch{1}];
        end
    end
    
    % 新增檔名欄位
    features = [{string(file_list(i).name)}, num2cell(features')];
    var_names = [{'Filename'}, var_names];
    
    % 加入到 results 表格
    results = [results; cell2table(features, 'VariableNames', var_names)];

end

% 輸出到 CSV
writetable(results, fullfile(folder_path, 'EEG_spectral_features.csv'));
