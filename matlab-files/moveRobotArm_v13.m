%% BU KOD ROBOT KOLUN HAREKET ETTIRILMESINI SAGLAR.
% Bu kodda YOLO algoritmasi ile egitilen detektorler kullanilmistir.
%% LOADING THE LIBRARIES

lib_name = '';

if strcmp(computer, 'PCWIN')
    lib_name = 'dxl_x86_c';
elseif strcmp(computer, 'PCWIN64')
    lib_name = 'dxl_x64_c';
elseif strcmp(computer, 'GLNX86')
    lib_name = 'libdxl_x86_c';
elseif strcmp(computer, 'GLNXA64')
    lib_name = 'libdxl_x64_c';
elseif strcmp(computer, 'MACI64')
    lib_name = 'libdxl_mac_c';
end

% Load Libraries
if ~libisloaded(lib_name)
    [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h', 'addheader', 'group_sync_write.h');
end

%% INITIAL SETTINGS FOR MOTORS

% Control table address
ADDR_MX_TORQUE_ENABLE       = 24;           % Control table address is different in Dynamixel model
ADDR_MX_GOAL_POSITION       = 30;
ADDR_MX_PRESENT_POSITION    = 36;
ADDR_SPEED                  = 32;
ADDR_LOAD                   = 40;

% Data Byte Length
LEN_MX_GOAL_POSITION        = 2;
LEN_MX_PRESENT_POSITION     = 2;
LEN_MX_SPEED                = 2;
LEN_LOAD                    = 2;

% Protocol version
PROTOCOL_VERSION            = 1.0;          % See which protocol version is used in the Dynamixel

% Default setting
DXL1_ID                     = 1;            % Dynamixel#1 ID: 1
DXL2_ID                     = 2;            % Dynamixel#2 ID: 2
DXL3_ID                     = 3;            % Dynamixel#2 ID: 3
DXL4_ID                     = 4;            % Dynamixel#4 ID: 4
DXL5_ID                     = 5;            % Dynamixel#5 ID: 5

DXL_ARRAY = [DXL1_ID, DXL2_ID, DXL3_ID, DXL4_ID, DXL5_ID];      %this array created to be used in the closing funcion.

BAUDRATE                    = 1000000;
DEVICENAME                  = 'COM6';       % Check which port is being used on your controller
% ex) Windows: 'COM1'   Linux: '/dev/ttyUSB0' Mac: '/dev/tty.usbserial-*'

DXL_SPEED                   = 50;
DXL_MOVING_STATUS_THRESHOLD = 10;           % Dynamixel moving status threshold

INIT_GLOB                   = 512;

DXL1_INIT_POS               = INIT_GLOB - 460; 
DXL2_INIT_POS               = INIT_GLOB;
DXL3_INIT_POS               = INIT_GLOB;
DXL4_INIT_POS               = INIT_GLOB;
DXL5_INIT_POS               = INIT_GLOB - 307;

%% CONNECTION SETTINGS

ESC_CHARACTER               = 'e';          % Key for escaping loop

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed

% Initialize PortHandler Structs
% Set the port path
% Get methods and members of PortHandlerLinux or PortHandlerWindows
port_num = portHandler(DEVICENAME);

% Initialize PacketHandler Structs
packetHandler();

% Initialize Groupsyncwrite instance for position
group_num_position = groupSyncWrite(port_num, PROTOCOL_VERSION, ADDR_MX_GOAL_POSITION, LEN_MX_GOAL_POSITION);

% Initialize Groupsyncwrite instance for position
group_num_speed = groupSyncWrite(port_num, PROTOCOL_VERSION, ADDR_SPEED, LEN_MX_SPEED);

index = 1;
dxl_comm_result = COMM_TX_FAIL;             % Communication result
dxl_addparam_result = false;                % AddParam result

dxl_error = 0;                              % Dynamixel error

dxl1_present_position = 0;                  % Present positions
dxl2_present_position = 0;
dxl3_present_position = 0;
dxl4_present_position = 0;
dxl5_present_position = 0;

