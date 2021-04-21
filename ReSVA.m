%Remote Sensing Video Alignment (ReSVA)
%Dr. Tomas Naprstek, 2020
%National Research Council Canada

clear;
%Load in frame data. The data should be in the following form:
%frame_data(number of frames,y resolution, x resolution)
%xpos(y resolution, x resolution)
%ypos(y resolution, x resolution)
%Where the xpos and ypos data is the x position and y position data of the
%FIRST frame in the frame data in UTM (Eastings, Northings). Essentially 
%this goes under the assumption that somewhere in the dataset the user is 
%able to get enough GPS information such that every pixel in a frame can be
%assigned a GPS location. This is likely done either through a GPS-tag or 
%using a known feature within the dataset to get educated estimated positions.
load('raw_ir_data.mat'); %The example data contains variables: ir_data, xpos, and ypos.
frame_data = ir_data; %Assign the example ir_data to the generic frame_data variable.

%If no positional information is available, or the user simply does not
%require geographical alignment, then uncomment the below line to use
%the row and column numbers for the xpos and ypos matrices. Note that this
%essentially means that each cell is "1 meter x 1 meter" in size, and
%should be accoutned for in the gridding process.
% [xpos, ypos] = meshgrid(1:length(frame_data(1,1,:)),1:length(frame_data(1,:,1)));

%If the frame data is from a sensor that contains more than 1 channel, the
%data must be "flattened" before registration, or only a single channel
%must be used for the registration. For instance, if using an RGB sensor,
%uncomment the following section to convert to grayscale before
%registering. Afterwards, the gridding function should be run separately 
%for each channel.
%%
% xres = length(frame_data(1,1,:,1));
% yres = length(frame_data(1,:,1,1));
% frame_data_grey = zeros(length(frame_data(:,1,1,1)),yres,xres);
% for i = 1:length(frame_data(:,1,1,1))
%     tempframe = reshape(frame_data(i,:,:,:),yres,xres,3);
%     frame_data_grey(i,:,:) = rgb2gray(tempframe);
% end
%%

%Register the data.
[reg_x,reg_y] = resva_register(frame_data,xpos,ypos);

%Uncomment the section below to see the data before gridding.
%WARNING: if the dataset is large, it may take a long time to plot all data!
%%
% res_x = length(frame_data(1,1,:));
% res_y = length(frame_data(1,:,1));
% figure;
% for i = 1:length(frame_data(:,1,1))
%     xvals = reshape(reg_x(i,:,:),res_y,res_x);
%     yvals = reshape(reg_y(i,:,:),res_y,res_x);
%     vals = reshape(frame_data(i,:,:),res_y,res_x);
%     
%     surf(xvals,yvals,vals,'edgecolor','none');
%     hold on;
% end
% grid on;
% axis equal;
% view([-40 85]);
% xlabel('Eastings (m)');
% ylabel('Northings (m)');
% zlabel('Counts');
% title('Registered Dataset');
% caxis([2050 2150]);
%%

%Set up gridding parameters
cell = 1; %subsample to this cell size (in metres)
%Choose a gridding method:
%   'average' = take the average of all data that falls into each cell.
%   'centerframe' = use only the datapoint whose location was closest to
%   its origin frame's center (this is useful for cameras/sensors that have 
%   an accuracy bias towards the center of the frame data).
gridmethod = 'centerframe';

%Grid the data
[grid_data,grid_x,grid_y] = resva_grid(frame_data,reg_x,reg_y,cell,gridmethod);

%Plot the final gridded dataset
figure;
surf(grid_x,grid_y,grid_data,'edgecolor','none');
grid on;
axis equal;
view([-40 85]);
xlabel('Eastings (m)');
ylabel('Northings (m)');
zlabel('Counts');
title('Gridded Dataset (centerframe)');
caxis([2050 2150]);
h = colorbar;
set(get(h,'label'),'string','Infrared Response (Counts)');
