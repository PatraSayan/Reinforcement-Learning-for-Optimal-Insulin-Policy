%% Glucose Monitoring Reinforcement Learning
% Author 1 - Ojasvi Kapoor - 26D0067
% Author 2 - Sayan Patra - 26D0076
% BB709

clear; close all; clc;

outputFolder = fullfile(pwd, 'image');

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% Plotting the Data
clc;

filename = 'New_Insulin_Column_Glucose_Data_29-10-2026.csv';
standardized_data = readtable(filename);

standardized_data.timestamp = datetime( ...
    standardized_data.timestamp, ...
    'InputFormat', 'yyyy-MM-dd HH:mm:ss');
patient_ids = arrayfun(@(x) sprintf('U%03d', x), ...
    1:10, 'UniformOutput', false);

figure('Color', 'w', 'Position', [100, 50, 1500, 950]);
t = tiledlayout(5, 2, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');
ax = gobjects(10,1);

for i = 1:10

    user_data = standardized_data( ...
        strcmp(standardized_data.user_id, patient_ids{i}), :);
    user_data = sortrows(user_data, 'timestamp');

    ax(i) = nexttile;
    yyaxis left
    plot(user_data.timestamp, user_data.glucose, ...
        'Color', [0 0.62 0.45], ...
        'LineWidth', 1.1);
    ylabel('Glucose', 'FontWeight', 'bold');
    ax(i).YColor = [0 0.62 0.45];
    yyaxis right
    plot(user_data.timestamp, user_data.insulin, ...
        'Color', [0.94 0.35 0.68], ...
        'LineWidth', 1.1);
    ylabel('Insulin', 'FontWeight', 'bold');
    ax(i).YColor = [0.94 0.35 0.68];
    title(patient_ids{i}, 'FontWeight', 'bold');
    grid on;
    ax(i).FontSize = 9;
    ax(i).XTickLabelRotation = 30;
    xlabel('Timestamp');

end
linkaxes(ax, 'x');
sgtitle(t, 'Glucose and Insulin vs Timestamp (Patients U001-U010)', ...
    'FontSize', 16, 'FontWeight', 'bold');
lgd = legend(ax(1), {'Glucose', 'Insulin'}, ...
    'Orientation', 'horizontal');
lgd.Layout.Tile = 'north';
exportgraphics(gcf, 'image/Glucose_Insulin_U001_U010.png', ...
    'Resolution', 300);
savefig(gcf, 'image/Glucose_Insulin_U001_U010.fig');

%% Q-learning 
clc;
df = readtable('diabetes_q_learning_training_history.csv');
window = 1000;
df.Smoothed_Reward = movmean( ...
    df.Total_Reward, [window-1 0], ...
    'Endpoints', 'shrink');
figure('Color', 'w', 'Position', [100 100 1200 600]);
plot(df.Episode, df.Smoothed_Reward, ...
    'Color', [0 0.4470 0.7410], ...
    'LineWidth', 2);
title('Q-Learning Agent Progress: Total Reward vs. Episode', ...
    'FontSize', 14, 'FontWeight', 'bold');
xlabel('Episode', ...
    'FontSize', 12, 'FontWeight', 'bold');
ylabel('Total Reward', ...
    'FontSize', 12, 'FontWeight', 'bold');
grid on;
box on;

set(gca, 'FontSize', 11);
xlim([min(df.Episode), max(df.Episode)]);
exportgraphics(gcf, ...
    'image/Agent_Total_Reward_vs_Episode.png', ...
    'Resolution', 1024);
savefig(gcf, ...
    'image/Agent_Total_Reward_vs_Episode.fig');

%% Patient 9 Comparison Data
clc;
comparison_df = readtable('Patient_9_comparison_df.csv');
epoch_ranges = [
    1,   200;
    741, 940;
    1301, 1500
];

figure('Color', 'w', 'Position', [100 100 1400 900]);
t = tiledlayout(3, 1, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

for i = 1:3
    start_idx = epoch_ranges(i, 1);
    end_idx   = min(epoch_ranges(i, 2), height(comparison_df));
    data = comparison_df(start_idx:end_idx, :);
    epochs = data.Decision_Epoch;
    clinician_dose = data.Clinician_Insulin;
    rl_dose = data.RL_Insulin;
    ax = nexttile;
    plot(epochs, clinician_dose, ...
        'Color', [0.85 0.37 0.01], ...
        'LineWidth', 1.5, ...
        'DisplayName', 'Clinician Action');
    hold on;
    plot(epochs, rl_dose, ...
        'Color', [0.17 0.36 0.56], ...
        'LineStyle', '--', ...
        'LineWidth', 1.5, ...
        'DisplayName', 'RL Agent Action');
    title(sprintf('U009: Clinician vs. RL Agent Insulin Dosing (Epochs %d-%d)', ...
        start_idx-1, end_idx-1), ...
        'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Decision Epoch');
    ylabel('Insulin Dose (Units)');
    legend('Location', 'northeast');
    grid on;
    box on;
    set(gca, 'FontSize', 10);
    hold off;

end
sgtitle(t, 'Clinician vs. RL Agent Insulin Dose Comparison', ...
    'FontSize', 15, 'FontWeight', 'bold');

exportgraphics(gcf, ...
    'image/U009_Insulin_value_fluctuation.png', ...
    'Resolution', 600);
savefig(gcf, ...
    'image/U009_Insulin_value_fluctuation.fig');

%% Patient 10 Comparison Data

clc;
comparison_df = readtable('Patient_10_comparison_df.csv');
epoch_ranges = [
    1,   200;
    741, 940;
    1301, 1500
    ];

figure('Color', 'w', 'Position', [100 100 1400 900]);

t = tiledlayout(3, 1, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');
for i = 1:3

    start_idx = epoch_ranges(i, 1);
    end_idx   = min(epoch_ranges(i, 2), height(comparison_df));
    data = comparison_df(start_idx:end_idx, :);

    epochs = data.Decision_Epoch;
    clinician_dose = data.Clinician_Insulin;
    rl_dose = data.RL_Insulin;

    ax = nexttile;
    plot(epochs, clinician_dose, ...
        'Color', [0.85 0.37 0.01], ...
        'LineWidth', 1.5, ...
        'DisplayName', 'Clinician Action');
    hold on;

    plot(epochs, rl_dose, ...
        'Color', [0.17 0.36 0.56], ...
        'LineStyle', '--', ...
        'LineWidth', 1.5, ...
        'DisplayName', 'RL Agent Action');
    title(sprintf('U010: Clinician vs. RL Agent Insulin Dosing (Epochs %d-%d)', ...
        start_idx-1, end_idx-1), ...
        'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Decision Epoch');
    ylabel('Insulin Dose (Units)');
    legend('Location', 'northeast');
    grid on;
    box on;
    set(gca, 'FontSize', 10);
    hold off;

end
sgtitle(t, 'Clinician vs. RL Agent Insulin Dose Comparison', ...
    'FontSize', 15, 'FontWeight', 'bold');

exportgraphics(gcf, ...
    'image/U010_Insulin_value_fluctuation.png', ...
    'Resolution', 600);
savefig(gcf, ...
    'image/U010_Insulin_value_fluctuation.fig');

%% U009 Glucose
clc;

actual_df = readtable('U009_actual_clinician_trajectory.csv');
rl_df = readtable('U009_trained_RL_agent_trajectory.csv');
total_rows = min(height(actual_df), height(rl_df));

epoch_ranges = [
    1,   200;
    741, 940;
    1301, 1500
    ];

figure('Color', 'w', 'Position', [100 100 1400 900]);

t = tiledlayout(3, 1, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

for i = 1:3
    start_epoch = epoch_ranges(i, 1);
    end_epoch   = epoch_ranges(i, 2);
    start_idx = start_epoch + 1;
    end_idx = min(end_epoch, total_rows);

    if start_idx > total_rows
        continue;
    end

    epochs = (start_idx-1):(end_idx-1);
    clinician_traj = actual_df.glucose(start_idx:end_idx);
    rl_traj = rl_df.Glucose_t(start_idx:end_idx);

    ax = nexttile;
    plot(epochs, clinician_traj, ...
        'Color', [0.85 0.37 0.01], ...
        'LineWidth', 1.5, ...
        'DisplayName', 'Clinician Trajectory');
    hold on;

    plot(epochs, rl_traj, ...
        'Color', [0.17 0.36 0.56], ...
        'LineStyle', '--', ...
        'LineWidth', 2.0, ...
        'DisplayName', 'RL Agent Trajectory');
    yline(180, 'r:', 'LineWidth', 1.2, ...
        'DisplayName', 'Hyperglycemia (180)');
    yline(70, 'r:', 'LineWidth', 1.2, ...
        'DisplayName', 'Hypoglycemia (70)');
    title(sprintf( ...
        'Patient U009: Clinician vs. RL Agent (Epochs %d-%d)', ...
        start_epoch, end_epoch-1), ...
        'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Decision Epoch');
    ylabel('Blood Glucose (mg/dL)');
    grid on;
    box on;
    set(gca, 'FontSize', 10);
    legend('Location', 'northeastoutside');
    hold off;

end
sgtitle(t, ...
    'Patient U009 Glucose Trajectory: Clinician vs. RL Agent', ...
    'FontSize', 15, 'FontWeight', 'bold');


exportgraphics(gcf, ...
    'image/U009_Glucose_value_fluctuation.png', ...
    'Resolution', 600);
savefig(gcf, ...
    'image/U009_Glucose_value_fluctuation.fig');

%% Transition Model

evaluation = readtable('U009_transition_model_evaluation.csv');
evaluation.Next_Timestamp = datetime( ...
    evaluation.Next_Timestamp);

evaluation = sortrows(evaluation, 'Next_Timestamp');
selected_date = dateshift( ...
    evaluation.Next_Timestamp(1), 'start', 'day');

start_time = selected_date;
end_time = start_time + days(1);
day_data = evaluation( ...
    evaluation.Next_Timestamp >= start_time & ...
    evaluation.Next_Timestamp < end_time, :);

figure('Color', 'w', ...
       'Position', [100 100 1400 600]);
plot(day_data.Next_Timestamp, ...
    day_data.Actual_Next_Representative_Glucose, ...
    'Color', [0.05 0.00 0.64], ...
    'LineWidth', 1.5, ...
    'Marker', '.', ...
    'MarkerSize', 5, ...
    'DisplayName', 'Actual Glucose');
hold on;

plot(day_data.Next_Timestamp, ...
    day_data.Predicted_Glucose, ...
    'Color', [0.96 0.17 0.01], ...
    'LineWidth', 1.5, ...
    'LineStyle', '--', ...
    'Marker', '.', ...
    'MarkerSize', 5, ...
    'DisplayName', 'Predicted Glucose');
xlabel('Time of Day', ...
    'FontSize', 12, 'FontWeight', 'bold');
ylabel('Representative Glucose (mg/dL)', ...
    'FontSize', 12, 'FontWeight', 'bold');
title(sprintf( ...
    'Patient U009: Actual vs Predicted Glucose (%s)', ...
    datestr(selected_date, 'dd-mmm-yyyy')), ...
    'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best');
grid on;
box on;
ax = gca;
ax.XAxis.TickLabelFormat = 'HH:mm';
ax.XTickLabelRotation = 0;
ax.FontSize = 11;
xlim([start_time end_time]);
hold off;

exportgraphics(gcf, ...
    'image/U009_One_Day_Actual_vs_Predicted_Glucose.png', ...
    'Resolution', 600);
savefig(gcf, ...
    'image/U009_One_Day_Actual_vs_Predicted_Glucose.fig');

%% U010 transition model evaluation

evaluation = readtable('U010_transition_model_evaluation.csv');
evaluation.Next_Timestamp = datetime( ...
    evaluation.Next_Timestamp);
evaluation = sortrows(evaluation, 'Next_Timestamp');
selected_date = dateshift( ...
    evaluation.Next_Timestamp(1), 'start', 'day');

start_time = selected_date;
end_time = start_time + days(1);
day_data = evaluation( ...
    evaluation.Next_Timestamp >= start_time & ...
    evaluation.Next_Timestamp < end_time, :);

figure('Color', 'w', ...
       'Position', [100 100 1400 600]);
plot(day_data.Next_Timestamp, ...
    day_data.Actual_Next_Representative_Glucose, ...
    'Color', [0.05 0.00 0.64], ...
    'LineWidth', 1.5, ...
    'Marker', '.', ...
    'MarkerSize', 5, ...
    'DisplayName', 'Actual Glucose');
hold on;
plot(day_data.Next_Timestamp, ...
    day_data.Predicted_Glucose, ...
    'Color', [0.96 0.17 0.01], ...
    'LineWidth', 1.5, ...
    'LineStyle', '--', ...
    'Marker', '.', ...
    'MarkerSize', 5, ...
    'DisplayName', 'Predicted Glucose');
xlabel('Time of Day', ...
    'FontSize', 12, 'FontWeight', 'bold');
ylabel('Representative Glucose (mg/dL)', ...
    'FontSize', 12, 'FontWeight', 'bold');
title(sprintf( ...
    'Patient U009: Actual vs Predicted Glucose (%s)', ...
    datestr(selected_date, 'dd-mmm-yyyy')), ...
    'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best');
grid on;
box on;
ax = gca;
ax.XAxis.TickLabelFormat = 'HH:mm';
ax.XTickLabelRotation = 0;
ax.FontSize = 11;
xlim([start_time end_time]);
hold off;

exportgraphics(gcf, ...
    'image/U010_One_Day_Actual_vs_Predicted_Glucose.png', ...
    'Resolution', 600);
savefig(gcf, ...
    'image/U010_One_Day_Actual_vs_Predicted_Glucose.fig');
%% Confusion Matrix

evaluation = readtable('U009_transition_model_evaluation.csv');
actual_states = evaluation.Next_State_ID;
predicted_states = evaluation.Predicted_Next_State;
actual_states = string(actual_states);
predicted_states = string(predicted_states);
labels = unique([actual_states; predicted_states]);
labels = sort(labels);
cm = confusionmat(actual_states, predicted_states, ...
    'Order', labels);

figure('Color', 'w', 'Position', [100 100 1000 900]);
imagesc(cm);
colormap(gca, parula);
colorbar;
num_states = length(labels);
xticks(1:num_states);
yticks(1:num_states);
xticklabels(labels);
yticklabels(labels);
xtickangle(90);
xlabel('Predicted next state', ...
    'FontSize', 12, 'FontWeight', 'bold');
ylabel('Actual next state', ...
    'FontSize', 12, 'FontWeight', 'bold');
title('Patient U009: Transition Model Confusion Matrix', ...
    'FontSize', 14, 'FontWeight', 'bold');
axis square;
set(gca, 'FontSize', 10);

threshold = max(cm(:)) / 2;
for i = 1:num_states
    for j = 1:num_states

        if cm(i,j) > threshold
            text_color = 'w';
        else
            text_color = 'k';
        end

        text(j, i, sprintf('%d', cm(i,j)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'Color', text_color, ...
            'FontSize', 9, ...
            'FontWeight', 'bold');

    end
end

exportgraphics(gcf, ...
    'image/Confusion_matrix.png', ...
    'Resolution', 600);

savefig(gcf, ...
    'image/Confusion_matrix.fig');

%% Confusion Matrix U010
evaluation = readtable('U010_transition_model_evaluation.csv');

actual_states = evaluation.Next_State_ID;
predicted_states = evaluation.Predicted_Next_State;
actual_states = string(actual_states);
predicted_states = string(predicted_states);

labels = unique([actual_states; predicted_states]);
labels = sort(labels);
cm = confusionmat(actual_states, predicted_states, ...
    'Order', labels);

figure('Color', 'w', 'Position', [100 100 1000 900]);
imagesc(cm);
colormap(gca, parula);
colorbar;
num_states = length(labels);
xticks(1:num_states);
yticks(1:num_states);
xticklabels(labels);
yticklabels(labels);
xtickangle(90);
xlabel('Predicted next state', ...
    'FontSize', 12, 'FontWeight', 'bold');
ylabel('Actual next state', ...
    'FontSize', 12, 'FontWeight', 'bold');
title('Patient U010: Transition Model Confusion Matrix', ...
    'FontSize', 14, 'FontWeight', 'bold');
axis square;
set(gca, 'FontSize', 10);
threshold = max(cm(:)) / 2;

for i = 1:num_states
    for j = 1:num_states

        if cm(i,j) > threshold
            text_color = 'w';
        else
            text_color = 'k';
        end

        text(j, i, sprintf('%d', cm(i,j)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'Color', text_color, ...
            'FontSize', 9, ...
            'FontWeight', 'bold');

    end
end

if ~exist('image', 'dir')
    mkdir('image');
end

exportgraphics(gcf, ...
    'image/U010_Confusion_matrix.png', ...
    'Resolution', 600);

savefig(gcf, ...
    'image/U010_Confusion_matrix.fig');


%% Diabetes RL Heatmap

qOpt = readmatrix(fullfile('diabetes_theoretical_optimal_Q_table.csv'));

qLrn = readmatrix(fullfile('diabetes_learned_Q_table.csv'));
close all;

f = figure('Visible','on','Color','w');

subplot(1,3,1);
imagesc(qOpt);
colorbar;
title('Theoretical Q');
xlabel('Action');
ylabel('State');

subplot(1,3,2);
imagesc(qLrn);
colorbar;
title('Learned Q');
xlabel('Action');
ylabel('State');

subplot(1,3,3);
imagesc(qLrn-qOpt);
colorbar;
title('Difference');

sgtitle('Q-table Comparison');

exportgraphics(f, fullfile('image', ...
    '07_heatmap_q_tables.png'), 'Resolution', 300);
