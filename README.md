## Motivation
Ball Tracking is a modern technology that has taken the world of sports by storm.  Various sports including tennis,cricket and table tennis employ ball tracking and path prediction techniques to enhance the viewing experience and improving the quality of the game as well as assisting referees to make decisions. This project uses MATLAB to acquire the images of a moving table tennis ball and tracks the ball’s path for the specified time and predicts its future path in light of its recent trajectory.

## The Nitty-Gritty
### a)	Image Acquisition:
Image Acquisition was done by taking 10 consecutive frames for the video feed  of the webcam

### b)	Ball Segmentation:
Ball was segmented from the image by first removing the parts of image where the Red, Green and Blue components are all greater than a certain threshold limit which removes the parts with gray and black shades. 
The Red component of this image is then separated and morphological operations ensure that the only object left in the image is the ball. The image is converted to binary and the centre of the ball is detected. 

### c)	Path Finding:
The vector containing the centres of ball in the acquired frames gives a crude idea of the trajectory followed by the ball. This is further enhanced by applying Kalman Filtering techniques to the set of data points.
For Kalman Filtering,  a constant velocity model is assumed
Equation of motion:  Xk(n) = Xk(n-1) + Vk(n-1) * dt
State Transition Model : [1 dt; 0 1]
Observation Model: [1 0]
Covariance of Process Noise: [0 0; 0 0]
Covariance of Measurement Noise: [sigma_meas^2]

### d)	Path Prediction:
The future path of the ball is predicted by considering the last two points of the observation instead of the whole data set. This is so because unlike traditional data sets, the trajectory of the ball in a sport keeps changing drastically so to fit a curve inside it’s data points is inefficient as well as inaccurate. 
As an example, suppose the trajectory of a cricket ball when it is bowled to the batsman. The ball bounces and then reaches the batsman. If the whole set data points are considered, the predicted value will be way off target but I the data points after the ball is pitched are considered, they will give a fairly accurate estimate of the future trajectory.

## Screenshots
<p align="center">
<img src="http://s7.postimg.org/izxi2bojf/Screen_Shot_2014_11_19_at_4_04_27_AM.png" />
</p>
