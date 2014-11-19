clc % Clear command window 
close all % Close all open windows
vid=videoinput('winvideo',1,'YUY2_640x480'); %Video input object
start(vid) % Start video
data = getdata(vid,10); % Get 10 frames from live video feed
delete(vid); % Delete video object
 
figure
centres_x = []; % Initialize vector to store the x-coordinates of ball
centres_y = []; % Intialize vectot to store the y-coordinates of ball
 
for k = 1:10    % Loop 10 times as Number of frames captures = 10
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
    imshow(Imorg);   
    hold on
    
    Im = im2double(Im); % Convert image to double
    imR = squeeze(Im(:,:,1)); % Extract the red part of image
    imBinaryR = im2bw(imR,graythresh(imR)); %Convert red part to binary
    imBinaryR = bwareaopen(imBinaryR,20); % Remove areas less than 20 pixels
    imBinaryR = imfill(imBinaryR,'holes'); % Remove holes in the binary image
 
    [B,L] = bwboundaries(imBinaryR,'noholes'); % Extract the distinct regions in the image
    numRegions = max(L(:)) % Number of distinct regions (ideally 1)
    
    if (numRegions > 0) % If number of regions is greater than zero (i.e. atleast 1 object is detected)
        stats = regionprops(L,'all'); % Get stats for the objects in the image
        centre = stats.Centroid; % Get the struct for centre of the ball
        centres_x(k) = centre(1); % Store x - coordinate of the center
        centres_y(k) = centre(2); % Store y - coordinate of the center
    else
        centres_x(k) = centres_x(k-1); % If ball not detected, keep previous value
        centres_y(k) = centres_y(k-1);
    end
    
    plot (centre(1),centre(2),'*'); % Plot the centre of the subplot of the image
    hold off
    
    
end
 
 
%%%%%%%%%%% Kalman Filtering For X - Coordinates %%%%%%%%%%%
Nsamples=10; % Number of frames
dt = 1; % Step size
 
Xinitial = centres_x(1); % Initial X Coordinate Value of Ball
Xtrue = centres_x; % Vector for measured values
Xk_prev = [Xinitial; 0]; % Matrix for previous state
 
Xk=[]; % Matrix for current state
 
Phi = [1 dt; 0  1]; % Motion equation
 
sigma_model = 1; % Error matrix P
P = [sigma_model^2             0; 0 sigma_model^2];
 
Q = [0 0; 0 0]; %Process Noise covariance
 
M = [1 0]; % Measurement matrix
 
sigma_meas = 1; 
R = sigma_meas^2; % Measurement Noise Covariance
 
 
% Buffers for later display
Xk_buffer = zeros(2,Nsamples+1); % Vector to store kalman filtered values
Xk_buffer(:,1) = Xk_prev; % Intialize vector with initial value
 
for k=1:Nsamples
    
    
    Xest = Xtrue(k);
    
    % Kalman iteration
    P1 = Phi*P*Phi' + Q;
    S = M*P1*M' + R;
    K = P1*M'*inv(S); % K is Kalman gain. If K is large, more weight goes to the measurement.
    P = P1 - K*M*P1;
   
    Xk = Phi*Xk_prev + K*(Xest-M*Phi*Xk_prev);
    Xk_buffer(:,k+1) = Xk;
    
    % For the next iteration
    Xk_prev = Xk; 
end;
 
%%%%%% Xk_buffer contains the smoothed value of x corrdinates %%%%%%%%%% 
 
%%%%%%%%%%% Kalman Filtering For Y - Coordinates %%%%%%%%%%%
Nsamples=10;
dt = 1;
 
Yinitial = centres_y(1); % Initial X Coordinate Value of Ball
Ytrue = centres_y; % Vector for measured values
Yk_prev = [Yinitial; 0]; 
 
Yk=[]; % Current value estimate
 
Phi = [1 dt; 0  1];
 
sigma_model = 1;
P = [sigma_model^2             0; 0 sigma_model^2];
 
Q = [0 0; 0 0];
 
M = [1 0]; 
 
sigma_meas = 1; 
R = sigma_meas^2; 
 
 
 
Yk_buffer = zeros(2,Nsamples+1);
Yk_buffer(:,1) = Yk_prev;
 
for k=1:Nsamples
    
    
    Yest = Ytrue(k);
    
    
    P1 = Phi*P*Phi' + Q;
    S = M*P1*M' + R;
    
    K = P1*M'*inv(S);
    P = P1 - K*M*P1;
    
    Yk = Phi*Yk_prev + K*(Yest-M*Phi*Yk_prev);
    Yk_buffer(:,k+1) = Yk;
    
    
    Yk_prev = Yk; 
end;
 
%%%%%% Yk_buffer contains the smoothed value of y corrdinates %%%%%%%%%% 
 
 
%%
pointer = length(centres_x) % Number of measurements
 
slope_x = (centres_x(pointer)-centres_x(pointer-1)) % Slope (difference) b/w last 2 x coordinates
slope_y = (centres_y(pointer)-centres_y(pointer-1)) % Slope (difference) b/w last 2 y coordinates
 
Xk_extra(1) = centres_x(1,end)+slope_x; % Calculate 1st projected value
Yk_extra(1) = centres_y(1,end)+slope_y;
 
 
 
for n = 2:12 % Calculate next 11 projected values
    Xk_extra(n) = Xk_extra(n-1)+slope_x; 
    Yk_extra(n) = Yk_extra(n-1)+slope_y;
    
end
 
figure;
imshow(Imorg)
whitebg([0 0 0])
hold on;
plot(centres_x,centres_y,'g.-','LineWidth',5); % Plot the measured values
plot(Xk_buffer(1,:),Yk_buffer(1,:),'c.'); % Plot Kalman FIltered Values
plot(Xk_extra,Yk_extra,'m+-','LineWidth',5); % Plot Extrapolated (Projected) Values
title('Position estimation results');
xlabel('X - Coordinates');
ylabel('Y - Coordinates');
legend('Measured Trajectory of the Ball','Kalman Filtered Trajectory of the Ball','Projected Path');
