clc
clear

% % Create VideoReader object
vidReader1 = VideoReader('LeftVideo'); % Replace with your video file path
vidReader2 = VideoReader('RightVideo'); % Replace with your video file path
figure;
frameCounter  = 0;
% Loop through each frame of the video
myArray = zeros(1, 100);
while hasFrame(vidReader1) && hasFrame(vidReader2)
    % Read the current frame
    img = readFrame(vidReader1);
    img = imresize(img, 1/2); % Scale down by a factor of 4
    % Convert the image to HSV color space
     img2 = readFrame(vidReader2);
    img2= imresize(img2, 1/2); % Scale down by a factor of 4
     %[di, sim, peak] = istereo(img, img2, [10, 200], 3);


    % Perform `stdisp` only for every nth frame (e.g., every 5th frame)
    if mod(frameCounter, 35) == 0 && frameCounter > 69
        % Example: Disparity calculation
        [di, sim, peak] = istereo(img, img2, [10, 400], 3);
        % Perform actions with `disparityMap`...
        fprintf('Processing frame %d for disparity\n', frameCounter);
    end
    hsvImg = rgb2hsv(img); % rEADDDDDDD!!!!!

    % Define the HSV thresholds for Green
    lowerGreen = [0.167, 0.25, 0.25];
    upperGreen = [0.389, 1.0, 1.0];

    % Create a mask for Green
    hMaskGreen = (hsvImg(:,:,1) >= lowerGreen(1)) & (hsvImg(:,:,1) <= upperGreen(1));
    sMaskGreen = (hsvImg(:,:,2) >= lowerGreen(2)) & (hsvImg(:,:,2) <= upperGreen(2));
    vMaskGreen = (hsvImg(:,:,3) >= lowerGreen(3)) & (hsvImg(:,:,3) <= upperGreen(3));
    greenMask = hMaskGreen & sMaskGreen & vMaskGreen;

    % Define the HSV thresholds for Red
    lowerRed1 = [0/255, 50/255, 50/255]; % Near 0
    upperRed1 = [15/255, 255/255, 255/255];
    lowerRed2 = [240/255, 50/255, 50/255]; % Near 1
    upperRed2 = [255/255, 255/255, 255/255];

    % Create a mask for Red
    redMask1 = (hsvImg(:,:,1) >= lowerRed1(1)) & (hsvImg(:,:,1) <= upperRed1(1)) & ...
               (hsvImg(:,:,2) >= lowerRed1(2)) & (hsvImg(:,:,2) <= upperRed1(2)) & ...
               (hsvImg(:,:,3) >= lowerRed1(3)) & (hsvImg(:,:,3) <= upperRed1(3));
    redMask2 = (hsvImg(:,:,1) >= lowerRed2(1)) & (hsvImg(:,:,1) <= upperRed2(1)) & ...
               (hsvImg(:,:,2) >= lowerRed2(2)) & (hsvImg(:,:,2) <= upperRed2(2)) & ...
               (hsvImg(:,:,3) >= lowerRed2(3)) & (hsvImg(:,:,3) <= upperRed2(3));
    redMask = redMask1 | redMask2;

    % Define the HSV thresholds for Blue
    lowerBlue = [0.556, 0.25, 0.25];
    upperBlue = [0.708, 1.0, 1.0];
    % Define stronger HSV thresholds for Orange
