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
% Read the uploaded CSV file
filename = 'New_Insulin_Column_Glucose_Data_29-10-2026.csv';
standardized_data = readtable(filename);

% Convert timestamp column to datetime
standardized_data.timestamp = datetime( ...
    standardized_data.timestamp, ...
    'InputFormat', 'yyyy-MM-dd HH:mm:ss');

% Patient IDs U001 to U010
patient_ids = arrayfun(@(x) sprintf('U%03d', x), ...
    1:10, 'UniformOutput', false);

% Create figure: 5 rows x 2 columns
figure('Color', 'w', 'Position', [100, 50, 1500, 950]);

t = tiledlayout(5, 2, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

% Store axes for linking x-axes
ax = gobjects(10,1);

for i = 1:10

    % Select data for current patient
    user_data = standardized_data( ...
        strcmp(standardized_data.user_id, patient_ids{i}), :);

    % Sort measurements by timestamp
    user_data = sortrows(user_data, 'timestamp');

    % Create subplot
    ax(i) = nexttile;

    % Plot glucose on left y-axis
    yyaxis left
    plot(user_data.timestamp, user_data.glucose, ...
        'Color', [0 0.62 0.45], ...
        'LineWidth', 1.1);

    ylabel('Glucose', 'FontWeight', 'bold');
    ax(i).YColor = [0 0.62 0.45];

    % Plot insulin on right y-axis
    yyaxis right
    plot(user_data.timestamp, user_data.insulin, ...
        'Color', [0.94 0.35 0.68], ...
        'LineWidth', 1.1);

    ylabel('Insulin', 'FontWeight', 'bold');
    ax(i).YColor = [0.94 0.35 0.68];

    % Formatting
    title(patient_ids{i}, 'FontWeight', 'bold');
    grid on;
    ax(i).FontSize = 9;
    ax(i).XTickLabelRotation = 30;

    % Add x-axis label
    xlabel('Timestamp');

end

% Link all x-axes for synchronized time range
linkaxes(ax, 'x');

% Overall figure title
sgtitle(t, 'Glucose and Insulin vs Timestamp (Patients U001-U010)', ...
    'FontSize', 16, 'FontWeight', 'bold');

% Add common legend
lgd = legend(ax(1), {'Glucose', 'Insulin'}, ...
    'Orientation', 'horizontal');
lgd.Layout.Tile = 'north';

% Save figure as high-resolution PNG
exportgraphics(gcf, 'Glucose_Insulin_U001_U010.png', ...
    'Resolution', 300);

% Save as MATLAB figure (editable later)
savefig(gcf, 'Glucose_Insulin_U001_U010.fig');

%% Q-learning 
clc;
% Load the training history data
df = readtable('diabetes_q_learning_training_history.csv');

% Calculate moving average
window = 1000;

df.Smoothed_Reward = movmean( ...
    df.Total_Reward, [window-1 0], ...
    'Endpoints', 'shrink');

% Create figure
figure('Color', 'w', 'Position', [100 100 1200 600]);

% Plot smoothed moving average
plot(df.Episode, df.Smoothed_Reward, ...
    'Color', [0 0.4470 0.7410], ...
    'LineWidth', 2);

% Formatting
title('Q-Learning Agent Progress: Total Reward vs. Episode', ...
    'FontSize', 14, 'FontWeight', 'bold');

xlabel('Episode', ...
    'FontSize', 12, 'FontWeight', 'bold');

ylabel('Total Reward', ...
    'FontSize', 12, 'FontWeight', 'bold');

grid on;
box on;

% Improve plot appearance
set(gca, 'FontSize', 11);
xlim([min(df.Episode), max(df.Episode)]);

% Save high-resolution image
if ~exist('image', 'dir')
    mkdir('image');
end

exportgraphics(gcf, ...
    'image/Agent_Total_Reward_vs_Episode.png', ...
    'Resolution', 1024);

% Save editable MATLAB figure
savefig(gcf, ...
    'image/Agent_Total_Reward_vs_Episode.fig');

%% Patient 9 Comparison Data
clc;
% Load patient comparison data
comparison_df = readtable('Patient_9_comparison_df.csv');

% Define epoch ranges (MATLAB uses 1-based indexing)
epoch_ranges = [
    1,   200;
    741, 940;
    1301, 1500
];

% Create figure
figure('Color', 'w', 'Position', [100 100 1400 900]);

% Create 3 vertically stacked plots
t = tiledlayout(3, 1, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

for i = 1:3

    % Get row indices for current range
    start_idx = epoch_ranges(i, 1);
    end_idx   = min(epoch_ranges(i, 2), height(comparison_df));

    % Extract data
    data = comparison_df(start_idx:end_idx, :);

    epochs = data.Decision_Epoch;
    clinician_dose = data.Clinician_Insulin;
    rl_dose = data.RL_Insulin;

    % Create subplot
    ax = nexttile;

    % Plot clinician insulin dose
    plot(epochs, clinician_dose, ...
        'Color', [0.85 0.37 0.01], ...
        'LineWidth', 1.5, ...
        'DisplayName', 'Clinician Action');

    hold on;

    % Plot RL agent insulin dose
    plot(epochs, rl_dose, ...
        'Color', [0.17 0.36 0.56], ...
        'LineStyle', '--', ...
        'LineWidth', 1.5, ...
        'DisplayName', 'RL Agent Action');

    % Formatting
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

% Overall title
sgtitle(t, 'Clinician vs. RL Agent Insulin Dose Comparison', ...
    'FontSize', 15, 'FontWeight', 'bold');

% Create image folder if needed
if ~exist('image', 'dir')
    mkdir('image');
end

% Save high-resolution image
exportgraphics(gcf, ...
    'image/U009_Insulin_value_fluctuation.png', ...
    'Resolution', 600);

% Save editable MATLAB figure
savefig(gcf, ...
    'image/U009_Insulin_value_fluctuation.fig');

%% Patient 10 Comparison Data

clc;
% Load patient comparison data
comparison_df = readtable('Patient_10_comparison_df.csv');

% Define epoch ranges (MATLAB uses 1-based indexing)
epoch_ranges = [
    1,   200;
    741, 940;
    1301, 1500
    ];

% Create figure
figure('Color', 'w', 'Position', [100 100 1400 900]);

% Create 3 vertically stacked plots
t = tiledlayout(3, 1, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

for i = 1:3

    % Get row indices for current range
    start_idx = epoch_ranges(i, 1);
    end_idx   = min(epoch_ranges(i, 2), height(comparison_df));

    % Extract data
    data = comparison_df(start_idx:end_idx, :);

    epochs = data.Decision_Epoch;
    clinician_dose = data.Clinician_Insulin;
    rl_dose = data.RL_Insulin;

    % Create subplot
    ax = nexttile;

    % Plot clinician insulin dose
    plot(epochs, clinician_dose, ...
        'Color', [0.85 0.37 0.01], ...
        'LineWidth', 1.5, ...
        'DisplayName', 'Clinician Action');

    hold on;

    % Plot RL agent insulin dose
    plot(epochs, rl_dose, ...
        'Color', [0.17 0.36 0.56], ...
        'LineStyle', '--', ...
        'LineWidth', 1.5, ...
        'DisplayName', 'RL Agent Action');

    % Formatting
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

% Overall title
sgtitle(t, 'Clinician vs. RL Agent Insulin Dose Comparison', ...
    'FontSize', 15, 'FontWeight', 'bold');

% Create image folder if needed
if ~exist('image', 'dir')
    mkdir('image');
end

% Save high-resolution image
exportgraphics(gcf, ...
    'image/U010_Insulin_value_fluctuation.png', ...
    'Resolution', 600);

% Save editable MATLAB figure
savefig(gcf, ...
    'image/U010_Insulin_value_fluctuation.fig');

%% U009 Glucose
clc;

% Load the separate trajectory files
actual_df = readtable('U009_actual_clinician_trajectory.csv');
rl_df = readtable('U009_trained_RL_agent_trajectory.csv');

% Use minimum length in case the simulation ended early
total_rows = min(height(actual_df), height(rl_df));

% Define epoch ranges (zero-based, end-exclusive)
epoch_ranges = [
    1,   200;
    741, 940;
    1301, 1500
    ];

% Create figure
figure('Color', 'w', 'Position', [100 100 1400 900]);

% Create 3 vertically stacked plots
t = tiledlayout(3, 1, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

for i = 1:3

    % Get epoch range
    start_epoch = epoch_ranges(i, 1);
    end_epoch   = epoch_ranges(i, 2);

    % Convert zero-based Python indices to MATLAB indices
    start_idx = start_epoch + 1;
    end_idx = min(end_epoch, total_rows);

    % Skip if range exceeds available data
    if start_idx > total_rows
        continue;
    end

    % Extract data
    epochs = (start_idx-1):(end_idx-1);

    clinician_traj = actual_df.glucose(start_idx:end_idx);
    rl_traj = rl_df.Glucose_t(start_idx:end_idx);

    % Create subplot
    ax = nexttile;

    % Plot clinician trajectory
    plot(epochs, clinician_traj, ...
        'Color', [0.85 0.37 0.01], ...
        'LineWidth', 1.5, ...
        'DisplayName', 'Clinician Trajectory');

    hold on;

    % Plot RL agent trajectory
    plot(epochs, rl_traj, ...
        'Color', [0.17 0.36 0.56], ...
        'LineStyle', '--', ...
        'LineWidth', 2.0, ...
        'DisplayName', 'RL Agent Trajectory');

    % Glucose clinical thresholds
    yline(180, 'r:', 'LineWidth', 1.2, ...
        'DisplayName', 'Hyperglycemia (180)');

    yline(70, 'r:', 'LineWidth', 1.2, ...
        'DisplayName', 'Hypoglycemia (70)');

    % Formatting
    title(sprintf( ...
        'Patient U009: Clinician vs. RL Agent (Epochs %d-%d)', ...
        start_epoch, end_epoch-1), ...
        'FontSize', 12, 'FontWeight', 'bold');

    xlabel('Decision Epoch');
    ylabel('Blood Glucose (mg/dL)');

    grid on;
    box on;
    set(gca, 'FontSize', 10);

    % Place legend outside the plot
    legend('Location', 'northeastoutside');

    hold off;

end

% Overall title
sgtitle(t, ...
    'Patient U009 Glucose Trajectory: Clinician vs. RL Agent', ...
    'FontSize', 15, 'FontWeight', 'bold');

% Create image folder if it does not exist
if ~exist('image', 'dir')
    mkdir('image');
end

% Save high-resolution PNG
exportgraphics(gcf, ...
    'image/U009_Glucose_value_fluctuation.png', ...
    'Resolution', 600);

% Save editable MATLAB figure
savefig(gcf, ...
    'image/U009_Glucose_value_fluctuation.fig');

%% Glucose Reward


% --------------------------------------------------
% 1. DEFINE PARAMETERS
% --------------------------------------------------

G_IDEAL = 110;

G_LOW = 70;
G_HIGH = 180;

SIGMA_L = 20;
SIGMA_R = 35;

LAMBDA_L = 1;
LAMBDA_R = 1;


% --------------------------------------------------
% 2. VALIDATE PARAMETERS
% --------------------------------------------------

if ~(G_LOW < G_IDEAL && G_IDEAL < G_HIGH)
    error(['Glucose thresholds must satisfy ', ...
           'G_LOW < G_IDEAL < G_HIGH.']);
end

if SIGMA_L <= 0 || SIGMA_R <= 0
    error('Sigma values must be positive.');
end

if LAMBDA_L < 0 || LAMBDA_R < 0
    error('Penalty coefficients cannot be negative.');
end


% --------------------------------------------------
% 3. DEFINE THE REWARD FUNCTION
% --------------------------------------------------

glucose_reward = @(g) calculate_reward( ...
    g, G_LOW, G_IDEAL, G_HIGH, ...
    SIGMA_L, SIGMA_R, LAMBDA_L, LAMBDA_R);

disp('Glucose reward function defined successfully.');


% --------------------------------------------------
% 4. GENERATE GLUCOSE VALUES
% --------------------------------------------------

glucose_values = linspace(40, 250, 500);

% Calculate rewards
rewards = glucose_reward(glucose_values);


% --------------------------------------------------
% 5. PLOT REWARD FUNCTION
% --------------------------------------------------

figure('Color', 'w', 'Position', [100 100 1000 500]);

plot(glucose_values, rewards, ...
    'LineWidth', 2, ...
    'Color', [0 0.4470 0.7410], ...
    'DisplayName', 'Glucose reward');

hold on;

% Glucose thresholds
xline(G_LOW, '--', ...
    'Color', [0.48 0.17 0.75], ...
    'LineWidth', 1.5, ...
    'DisplayName', 'Lower threshold');

xline(G_IDEAL, '--', ...
    'Color', [0.44 0.88 0], ...
    'LineWidth', 1.5, ...
    'DisplayName', 'Ideal reference');

xline(G_HIGH, '--', ...
    'Color', [0.90 0.22 0.27], ...
    'LineWidth', 1.5, ...
    'DisplayName', 'Upper threshold');

% Zero reward reference
yline(0, 'k--', ...
    'LineWidth', 0.8, ...
    'HandleVisibility', 'off');

% Formatting
xlabel('Glucose (mg/dL)', ...
    'FontSize', 12, 'FontWeight', 'bold');

ylabel('Reward', ...
    'FontSize', 12, 'FontWeight', 'bold');

title('Illustrative Glucose-Based Reward Function', ...
    'FontSize', 14, 'FontWeight', 'bold');

legend('Location', 'best');
grid on;
box on;

set(gca, 'FontSize', 11);
ylim padded;

hold off;


% --------------------------------------------------
% 6. SAVE FIGURE
% --------------------------------------------------

if ~exist('image', 'dir')
    mkdir('image');
end

exportgraphics(gcf, ...
    'image/Reward_Function.png', ...
    'Resolution', 600);

savefig(gcf, ...
    'image/Reward_Function.fig');


% --------------------------------------------------
% 7. REWARD FUNCTION DEFINITION
% --------------------------------------------------

function reward = calculate_reward(g, G_LOW, G_IDEAL, ...
    G_HIGH, SIGMA_L, SIGMA_R, LAMBDA_L, LAMBDA_R)

    if any(isnan(g(:)))
        error('Representative glucose is missing.');
    end

    reward = zeros(size(g));

    % Region 1: Below lower threshold
    idx = g < G_LOW;

    reward(idx) = -LAMBDA_L .* ...
        ((G_LOW - g(idx)) ./ ...
        (G_IDEAL - G_LOW)).^2;

    % Region 2: Lower threshold to ideal
    idx = g >= G_LOW & g <= G_IDEAL;

    boundary_L = exp( ...
        -((G_LOW - G_IDEAL)^2) / ...
        (2 * SIGMA_L^2));

    reward(idx) = ( ...
        exp(-((g(idx) - G_IDEAL).^2) ./ ...
        (2 * SIGMA_L^2)) - boundary_L) ./ ...
        (1 - boundary_L);

    % Region 3: Ideal to upper threshold
    idx = g > G_IDEAL & g <= G_HIGH;

    boundary_R = exp( ...
        -((G_HIGH - G_IDEAL)^2) / ...
        (2 * SIGMA_R^2));

    reward(idx) = ( ...
        exp(-((g(idx) - G_IDEAL).^2) ./ ...
        (2 * SIGMA_R^2)) - boundary_R) ./ ...
        (1 - boundary_R);

    % Region 4: Above upper threshold
    idx = g > G_HIGH;

    reward(idx) = -LAMBDA_R .* ...
        ((g(idx) - G_HIGH) ./ ...
        (G_HIGH - G_IDEAL)).^2;

end

%% U009 transition model evaluation

% --------------------------------------------------
% 1. LOAD EVALUATION DATA
% --------------------------------------------------

evaluation = readtable('U009_transition_model_evaluation.csv');

% Convert timestamp column to datetime
evaluation.Next_Timestamp = datetime( ...
    evaluation.Next_Timestamp, ...
    'InputFormat', 'yyyy-MM-dd HH:mm:ss');

% Sort data by timestamp
evaluation = sortrows(evaluation, 'Next_Timestamp');


% --------------------------------------------------
% 2. CREATE PLOT
% --------------------------------------------------

figure('Color', 'w', 'Position', [100 100 1600 600]);

% Actual next-state glucose
plot(evaluation.Next_Timestamp, ...
    evaluation.Actual_Next_Representative_Glucose, ...
    'Color', [0.05 0.00 0.64], ...
    'LineWidth', 1.5, ...
    'Marker', '.', ...
    'MarkerSize', 3, ...
    'DisplayName', 'Actual next-state representative glucose');

hold on;

% Predicted next-state glucose
plot(evaluation.Next_Timestamp, ...
    evaluation.Predicted_Glucose, ...
    'Color', [0.96 0.17 0.01], ...
    'LineWidth', 1.2, ...
    'Marker', '.', ...
    'MarkerSize', 3, ...
    'DisplayName', 'Predicted next-state representative glucose');


% --------------------------------------------------
% 3. FORMAT THE PLOT
% --------------------------------------------------

xlabel('Date and time', ...
    'FontSize', 12, 'FontWeight', 'bold');

ylabel('Representative glucose (mg/dL)', ...
    'FontSize', 12, 'FontWeight', 'bold');

title('Patient U009: Actual vs Predicted Representative Glucose', ...
    'FontSize', 14, 'FontWeight', 'bold');

legend('Location', 'best');

grid on;
box on;

% Format date labels
ax = gca;
ax.XAxis.TickLabelFormat = 'dd-MMM-yyyy HH:mm';
ax.XTickLabelRotation = 45;
ax.FontSize = 10;

% Tight layout equivalent
ax.Position = [0.08 0.20 0.88 0.68];

hold off;


% --------------------------------------------------
% 4. SAVE FIGURE
% --------------------------------------------------

if ~exist('image', 'dir')
    mkdir('image');
end

exportgraphics(gcf, ...
    'image/Patient_U009_Actual_vs_Predicted_Representative_Glucose.png', ...
    'Resolution', 600);

savefig(gcf, ...
    'image/Patient_U009_Actual_vs_Predicted_Representative_Glucose.fig');

%%

% --------------------------------------------------
% 1. LOAD EVALUATION DATA
% --------------------------------------------------

evaluation = readtable('U009_transition_model_evaluation.csv');

% Convert timestamp to datetime
evaluation.Next_Timestamp = datetime( ...
    evaluation.Next_Timestamp);

% Sort chronologically
evaluation = sortrows(evaluation, 'Next_Timestamp');


% --------------------------------------------------
% 2. SELECT ONE DAY
% --------------------------------------------------

% Select the first day in the dataset
selected_date = dateshift( ...
    evaluation.Next_Timestamp(1), 'start', 'day');

% Define 24-hour interval
start_time = selected_date;
end_time = start_time + days(1);

% Filter data for selected day
day_data = evaluation( ...
    evaluation.Next_Timestamp >= start_time & ...
    evaluation.Next_Timestamp < end_time, :);

% Display selected date
fprintf('Selected date: %s\n', ...
    datestr(selected_date, 'dd-mmm-yyyy'));


% --------------------------------------------------
% 3. PLOT ONE-DAY GLUCOSE COMPARISON
% --------------------------------------------------

figure('Color', 'w', ...
       'Position', [100 100 1400 600]);

% Actual glucose
plot(day_data.Next_Timestamp, ...
    day_data.Actual_Next_Representative_Glucose, ...
    'Color', [0.05 0.00 0.64], ...
    'LineWidth', 1.5, ...
    'Marker', '.', ...
    'MarkerSize', 5, ...
    'DisplayName', 'Actual Glucose');

hold on;

% Predicted glucose
plot(day_data.Next_Timestamp, ...
    day_data.Predicted_Glucose, ...
    'Color', [0.96 0.17 0.01], ...
    'LineWidth', 1.5, ...
    'LineStyle', '--', ...
    'Marker', '.', ...
    'MarkerSize', 5, ...
    'DisplayName', 'Predicted Glucose');


% --------------------------------------------------
% 4. FORMAT PLOT
% --------------------------------------------------

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

% Display time only on x-axis
ax = gca;
ax.XAxis.TickLabelFormat = 'HH:mm';
ax.XTickLabelRotation = 0;
ax.FontSize = 11;

% Set axis limits to the selected day
xlim([start_time end_time]);

hold off;


% --------------------------------------------------
% 5. SAVE FIGURE
% --------------------------------------------------

if ~exist('image', 'dir')
    mkdir('image');
end

exportgraphics(gcf, ...
    'image/U009_One_Day_Actual_vs_Predicted_Glucose.png', ...
    'Resolution', 600);

savefig(gcf, ...
    'image/U009_One_Day_Actual_vs_Predicted_Glucose.fig');
%%
%% U010 transition model evaluation

% --------------------------------------------------
% 1. LOAD EVALUATION DATA
% --------------------------------------------------

evaluation = readtable('U010_transition_model_evaluation.csv');

% Convert timestamp column to datetime
evaluation.Next_Timestamp = datetime( ...
    evaluation.Next_Timestamp, ...
    'InputFormat', 'yyyy-MM-dd HH:mm:ss');

% Sort data by timestamp
evaluation = sortrows(evaluation, 'Next_Timestamp');


% --------------------------------------------------
% 2. CREATE PLOT
% --------------------------------------------------

figure('Color', 'w', 'Position', [100 100 1600 600]);

% Actual next-state glucose
plot(evaluation.Next_Timestamp, ...
    evaluation.Actual_Next_Representative_Glucose, ...
    'Color', [0.05 0.00 0.64], ...
    'LineWidth', 1.5, ...
    'Marker', '.', ...
    'MarkerSize', 3, ...
    'DisplayName', 'Actual next-state representative glucose');

hold on;

% Predicted next-state glucose
plot(evaluation.Next_Timestamp, ...
    evaluation.Predicted_Glucose, ...
    'Color', [0.96 0.17 0.01], ...
    'LineWidth', 1.2, ...
    'Marker', '.', ...
    'MarkerSize', 3, ...
    'DisplayName', 'Predicted next-state representative glucose');


% --------------------------------------------------
% 3. FORMAT THE PLOT
% --------------------------------------------------

xlabel('Date and time', ...
    'FontSize', 12, 'FontWeight', 'bold');

ylabel('Representative glucose (mg/dL)', ...
    'FontSize', 12, 'FontWeight', 'bold');

title('Patient U010: Actual vs Predicted Representative Glucose', ...
    'FontSize', 14, 'FontWeight', 'bold');

legend('Location', 'best');

grid on;
box on;

% Format date labels
ax = gca;
ax.XAxis.TickLabelFormat = 'dd-MMM-yyyy HH:mm';
ax.XTickLabelRotation = 45;
ax.FontSize = 10;

% Tight layout equivalent
ax.Position = [0.08 0.20 0.88 0.68];

hold off;


% --------------------------------------------------
% 4. SAVE FIGURE
% --------------------------------------------------

if ~exist('image', 'dir')
    mkdir('image');
end

exportgraphics(gcf, ...
    'image/Patient_U010_Actual_vs_Predicted_Representative_Glucose.png', ...
    'Resolution', 600);

savefig(gcf, ...
    'image/Patient_U010_Actual_vs_Predicted_Representative_Glucose.fig');

%%

% --------------------------------------------------
% 1. LOAD EVALUATION DATA
% --------------------------------------------------

evaluation = readtable('U010_transition_model_evaluation.csv');

% Convert timestamp to datetime
evaluation.Next_Timestamp = datetime( ...
    evaluation.Next_Timestamp);

% Sort chronologically
evaluation = sortrows(evaluation, 'Next_Timestamp');


% --------------------------------------------------
% 2. SELECT ONE DAY
% --------------------------------------------------

% Select the first day in the dataset
selected_date = dateshift( ...
    evaluation.Next_Timestamp(1), 'start', 'day');

% Define 24-hour interval
start_time = selected_date;
end_time = start_time + days(1);

% Filter data for selected day
day_data = evaluation( ...
    evaluation.Next_Timestamp >= start_time & ...
    evaluation.Next_Timestamp < end_time, :);

% Display selected date
fprintf('Selected date: %s\n', ...
    datestr(selected_date, 'dd-mmm-yyyy'));


% --------------------------------------------------
% 3. PLOT ONE-DAY GLUCOSE COMPARISON
% --------------------------------------------------

figure('Color', 'w', ...
       'Position', [100 100 1400 600]);

% Actual glucose
plot(day_data.Next_Timestamp, ...
    day_data.Actual_Next_Representative_Glucose, ...
    'Color', [0.05 0.00 0.64], ...
    'LineWidth', 1.5, ...
    'Marker', '.', ...
    'MarkerSize', 5, ...
    'DisplayName', 'Actual Glucose');

hold on;

% Predicted glucose
plot(day_data.Next_Timestamp, ...
    day_data.Predicted_Glucose, ...
    'Color', [0.96 0.17 0.01], ...
    'LineWidth', 1.5, ...
    'LineStyle', '--', ...
    'Marker', '.', ...
    'MarkerSize', 5, ...
    'DisplayName', 'Predicted Glucose');


% --------------------------------------------------
% 4. FORMAT PLOT
% --------------------------------------------------

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

% Display time only on x-axis
ax = gca;
ax.XAxis.TickLabelFormat = 'HH:mm';
ax.XTickLabelRotation = 0;
ax.FontSize = 11;

% Set axis limits to the selected day
xlim([start_time end_time]);

hold off;


% --------------------------------------------------
% 5. SAVE FIGURE
% --------------------------------------------------

if ~exist('image', 'dir')
    mkdir('image');
end

exportgraphics(gcf, ...
    'image/U010_One_Day_Actual_vs_Predicted_Glucose.png', ...
    'Resolution', 600);

savefig(gcf, ...
    'image/U010_One_Day_Actual_vs_Predicted_Glucose.fig');
%% Confusion Matrix
% --------------------------------------------------
% 1. LOAD EVALUATION DATA
% --------------------------------------------------

evaluation = readtable('U009_transition_model_evaluation.csv');

% Actual and predicted next-state IDs
actual_states = evaluation.Next_State_ID;
predicted_states = evaluation.Predicted_Next_State;

% Convert to categorical/string if needed
actual_states = string(actual_states);
predicted_states = string(predicted_states);


% --------------------------------------------------
% 2. GET ALL UNIQUE STATE LABELS
% --------------------------------------------------

labels = unique([actual_states; predicted_states]);
labels = sort(labels);

% Calculate confusion matrix
cm = confusionmat(actual_states, predicted_states, ...
    'Order', labels);


% --------------------------------------------------
% 3. PLOT CONFUSION MATRIX
% --------------------------------------------------

figure('Color', 'w', 'Position', [100 100 1000 900]);

imagesc(cm);

% Blue color map
colormap(gca, parula);

% Colorbar
colorbar;

% Configure axes
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


% --------------------------------------------------
% 4. ADD CELL ANNOTATIONS
% --------------------------------------------------

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


% --------------------------------------------------
% 5. SAVE FIGURE
% --------------------------------------------------

if ~exist('image', 'dir')
    mkdir('image');
end

exportgraphics(gcf, ...
    'image/Confusion_matrix.png', ...
    'Resolution', 600);

savefig(gcf, ...
    'image/Confusion_matrix.fig');
%%
%% Confusion Matrix U010
% --------------------------------------------------
% 1. LOAD EVALUATION DATA
% --------------------------------------------------

evaluation = readtable('U010_transition_model_evaluation.csv');

% Actual and predicted next-state IDs
actual_states = evaluation.Next_State_ID;
predicted_states = evaluation.Predicted_Next_State;

% Convert to categorical/string if needed
actual_states = string(actual_states);
predicted_states = string(predicted_states);


% --------------------------------------------------
% 2. GET ALL UNIQUE STATE LABELS
% --------------------------------------------------

labels = unique([actual_states; predicted_states]);
labels = sort(labels);

% Calculate confusion matrix
cm = confusionmat(actual_states, predicted_states, ...
    'Order', labels);


% --------------------------------------------------
% 3. PLOT CONFUSION MATRIX
% --------------------------------------------------

figure('Color', 'w', 'Position', [100 100 1000 900]);

imagesc(cm);

% Blue color map
colormap(gca, parula);

% Colorbar
colorbar;

% Configure axes
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


% --------------------------------------------------
% 4. ADD CELL ANNOTATIONS
% --------------------------------------------------

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


% --------------------------------------------------
% 5. SAVE FIGURE
% --------------------------------------------------

if ~exist('image', 'dir')
    mkdir('image');
end

exportgraphics(gcf, ...
    'image/U010_Confusion_matrix.png', ...
    'Resolution', 600);

savefig(gcf, ...
    'image/U010_Confusion_matrix.fig');


%% Diabetes RL plotting script

clear; clc; 

DATA_DIR = ".";
OUT_DIR = "image";
if ~isfolder(OUT_DIR), mkdir(OUT_DIR); end

% Load CSV files once
actual = loadCSV(DATA_DIR,"U010_actual_clinician_trajectory.csv");
rl     = loadCSV(DATA_DIR,"U010_trained_RL_agent_trajectory.csv");
comp   = loadCSV(DATA_DIR,"Patient_10_comparison_df.csv");
histT  = loadCSV(DATA_DIR,"diabetes_q_learning_training_history.csv");
pred   = loadCSV(DATA_DIR,"diabetes_test_transition_predictions.csv");
u009   = loadCSV(DATA_DIR,"U009_transition_model_evaluation.csv");
visits = loadCSV(DATA_DIR,"state_visit_counts.csv");
cover  = loadCSV(DATA_DIR,"diabetes_train_state_action_coverage.csv");
trainD = loadCSV(DATA_DIR,"diabetes_train_discretised.csv");
ope    = loadCSV(DATA_DIR,"diabetes_ope_evaluation_results.csv");
polOpt = loadCSV(DATA_DIR,"diabetes_theoretical_optimal_policy.csv");
polLrn = loadCSV(DATA_DIR,"diabetes_learned_policy.csv");
qOpt   = loadQTable(DATA_DIR,"diabetes_theoretical_optimal_Q_table.csv");
qLrn   = loadQTable(DATA_DIR,"diabetes_learned_Q_table.csv");

%% 3. Scatter plots
if ~isempty(pred)
    a = pickCol(pred, "Actual_Next_Representative_Glucose");
    p = pickCol(pred, "Predicted_Next_Representative_Glucose");
    if a ~= "" && p ~= ""
        x = pred.(a); y = pred.(p);
        ok = isfinite(x) & isfinite(y); x=x(ok); y=y(ok);
        if ~isempty(x)
            f=figure; scatter(x,y,8,'MarkerFaceAlpha',0.4); hold on;
            lo=min([x;y]); hi=max([x;y]); plot([lo hi],[lo hi],'r--','DisplayName','Perfect prediction');
            title('Predicted vs actual next glucose'); xlabel('Actual (mg/dL)'); ylabel('Predicted (mg/dL)');
            legend; saveFig(f,OUT_DIR,'03_scatter_pred_vs_actual.png');
        end
    end
end
if ~isempty(comp) && hasVars(comp,["Clinician_Insulin","RL_Insulin"])
    x=comp.Clinician_Insulin; y=comp.RL_Insulin; ok=isfinite(x)&isfinite(y);
    f=figure; scatter(x(ok),y(ok),10,'MarkerFaceAlpha',0.3); hold on;
    m=max([x(ok);y(ok)]); plot([0 m],[0 m],'r--','DisplayName','Agreement');
    title('U010: clinician vs RL insulin dose'); xlabel('Clinician (units)'); ylabel('RL agent (units)');
    legend; saveFig(f,OUT_DIR,'03b_scatter_dose_agreement.png');
end

%% 4. Bar charts
if ~isempty(visits) && hasVars(visits,["State_ID","Visit_Count"])
    f=figure; bar(categorical(string(visits.State_ID)),visits.Visit_Count); hold on;
    yline(20,'r--','Minimum visits (20)'); title('State visit counts (training)');
    xlabel('State ID'); ylabel('Visits'); saveFig(f,OUT_DIR,'04_bar_state_visits.png');
end
if ~isempty(polLrn) && ~isempty(polOpt)
    la=pickCol(polLrn,"Learned_Action_ID"); oa=pickCol(polOpt,"Optimal_Action_ID");
    if la~="" && oa~=""
        ids=unique([string(polOpt.(oa));string(polLrn.(la))]);
        c1=zeros(numel(ids),1); c2=c1;
        for k=1:numel(ids)
            c1(k)=sum(string(polOpt.(oa))==ids(k)); c2(k)=sum(string(polLrn.(la))==ids(k));
        end
        f=figure; bar(categorical(ids),[c1 c2]); legend('Value iteration','Q-learning');
        title('How often each action is chosen by the policy'); xlabel('Action ID'); ylabel('Number of states');
        saveFig(f,OUT_DIR,'04b_bar_action_frequency.png');
    end
end
if ~isempty(pred) && hasVars(pred, ...
        ["Predicted_State_Probability","Correct"])

    prob = pred.Predicted_State_Probability;

    % Convert Correct column to numeric values
    corrRaw = lower(strtrim(string(pred.Correct)));

    corr = str2double(corrRaw);

    % Handle logical/text values such as True/False
    corr(corrRaw == "true")  = 1;
    corr(corrRaw == "false") = 0;

    % Handle text labels if present
    corr(corrRaw == "correct")   = 1;
    corr(corrRaw == "incorrect") = 0;

    % Group predicted probabilities into bins
    edges = [0 .2 .4 .6 .8 1];
    bins = discretize(prob, edges, 'IncludedEdge', 'left');
    bins(prob == 1) = 5;

    acc = nan(5,1);

    for k = 1:5
        acc(k) = mean(corr(bins == k), 'omitnan');
    end

    % Plot confidence vs accuracy
    f = figure;
    bar(1:5, acc);
    ylim([0 1]);

    xticks(1:5);
    xticklabels({'[0,.2)','[.2,.4)','[.4,.6)', ...
                 '[.6,.8)','[.8,1]'});

    title('Prediction confidence vs accuracy');
    xlabel('Predicted probability bin');
    ylabel('Accuracy');

    saveFig(f, OUT_DIR, ...
        '04c_bar_confidence_vs_accuracy.png');
end

%% 5. Histograms
if ~isempty(trainD) && hasVars(trainD,["glucose","insulin"])
    f=figure; tiledlayout(1,2);
    nexttile; histogram(trainD.glucose,50); title('Training glucose distribution'); xlabel('Glucose (mg/dL)');
    nexttile; histogram(trainD.insulin,50); title('Training insulin distribution'); xlabel('Insulin (units)');
    saveFig(f,OUT_DIR,'05_hist_glucose_insulin.png');
end
if ~isempty(comp) && ismember("Dose_Difference",string(comp.Properties.VariableNames))
    f=figure; histogram(comp.Dose_Difference,40); xline(0,'k--');
    title('Dose difference (RL - clinician)'); xlabel('Units');
    saveFig(f,OUT_DIR,'05b_hist_dose_difference.png');
end

%% 6. Box plot (OPE)
if ~isempty(ope)
    cols=intersect(["DM_Value","IS_Value","DR_Value"],string(ope.Properties.VariableNames),'stable');
    if ~isempty(cols)
        vals=cell(numel(cols),1);
        for k=1:numel(cols), vals{k}=ope.(cols(k)); end
        f=figure; boxplot(vertcat(vals{:}), repelem(cols,cellfun(@numel,vals))');
        title('Off-policy evaluation: value estimates per test patient'); ylabel('Estimated value');
        saveFig(f,OUT_DIR,'06_box_ope.png');
    end
end

%% 7. Heatmaps
if ~isempty(qOpt) && ~isempty(qLrn) && isequal(size(qOpt),size(qLrn))
    f=figure; tiledlayout(1,3);
    vmin=min([qOpt(:);qLrn(:)]); vmax=max([qOpt(:);qLrn(:)]);
    nexttile; imagesc(qOpt); clim([vmin vmax]); colorbar; title('Theoretical Q (value iteration)'); xlabel('Action'); ylabel('State');
    nexttile; imagesc(qLrn); clim([vmin vmax]); colorbar; title('Learned Q (Q-learning)'); xlabel('Action'); ylabel('State');
    nexttile; imagesc(qLrn-qOpt); colorbar; title('Learned - theoretical'); xlabel('Action');
    saveFig(f,OUT_DIR,'07_heatmap_q_tables.png');
end
if ~isempty(cover) && hasVars(cover,["State_ID","Action_ID","Observations"])
    [G,states,actions]=findgroups(cover.State_ID,cover.Action_ID);
    sums=splitapply(@sum,cover.Observations,G);
    piv=unstack(table(states,actions,sums,'VariableNames',{'State_ID','Action_ID','Observations'}),'Observations','Action_ID');
    M=table2array(piv(:,2:end)); M(isnan(M))=0;
    f=figure; imagesc(log1p(M)); colorbar; title('State-action coverage (log observations)');
    xlabel('Action ID'); ylabel('State ID'); saveFig(f,OUT_DIR,'07b_heatmap_coverage.png');
end

%% 8. Confusion matrix (8 glucose-range bins)
if ~isempty(pred)
    a=pickCol(pred,"Actual_Next_Representative_Glucose"); p=pickCol(pred,"Predicted_Next_Representative_Glucose");
    if a~="" && p~=""
        x=pred.(a); y=pred.(p); ok=isfinite(x)&isfinite(y); x=x(ok); y=y(ok);
        if ~isempty(x)
            edges=linspace(min([x;y]),max([x;y]),9);
            bx=discretize(x,edges); by=discretize(y,edges); bx(x==edges(end))=8; by(y==edges(end))=8;
            cm=accumarray([bx by],1,[8 8],@sum,0); rowS=sum(cm,2); cmn=cm./rowS; cmn(rowS==0)=NaN;
            labels=strings(8,1); for k=1:8, labels(k)=sprintf('%.0f-%.0f',edges(k),edges(k+1)); end
            f=figure; imagesc(cmn,[0 1]); colorbar; axis tight;
            xticks(1:8); xticklabels(labels); yticks(1:8); yticklabels(labels); xtickangle(45);
            for i=1:8, for j=1:8, text(j,i,num2str(cm(i,j)),'HorizontalAlignment','center','FontSize',8); end, end
            title('Next-glucose confusion matrix (row-normalised colour)');
            xlabel('Predicted range (mg/dL)'); ylabel('Actual range (mg/dL)');
            saveFig(f,OUT_DIR,'08_confusion_matrix.png');
        end
    end
end

%% 9. Policy step plot
if ~isempty(polOpt) && ~isempty(polLrn)
    xo=pickCol(polOpt,"Representative_Glucose"); xl=pickCol(polLrn,"Representative_Glucose");
    yo=pickCol(polOpt,"Representative_Insulin","Optimal_Action_ID");
    yl=pickCol(polLrn,"Representative_Insulin","Learned_Insulin","Learned_Action_ID");
    if xo~="" && xl~="" && yo~="" && yl~=""
        [x1,i1]=sort(polOpt.(xo)); y1=polOpt.(yo); y1=y1(i1);
        [x2,i2]=sort(polLrn.(xl)); y2=polLrn.(yl); y2=y2(i2);
        f=figure; stairs(x1,y1,'LineWidth',2,'DisplayName','Value iteration'); hold on;
        stairs(x2,y2,'--','LineWidth',2,'DisplayName','Q-learning');
        title('Recommended insulin by glucose state'); xlabel('Glucose (mg/dL)');
        if contains(yo,'Insulin'), ylabel('Insulin (units)'); else, ylabel('Action ID'); end
        legend; saveFig(f,OUT_DIR,'09_policy_step_plot.png');
    end
end

disp("Plot generation complete.");

%% Local helper functions
function T=loadCSV(folder,name)
    file=fullfile(folder,name);
    if isfile(file)
        T=readtable(file,'VariableNamingRule','preserve');
    else
        fprintf('[skip] %s not found\\n',name); T=[];
    end
end
function c=pickCol(T,varargin)
    c="";
    if isempty(T), return; end
    names=string(T.Properties.VariableNames);
    for k=1:numel(varargin)
        if any(names==string(varargin{k})), c=string(varargin{k}); return; end
    end
end
function tf=hasVars(T,vars)
    tf=all(ismember(string(vars),string(T.Properties.VariableNames)));
end
function Q=loadQTable(folder,name)
    T=loadCSV(folder,name); Q=[];
    if isempty(T), return; end
    Q=table2array(T(:,2:end));
    Q=double(Q);
end
function saveFig(f,folder,name)
    set(f,'Color','w'); exportgraphics(f,fullfile(folder,name),'Resolution',150);
    close(f);
end































































