clc % Clear command window 
close all % Close all open windows
vid=videoinput('winvideo',1,'YUY2_640x480'); %Video input object
start(vid) % Start video
data = getdata(vid,10); % Get 10 frames from live video feed
delete(vid); % Delete video object

%%
figure
centres_x = []; % Initialize vector to store the x-coordinates of ball
centres_y = []; % Intialize vectot to store the y-coordinates of ball

for k = 1:10    % Loop 10 times as Number of frames captures = 10
    tic
    Im = ycbcr2rgb(data(:,:,:,k)); %Convert the kth frame to RGB format 
    Imorg = Im; % Backup the RGB image
    
    % Segmentaion Started
    for i = 1:size(Im,1)       % Loop through the rows of image
        for j = 1:size(Im,2)   % Loop through the cols of image
            if (Im(i,j,1) >= 0.5 && Im(i,j,2) >= 0.5 && Im(i,j,3) >= 0.5) % Remove all parts of image containing shades of gray and white, keep only distinct colors
                Im(i,j,1) = 0;
                Im(i,j,2) = 0;
                Im(i,j,3) = 0;
            end
        end
    end

    %figure 
    subplot(2,5,k) % plot original image in a subplot window
    imshow(Im);   
    hold on
    
    Im = im2double(Im); % Convert image to double
    imR = squeeze(Im(:,:,1)); % Extract the red part of image
    imBinaryR = im2bw(imR,graythresh(imR)); %Convert red part to binary
    imBinaryR = bwareaopen(imBinaryR,20); % Remove areas less than 20 pixels
    imBinaryR = imfill(imBinaryR,'holes'); % Remove holes in the binary image

    [B,L] = bwboundaries(imBinaryR,'noholes'); % Extract the distinct regions in the image
    numRegions = max(L(:)); % Number of distinct regions (ideally 1)
    
    if (numRegions > 0) % If number of regions is greater than zero (i.e. atleast 1 object is detected)
        stats = regionprops(L,'all'); % Get stats for the objects in the image
        centre = stats.Centroid % Get the struct for centre of the ball
        centres_x(k) = centre(1); % Store x - coordinate of the center
        centres_y(k) = centre(2); % Store y - coordinate of the center
    else
        centres_x(k) = centres_x(k-1); % If ball not detected, keep previous value
        centres_y(k) = centres_y(k-1);
    end
    
    plot (centre(1),centre(2),'*'); % Plot the centre of the subplot of the image
    hold off
    elapsed_time =toc
    
end







