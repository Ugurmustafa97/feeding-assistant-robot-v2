function [] = setServoSpeed(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_SPEED, DXL_SPEED)
% BU FONKSIYON BIR CIKTI VERMEZ. BES MOTORUN BIRDEN SERVOLARIN HIZINI 
% AYARLAR, EGER BIR HATA MESAJI ALINIRSA BUNUN KOMUT EKRANINA
% YAZILMASINI SAGLAR.

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed

write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_SPEED, typecast(int16(DXL_SPEED), 'uint16'));
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
else
    fprintf('Speed of the [ID:%03d] motor has been successfully changed. \n', DXL_ID);
end

end

