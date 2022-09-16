clear all

% load('../data/normalized/Rocky20220216to0303_ma50ms_successesOnly.mat');
load('../data/normalized/emg/Rocky20220216to0303_ma50ms_345.mat');
%% visualize 

%% save analog data only file
% dates = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];
% 
% wholeTrialData.data = struct.empty(0);
% wholeTrialData.sessionProp = struct.empty(0);
% for i=(1:length(dates))
%     date = dates(i);
%     file = dir('../data/synchronized/*2022' +date+ '*.mat');
%     load("../data/synchronized/" + file.name);
%     load('../data/normalized/emg/singleTrials_Rocky2022' + date +'_1ms.mat');
%     load('../data/normalized/others/singleTrials_Rocky2022' + date +'.mat');
%     [selectedTrialData,selectedArray] = selectStateTransition(trialData, [3 4 5]);
% 
%     normalizedEMGData = normalizedTrialData(selectedArray);
%     otherTrialData = otherTrialData(selectedArray);
% 
% 
%     wholeTrialData.sessionProp(i).EMGMetrics = EMGMetrics;
%     wholeTrialData.sessionProp(i).otherChannels = channelLabels;
%     wholeTrialData.sessionProp(i).dataSizes = length(selectedTrialData);
%     l = length(wholeTrialData.data);
%     timewindow = 801;
%     for s=(1:length(selectedTrialData))
%         stateTransition = selectedTrialData(s).stateTable;
%         GoCueTime = stateTransition(2, find(stateTransition(1, :)==4));
%         % start: -200ms end: +600ms at GoCue
%         wholeTrialData.data(l+s).emg.EMG = normalizedEMGData(s).EMG(GoCueTime-200:GoCueTime+timewindow-201);
%         wholeTrialData.data(l+s).emg.goodEMGData = normalizedEMGData(s).goodEMGData;
%         % GoCueTime-200:GoCueTime+600をそれぞれTime関数から取得しindexに変換する
%         movementStartTime = find(selectedTrialData(s).time == GoCueTime);
%         selectedTrialData(s).handKinematics = selectedTrialData(s).handKinematics.velocity(movementStartTime-200:movementStartTime+timewindow-201, :);
%         
%         wholeTrialData.data(l+s).others = otherTrialData(s).others(GoCueTime-200:GoCueTime+timewindow-201, :);
%         wholeTrialData.data(l+s).kinematics = selectedTrialData(s);
%     end
% end
% save("../data/processed/singleTrials_Rocky2022to0303.mat", "wholeTrialData")

%% get maxVelosity data
% movement = exceptionRemovedEMG.data.kinematics.integratedVelosities; % timewindow * N
% [maxVelosityMagnitudes, maxVelosityIndexs] = max(movement, [], 1); % should be 1*N
% normals = zeros(1,size(movement, 2), 'logical');
% for i=(1:length(maxVelosityIndexs))
%     if maxVelosityIndexs(i) > 300+200
%         normals(i) = 1;
%     end
% end

%% mean peak velocity of EMG as a function of reward
% Y = zeros(1, 4);
% Yerror = zeros(1, 4);
% for reward=(1:4)
%     condition = all([exceptionRemovedEMG.data.rewards==reward;normals]);
%     Y(reward) = mean(maxVelosityMagnitudes(condition));
%     Yerror(reward) = std(maxVelosityMagnitudes(condition)) / length(maxVelosityMagnitudes(condition));
% end
% errorbar(Y, Yerror, 'Color', "k",'linewidth',2)
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% xticks([1 2 3 4]);
% xticklabels({'Small', 'Medium', 'Large', 'Jackpot'});

%% add goodEMG data 
% dates = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];
% for d=(1:length(dates))
%     date = dates(d);
%     load('../data/normalized/emg/singleTrials_Rocky2022' + date + '_1ms.mat');
%     
% 
%     for i=(1:length(normalizedTrialData))
%         if d == 1
%             normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Trap";
%         elseif d == 6 || d == 7 || d == 8
%             normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Tric";
%         elseif d == 9
%             condition = any([EMGMetrics.muscleNames == "Tric"; EMGMetrics.muscleNames == "LBic"; EMGMetrics.muscleNames == "PDel"]);
%             normalizedTrialData(i).goodEMGData = ~condition;
%         elseif d == 12
%             normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Trap";
%         else
%             normalizedTrialData(i).goodEMGData = true(5, 1);
%         end
%     end
% 
%     save('../data/normalized/emg/singleTrials_Rocky2022' + date + '_1ms.mat', 'normalizedTrialData', 'EMGMetrics');
% end

