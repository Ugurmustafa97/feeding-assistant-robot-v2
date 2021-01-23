function [servoPosition] = qTaskToServoPosition(qTask)

% Bu kod initialize_robot.m dosyasindaki initial position degerleri esas
% alinarak yazilmistir. PArcalar?n birbiri ile carpismasi durumunda
% parcalarin montajini ve bu kodu degistiriniz.

% Default values
SERVO_RESOLUTION    = 1023;
SERVO_RANGE_DEGREE  = 300;
SERVO_ORIGIN        = 512;

% Convert radian to degree
qTaskDeg = rad2deg(qTask);

% Convert degree to servo values
qTaskServo = (qTaskDeg * SERVO_RESOLUTION) / SERVO_RANGE_DEGREE;

% Initialize output matrix
servoPosition = zeros(5, length(qTask(1,:)));

% Assign output values
servoPosition(1,:) = (SERVO_ORIGIN - 153) + qTaskServo(1,:);
servoPosition(2,:) = SERVO_ORIGIN - qTaskServo(2,:);
servoPosition(3,:) = SERVO_ORIGIN + qTaskServo(2,:);
servoPosition(4,:) = SERVO_ORIGIN + qTaskServo(3,:);
servoPosition(5,:) = SERVO_ORIGIN + qTaskServo(4,:);

% Round to the closest integer
servoPosition = round(servoPosition);

end

