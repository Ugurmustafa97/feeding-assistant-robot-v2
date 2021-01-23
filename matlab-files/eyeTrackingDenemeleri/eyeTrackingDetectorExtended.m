%% CLEARING BEFORE RUNNING
clear all
clc
close all

%% PROGRAM

load('.\detectors\Detector7.mat');

leftEyeDetector = detector;

load('.\detectors\rightEyeDetector.mat');

rightEyeDetector = detector;

% Create the face detector object.
faceDetector = vision.CascadeObjectDetector();

% Create the webcam object.
cam = webcam();

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

thresolhForDetection = 10;

leftBestScore   = 0;
rigthBestScore  = 0;

while runLoop
    % Get the next frame.
    videoFrame = snapshot(cam);
    
    % Convert image to the grayscale
    videoFrameGray = rgb2gray(videoFrame);
    
    % Find the position of the face
    bbox = faceDetector.step(videoFrameGray);
    
    %% SECTION FOR SEARCHING LEFT EYE
    
    % Limit the searching area
    if ~isempty(bbox) && (((bbox(1) + bbox(3)/2)) < frameSize(2)) && ((bbox(2) + bbox(4)/2) < frameSize(1))
        % Create a region of interest to find mouth.
        roiForLeftEye = [(bbox(1) + bbox(3)/2), bbox(2), bbox(3)/2, bbox(4)/2];
    else
        fprintf('Could not find the position of the face. It will be looked again!\n');
        roiForLeftEye = [10, 10, frameSize(1)/2, frameSize(2)/2];
    end
    
    % Find the position of the left eye
    [bboxesLeft,scoresLeft] = detect(leftEyeDetector, videoFrame, roiForLeftEye);
    % Seelect the strongest result
    [~,idxLeft] = max(scoresLeft);
    
    %% SECTION FOR SEARCHING RIGHT EYE
    
    % Limit the searching area
    if ~isempty(bbox)
        % Create a region of interest to find right eye
        roiForRightEye = [bbox(1), bbox(2), bbox(3)/2, bbox(4)/2];
        
    else
        fprintf('Could not find the position of the face. It will be looked again!\n');
        roiForRightEye = [10, 10, frameSize(1)/2, frameSize(2)/2];
    end
    
    % Find the position of the right eye
    [bboxesRight,scoresRight] = detect(rightEyeDetector, videoFrame, roiForRightEye);
    % Seelect the strongest result
    [~,idxRight] = max(scoresRight);
    
    %% THE CASE FOR BOTH EYES ARE CLOSE
    if isempty(scoresLeft(idxLeft))
        leftBestScore = 0;
    else
        leftBestScore = scoresLeft(idxLeft);
    end
    
    if ((scoresLeft(idxLeft) > thresolhForDetection) && (scoresRight(idxRight) > thresolhForDetection))
        % Write the confidence score of the left eye detection
        annotation = sprintf('%s , Confidence %4.2f',detector.ModelName,scoresLeft(idxLeft));
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesLeft(idxLeft,:),annotation);
        
        % Write the confidence score of the right eye detection
        annotation = sprintf('%s , Confidence %4.2f',detector.ModelName,scoresRight(idxRight));
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesRight(idxRight,:),annotation);
        
        if counterBoth <= requiredTimeForBoth
            counterBoth = counterBoth + 1;
        end
        
        text = ['Elapsed Time With Both Eyes Are Closed:',num2str(counterBoth),'/3 s'];
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 20],text, 'FontSize',32);
        videoFrame=insertShape(videoFrame,'FilledRectangle',[410 80 100*counterBoth 40]);
        videoFrame=insertShape(videoFrame,'Rectangle',[410 80 100*requiredTimeForBoth 40],'Color','blue');
    else
        counterBoth = 0;
    end
    
    %% THE CASE FOR ONLY LEFT EYE IS CLOSED
    
    if (scoresLeft(idxLeft) > thresolhForDetection) && (scoresRight(idxRight) < thresolhForDetection)
        % Write the confidence score of the left eye detection
        annotation = sprintf('%s , Confidence %4.2f',detector.ModelName,scoresLeft(idxLeft));
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesLeft(idxLeft,:),annotation);
        
        if counterLeft <= requiredTime
            counterLeft = counterLeft + 1;
        end
        
        text = ['Elapsed Time With Left Eye Is Closed:',num2str(counterLeft),'/5 s'];
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 20],text, 'FontSize',32);
        videoFrame=insertShape(videoFrame,'FilledRectangle',[410 80 100*counterLeft 40]);
        videoFrame=insertShape(videoFrame,'Rectangle',[410 80 100*requiredTime 40],'Color','blue');
    else
        counterLeft = 0;
    end
    
    %% THE CASE FOR ONLY RIGHT EYE IS CLOSED
    
    if (scoresLeft(idxRight) < thresolhForDetection) && (scoresRight(idxLeft) > thresolhForDetection)
        % Write the confidence score of the right eye detection
        annotation = sprintf('%s , Confidence %4.2f',detector.ModelName,scoresRight(idxRight));
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesRight(idxRight,:),annotation);
        
        if counterRight <= requiredTime
            counterRight = counterRight + 1;
        end
        
        text = ['Elapsed Time With Right Eye Is Closed:',num2str(counterRight),'/5 s'];
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 20],text, 'FontSize',32);
        videoFrame=insertShape(videoFrame,'FilledRectangle',[410 80 100*counterRight 40]);
        videoFrame=insertShape(videoFrame,'Rectangle',[410 80 100*requiredTime 40],'Color','blue');
    else
        counterRight = 0;
    end
    
    
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    
    % Go to the third bowl
    if counterBoth == requiredTimeForBoth
        % Write that system will go the the first bowl
        text = 'System will go to the third bowl!';
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 500],text, 'FontSize',32);
        
        % Display the annotated video frame using the video player object.
        step(videoPlayer, videoFrame);
        
        pause(3);
        break;
    end
    
    % Go to the second bowl
    if counterLeft == requiredTime
        % Write that system will go the the first bowl
        text = 'System will go to the second bowl!';
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 500],text, 'FontSize',32);
        
        % Display the annotated video frame using the video player object.
        step(videoPlayer, videoFrame);
        
        pause(3);
        break;
    end
    
    % Go to the first bowl
    if counterLeft == requiredTime
        % Write that system will go the the first bowl
        text = 'System will go to the first bowl!';
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 500],text, 'FontSize',32);
        
        % Display the annotated video frame using the video player object.
        step(videoPlayer, videoFrame);
        
        pause(3);
        break;
    end
    
    
    runLoop = isOpen(videoPlayer);
    
    pause(1/freq);
    
end

% Clean up.
clear cam;
delete(findall(0));
release(videoPlayer);