%% check normalization method
% dates = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];
% figure
% for d=(1:length(dates))
%     date = dates(d);
%     load('../data/normalized/singleTrials_Rocky2022' + date + '_1ms.mat');
%     Y = (EMGMetrics.maxSignalTuningCurve_mean - EMGMetrics.normalizedParams(1,:)) ./ EMGMetrics.normalizedParams(2,:);
%     if d == 1
%         Y(:, EMGMetrics.muscleNames == "Trap") = 0;
%     elseif d == 6 || d == 7 || d == 8
%         Y(:, EMGMetrics.muscleNames == "Tric") = 0;
%     elseif d == 9
%         condition = any([EMGMetrics.muscleNames == "Tric"; EMGMetrics.muscleNames == "LBic"; EMGMetrics.muscleNames == "PDel"]);
%         Y(:, condition) = 0;
%     elseif d == 12
%         Y(:, EMGMetrics.muscleNames == "Trap") = 0;
%     end
%     plot(Y)
%     rewColors = [1 0 0; 1 0.6470 0; 0 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     hold on
% end
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% hold off

%% EMG fatigue across the session
% parameters = struct.empty(5, 0);
% for channel=(1:5)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     acrossday = zeros(size(emg.exceptions));
%     startTrial = 1;
%     parameters(channel).diff = [];
%     for day = (1:length(exceptionRemovedEMG.preprocessProp.IndexEachDay))
%         fetchedEMG = mean(emg.signals(50:250, startTrial:exceptionRemovedEMG.preprocessProp.IndexEachDay(day)), 1); %-150~+50ms
%         exception = emg.exceptions(startTrial:exceptionRemovedEMG.preprocessProp.IndexEachDay(day));
%         fetchedEMG = fetchedEMG(cast(exception, "logical"));
%         startTrial = exceptionRemovedEMG.preprocessProp.IndexEachDay(day)+1;
% %         fprintf("emg size: %d \n", length(fetchedEMG));
%         if length(fetchedEMG) > 2
%             movcar = round(length(fetchedEMG)*0.1);
%             Y = fetchedEMG;
% %             covariance = cov(Y, X);
% %             alpha = covariance(1,2) / var(X);
% %             beta = mean(Y) - alpha * mean(X);
%             parameters(channel).diff(end+1) = mean(fetchedEMG(end-movcar:end)) - mean(fetchedEMG(1:movcar));
% %             figure
% %             plot(X,Y, 'color', [.5 .5 .5])
% %             hold on
% %             plot(X, (alpha*X+beta), "k", "LineWidth", 2);
% %             title([emg.name + ": Day" + num2str(day)]);
% %             hold off
%         end
%     end
% end
% xlabels = string.empty(0);
% for channel=(1:5)
%     scatter(channel * ones(size(parameters(channel).diff)), parameters(channel).diff, '*', "b");
%     hold on
%     xlabels(end+1) = exceptionRemovedEMG.data.emgs(channel).name;
%     scatter(channel, mean(parameters(channel).diff), '*', "r");
%     [h,p] = ttest(parameters(channel).diff);
%     disp(p)
% end
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out', "LineWidth", 2);
% ylabel("last 10% EMG - first 10% EMG")
% xlim([0.5 5.5])
% xticklabels(xlabels)
% yline(0)
% hold off

%% EMG variablity as a function of reward
Y = struct.empty(0);
for i=(1:4)
    Y(i).emg = double.empty(0);
end
for channel=(5:5)
    data = exceptionRemovedEMG.data;
    emg = exceptionRemovedEMG.data.emgs(channel);
    for direction=(1:8)
        condition = all([data.directions==direction; emg.exceptions]);
        rewardArray = data.rewards(condition);
        fetchedEMG = mean(emg.signals(50:250, condition), 1); %-150~+50ms
        zScoredEMG = zscore(fetchedEMG);
        for reward=(1:4)
            Y(reward).emg = cat(1, Y(reward).emg, zScoredEMG(rewardArray==reward).');
        end
    end
end
figure
rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
edges = (-3.05:0.1:3.05);
x = (-3:0.1:3);
for i=(1:size(Y, 2))
    N = histcounts(Y(i).emg, edges);
    prob = N / size(Y(i).emg, 1);
    plot(x, prob, 'Color', rewColors(i, :), LineWidth=2)
    % set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
    hold on
end
hold off
legend({'Small', 'Medium', 'Large', 'Jackpot'});
xlabel("z-indexed emg")
gca.YAxis.Visible = 'off';
box off;

%% mean trajectories around Go Cue(-200~+600) as a function of direction
% for channel=(1:5)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     Y = zeros(801, 8);
%     for direction=(1:8)
%         condition = all([data.directions==direction; emg.exceptions]);
%         fetchedEMG = emg.signals(1:801, condition);
%         Y(:, direction) = mean(fetchedEMG, 2);
%     end
%     figure
%     plot((-200:600), Y, "LineWidth", 2)
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out', "LineWidth", 2);
%     legend(["right", "upper right", "upper", "upper left", "left", "lower left", "lower", "lower right"], ...
%             "Location", "northwest")
%     title(emg.name);
% end

%% histogram of the time spent on reaching period of both successes and failure 
% for channel=(5:5)
%     successes = [];
%     failures = [];
%     for i=(1:size(exceptionRemovedEMG.data.transitions, 3))
%         transition = exceptionRemovedEMG.data.transitions(:, :, i);
%         if transition(1,4) == 6
%             successes = [successes, int32(transition(2,4)-transition(2,2))];
%         else
%             failures = [failures, int32(transition(2,4)-transition(2,2))];
%         end
%     end
%     histogram(successes,'FaceAlpha',0.2, "FaceColor","r")
%     hold on
%     histogram(failures,'FaceAlpha',0.2, "FaceColor","b")
%     hold off
% end

%% visualize mean EMG across day
% for channel = (1:5)
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     Y = emg.signals(50:251, cast(emg.exceptions, 'logical'));
%     figure
%     plot(mean(Y, 1),'linewidth',2)
%     title(emg.name);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     hold off
% end

%% visualize mean EMG around velocity peak value aligned by holding time 
% baseline = zeros(8, 5);
% for channel=(1:5)
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     for direction=(1:8)
%         EMGtmp = emg.signals(50:250, exceptionRemovedEMG.data.directions==direction);
%         meanOneDirectionEMG = mean(EMGtmp, 2);
%         baseline(direction, channel) = mean(meanOneDirectionEMG);
%     end
% end
% datapoint = zeros(8,4,5);
% for channel=(1:5) %1:length(exceptionRemovedEMG.data.emgs)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
% 
%     Y = zeros(8,4);
%     Yerror = zeros(8,4);
%     for reward=(1:4)
%         for direction=(1:8)
%             condition = all([data.directions==direction; data.rewards==reward; normals; emg.exceptions]);
%             maxVelosityIndexsConditioned = maxVelosityIndexs(condition);
%             EMGtmp = emg.signals(:, condition);
%             EMGAroundPeak = zeros(1, size(EMGtmp, 2));
%             for i=(1:length(maxVelosityIndexsConditioned))
%                 maxVIdx = maxVelosityIndexsConditioned(i);
%                 EMGAroundPeak(i) = mean(EMGtmp(maxVIdx-100:maxVIdx+100, i));
%             end
%             MeanIntensitysAtOneDirection = mean(EMGAroundPeak);
%             standardError = std(EMGAroundPeak) / sqrt(length(EMGAroundPeak));
%             Y(direction, reward) = MeanIntensitysAtOneDirection;
%             Yerror(direction, reward) = standardError;
%             datapoint(direction, reward, channel) = size(EMGtmp, 2);
%         end
%     end
%     figure
%     errorbar(abs(Y-baseline(:,channel)), Yerror,'linewidth',2);
%     title(emg.name);
%     legend(["Small", "Medium", "Large", "Jackpot"])
%     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     xticks([1 2 3 4 5 6 7 8]);
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
%     xlim([0.5 8.5]);
% end

%% visualize mean EMG around velocity peak value
% datapoint = zeros(8,4,5);
% for channel=(1:5) %1:length(exceptionRemovedEMG.data.emgs)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
% 
%     Y = zeros(8,4);
%     Yerror = zeros(8,4);
%     for reward=(1:4)
%         for direction=(1:8)
%             condition = all([data.directions==direction; data.rewards==reward; normals; emg.exceptions]);
%             maxVelosityIndexsConditioned = maxVelosityIndexs(condition);
%             EMGtmp = emg.signals(:, condition);
%             EMGAroundPeak = zeros(1, size(EMGtmp, 2));
%             for i=(1:length(maxVelosityIndexsConditioned))
%                 maxVIdx = maxVelosityIndexsConditioned(i);
%                 EMGAroundPeak(i) = mean(EMGtmp(maxVIdx-100:maxVIdx+100, i));
%             end
%             MeanIntensitysAtOneDirection = mean(EMGAroundPeak);
%             standardError = std(EMGAroundPeak) / sqrt(length(EMGAroundPeak));
%             Y(direction, reward) = MeanIntensitysAtOneDirection;
%             Yerror(direction, reward) = standardError;
%             datapoint(direction, reward, channel) = size(EMGtmp, 2);
%         end
%     end
%     figure
%     errorbar(Y, Yerror,'linewidth',2);
%     title(emg.name);
%     legend(["Small", "Medium", "Large", "Jackpot"])
%     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     xticks([1 2 3 4 5 6 7 8]);
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
%     xlim([0.5 8.5]);
% end

% Y = movement(:, normals);
% figure
% plot(Y, "Color", [0.7 0.7 0.7]);
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% hold on
% plot(mean(Y, 2), "Color", [0 0 0])
% hold off
% histogram(maxVelosityMagnitudes(normals))
% title("Histogram of maxVelosityMagnitudes for each trial")
% histogram(maxVelosityIndexs(normals)-200)
% title("Histogram of maxVelosityMagnitudes for each trial")

%% coefficient of variation across days
% figure
% for channel=(1:5)
%     titles = {'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7', 'Day8', 'Day9', 'Day10', 'Day11', 'Day12'};
%     Y = normalizedParams(2, channel, :) ./ normalizedParams(1, channel, :);
%     Y = reshape(Y, 1, []);
%     if file.muscleLabel(channel) == "Tric"
%         Y(5:9) = [];
%         titles(5:9) = [];
%     elseif file.muscleLabel(channel) == "Trap"
%         Y(1) = [];
%         titles(1) = [];
%     elseif file.muscleLabel(channel) == "LBic" || file.muscleLabel(channel) == "PDel"
%         Y(9) = [];
%         titles(9) = [];
%     end
%     plot(Y,'linewidth',2)
%     hold on
% end
% legend(file.muscleLabel)
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% hold off

%% z-indexed 9 datapoint metadata 
% for channel=(1:5)
%     titles = {'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7', 'Day8', 'Day9', 'Day10', 'Day11', 'Day12'};
%     figure
%     Y = reshape(tenDmetadataAcrossDays(:, channel, :), 9, []);
%     if file.muscleLabel(channel) == "Tric"
%         Y(:, 5:9) = [];
%         titles(5:9) = [];
%     elseif file.muscleLabel(channel) == "Trap"
%         Y(:, 1) = [];
%         titles(1) = [];
%     elseif file.muscleLabel(channel) == "LBic" || file.muscleLabel(channel) == "PDel"
%         Y(:, 9) = [];
%         titles(9) = [];
%     end
%     plot(Y)
%     title(file.muscleLabel(channel));
%     legend(titles)
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325', 'hold'});
% end

%% Mean EMG at holding time as a function of reward  
% for channel=(1:5)
%     Y = zeros(1,4);
%     Yerror = zeros(1,4);
%     datapoint = zeros(1,4);
%     for reward=(1:4)
%         EMGtmp = normalizedEMGAcrossDays(50:250, channel, rewardAcrossDays==reward);
%         meanOneDirectionEMG = mean(EMGtmp, 3);
%         MaxIntensitysAtOneDirection = mean(meanOneDirectionEMG);
%         standardError = std(meanOneDirectionEMG) / sqrt(size(EMGtmp, 3));
%         Y(reward) = MaxIntensitysAtOneDirection;
%         Yerror(reward) = standardError;
%         datapoint(reward) = size(EMGtmp, 3);
%     end
%     figure
%     errorbar([1 2 3 4],Y, Yerror,'linewidth',2);
%     title(muscleLabel(channel));
%     xticks([1 2 3 4]);
%     xticklabels(["Small", "Medium", "Large", "Jackpot"]);
% %     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
% %     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% end

%% EMG as a function of reward hypothesis
% x = (1:8)
% Yhypo = sin(x / 4 * pi)
% Yhypos = ones(4, 8) .* Yhypo
% Yhypos = Yhypos ./ 10
% Yhypos = Yhypos + [-.95; -.9; -.85; -.8]
% plot(Yhypos.','linewidth',2);
% title('ADel');
% legend(["Small", "Medium", "Large", "Jackpot"])
% rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
% colororder(rewColors);
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out','linewidth',2);
% xticks([1 2 3 4 5 6 7 8]);
% xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
% xlim([0.5 8.5]);

%% EMG tuning curve at holding time as a function of reward and direction 
% for channel=(5:5)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     Y = zeros(8,4);
%     Yerror = zeros(8,4);
%     datapoint = zeros(8,4);
%     for reward=(1:4)
%         for direction=(1:8)
%             condition = all([data.directions==direction; data.rewards==reward; emg.exceptions]);
%             EMGtmp = emg.signals(50:250, condition);
%             meanOneDirectionEMG = mean(EMGtmp, 2);
%             meanIntensitysAtOneDirection = mean(meanOneDirectionEMG);
%             standardError = std(meanOneDirectionEMG) / sqrt(size(EMGtmp, 2));
%             Y(direction, reward) = meanIntensitysAtOneDirection;
%             Yerror(direction, reward) = standardError;
%             datapoint(direction, reward) = size(EMGtmp, 2);
%         end
%     end
%     figure
%     errorbar(Y, Yerror,'linewidth',2);
%     title(emg.name);
%     legend(["Small", "Medium", "Large", "Jackpot"], Location="southwest")
%     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     xticks([1 2 3 4 5 6 7 8]);
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
%     xlim([0.5 8.5]);
% end