lowerOrange = [0.05, 0.7, 0.5]; % Lower bound [Hue, Saturation, Value]
upperOrange = [0.12, 1.0, 1.0]; % Upper bound [Hue, Saturation, Value]
    % Create a mask for Blue
    blueMask = (hsvImg(:,:,1) >= lowerBlue(1)) & (hsvImg(:,:,1) <= upperBlue(1)) & ...
               (hsvImg(:,:,2) >= lowerBlue(2)) & (hsvImg(:,:,2) <= upperBlue(2)) & ...
               (hsvImg(:,:,3) >= lowerBlue(3)) & (hsvImg(:,:,3) <= upperBlue(3));

     orangeMask = (hsvImg(:,:,1) >= lowerOrange(1)) & (hsvImg(:,:,1) <= upperOrange(1)) & ...
               (hsvImg(:,:,2) >= lowerOrange(2)) & (hsvImg(:,:,2) <= upperOrange(2)) & ...
               (hsvImg(:,:,3) >= lowerOrange(3)) & (hsvImg(:,:,3) <= upperOrange(3));

    % Combine masks for Green, Red, and Blue
    objectMask = greenMask  | redMask2 | orangeMask;

    % Apply morphological operations to clean the mask
    cleanedMask = imopen(objectMask, strel('disk', 5)); % Remove small noise
    cleanedMask = imclose(cleanedMask, strel('disk', 5)); % Fill gaps

    % Label connected components
    labeledObjects = bwlabel(cleanedMask);

    % Measure properties of connected components (e.g., bounding boxes)
    objectStats = regionprops(labeledObjects, 'BoundingBox', 'Area');

    % Clear the current figure (axes) before displaying the new frame

    % Show the image and keep it active for overlay
    imshow(img);
    hold on;

    % Loop through detected objects and draw bounding boxes
    for i = 1:length(objectStats)
        if objectStats(i).Area > 1500
        % Get the bounding box [x, y, width, height]
        bbox = objectStats(i).BoundingBox;
        x = bbox(1);
        y = bbox(2);
        width = bbox(3);
        height = bbox(4);

        % Calculate the midpoint of the bounding box
        midX = floor(x + width / 2);
        midY = floor(y + height / 2);
        z = 0;
        % Extract region from disparity array (di)
        rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2);
        if frameCounter > 70
            region = di((midY-5):(midY+5), midX);
        % Calculate the average of the region
        disparity = mean(region);
        
        % Example: Disparity calculation
        % Perform actions with `disparityMap`...


         z = (435.6) * 0.166; % Example calibration constan
         z = z / disparity;
		 %Add Here
        % 
        if  y < 500 
             text(x, y - 10, num2str(z), 'Color', 'black', 'FontSize', 12, 'FontWeight', 'bold');
           % z = z + 0.1;
        end  
        
         text(10, 10, num2str(frameCounter), 'Color', 'black', 'FontSize', 12, 'FontWeight', 'bold');

        % if mod(frameCounter, 35) == 0
        %     disp(x)
        %     disp(y)
        % end


        %disp(objectStats(i).Area)
       
    %      frameAnnotated = getframe(gca); % Capture the current figure
    % writeVideo(outputVideo, frameAnnotated.cdata); % Write frame to video
        %disp(objectStats(i));
        % Calculate the depth based on disparity     
    end
    end

    % Pause to match the video's frame rate (optional)
    frameStartTime = tic; % Start a timer

    % Frame reading and processing code here...

    % Calculate elapsed time and adjust pause
    elapsedTime = toc(frameStartTime);
    pauseTime = max(0, (1 / vidReader1.FrameRate) - elapsedTime);
    pause(pauseTime); % Pause to match the frame rate
    frameCounter = frameCounter + 1;
end

close(outputVideo);
disp(['Annotated video saved to ', outputVideoPath]);


% % Output video path
% vidReader2 = VideoReader('left.mp4'); % Replace with your video file path
% vidReader1 = VideoReader('right.mp4'); % Replace with your video file path
% outputPath = 'combined_video.mp4';
% 
% % Create a VideoWriter object for the output video
% outputVideo = VideoWriter(outputPath, 'MPEG-4');
% outputVideo.FrameRate = min(vidReader1 .FrameRate, vidReader2 .FrameRate); % Set frame rate to the lower of the two videos
% open(outputVideo);
% 
% % Create a figure to display the videos
% figure;
% 
% % Read and display frames while both videos have frames
% while hasFrame(vidReader1 ) && hasFrame(vidReader2)
%     frame1 = readFrame(vidReader1); % Read frame from first video
%     frame2 = readFrame(vidReader2); % Read frame from second video
% 
%     % Resize frames to be the same height for alignment (optional)
%     frameHeight = min(size(frame1, 1), size(frame2, 1));
%     frame1 = imresize(frame1, [frameHeight NaN]);
%     frame2 = imresize(frame2, [frameHeight NaN]);
% 
%     % Combine frames side by side
%     combinedFrame = [frame1, frame2];
% 
%     % Display the combined frame
%     imshow(combinedFrame);
%     title('left vs right Stereo');
%     drawnow; % Update the figure window
% 
%     % Write the combined frame to the output video
%     writeVideo(outputVideo, combinedFrame);
% end
% 
% % Close the VideoWriter object
% close(outputVideo);
% disp(['Combined video saved to ', outputPath]);
