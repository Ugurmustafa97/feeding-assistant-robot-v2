function [isTwoServosOk] = checkTwoServosMotion(qServo)
% BU FONKSIYON IKINCI VE UCUNCU MOTOR AYNI JOINTI HARKETE DONDURUYOR. ANCAK
% BIRBIRI ILE TERS KONUMDALAR. BU YUZDEN SAYISAL OLARAK TERS KONUMA
% GIDIYORLAR. BU MOTORLARIN HAREKTININ SISTEME ZARAR VERMEMESI ICIN BOYLE
% BIR KONTROL FONKSIYONU YAZILMISTIR.
 
% The servo positions for the second motor.
secondServo = qServo(2,:);

% The servo positions for the third motor.
thirdServo = qServo(3,:);

% Subtract the origin from second servo positions.
checkSecond = secondServo - 512;

% Subtract third servo positions from origin.
checkThird = 512 - thirdServo;

isTwoServosOk = isequal(checkSecond, checkThird);

end

