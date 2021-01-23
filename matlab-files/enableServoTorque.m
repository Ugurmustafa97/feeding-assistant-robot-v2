function [] = enableServoTorque(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_TORQUE_ENABLE)
% BU FONKSIYON BIR CIKTI VERMEZ. BES MOTORUN BIRDEN TORQLARIN ENABLE HALE
% GETIRILMESINI VE EGER BIR HATA MESAJI ALINIRSA BUNUN KOMUT EKRANINA
% YAZILMASINI SAGLAR.

TORQUE_ENABLE = 1; % Value for enabling the torque

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed

write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_TORQUE_ENABLE, TORQUE_ENABLE);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
else
    fprintf('Dynamixel has been successfully connected \n');
end

end

