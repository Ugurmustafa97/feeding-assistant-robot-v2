function [] = closeProgram(port_num, PROTOCOL_VERSION, DXL_ARRAY, ADDR_MX_TORQUE_ENABLE, lib_name)
%BU FONKSIYON HARKETE DEVAM ETMEK ISTEMEDIGIMIZDE MOTORLARIN DUGUN BIR
%SEKILDE KAPATILMASI ICIN KULLANILIR.

% Disable Dynamixel#1 torque
disableServoTorques(port_num, PROTOCOL_VERSION, DXL_ARRAY(1), ADDR_MX_TORQUE_ENABLE);
% Disable Dynamixel#2 torque
disableServoTorques(port_num, PROTOCOL_VERSION, DXL_ARRAY(2), ADDR_MX_TORQUE_ENABLE);
% Disable Dynamixel#3 torque
disableServoTorques(port_num, PROTOCOL_VERSION, DXL_ARRAY(3), ADDR_MX_TORQUE_ENABLE);
% Disable Dynamixel#4 torque
disableServoTorques(port_num, PROTOCOL_VERSION, DXL_ARRAY(4), ADDR_MX_TORQUE_ENABLE);
% Disable Dynamixel#5 torque
disableServoTorques(port_num, PROTOCOL_VERSION, DXL_ARRAY(5), ADDR_MX_TORQUE_ENABLE);


% Close port
closePort(port_num);

% Unload Library
unloadlibrary(lib_name);

close all;
clear all;
end

