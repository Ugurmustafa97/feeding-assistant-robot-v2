%% RUN THE THRESHOLD PROGRAM
% determineThereshold

%% PROGRAM

load('.\detectors\yoloDetectorLeft.mat');

leftEyeDetector = detectorYolo2;

load('.\detectors\yoloDetectorRight.mat');

rightEyeDetector = detectorYolo2;

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
thresolhForRightEyeDetection = rightAvarage + 20;
thresolhForLeftEyeDetection  = leftAvarage + 20;

% Best scores for detections.
leftBestScore   = 0;
rigthBestScore  = 0;

% Avarage values
leftAvarage  = 0;
rightAvarage = 0;

% Output value for the program
whichBowlOutput = zeros(1,3);


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
    
    if isempty(scoresLeft(idxLeft))
        leftBestScore = 0;
    else
        leftBestScore = scoresLeft(idxLeft);
    end
    
    display(leftBestScore);
    
    if isempty(scoresRight(idxRight))
        rigthBestScore = 0;
    else
        rigthBestScore = scoresRight(idxRight);
    end
    
    
    display(rigthBestScore);
    
    %% THE CASE FOR BOTH EYES ARE CLOSE
    
    if ( (leftBestScore > thresolhForLeftEyeDetection) && (rigthBestScore > thresolhForRightEyeDetection) )
        % Write the confidence score of the left eye detection
        annotation = sprintf('%s , Confidence %4.2f',leftEyeDetector.ModelName,leftBestScore);
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesLeft(idxLeft,:),annotation);
        
        % Write the confidence score of the right eye detection
        annotation = sprintf('%s , Confidence %4.2f',rightEyeDetector.ModelName,rigthBestScore);
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
    
    if ( (leftBestScore > thresolhForLeftEyeDetection) && (rigthBestScore < thresolhForRightEyeDetection) )
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
    else
        counterLeft = 0;
    end
    
    %% THE CASE FOR ONLY RIGHT EYE IS CLOSED
    
    if ( (leftBestScore < thresolhForLeftEyeDetection) && (rigthBestScore > thresolhForRightEyeDetection) )
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
    else
        counterRight = 0;
    end
    
    
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    
    % Go to the third bowl
    if counterBoth == requiredTimeForBoth
        % The output for chosing the bowl.
        whichBowlOutput = [0 0 1];
        
        % Write that system will go the the first bowl
        text = 'System will go to the third bowl!';
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 500],text, 'FontSize',32);
        
        % Display the annotated video frame using the video player object.
        step(videoPlayer, videoFrame);
      
        % Play the voice
        load('voices\thirdBowlVoiceData.mat');
        sound(data,fs);
        
        pause(3);
        break;
    end
    
    % Go to the second bowl
    if counterLeft == requiredTime
        % The output for chosing the bowl.
        whichBowlOutput = [0 1 0];
        
        % Write that system will go the the first bowl
        text = 'System will go to the second bowl!';
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 500],text, 'FontSize',32);
        
        % Display the annotated video frame using the video player object.
        step(videoPlayer, videoFrame);
        
        % Play the voice
        load('voices\secondBowlVoiceData.mat');
        sound(data, fs);
        
        pause(3);
        break;
    end
    
    % Go to the first bowl
    if counterRight == requiredTime
        % The output for chosing the bowl.
        whichBowlOutput = [1 0 0];
        
        % Write that system will go the the first bowl
        text = 'System will go to the first bowl!';
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 500],text, 'FontSize',32);
        
        % Display the annotated video frame using the video player object.
        step(videoPlayer, videoFrame);
        
        % Play the voice
        load('voices\firstBowlVoiceData.mat');
        sound(data, fs);
        
        pause(3);
        break;
    end
    
    
    runLoop = isOpen(videoPlayer);
    
    pause(1/freq);
    
end

% Clean up.
clear cam;

% delete(findall(0));
release(videoPlayer);

% Clear all thing except whichBowlOutput
clear annotation; clear bbox; clear bboxesLeft; clear bboxesRight;
clear counterBoth; clear counterLeft; clear data; clear detector;
clear faceDetector; clear frameSize; clear freq; clear fs; clear idxLeft;
clear idxRight; clear leftBestScore; clear leftEyeDetector; clear requiredTime;
clear requiredTimeForBoth; clear rightEyeDetector; clear rigthBestScore; 
clear roiForLeftEye; clear roiForRightEye; clear runLoop; clear scoresLeft;
clear scoresRight; clear text; clear thresolhForLeftEyeDetection;
clear thresolhForRightEyeDetection; clear videoFrame; clear videoFrameGray;
clear videoPlayer; clear counterRight;

