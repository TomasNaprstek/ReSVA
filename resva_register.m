function [reg_x,reg_y] = resva_register(frame_data,xpos,ypos)

%Find the x and y resolutions of the frame data
res_x = length(frame_data(1,1,:));
res_y = length(frame_data(1,:,1));

%Initialize the registered position data
reg_x = zeros(length(frame_data(:,1,1)),res_y,res_x);
reg_y = zeros(length(frame_data(:,1,1)),res_y,res_x);
%Assign the GPS positions that we know to the first frame
reg_x(1,:,:) = xpos;
reg_y(1,:,:) = ypos;

%Create the optimizer and metric for the registration
[optimizer, metric] = imregconfig('monomodal'); %Monomodal since the data is from a single sensor
optimizer.GradientMagnitudeTolerance = 1e-4; %Default is 1e-4
optimizer.MinimumStepLength = 1e-5; %Default is 1e-5
optimizer.MaximumStepLength = 0.0625; %Default is 0.0625
optimizer.MaximumIterations = 100; %Default is 100
optimizer.RelaxationFactor = 1e-4; %Default is 0.5

%Create a waitbar to keep track of iteration number
wait_tracker = waitbar(0,['Iteration# 0 of ' sprintf('%5.0f',length(frame_data(:,1,1)))],'Name','Registration');

%Now loop through all frames of data
for i = 2:length(frame_data(:,1,1))
    %Update the waitbar
    waitbar(i/length(frame_data(:,1,1)),wait_tracker,['Iteration# ' sprintf('%5.0f',i) ' of ' sprintf('%5.0f',length(frame_data(:,1,1)))]);
    
    %Create the indices for the fixed and moving frames
    fixN = i-1;
    movN = i;

    %Create the variables holding the fixed and moving frames
    fixedU = reshape(frame_data(fixN,:,:),res_y,res_x);
    movingU = reshape(frame_data(movN,:,:),res_y,res_x);

    %Apply the registration process
    transform_structure = imregtform(movingU, fixedU, 'translation', optimizer, metric);

    %Get the fixed frame's position
    xfix = reshape(reg_x(fixN,:,:),res_y,res_x);
    yfix = reshape(reg_y(fixN,:,:),res_y,res_x);

    %Find the average position change across pixels in the x and y directions
    xcellx = mean(diff(xfix(1,:)));
    xcelly = mean(diff(xfix(:,1)));
    ycellx = mean(diff(yfix(1,:)));
    ycelly = mean(diff(yfix(:,1)));

    %Get the translation amounts from the transform struct
    xpixels = transform_structure.T(3,1);
    ypixels = transform_structure.T(3,2);

    %Calculate the total change in x and y positions
    netx = (xpixels * xcellx) + (ypixels * xcelly);
    nety = (xpixels * ycellx) + (ypixels * ycelly);
    
    %Apply the translations to the original data, giving the registered frame position
    reg_x(i,:,:) = xfix+netx;
    reg_y(i,:,:) = yfix+nety;
end

close(wait_tracker); %Close the waitbar before exiting the function