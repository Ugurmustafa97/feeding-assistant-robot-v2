%% PROGRAM

load('.\detectors\yoloDetectorLeft.mat');

leftEyeDetector = detectorYolo2;

load('.\detectors\yoloDetectorRight01.mat');

rightEyeDetector = detectorYolo2;

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

% Best scores for detections.
leftBestScore   = 0;
rigthBestScore  = 0;

% Output value for the program
whichBowlOutput = zeros(1,3);


while runLoop
    % Get the next frame.
    videoFrame = snapshot(cam);
    
    
    %% SECTION FOR SEARCHING LEFT EYE
    
    % Find the position of the left eye
    [bboxesLeft,scoresLeft, labelsLeft] = detect(leftEyeDetector, videoFrame);
    % Seelect the strongest result
    [~,idxLeft] = max(scoresLeft);
    
    %% SECTION FOR SEARCHING RIGHT EYE
    
    % Find the position of the right eye
    [bboxesRight,scoresRight, labelsRight] = detect(rightEyeDetector, videoFrame);
    % Seelect the strongest result
    [~,idxRight] = max(scoresRight);
    
    %% THE CASE FOR BOTH EYES ARE CLOSE
    
    while (~isempty(labelsLeft(idxLeft))) && (~isempty(labelsRight(idxRight)))
        
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesLeft(idxLeft,:),cellstr(labelsLeft(idxLeft)));
            
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesRight(idxRight,:),cellstr(labelsRight(idxRight)));
        
        
        if ( (labelsLeft(idxLeft) == "leftEyeClosed")  && (labelsRight(idxRight) == "rightEyeClosed") )
            
%             videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesLeft(idxLeft,:),cellstr(labelsLeft(idxLeft)));
            
%             videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesRight(idxRight,:),cellstr(labelsRight(idxRight)));
            
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
        
        if ( (labelsLeft(idxLeft) == "leftEyeClosed")  && (labelsRight(idxRight) == "rightEyeOpened") )
            
%             videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesLeft(idxLeft,:),cellstr(labelsLeft(idxLeft)));
            
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
        
        if ( (labelsLeft(idxLeft) == "leftEyeOpened")  && (labelsRight(idxRight) == "rightEyeClosed") )
            
%             videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesRight(idxRight,:),cellstr(labelsRight(idxRight)));
            
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
        
        break;
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

clear bboxesLeft; clear bboxesRight; clear counterBoth; clear counterLeft;
clear counterRight; clear data; clear detectorYolo2; clear frameSize;
clear freq; clear fs; clear idxLeft; clear idxRight; clear labelsLeft;
clear labelsRight; clear leftBestScore; clear leftEyeDetector; clear requiredTime;
clear requiredTimeForBoth; clear rightEyeDetector; clear rigthBestScore;
clear runLoop; clear scoresLeft; clear scoresRight; clear text; clear videoFrame;
clear videoPlayer;


