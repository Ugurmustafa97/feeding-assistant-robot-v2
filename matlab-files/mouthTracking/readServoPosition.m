function [servo_position] = readServoPosition(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_PRESENT_POSITION)
% BU FONKSIYON SERVO MOTORUN GUNCEL POZISYON DEGERINI OKUR. EGER BIR HATA
% VARSA KOMUT EKRANINA CIKTI VERIR.

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed

% Read Dynamixel#1 present position
servo_position = read2ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_PRESENT_POSITION);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
end

end

