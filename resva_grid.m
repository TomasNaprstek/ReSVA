function [grid_data,grid_x,grid_y] = resva_grid(frame_data,reg_x,reg_y,cell,gridmethod)

%Find the x and y resolutions of the frame data
res_x = length(frame_data(1,1,:));
res_y = length(frame_data(1,:,1));

%Find the physical extent of the total dataset
minX = ceil(min(min(min(reg_x(reg_x>0))))); %Ensure we ignore any nonsensical negative values that may exist outside the dataset
minY = ceil(min(min(min(reg_y(reg_y>0))))); %Ensure we ignore any nonsensical negative values that may exist outside the dataset
maxX = ceil(max(max(max(reg_x))));
maxY = ceil(max(max(max(reg_y))));

%Now use the extent and the user-defined cellsize to determine the total
%number of cells in the x and y directions.
lengthX = ceil((maxX - minX) / cell)+1;
lengthY = ceil((maxY - minY) / cell)+1;
%Create matrices containing the positions 
[grid_y, grid_x] = meshgrid(minY:lengthY+minY-1,minX:lengthX+minX-1);

%Create temporary matrices for the values and associated flags
tempV = zeros(lengthX,lengthY);
tempF = zeros(lengthX,lengthY);
switch gridmethod
    case 'centerframe'
        tempF(:,:) = 999999; %Set all flags to a dummy variable for initialization
end

%Create a waitbar to keep track of iteration number
wait_tracker = waitbar(0,['Iteration# 0 of ' sprintf('%5.0f',length(frame_data(:,1,1)))],'Name','Gridding');

%Now loop through all frames of data.
for i = 1:length(frame_data(:,1,1))
    %Update the waitbar
    waitbar(i/length(frame_data(:,1,1)),wait_tracker,['Iteration# ' sprintf('%5.0f',i) ' of ' sprintf('%5.0f',length(frame_data(:,1,1)))]);
    
    %Loop through all pixels of each frame
    for j = 1:res_y
        for k = 1:res_x
            %First calculate where this pixel falls in the total dataset meshgrid
            xPos = floor(abs(reg_x(i,j,k) - minX) / cell) + 1;
            yPos = floor(abs(reg_y(i,j,k) - minY) / cell) + 1;
            
            %Now we complete the calculation depending on what gridding
            %method was chosen by the user.
            switch gridmethod
                case 'average'
                    vals = frame_data(i,j,k);
                    tempV(xPos,yPos) = tempV(xPos,yPos) + vals;
                    tempF(xPos,yPos) = tempF(xPos,yPos) + 1;
                case 'centerframe'
                    %We only want to grab the frame whose center is closest to the cell.
                    xdis = grid_x(xPos,yPos) - reg_x(i,res_y/2,res_x/2);
                    ydis = grid_y(xPos,yPos) - reg_y(i,res_y/2,res_x/2);
                    rdis = sqrt((xdis^2) + (ydis^2));

                    %if the distance is smaller than any currently saved
                    if rdis < tempF(xPos,yPos)
                        tempF(xPos,yPos) = rdis;
                        vals = frame_data(i,j,k);
                        tempV(xPos,yPos) = vals;
                    end
                otherwise
                    error('Invalid gridding method chosen!');
            end
            
        end
    end
end
close(wait_tracker); %Close the waitbar

%Now return the grid_data variable
switch gridmethod
    case 'average'
        %Take the average of the combined cell data. Note that this will
        %inherently set all cells outside of the dataset to NaN (i.e.
        %divided by 0).
        grid_data = tempV./tempF; 
    case 'centerframe'
        tempV(tempF == 999999) = NaN; %Manually set all cells outside of the dataset to NaN
        grid_data = tempV;
    otherwise
        error('Invalid gridding method chosen!');
end