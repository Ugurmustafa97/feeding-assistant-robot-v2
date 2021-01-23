function [] = addParamerToGroup(group, DXL_ID, parameter, LEN_MX)
% BU FONKSIYON GROUBA YAZILACAK PARAMETREYI VERMEZ. HERHANGI BIR HATA
% ALINMASI DURUMUNDA HATA MESAJINA KOMUT EKRANINA YAZDIRIR.

% Parameters
% group         groups name that parameter will be added.
% DXL_ID        Dynamixel ID that the parameter will be added.
% parameter     parameter that will be added to the group.
% LEN_MX        the byte length of the parameter.

dxl_addparam_result = groupSyncWriteAddParam(group, DXL_ID, parameter, LEN_MX);
if dxl_addparam_result ~= true
    fprintf('[ID:%03d] groupSyncWrite addparam failed', DXL_ID);
    return;
end

end

