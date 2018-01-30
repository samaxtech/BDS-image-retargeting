function [ nearest_neighbor ] = random_search(source,target,patch_R,patch_C,nearest_neighbor,target_R,target_C)

[RS, CS, ~] = size(source);
length_R = floor(patch_R/2);
length_C = floor(patch_C/2);

%Sets parameters and data for random search operation:
k = 0;
q1 = [nearest_neighbor(target_R,target_C,1) nearest_neighbor(target_R,target_C,2)];
parameter_alpha = 0.5;

patch_T = target(target_R:target_R-1+patch_R,target_C:target_C-1+patch_C,:);
while parameter_alpha^k*RS > patch_R && parameter_alpha^k*CS > patch_C 
    
    %Performs operation by resizing window:
    window = floor([parameter_alpha^k*RS parameter_alpha^k*CS]);
    if k > 0
        upper_edge = 1;
        left_edge = 1;
        off_mid(1) = q1(1)-(floor(window(1)/2)+upper_edge-1);  %Rows adjustment
        while off_mid(1) > 0 && upper_edge < RS-window(1)
            upper_edge = upper_edge + 1;
            off_mid(1) = q1(1)-(floor(window(1)/2)+upper_edge-1);               
        end        
        off_mid(2) = q1(2)-(floor(window(2)/2)+left_edge-1);  %Columns adjustment
        while off_mid(2) > 0 && left_edge < CS-window(2)
            left_edge = left_edge + 1;
            off_mid(2) = q1(2)-(floor(window(2)/2)+left_edge-1); 
        end       
    else
        left_edge = 0;
        upper_edge = 0; 
    end
    
    window_random = [1+length_R+upper_edge window(1)-length_R+upper_edge; 1+length_C+left_edge window(2)-length_C+left_edge];
    R_random = randi([window_random(1,1) window_random(1,2)]);
    C_random = randi([window_random(2,1) window_random(2,2)]);
    patch_random = source(R_random-length_R:R_random+length_R,C_random-length_C:C_random+length_C,:);
    %Performs distance between T patch and previously defined random patch:
    distance = 0;
         for x = 1:size(patch_T,1)
             for y = 1:size(patch_T,2)
                   distance = distance + double((patch_T(x,y)-patch_random(x,y))^2);
             end
         end
    distance = distance/(size(patch_T,1)+size(patch_T,2));  
    %Assigns such distance value to 'nearest_neighbor' matrix:
    if distance < nearest_neighbor(target_R,target_C,3)
        nearest_neighbor(target_R,target_C,1) = R_random;
        nearest_neighbor(target_R,target_C,2) = C_random;
        nearest_neighbor(target_R,target_C,3) = distance;
    end  
    k = k + 1;
end