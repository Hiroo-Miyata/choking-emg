% This function preprocesses the EMG data, including filtering,
% rectification, and downsampling. Then, we get the segment applied to each
% trial in trialData and store it accordingly.
%
% Inputs:
% - analogData: structure with 4 fields:
%   - channelLabels: names for each of the analog channels. For this, we
%   use 'EMG_1' through 'EMG_8'
%   - fs: scalar, sampling frequency of the data
%   - time: [ntime x 1] vector with the time (relative to task CPU) of the
%   analog data
%   - data: [ntime x nchannels] analog data
% - synchInfo: structure with many fields of synch information, but
% for this, all we use is the "taskSynchTrialTimes", which indicates when
% state 1 (center target appearance) first occurred for each trial ([ntrials
% x 1])
% - trialData: [ntrials x 1] structure with the trial parameter data and
% kinematics
%
% Outputs:
% - trialData: same as input, but now has 2 more fields:
%   - EMGData: structure with 2 fields:
%       - EMG: [ntime x nmuscles] matrix with EMG values
%       - muscleNames: [nmuscles x 1] cell array with the corresponding 
%       muscle names for each
%   - goodEMGData: [nmuscles x 1] boolean array indicating if the trial's 
%   data for each muscle is good/does not have artifacts or issues
% - EMGMetrics: a structure indicating signal quality for each muscle
%   - baseline = [nmuscles x 1]
%   - maxSignalTuningCurve_mean = [nmuscles x ndirections+1]
%   - maxSignalTuningCurve_std = [nmuscles x ndirections+1]
%   - maxSNR = [nmuscles x 1] (peak avg activity)/(baseline)
dates = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];
for date=dates
    file = dir('../data/synchronized/*2022' +date+ '*.mat');
    alldata = load("../data/synchronized/" + file.name);
    signalData = alldata.analogData;
    muscleLabel = ["ADel", "LBic", "PDel", "Trap", "Tric"];
    fs = 10000;
    new_fs = 1000;
    zerotime = alldata.analogData.time(1); %second 
    
    % separate signal by trial
    % Step 1 prepare (downsampled length, 5) double array
    % Step 2 smoothed and put into the array
    % Step 3 separate by trial from synchInfo
    % Step 4 load Property from Hand data (reward, direction, success/failure, Handmovement)
    preprocessedEMGs = emgFiltering(signalData,fs, 0.001, muscleLabel);
    
    preprocessedTrialData = struct.empty(0);
    otherTrialData = struct.empty(0);
    channelLabels = alldata.analogData.channelLabels(8:11);
    for t=(1:length(alldata.trialData))
        trialData = alldata.trialData(t);
        startTime = ceil((trialData.taskSynchTrialTime-zerotime)*1000);
        endTime = ceil((trialData.taskSynchTrialTime-zerotime)*1000 + max(trialData.time));
        preprocessedTrialData(t).emg = preprocessedEMGs(startTime:endTime, :);
        preprocessedTrialData(t).prop.result = trialData.trialStatus;
        preprocessedTrialData(t).prop.direction = trialData.directionLabel;
        preprocessedTrialData(t).prop.reward = trialData.rewardLabel;
        preprocessedTrialData(t).prop.startTarget = trialData.centerTarget;
        preprocessedTrialData(t).prop.endTarget = trialData.reachTarget;
        preprocessedTrialData(t).prop.stateTransition = trialData.stateTable;
        preprocessedTrialData(t).handKinematics = trialData.handKinematics;
        preprocessedTrialData(t).timeInTrial = trialData.time;
        otherTrialData(t).others = signalData.data(startTime:endTime, 8:11);
    end
    
    emgRest = preprocessedEMGs(1:120*new_fs, :);
    % save('../data/processed/singleTrials_Rocky20220216_movave_50ms.mat', 'preprocessedTrialData', 'muscleLabel', "emg_rest");
    [normalizedTrialData, EMGMetrics] = emgNormalization(preprocessedTrialData, emgRest, muscleLabel);
    save('../data/normalized/emg/singleTrials_Rocky2022' + date +'_1ms.mat', 'normalizedTrialData', 'EMGMetrics');
    save('../data/normalized/others/singleTrials_Rocky2022' + date +'.mat', 'otherTrialData', 'channelLabels');
end