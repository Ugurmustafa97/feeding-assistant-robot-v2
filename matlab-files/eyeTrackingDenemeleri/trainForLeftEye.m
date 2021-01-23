% laod the truth object forr first video
load('.\groundTruths\leftEye3.mat');

% Select labels for first video
leftEyeGtruth1 =  selectLabels(gTruth,'leftEyeClosed');

% Laod the truth object forr first video
load('.\groundTruths\leftEye4.mat');

% Select labels for first video
leftEyeGtruth2 =  selectLabels(gTruth,'leftEyeClosed');

%% SECTION FOR CREATING FILE
if isfolder(fullfile('TrainingDataForLeft'))
    cd TrainingDataForLeft
else
    mkdir TrainingDataForLeft
end
addpath('TrainingDataForLeft');

%% SECTION FOR DATA 
trainingData1 = objectDetectorTrainingData(leftEyeGtruth1,'SamplingFactor',1,...
    'WriteLocation','TrainingDataForLeft');

trainingData2 = objectDetectorTrainingData(leftEyeGtruth2,'SamplingFactor',1,...
    'WriteLocation','TrainingDataForLeft');

trainingDataComplete = [trainingData1; trainingData2];

%% TRAINING SECTION
detector = trainACFObjectDetector(trainingDataComplete,'NumStages',5);
%save('Detector7.mat','detector');
rmpath('TrainingDataForLeft');
