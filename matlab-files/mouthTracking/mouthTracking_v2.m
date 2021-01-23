% Load the detecter file.
load('detectors\yoloMouthDetector.mat');

mouthDetector = detectorYolo2;

% Create the webcam object.
% cam = webcam('Microsoft® LifeCam HD-3000');
% cam.Resolution = '1280x720';
cam = webcam();

% Counters for limit the movement in y-axis.
counterForUp = 0;
counterForDown = 0;

% Capture one frame to get its size.
videoFrame = snapshot(cam);
frameSize = size(videoFrame);

% Vector presents the middle of the frame.
frameMiddle = [frameSize(1,2)/2 , frameSize(1,1)/2];

% Row vectors for lines to show the middle of the frame.
position1 = [0 ,frameSize(1,1)/2 , frameSize(1,2) ,  frameSize(1,1)/2,];
position2 = [frameSize(1,2)/2 , 0 , frameSize(1,2)/2 , frameSize(1,1)];

% Constants for text writing.
position = [frameSize(1,2)-200 20;frameSize(1,2)-200 55];
box_color = {'yellow','yellow'};

bestScore = 200;

while 1
    % Get the next frame.
    videoFrame = snapshot(cam);
    
    % Find the position of the left eye
    [bboxesMouth,scoresMouth, labelMouth] = detect(mouthDetector, videoFrame);
    
    % Select the strongest result
    [~,idxMouth] = max(scoresMouth);
    
    
    if  (scoresMouth(idxMouth) > 0.5)
        % Write the confidence score of the left eye detection
        annotation = sprintf('%s , Confidence %4.2f',mouthDetector.ModelName,mBEST);
        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bboxesMouth(1,:),annotation);
        
        % Find the position of the middle of the mouth.
        bboxPoints = bbox2points(bboxesMouth(1, :));
        middleOfTheMouth = [sum(bboxPoints(:,1))/4 , sum(bboxPoints(:,2)/4)];
        
        % Calculate the delta values.
        deltaVector = middleOfTheMouth - frameMiddle;
        
        % Create the text cell.
        text_str = cell(2,1);
        text_str{1} = ['Delta X: ' num2str(deltaVector(1),'%0.2f')];
        text_str{2} = ['Delta Y: ' num2str(deltaVector(2),'%0.2f')];
        
        % Display delta values in the video player.
        videoFrame = insertText(videoFrame,position,text_str,'FontSize',18,'BoxColor',...
            box_color,'BoxOpacity',0.4,'TextColor','white');
        
        
        % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
        % format required by insertShape.
        bboxPolygon = reshape(bboxPoints', 1, []);
        
        % Display a bounding box around the detected mouth.
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
        
        % Display the middle of the mouth
        videoFrame = insertMarker(videoFrame, middleOfTheMouth, '+', 'Color', 'red');
        
        % Lines for showing the middle of the frame.
        videoFrame = insertShape(videoFrame,'Line',position1,'LineWidth',3);
        videoFrame = insertShape(videoFrame,'Line',position2,'LineWidth',3);
        
        % Create a figure and keep it.
        imshow(videoFrame);
        
        % Thresholds for each axes in pixels.
        thresholdInX = 20; %40
        thresholdInY = 20; %40
        
        if ~isempty(deltaVector)
            fprintf('DeltaX : %.2f\n', deltaVector(1));
            fprintf('DeltaY : %.2f\n', deltaVector(2));
            
            if (deltaVector(1) > thresholdInX) || (deltaVector(1) < -thresholdInX)
                % Read the position of the first servo motor.
                servoPosition1 = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
                
                % Condition for servos are in their limit postion.
                if servoPosition1 <= 5 || servoPosition1 >= 1018
                    fprintf('Servo position is too low or high!');
                    break;
                end
                
                if (deltaVector(1) > thresholdInX)
                    % Motor values should decrease.
                    goalPosition1 = servoPosition1 - 10;
                    
                    % Write new goal position to the first servo
                    write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_GOAL_POSITION, goalPosition1);
                    dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
                    dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
                    if dxl_comm_result ~= COMM_SUCCESS
                        fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
                    elseif dxl_error ~= 0
                        fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
                    else
                        fprintf('Goal position of the motor has been successfully changed. \n');
                    end
                    
                    while 1
                        % Read Dynamixel#1 position
                        servoPosition1 = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
                        
                        % Control loop for position checking.
                        if ~((abs(goalPosition1 - servoPosition1) > DXL_MOVING_STATUS_THRESHOLD))
                            break;
                        end
                    end
                    
                else
                    % Motor values should increase.
                    goalPosition1 = servoPosition1 + 10;
                    
                    % Write new goal position to the first servo
                    write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_GOAL_POSITION, goalPosition1);
                    dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
                    dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
                    if dxl_comm_result ~= COMM_SUCCESS
                        fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
                    elseif dxl_error ~= 0
                        fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
                    else
                        fprintf('Goal position of the motor has been successfully changed. \n');
                    end
                    
                    while 1
                        % Read Dynamixel#1 position
                        servoPosition1 = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
                        
                        % Control loop for position checking.
                        if ~((abs(goalPosition1 - servoPosition1) > DXL_MOVING_STATUS_THRESHOLD))
                            break;
                        end
                    end
                    
                end
                
                fprintf('The system is matched in the x-axis!\n');
                
            else
                
                if (deltaVector(2) > thresholdInY) || (deltaVector(2) < -thresholdInY)
                    % Read the position of the forth servo motor.
                    servoPosition4 = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
                    
                    % Read the position of the fifth servo motor.
                    servoPosition5 = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
                    
                    if counterForUp >= 5 || counterForDown >= 5
                        fprintf('The robot arm has reached the limits!');
                        break;
                    end
                    
                    if (deltaVector(2)) > thresholdInY
                        % The robot arm should move to down
                        % According to the trajectory datas servo4 degree should
                        % increase 12 and servo5 degree should decrease 13.
                        
                        counterForDown = counterForDown + 1;
                        
                        goalPosition4 = servoPosition4 + 12;
                        goalPosition5 = servoPosition5 - 13;

                        %  Write new goal position to the fourth servo
                        write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_GOAL_POSITION, goalPosition4);
                        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
                        dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
                        if dxl_comm_result ~= COMM_SUCCESS
                            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
                        elseif dxl_error ~= 0
                            fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
                        else
                            fprintf('Goal position of the motor has been successfully changed. \n');
                        end
                        
                        % Write new goal position to the fifth servo
                        write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_GOAL_POSITION, goalPosition5);
                        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
                        dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
                        if dxl_comm_result ~= COMM_SUCCESS
                            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
                        elseif dxl_error ~= 0
                            fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
                        else
                            fprintf('Goal position of the motor has been successfully changed. \n');
                        end
                        
                        while 1
                            % Read Dynamixel#1 present position
                            servoPosition4 = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
                            
                            % Read Dynamixel#2 present position
                            servoPosition5 = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
                            
                            % Control to end movement
                            if ~((abs(goalPosition4 - servoPosition4) > DXL_MOVING_STATUS_THRESHOLD) || ...
                                    (abs(goalPosition5 - servoPosition5) > DXL_MOVING_STATUS_THRESHOLD))
                                break;
                            end
                        end
                        
                    else
                        % The robot arm should move to up
                        % According to the trajectory datas servo4 degree should
                        % decrease 15 and servo5 degree should increase 15.
                        
                        courterForUp = counterForUp + 1;
                        
                        goalPosition4 = servoPosition4 - 15;
                        goalPosition5 = servoPosition5 + 15;
                        
                        %  Write new goal position to the fourth servo
                        write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_GOAL_POSITION, goalPosition4);
                        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
                        dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
                        if dxl_comm_result ~= COMM_SUCCESS
                            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
                        elseif dxl_error ~= 0
                            fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
                        else
                            fprintf('Goal position of the motor has been successfully changed. \n');
                        end
                        
                        % Write new goal position to the fifth servo
                        write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_GOAL_POSITION, goalPosition5);
                        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
                        dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
                        if dxl_comm_result ~= COMM_SUCCESS
                            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
                        elseif dxl_error ~= 0
                            fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
                        else
                            fprintf('Goal position of the motor has been successfully changed. \n');
                        end
                        
                        while 1
                            % Read Dynamixel#1 present position
                            servoPosition4 = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
                            
                            % Read Dynamixel#2 present position
                            servoPosition5 = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
                            
                            % Control to end movement
                            if ~((abs(goalPosition4 - servoPosition4) > DXL_MOVING_STATUS_THRESHOLD) || ...
                                    (abs(goalPosition5 - servoPosition5) > DXL_MOVING_STATUS_THRESHOLD))
                                break;
                            end
                        end
                        
                    end
                    
                else
                    fprintf('The system is matched in the y-axis!\n');
                    fprintf('You can eat your food, safely:)\n');
                    break
                end
                
            end
        else
            fprintf('System will look again for the mouth.\n');
        end
        
    end
    pause(0.5);
end