% Open port
if (openPort(port_num))
    fprintf('Succeeded to open the port!\n');
else
    unloadlibrary(lib_name);
    fprintf('Failed to open the port!\n');
    input('Press any key to terminate...\n');
    return;
end

% Set port baudrate
if (setBaudRate(port_num, BAUDRATE))
    fprintf('Succeeded to change the baudrate!\n');
else
    unloadlibrary(lib_name);
    fprintf('Failed to change the baudrate!\n');
    input('Press any key to terminate...\n');
    return;
end

%% ENABLE SERVO TORQUES

% Enable Dynamixel#1 Torque
enableServoTorque(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_TORQUE_ENABLE);
% Enable Dynamixel#2 Torque
enableServoTorque(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_TORQUE_ENABLE);
% Enable Dynamixel#3 Torque
enableServoTorque(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_TORQUE_ENABLE);
% Enable Dynamixel#4 Torque
enableServoTorque(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_TORQUE_ENABLE);
% Enable Dynamixel#5 Torque
enableServoTorque(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_TORQUE_ENABLE);

%% SET INITIAL SPEEDS OF THE SERVOS AND INITIALIZATION OF THE ARM

% Set Dynamixel#1 Speed
setServoSpeed(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_SPEED, DXL_SPEED);
% Set Dynamixel#2 Speed
setServoSpeed(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_SPEED, DXL_SPEED);
% Set Dynamixel#3 Speed
setServoSpeed(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_SPEED, DXL_SPEED);
% Set Dynamixel#4 Speed
setServoSpeed(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_SPEED, (DXL_SPEED * 0.5));
% Set Dynamixel#5 Speed
setServoSpeed(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_SPEED, (DXL_SPEED * 0.5));

tic

% Add Dynamixel#1 position value to the Syncwrite storage
addParamerToGroup(group_num_position, DXL1_ID, DXL1_INIT_POS, LEN_MX_PRESENT_POSITION);

% Add Dynamixel#2 position value to the Syncwrite storage
addParamerToGroup(group_num_position, DXL2_ID, DXL2_INIT_POS, LEN_MX_PRESENT_POSITION);

% Add Dynamixel#3 position value to the Syncwrite storage
addParamerToGroup(group_num_position, DXL3_ID, DXL3_INIT_POS, LEN_MX_PRESENT_POSITION);

% Add Dynamixel#4 position value to the Syncwrite storage
addParamerToGroup(group_num_position, DXL4_ID, DXL4_INIT_POS, LEN_MX_PRESENT_POSITION);

% Add Dynamixel#5 position value to the Syncwrite storage
addParamerToGroup(group_num_position, DXL5_ID, DXL5_INIT_POS, LEN_MX_PRESENT_POSITION);

% Syncwrite goal position
groupSyncWriteTxPacket(group_num_position);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
end

% Clear syncwrite parameter storage
groupSyncWriteClearParam(group_num_position);

