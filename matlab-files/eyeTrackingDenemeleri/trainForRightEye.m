% laod the truth object forr first video
load('.\groundTruths\rightEye1.mat');

% Select labels for first video
rightEyeGtruth1 =  selectLabels(gTruth,'rightEyeClosed');

% Laod the truth object forr first video
load('.\groundTruths\rightEye2.mat');

% Select labels for first video
rightEyeGtruth2 =  selectLabels(gTruth,'rightEyeClosed');

% Laod the truth object forr first video
load('.\groundTruths\rightEye3.mat');

% Select labels for first video
rightEyeGtruth3 =  selectLabels(gTruth,'rightEyeClosed');

% Laod the truth object forr first video
load('.\groundTruths\rightEye4.mat');

% Select labels for first video
rightEyeGtruth4 =  selectLabels(gTruth,'rightEyeClosed');

% Laod the truth object for first video
load('.\groundTruths\rightEye5.mat');

% Select labels for first video
rightEyeGtruth5 =  selectLabels(gTruth,'rightEyeClosed');

% Laod the truth object for first video
load('.\groundTruths\rightEye6.mat');

% Select labels for first video
rightEyeGtruth6 =  selectLabels(gTruth,'rightEyeClosed');

% Laod the truth object for first video
load('.\groundTruths\rightEye7.mat');

% Select labels for first video
rightEyeGtruth7 =  selectLabels(gTruth,'rightEyeClosed');

%% SECTION FOR CREATING FILE
if isfolder(fullfile('TrainingDataForRight2'))
    cd TrainingDataForRight2
else
    mkdir TrainingDataForRight2
end
addpath('TrainingDataForRight2');

%% SECTION FOR DATA 
trainingData1 = objectDetectorTrainingData(rightEyeGtruth1,'SamplingFactor',1,...
    'WriteLocation','TrainingDataForRight');

trainingData2 = objectDetectorTrainingData(rightEyeGtruth2,'SamplingFactor',1,...
    'WriteLocation','TrainingDataForRight');

trainingData3 = objectDetectorTrainingData(rightEyeGtruth3,'SamplingFactor',1,...
    'WriteLocation','TrainingDataForRight');

trainingData4 = objectDetectorTrainingData(rightEyeGtruth4,'SamplingFactor',1,...
    'WriteLocation','TrainingDataForRight');

trainingData5 = objectDetectorTrainingData(rightEyeGtruth5,'SamplingFactor',1,...
    'WriteLocation','TrainingDataForRight');

trainingData6 = objectDetectorTrainingData(rightEyeGtruth6,'SamplingFactor',1,...
    'WriteLocation','TrainingDataForRight2');

trainingData7 = objectDetectorTrainingData(rightEyeGtruth7,'SamplingFactor',1,...
    'WriteLocation','TrainingDataForRight2');

trainingDataComplete = [trainingData6; trainingData7];

% trainingDataComplete = [trainingData1; trainingData2; trainingData3; trainingData4; trainingData5];

%% TRAINING SECTION
detector = trainACFObjectDetector(trainingDataComplete,'NumStages',5);
save('rightEyeDetector2.mat','detector');
rmpath('TrainingDataForRight2');
