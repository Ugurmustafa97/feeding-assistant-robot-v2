function [intervalSpeeds] = calculateIntervalSpeeds(qServo)

% Calculate the differences.
diffServo = diff(qServo');

% Translate it.
diffServo = diffServo';

% Remove negative elements.
diffServo = abs(diffServo);

% Calculate the difference as revolution.
diffServoRev = (diffServo * (300 / 360)) / 1023;

% Scale the the movement in 0.2s to 60s.
diffServoRev = diffServoRev * 300;

% 0.111 rpm equals to 1 in motor. 1023*0.111rpm is max rpm 
intervalSpeeds = diffServoRev / 0.111;

% Round up the interval speeds.
intervalSpeeds = ceil(intervalSpeeds) * 2;

end

