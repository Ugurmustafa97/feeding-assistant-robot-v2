%% PROGRAM

load('.\detectors\leftEyeDetector.mat');

leftEyeDetector = detector;

load('.\detectors\rightEyeDetector2.mat');

rightEyeDetector = detector;

% Create the face detector object.
faceDetector = vision.CascadeObjectDetector();

% Create the webcam object.
% cam = webcam();
cam = webcam('Microsoft® LifeCam HD-3000');
cam.Resolution = '1280x720';

% Capture one frame to get its size.
videoFrame = snapshot(cam);
frameSize = size(videoFrame);

% Create the video player object.
videoPlayer = vision.VideoPlayer();

% Values for loops
runLoop = true;

% Counter for timing
counterBoth         = 0;
counterLeft         = 0;
counterRight        = 0;


% frequency for the image process
freq                = 2;


% Time constant for control
requiredTime        = 5;        % 5s is required for input
requiredTimeForBoth = 3;

% Threshold for each eye
% thresolhForRightEyeDetection = 60;
% thresolhForLeftEyeDetection  = 40;

% Best scores for detections.
leftBestScore   = 0;
rigthBestScore  = 0;

% Avarage values
leftAvarage  = 0;
rightAvarage = 0;

leftSum = 0;
rightSum = 0;

%% LEFT EYE SECTION

% Tell the user to close her left eye for five seconds
% Play the voice
load('voices\thresholdLeftEye.mat');
sound(data, fs);

pause(5);

while runLoop
    % Get the next frame.
    videoFrame = snapshot(cam);
    
    % Convert image to the grayscale
    videoFrameGray = rgb2gray(videoFrame);
    
    % Find the position of the face
    bbox = faceDetector.step(videoFrameGray);
    
    %% SECTION FOR SEARCHING LEFT EYE
    
    % Limit the searching area
    if ~isempty(bbox) && (((bbox(1,1) + bbox(1,3)/2)) < frameSize(2)) && ((bbox(1,2) + bbox(1,4)/2) < frameSize(1))
        % Create a region of interest to find mouth.
        roiForLeftEye = [(bbox(1,1) + bbox(1,3)/2), bbox(1,2), bbox(1,3)/2, bbox(1,4)/2];
    else
        fprintf('Could not find the position of the face. It will be looked again!\n');
        roiForLeftEye = [10, 10, frameSize(1)/2, frameSize(2)/2];
    end
   
    % Find the position of the left eye
    
    [bboxesLeft,scoresLeft] = detect(leftEyeDetector, videoFrame, roiForLeftEye);
    % Seelect the strongest result
    [~,idxLeft] = max(scoresLeft);
    
    
    %% CHECKING FOR ZERO SCORE
    
    if isempty(scoresLeft(idxLeft))
        leftBestScore = 0;
    else
        leftBestScore = scoresLeft(idxLeft);
    end
    
  
    %% THE CASE FOR ONLY LEFT EYE IS CLOSED

    if leftBestScore > 10
        % Write the confidence score of the left eye detection
        annotation = sprintf('%s , Confidence %4.2f',leftEyeDetector.ModelName,leftBestScore);
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesLeft(idxLeft,:),annotation);
        
        if counterLeft <= requiredTime
            counterLeft = counterLeft + 1;
        end
        
        text = ['Elapsed Time With Left Eye Is Closed:',num2str(counterLeft),'/5 s'];
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 20],text, 'FontSize',32);
        videoFrame=insertShape(videoFrame,'FilledRectangle',[410 80 100*counterLeft 40]);
        videoFrame=insertShape(videoFrame,'Rectangle',[410 80 100*requiredTime 40],'Color','blue');
        
        leftSum = leftSum + leftBestScore;
    else
        %%
        counterLeft = 0;
    end
    
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    
    runLoop = isOpen(videoPlayer);
    
    pause(1/freq);
    
    if counterLeft == 5
        break;
    end
    
end

%% RIGHT EYE SECTION  

% Tell the user to close her right eye for five seconds
% Play the voice
load('voices\thresholdRightEye.mat');
sound(data, fs);

pause(5);

while runLoop
    % Get the next frame.
    videoFrame = snapshot(cam);
    
    % Convert image to the grayscale
    videoFrameGray = rgb2gray(videoFrame);
    
    % Find the position of the face
    bbox = faceDetector.step(videoFrameGray);
    
    %% SECTION FOR SEARCHING RIGHT EYE
    
    % Limit the searching area
    if ~isempty(bbox) && (((bbox(1,1) + bbox(1,3)/2)) < frameSize(2)) && ((bbox(1,2) + bbox(1,4)/2) < frameSize(1))
        % Create a region of interest to find right eye
        roiForRightEye = [bbox(1,1), bbox(1,2), bbox(1,3)/2, bbox(1,4)/2];
        
    else
        fprintf('Could not find the position of the face. It will be looked again!\n');
        roiForRightEye = [10, 10, frameSize(1)/2, frameSize(2)/2];
    end
    
    % Find the position of the right eye
    [bboxesRight,scoresRight] = detect(rightEyeDetector, videoFrame, roiForRightEye);
    % Seelect the strongest result
    [~,idxRight] = max(scoresRight);
    
    %% CHECKING FOR ZERO SCORE
    
    if isempty(scoresRight(idxRight))
        rigthBestScore = 0;
    else
        rigthBestScore = scoresRight(idxRight);
    end
    
  
    %% THE CASE FOR ONLY LEFT EYE IS CLOSED

    if rigthBestScore > 10
        % Write the confidence score of the right eye detection
        annotation = sprintf('%s , Confidence %4.2f',rightEyeDetector.ModelName,rigthBestScore);
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesRight(idxRight,:),annotation);
        
        if counterRight <= requiredTime
            counterRight = counterRight + 1;
        end
        
        text = ['Elapsed Time With Right Eye Is Closed:',num2str(counterRight),'/5 s'];
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 20],text, 'FontSize',32);
        videoFrame=insertShape(videoFrame,'FilledRectangle',[410 80 100*counterRight 40]);
        videoFrame=insertShape(videoFrame,'Rectangle',[410 80 100*requiredTime 40],'Color','blue');
        
        rightSum = rightSum + rigthBestScore;
    else
        counterRight = 0;
    end
    
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    
    runLoop = isOpen(videoPlayer);
    
    pause(1/freq);
    
    if counterRight == 5
        break;
    end
    
end

leftAvarage = leftSum / counterLeft;

display(leftAvarage);

rightAvarage = rightSum / counterRight;

display(rightAvarage);

% Clean up.
clear cam;

% Clear all thing except whichBowlOutput
clear annotation; clear bbox; clear bboxesLeft; clear bboxesRight;
clear counterBoth; clear counterLeft; clear counterRight;clear data; clear detector;
clear faceDetector; clear frameSize; clear freq; clear fs; clear idxLeft;
clear idxRight; clear leftBestScore; clear leftEyeDetector; clear requiredTime;
clear requiredTimeForBoth; clear rightEyeDetector; clear rigthBestScore; 
clear roiForLeftEye; clear roiForRightEye; clear runLoop; clear scoresLeft;
clear scoresRight; clear text; clear thresolhForLeftEyeDetection;
clear thresolhForRightEyeDetection; clear videoFrame; clear videoFrameGray;
clear videoPlayer; clear leftSum; clear rightSum;