function [ nearest_neighbor ] = my_nn_naive(source,target,patch_R,patch_C)

[RS, CS, channels_S] = size(source);
[RT, CT, ~] = size(target);
length_R = floor(patch_R/2);
length_C = floor(patch_C/2);
nn_R=RS-2*length_R;
nn_C=CS-2*length_C;
nearest_neighbor = zeros(nn_R,nn_C,2);

%Define patch size based on function inputs:
patch_S = zeros(patch_R,patch_C);
patch_T = zeros(patch_R,patch_C);

%Naive search for the nearest neighbor implementation (with time complexity of O(n^2)):
for i = 1:nn_R
    for j = 1:nn_C
        nn_patch_pos=zeros(1,2);
        closest_dist=inf;
        for ch = 1:channels_S
            patch_S(:,:) = source(i:i-1+patch_R,j:j-1+patch_C,ch);
            for m = 1:RT-2*length_R
                for n = 1:CT-2*length_C 
                patch_T(:,:) = target(m:m-1+patch_R,n:n-1+patch_C,ch);  
                    %Performs distance between patches in S and T:
                    distance = 0;
                    for x = 1:size(patch_S,1)
                        for y = 1:size(patch_S,2)
                            distance = distance + double((patch_S(x,y)-patch_T(x,y))^2);
                        end
                    end
                    distance = distance/(size(patch_S,1)+size(patch_S,2));     
                %Compares current distance with previous closest distance value:
                if distance < closest_dist
                    closest_dist = distance;
                    nn_patch_pos(1,:) = [m+length_R n+length_C];
                end                  
                end
            end
        end
        
        nearest_neighbor(i,j,:) = nn_patch_pos;
    end
end

end