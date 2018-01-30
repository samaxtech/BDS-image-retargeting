clear;
clc;
close all;

%%% perform search and vote for resizing image by small amount
image = imread('test_35x47.png');
imageLab = rgb2lab(image); % Convert the source and target Images
imageLab = double(imageLab)/255;

targetSize = [35 46];
target_init = imresize(imageLab, targetSize, 'bicubic');

maxIter = 10;
[target_output, ~, ~] = search_vote_func(imageLab, target_init, maxIter);
figure;imshow(lab2rgb(double(target_output)));
imwrite(lab2rgb(double(target_output)), 'test_35x46.png');   