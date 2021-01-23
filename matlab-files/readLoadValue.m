function [] = readLoadValue(port_num, PROTOCOL_VERSION, DXL_ID, ADDR)
% BU FONKSIYON MOTORUN LOAD DEGERININ OKUNMASI ICIN OLUSTURULMUSTUR.

COMM_SUCCESS                = 0;            % Communication Success result value

% Read Dynamixel#1 present position
loadValue = read2ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR);

if loadValue <= 1023
    fprintf('The load value of [ID:%03d]:  %03d, in CCW direction.\n', DXL_ID, (loadValue));
else
    fprintf('The load value of [ID:%03d]:  %03d, in CW direction.\n', DXL_ID, (loadValue - 1023));
end

dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);

dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);

if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
end
    
end



