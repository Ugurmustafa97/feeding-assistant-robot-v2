%% CLEARING BEFORE RUNNING
clear all
clc
close all

%% PROGRAM

load('.\detectors\Detector7.mat');

leftEyeDetector = detector;

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

% Counter for the timer
j=0;

% frequency for the image process
freq = 2;


% Time constant for control
requiredTime = 5;        % 5s is required for input

while runLoop 
    % Get the next frame.
    videoFrame = snapshot(cam);
    
    % Convert image to the grayscale
    videoFrameGray = rgb2gray(videoFrame);
    
    % Find the position of the face
    bbox = faceDetector.step(videoFrameGray);

    if ~isempty(bbox) && (((bbox(1) + bbox(3)/2)) < frameSize(2)) && ((bbox(2) + bbox(4)/2) < frameSize(1))
        % Create a region of interest to find mouth.
        roiForLeftEye = [(bbox(1) + bbox(3)/2), bbox(2), bbox(3)/2, bbox(4)/2];
        
    else
        fprintf('Could not find the position of the face. It will be looked again!\n');
        roiForLeftEye = [10, 10, frameSize(1)/2, frameSize(2)/2];
    end

    % Find the position of the mouth
    [bboxes,scores] = detect(leftEyeDetector,videoFrame, roiForLeftEye);
    % Seelect the strongest result
    [~,idx] = max(scores);
    
    %VISUALIZE
    if scores(idx)> 70
        % Write the confidence score of the detection
        annotation = sprintf('%s , Confidence %4.2f',detector.ModelName,scores(idx));
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxes(idx,:),annotation);
        
        if j <= requiredTime
            j=j+1;
        end

        text = ['Elapsed Time With Closed Eye:',num2str(j),'/5 s'];
        
        % Insertation of the time bar.
        videoFrame=insertText(videoFrame,[410 20],text, 'FontSize',32);
        videoFrame=insertShape(videoFrame,'FilledRectangle',[410 80 100*j 40]);
        videoFrame=insertShape(videoFrame,'Rectangle',[410 80 100*requiredTime 40],'Color','blue');

    else
        j=0;
    end

    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    
    if j == requiredTime
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




