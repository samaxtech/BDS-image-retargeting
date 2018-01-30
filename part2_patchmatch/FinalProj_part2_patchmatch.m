clear;
clc;
close all;

tic
%%% Declaring parameters for the retargeting
minImgSize = 30;                % lowest scale resolution size for min(w, h)
outSizeFactor = [1, 0.65];		% the ration of output image
numScales = 10;                 % number of scales (distributed logarithmically)

%% Preparing data for the retargeting
image = imread('SimakovFarmer.png');
figure,
imshow(image);
[h, w, ~] = size(image);

targetSize = outSizeFactor .* [h, w];
imageLab = rgb2lab(image); % Convert the source and target Images
imageLab = double(imageLab)/255;
niters = 5;
patch_R = 7;
patch_C = 7;
% Gradual Scaling - iteratively increase the relative resizing scale between the input and
% the output (working in the coarse level).
%% STEP 1 - do the retargeting at the coarsest level

target_w=30;

%Downsample of original image:
down_w=47;
down_h=ceil(targetSize(1)*target_w/targetSize(2));

down_source=uint8(zeros([down_h,down_w,3]));

for i=1:down_h
    for j=1:down_w
        down_R=ceil(i*h/down_h);
        down_C=ceil(j*w/down_w);
        down_source(i,j,:)=image(down_R,down_C,:);
    end
end

%Gradual resizing step by doing the patch search and 
%vote (calling 'search_vote_func.m'):
target=down_source;

for temporal_w=down_w:-1:target_w
    initial_target=imresize(target,[35 temporal_w],'bicubic');
    [target,target2source,source2target]=my_search_and_vote_pm(down_source,initial_target,niters,patch_R,patch_C,[],[]);
end

figure(1)
imshow(target);
title('Step 1');

%% STEP 2 - do resolution refinment 
% (upsample for numScales times to get the desired resolution)
[target_R,target_C]=size(target);
[down_source_R,down_source_C]=size(down_source);

ref_target=target;
S_init=image;
for i=1:numScales
    
    size_T_R=ceil((targetSize(1)-target_R)/numScales*(i)+target_R);
    size_T_C=ceil((targetSize(2)-target_C)/numScales*(i)+target_C);
    T_init=imresize(ref_target,[size_T_R size_T_C]);
    
    size_S_R=ceil((h-down_source_R)/numScales*(i)+down_source_R);
    size_S_C=ceil((w-down_source_C)/numScales*(i)+down_source_C);
    S_init=imresize(S_init,[size_S_R size_S_C]);
    
    [ref_target,target2source,source2target]=my_search_and_vote_pm(S_init,T_init,niters,patch_R,patch_C,[],[]);
    disp(i);
end

figure(2)
imshow(ref_target);
title('Step 2');
%% STEP 3 - do final scale iterations
% (refine the result at the last scale)
[final_output,target2source,source2target]=my_search_and_vote_pm(image,ref_target,niters,patch_R,patch_C,[],[]);

figure(3)
imshow(final_output);
title('Step 3');
toc