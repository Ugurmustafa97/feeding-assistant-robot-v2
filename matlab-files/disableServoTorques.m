function [] = disableServoTorques(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_TORQUE_ENABLE)
% BU FONKSIYON BIR CIKTI VERMEZ. BES MOTORUN BIRDEN TORQLARIN DISABLE HALE
% GETIRILMESINI VE EGER BIR HATA MESAJI ALINIRSA BUNUN KOMUT EKRANINA
% YAZILMASINI SAGLAR.

TORQUE_DISABLE = 0; % Value for disabling the torque

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed

% Disable Dynamixel Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_TORQUE_ENABLE, TORQUE_DISABLE);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
end

end

