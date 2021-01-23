% laod the truth object forr first video
load('.\groundTruths\leftEye1.mat');

% Select labels for first video
LeftEyeGTruthForFirstVideo =  selectLabels(gTruth,'leftEyeClosed');

% laod the truth object forr first video
load('.\groundTruths\leftEye2.mat');

%Create Training Data From Ground Truth
LeftEyeGTruthForSecondVideo = selectLabels(gTruth,'leftEyeClosed');

%% SECTION FOR CREATING FILE
if isfolder(fullfile('TrainingData5'))
    cd TrainingData5
else
    mkdir TrainingData5
end
addpath('TrainingData5');

%% SECTION FOR DATA 
trainingDataForFirstVideo = objectDetectorTrainingData(LeftEyeGTruthForFirstVideo,'SamplingFactor',1,...
    'WriteLocation','TrainingData5');

trainingDataForSecondVideo = objectDetectorTrainingData(LeftEyeGTruth,'SamplingFactor',1,...
    'WriteLocation','TrainingData5');


trainingDataComplete = [trainingDataForFirstVideo; trainingDataForSecondVideo];

%% TRAINING SECTION
detector = trainACFObjectDetector(trainingDataComplete,'NumStages',5);
save('Detector7.mat','detector');
rmpath('TrainingData5');