while 1
    % Read Dynamixel#1 present position
    dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
    % Read Dynamixel#2 present position
    dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
    % Read Dynamixel#3 present position
    dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
    % Read Dynamixel#4 present position
    dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
    % Read Dynamixel#5 present position
    dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
    
    % This part can be removed or seen for DEBUGGING.
    %fprintf('[ID:%03d] GoalPos:%03d  PresPos:%03d\t[ID:%03d] GoalPos:%03d  PresPos:%03d\t[ID:%03d] GoalPos:%03d  PresPos:%03d\t[ID:%03d] GoalPos:%03d  PresPos:%03d\t[ID:%03d] GoalPos:%03d  PresPos:%03d\n', ...
    %    DXL1_ID, DXL1_INIT_POS, dxl1_present_position, DXL2_ID, DXL2_INIT_POS, dxl2_present_position, ...
    %    DXL3_ID, DXL3_INIT_POS, dxl3_present_position, DXL4_ID, DXL4_INIT_POS, dxl4_present_position, ...
    %    DXL5_ID, DXL5_INIT_POS, dxl5_present_position);
    
    if ~((abs(DXL1_INIT_POS - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
            (abs(DXL2_INIT_POS - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
            (abs(DXL3_INIT_POS - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
            (abs(DXL4_INIT_POS - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
            (abs(DXL5_INIT_POS - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
        break;
    end
    
end

taskTime = toc;
disp(['Move time to the initialization point take : ' num2str(taskTime) ' s']);

%% GENERAL WHILE LOOP
while 1
    %% INITIALIZATION OF THE ROBOT ARM
    
    % Set Dynamixel#1 Speed
    setServoSpeed(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_SPEED, DXL_SPEED);
    % Set Dynamixel#2 Speed
    setServoSpeed(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_SPEED, DXL_SPEED);
    % Set Dynamixel#3 Speed
    setServoSpeed(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_SPEED, DXL_SPEED);
    % Set Dynamixel#4 Speed
    setServoSpeed(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_SPEED, (DXL_SPEED * 0.5));
    % Set Dynamixel#5 Speed
    setServoSpeed(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_SPEED, (DXL_SPEED * 0.5));
    
    % Add Dynamixel#1 position value to the Syncwrite storage
    addParamerToGroup(group_num_position, DXL1_ID, DXL1_INIT_POS, LEN_MX_PRESENT_POSITION);
    % Add Dynamixel#2 position value to the Syncwrite storage
    addParamerToGroup(group_num_position, DXL2_ID, DXL2_INIT_POS, LEN_MX_PRESENT_POSITION);
    % Add Dynamixel#3 position value to the Syncwrite storage
    addParamerToGroup(group_num_position, DXL3_ID, DXL3_INIT_POS, LEN_MX_PRESENT_POSITION);
    % Add Dynamixel#4 position value to the Syncwrite storage
    addParamerToGroup(group_num_position, DXL4_ID, DXL4_INIT_POS, LEN_MX_PRESENT_POSITION);
    % Add Dynamixel#5 position value to the Syncwrite storage
    addParamerToGroup(group_num_position, DXL5_ID, DXL5_INIT_POS, LEN_MX_PRESENT_POSITION);
    
    % Syncwrite goal position
    groupSyncWriteTxPacket(group_num_position);
    dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
    if dxl_comm_result ~= COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
    end
    
    % Clear syncwrite parameter storage
    groupSyncWriteClearParam(group_num_position);
    
    while 1
        % Read Dynamixel#1 present position
        dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
        % Read Dynamixel#2 present position
        dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
        % Read Dynamixel#3 present position
        dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
        % Read Dynamixel#4 present position
        dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
        % Read Dynamixel#5 present position
        dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
        
        % This part can be removed or seen for DEBUGGING.
        %fprintf('[ID:%03d] GoalPos:%03d  PresPos:%03d\t[ID:%03d] GoalPos:%03d  PresPos:%03d\t[ID:%03d] GoalPos:%03d  PresPos:%03d\t[ID:%03d] GoalPos:%03d  PresPos:%03d\t[ID:%03d] GoalPos:%03d  PresPos:%03d\n', ...
        %    DXL1_ID, DXL1_INIT_POS, dxl1_present_position, DXL2_ID, DXL2_INIT_POS, dxl2_present_position, ...
        %    DXL3_ID, DXL3_INIT_POS, dxl3_present_position, DXL4_ID, DXL4_INIT_POS, dxl4_present_position, ...
        %    DXL5_ID, DXL5_INIT_POS, dxl5_present_position);
        
        if ~((abs(DXL1_INIT_POS - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                (abs(DXL2_INIT_POS - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                (abs(DXL3_INIT_POS - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                (abs(DXL4_INIT_POS - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                (abs(DXL5_INIT_POS - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
            break;
        end
        
        % end of reading motor positions
    end
    
    %% EYE-TRACKING SECTION FOR INTERFACE
    pause(2);
    
    tic
    
    run('eyeTrackingDenemeleri\eyeTrackingDetectorYOLO.m');
    
    bowlSelection = decideBowl(whichBowlOutput);
    
    taskTime = toc;
    disp(['Selecting the bowl with eye-tracking take : ' num2str(taskTime) ' s']);
    
    if bowlSelection == 5 % five comes from the function. check it.
        break;
    end
        
    %% FIRST BOWL MOVEMENTS
    
    if bowlSelection == 1
        tic
        %% SECTION FOR INITIALIZATION TO BOWL 
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID,(INIT_GLOB - 153) , LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, DXL2_INIT_POS, LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, DXL3_INIT_POS, LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, DXL4_INIT_POS, LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, INIT_GLOB, LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control to end movement
            if ~((abs((INIT_GLOB - 153) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(DXL2_INIT_POS - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(DXL3_INIT_POS - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(DXL4_INIT_POS - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(INIT_GLOB - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        %% SECTION FOR HOME TO BOWL
        % Load the trajectorty data.
        load('..\datalar\homesToBowls\firstHomeToFirstBowlNew.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTaskNew);
        
        % Calculate the speeds that need to be known.
        qSpeeds = calculateIntervalSpeeds(qServo);
        
        % The first row of the qSpeeds
        qSpeedsFirst = qSpeeds(:,1);
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, qSpeedsFirst(1), LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, qSpeedsFirst(2), LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, qSpeedsFirst(3), LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, qSpeedsFirst(4), LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, qSpeedsFirst(5), LEN_MX_SPEED);
        
        % Syncwrite speed
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, qServo(1,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, qServo(2,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, qServo(3,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, qServo(4,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, qServo(5,end), LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#1
            readLoadValue(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_LOAD)
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#2
            readLoadValue(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_LOAD)
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#3
            readLoadValue(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_LOAD)
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#4
            readLoadValue(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_LOAD)
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#5
            readLoadValue(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_LOAD)
            
            % Control to end movement
            if ~((abs(qServo(1,end) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(2,end) - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(3,end) - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(4,end) - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(5,end) - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        %% SECTION FOR SPOON MOVEMENT
        
        % Load the trajectorty data.
        load('..\datalar\spoonMovement\spoonMovementFirstBowl.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTask);
        
        % Calculate the speeds that need to be known.
        qSpeeds = calculateIntervalSpeeds(qServo);
        
        % The first row of the qSpeeds
        qSpeedsFirst = qSpeeds(:,1);
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, qSpeedsFirst(1), LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, qSpeedsFirst(2), LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, qSpeedsFirst(3), LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, qSpeedsFirst(4), LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, qSpeedsFirst(5), LEN_MX_SPEED);
        
        % Syncwrite speed
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, qServo(1,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, qServo(2,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, qServo(3,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, qServo(4,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, qServo(5,end), LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control to end movement
            if ~((abs(qServo(1,end) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(2,end) - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(3,end) - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(4,end) - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(5,end) - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        %% SECTION FOR BOWL TO HOME
        % Load the trajectorty data.
        load('..\datalar\bowlsToHomes\firstBowlToHomeTry.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTaskNew);
        
        % Calculate the speeds that need to be known.
        qSpeeds = calculateIntervalSpeeds(qServo);
        
        % The first row of the qSpeeds
        qSpeedsFirst = qSpeeds(:,1);
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, qSpeedsFirst(1), LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, qSpeedsFirst(2), LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, qSpeedsFirst(3), LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, qSpeedsFirst(4), LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, qSpeedsFirst(5), LEN_MX_SPEED);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, qServo(1,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, qServo(2,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, qServo(3,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, qServo(4,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, qServo(5,end), LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control to end movement
            if ~((abs(qServo(1,end) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(2,end) - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(3,end) - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(4,end) - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(5,end) - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        %% SECTION FOR HOME TO INTERACTION
        
        % Load the trajectorty data. The end of the data will be same for all
        % of the datas in this section.
        load('..\datalar\homesToInteractionPoint\fromFirstHomeToIP.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTask);
        
        %Take the last element of the data.
        qServoEnd = qServo(1,end);
        
        % Set Dynamixel#1 Speed
        setServoSpeed(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_SPEED, (DXL_SPEED * 1));
        
        % Set the goal position for Dynamixel#1
        write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_GOAL_POSITION, qServoEnd);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        elseif dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
        else
            fprintf('Goal position of the motor has been successfully changed. \n');
        end
        
        while 1
            % Read Dynamixel#1 position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control loop for position checking.
            if ~((abs(qServoEnd - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        taskTime = toc;
        disp(['Move time for the first bowl take : ' num2str(taskTime) ' s']);
        
    %% SECOND BOWL MOVEMENTS    
        
    elseif bowlSelection == 2
        tic
        %% SECTION FROM INITIALIZATION TO BOWL 
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, DXL_SPEED, LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, DXL_SPEED, LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, DXL_SPEED, LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, DXL_SPEED, LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, DXL_SPEED, LEN_MX_SPEED);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, INIT_GLOB, LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, DXL2_INIT_POS, LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, DXL3_INIT_POS, LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, DXL4_INIT_POS, LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, INIT_GLOB, LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control to end movement
            if ~((abs(INIT_GLOB - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(DXL2_INIT_POS - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(DXL3_INIT_POS - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(DXL4_INIT_POS - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(INIT_GLOB - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        
        %% MOVE TO THE BOWL SECTION
        % Load the trajectorty data.
        load('..\datalar\homesToBowls\secondHomeToSecondBowlNew.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTaskNew);
        
        % Calculate the speeds that need to be known.
        qSpeeds = calculateIntervalSpeeds(qServo);
        
        % The first row of the qSpeeds
        qSpeedsFirst = qSpeeds(:,1);
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, qSpeedsFirst(1), LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, qSpeedsFirst(2), LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, qSpeedsFirst(3), LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, qSpeedsFirst(4), LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, qSpeedsFirst(5), LEN_MX_SPEED);
        
        % Syncwrite speed
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, qServo(1,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, qServo(2,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, qServo(3,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, qServo(4,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, qServo(5,end), LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#1
            readLoadValue(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_LOAD)
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#2
            readLoadValue(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_LOAD)
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#3
            readLoadValue(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_LOAD)
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#4
            readLoadValue(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_LOAD)
           
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#5
            readLoadValue(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_LOAD)
            
            % Control to end movement
            if ~((abs(qServo(1,end) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(2,end) - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(3,end) - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(4,end) - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(5,end) - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        %% SPOON MOVEMENT SECTION
        % Load the trajectorty data.
        load('..\datalar\spoonMovement\spoonMovementSecondBowl.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTask);
        
        % Calculate the speeds that need to be known.
        qSpeeds = calculateIntervalSpeeds(qServo);
        
        % The first row of the qSpeeds
        qSpeedsFirst = qSpeeds(:,1);
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, qSpeedsFirst(1), LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, qSpeedsFirst(2), LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, qSpeedsFirst(3), LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, qSpeedsFirst(4), LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, qSpeedsFirst(5), LEN_MX_SPEED);
        
        % Syncwrite speed
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, qServo(1,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, qServo(2,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, qServo(3,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, qServo(4,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, qServo(5,end), LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control to end movement
            if ~((abs(qServo(1,end) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(2,end) - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(3,end) - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(4,end) - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(5,end) - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        %% BOWL TO HOME SECTION
        % Load the trajectorty data.
        load('..\datalar\bowlsToHomes\secondBowlToHomeTry.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTaskNew);
        
        % Calculate the speeds that need to be known.
        qSpeeds = calculateIntervalSpeeds(qServo);
        
        % The first row of the qSpeeds
        qSpeedsFirst = qSpeeds(:,1);
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, qSpeedsFirst(1), LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, qSpeedsFirst(2), LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, qSpeedsFirst(3), LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, qSpeedsFirst(4), LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, qSpeedsFirst(5), LEN_MX_SPEED);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, qServo(1,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, qServo(2,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, qServo(3,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, qServo(4,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, qServo(5,end), LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control to end movement
            if ~((abs(qServo(1,end) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(2,end) - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(3,end) - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(4,end) - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(5,end) - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        %% HOME TO INTERACTION SECTION
        
        % Load the trajectorty data. The end of the data will be same for all
        % of the datas in this section.
        load('..\datalar\homesToInteractionPoint\fromFirstHomeToIP.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTask);
        
        %Take the last element of the data.
        qServoEnd = qServo(1,end);
        
        % Set Dynamixel#1 Speed
        setServoSpeed(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_SPEED, (DXL_SPEED * 1));
        
        % Set the goal position for Dynamixel#1
        write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_GOAL_POSITION, qServoEnd);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        elseif dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
        else
            fprintf('Goal position of the motor has been successfully changed. \n');
        end
        
        while 1
            % Read Dynamixel#1 position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control loop for position checking.
            if ~((abs(qServoEnd - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        taskTime = toc;
        disp(['Move time for the second bowl take : ' num2str(taskTime) ' s']);
        
    %% THIRD BOWL MOVEMENTS    
    elseif bowlSelection == 3
        tic
        %% SECTION FROM INITIALIZATION TO BOWL 
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, DXL_SPEED, LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, DXL_SPEED, LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, DXL_SPEED, LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, DXL_SPEED, LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, DXL_SPEED, LEN_MX_SPEED);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, (INIT_GLOB + 153), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, DXL2_INIT_POS, LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, DXL3_INIT_POS, LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, DXL4_INIT_POS, LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, INIT_GLOB, LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control to end movement
            if ~((abs((INIT_GLOB + 153) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(DXL2_INIT_POS - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(DXL3_INIT_POS - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(DXL4_INIT_POS - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(INIT_GLOB - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        
        %% HOME TO BOWL SECTION
        
        % Load the trajectorty data.
        load('..\datalar\homesToBowls\thirdHomeToThirdBowlNew.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTaskNew);
        
        % Calculate the speeds that need to be known.
        qSpeeds = calculateIntervalSpeeds(qServo);
        
        % The first row of the qSpeeds
        qSpeedsFirst = qSpeeds(:,1);
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, qSpeedsFirst(1), LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, qSpeedsFirst(2), LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, qSpeedsFirst(3), LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, qSpeedsFirst(4), LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, qSpeedsFirst(5), LEN_MX_SPEED);
        
        % Syncwrite speed
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, qServo(1,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, qServo(2,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, qServo(3,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, qServo(4,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, qServo(5,end), LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#1
            readLoadValue(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_LOAD)
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#2
            readLoadValue(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_LOAD)
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#3
            readLoadValue(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_LOAD)
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#4
            readLoadValue(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_LOAD)
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Display torque value of Dynamixel#5
            readLoadValue(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_LOAD)
            
            % Control to end movement
            if ~((abs(qServo(1,end) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(2,end) - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(3,end) - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(4,end) - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(5,end) - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        %% SPOON MOVEMENT SECTION
        
        % Load the trajectorty data.
        load('..\datalar\spoonMovement\spoonMovementThirdBowl.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTask);
        
        % Calculate the speeds that need to be known.
        qSpeeds = calculateIntervalSpeeds(qServo);
        
        % The first row of the qSpeeds
        qSpeedsFirst = qSpeeds(:,1);
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, qSpeedsFirst(1), LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, qSpeedsFirst(2), LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, qSpeedsFirst(3), LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, qSpeedsFirst(4), LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, qSpeedsFirst(5), LEN_MX_SPEED);
        
        % Syncwrite speed
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, qServo(1,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, qServo(2,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, qServo(3,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, qServo(4,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, qServo(5,end), LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control to end movement
            if ~((abs(qServo(1,end) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(2,end) - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(3,end) - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(4,end) - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(5,end) - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        %% BOWL TO HOME SECTION
        
        % Load the trajectorty data.
        load('..\datalar\bowlsToHomes\thirdBowlToHomeTry.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTaskNew);
        
        % Calculate the speeds that need to be known.
        qSpeeds = calculateIntervalSpeeds(qServo);
        
        % The first row of the qSpeeds
        qSpeedsFirst = qSpeeds(:,1);
        
        % Add Dynamixel#1 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL1_ID, qSpeedsFirst(1), LEN_MX_SPEED);
        
        % Add Dynamixel#2 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL2_ID, qSpeedsFirst(2), LEN_MX_SPEED);
        
        % Add Dynamixel#3 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL3_ID, qSpeedsFirst(3), LEN_MX_SPEED);
        
        % Add Dynamixel#4 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL4_ID, qSpeedsFirst(4), LEN_MX_SPEED);
        
        % Add Dynamixel#5 speed value to the Syncwrite storage
        addParamerToGroup(group_num_speed, DXL5_ID, qSpeedsFirst(5), LEN_MX_SPEED);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_speed);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_speed);
        
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL1_ID, qServo(1,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#2 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL2_ID, qServo(2,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#3 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL3_ID, qServo(3,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#4 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL4_ID, qServo(4,end), LEN_MX_GOAL_POSITION);
        
        % Add Dynamixel#5 goal position value to the Syncwrite storage
        addParamerToGroup(group_num_position, DXL5_ID, qServo(5,end), LEN_MX_GOAL_POSITION);
        
        % Syncwrite goal position
        groupSyncWriteTxPacket(group_num_position);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        end
        
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(group_num_position);
        
        while 1
            % Read Dynamixel#1 present position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#2 present position
            dxl2_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#3 present position
            dxl3_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#4 present position
            dxl4_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL4_ID, ADDR_MX_PRESENT_POSITION);
            
            % Read Dynamixel#5 present position
            dxl5_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL5_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control to end movement
            if ~((abs(qServo(1,end) - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(2,end) - dxl2_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(3,end) - dxl3_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(4,end) - dxl4_present_position) > DXL_MOVING_STATUS_THRESHOLD) || ...
                    (abs(qServo(5,end) - dxl5_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        %% HOME TO INTERACTION SECTION
        
        % Load the trajectorty data. The end of the data will be same for all
        % of the datas in this section.
        load('..\datalar\homesToInteractionPoint\fromFirstHomeToIP.mat');
        
        % Convert the data to servo positions.
        qServo = qTaskToServoPosition(qTask);
        
        %Take the last element of the data.
        qServoEnd = qServo(1,end);
        
        % Set Dynamixel#1 Speed
        setServoSpeed(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_SPEED, (DXL_SPEED * 1));
        
        % Set the goal position for Dynamixel#1
        write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_GOAL_POSITION, qServoEnd);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        elseif dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
        else
            fprintf('Goal position of the motor has been successfully changed. \n');
        end
        
        while 1
            % Read Dynamixel#1 position
            dxl1_present_position = readServoPosition(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_MX_PRESENT_POSITION);
            
            % Control loop for position checking.
            if ~((abs(qServoEnd - dxl1_present_position) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        
        taskTime = toc;
        disp(['Move time for the third bowl take : ' num2str(taskTime) ' s']);
    else
        fprintf("You put an invalid input!\n");
        
        % Turn down the servos.
        closeProgram(port_num, PROTOCOL_VERSION, DXL_ARRAY, ADDR_MX_TORQUE_ENABLE, lib_name);
        
        % Close the entire program
        return;
    end
    
    %% MOUTH TRACKING SECTION
    tic
    
    run('mouthTracking\mouthTrackingYOLO.m');
    clear cam;
    
    taskTime = toc;
    disp(['Aligning with the position of the mouth take : ' num2str(taskTime) ' s']);
    
    pause(1);
    
    %% ESCAPE FROM THE LOOP
    if input('Press any key to move the robot the initial position! (or input e to quit!)\n', 's') == ESC_CHARACTER
        break;
    end
        
end

%% CLOSE THE LIBRARIES AND DISABLE THE TORQUES

% Turn down the servos.
closeProgram(port_num, PROTOCOL_VERSION, DXL_ARRAY, ADDR_MX_TORQUE_ENABLE, lib_name);
