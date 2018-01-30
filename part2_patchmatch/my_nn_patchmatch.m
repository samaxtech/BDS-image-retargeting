function [ nearest_neighbor ] = my_nn_patchmatch(source,target,patch_R,patch_C,initial_nearest_neighbor)
[RS, CS, ~] = size(source);
[RT, CT, ~] = size(target);
length_R = floor(patch_R/2);
length_C = floor(patch_C/2);
nearest_neighbor = zeros(RT-2*length_R, CT-2*length_C,3);
l_T1=RT-2*length_R;
l_T2=CT-2*length_C;
%Step 1: Initial random nearest-neighbor assignment.
    if size(initial_nearest_neighbor) == 0
        for i = 1:l_T1
            for j = 1:l_T2
                nearest_neighbor(i,j,1) = randi([length_R+1 RS-length_R]);
                nearest_neighbor(i,j,2) = randi([length_C+1 CS-length_C]);
                patch_T = target(i:i-1+patch_R,j:j-1+patch_C,:); 
                patch_S = source(nearest_neighbor(i,j,1)-length_R:nearest_neighbor(i,j,1)+length_R,nearest_neighbor(i,j,2)-length_C:nearest_neighbor(i,j,2)+length_C,:);
                %Performs distance between both S and T patches:
                distance = 0;
                for x = 1:size(patch_S,1)
                    for y = 1:size(patch_S,2)
                        distance = distance + double((patch_S(x,y)-patch_T(x,y))^2);
                    end
                end
                distance = distance/(size(patch_S,1)+size(patch_S,2));                
                %Assigns such distance value to 'nearest_neighbor' matrix:
                nearest_neighbor(i,j,3) = distance;
            end
        end   
    else
         nearest_neighbor = initial_nearest_neighbor;
    end

%Step 2: Improvement of previous neighbor search (propagation):
for i = 1:RT-2*length_R
    for j = 1:CT-2*length_C        
        patch_T = target(i:i-1+patch_R,j:j-1+patch_C,:); 
        %Computes for the pixel above:
        if i > 1 && nearest_neighbor(i-1,j,1)<RS-length_R
            patch_3 = source(nearest_neighbor(i-1,j,1)-length_R+1:nearest_neighbor(i-1,j,1)+length_R+1,nearest_neighbor(i-1,j,2)-length_C:nearest_neighbor(i-1,j,2)+length_C,:);
            %Performs distance between target patch and patch 3:
            distance = 0;
                for x = 1:size(patch_3,1)
                    for y = 1:size(patch_3,2)
                        distance = distance + double((patch_3(x,y)-patch_T(x,y))^2);
                    end
                end
            distance = distance/(size(patch_3,1)+size(patch_3,2)); 
            %Compares such distance and performs assignment to 'nearest_neighbor' matrix.
            if distance < nearest_neighbor(i,j,3)
                nearest_neighbor(i,j,1) = nearest_neighbor(i-1,j,1)+1;
                nearest_neighbor(i,j,2) = nearest_neighbor(i-1,j,2);
                nearest_neighbor(i,j,3) = distance;
            end
        end   
        %Computes for the pixel in the left:
        if j > 1 && nearest_neighbor(i,j-1,2) < CS-length_C
            patch_2 = source(nearest_neighbor(i,j-1,1)-length_R:nearest_neighbor(i,j-1,1)+length_R,nearest_neighbor(i,j-1,2)-length_C+1:nearest_neighbor(i,j-1,2)+length_C+1,:);
            %Performs distance between target patch and patch 2:
            distance = 0;
                for x = 1:size(patch_2,1)
                    for y = 1:size(patch_2,2)
                        distance = distance + double((patch_2(x,y)-patch_T(x,y))^2);
                    end
                end
            distance = distance/(size(patch_2,1)+size(patch_2,2)); 
            %Compares such distance and performs assignment to 'nearest_neighbor' matrix.
            if distance < nearest_neighbor(i,j,3)
                nearest_neighbor(i,j,1) = nearest_neighbor(i,j-1,1);
                nearest_neighbor(i,j,2) = nearest_neighbor(i,j-1,2)+1;
                nearest_neighbor(i,j,3) = distance;
            end
        end   
        %Step 3: Random search:
        nearest_neighbor = random_search(source,target,patch_R,patch_C,nearest_neighbor,i,j);
    end
end

for i = RT-2*length_R:-1:1
    for j = CT-2*length_C:-1:1      
        patch_T = target(i:i-1+patch_R,j:j-1+patch_C,:);           
        %Computes for the pixel below:
        if i < RT-2*length_R && nearest_neighbor(i+1,j,1)-1 > length_R
            patch_3 = source(nearest_neighbor(i+1,j,1)-length_R-1:nearest_neighbor(i+1,j,1)+length_R-1,nearest_neighbor(i+1,j,2)-length_C:nearest_neighbor(i+1,j,2)+length_C,:);          
            %Performs distance between target patch and patch 3:
            distance = 0;
                for x = 1:size(patch_3,1)
                    for y = 1:size(patch_3,2)
                        distance = distance + double((patch_3(x,y)-patch_T(x,y))^2);
                    end
                end
            distance = distance/(size(patch_3,1)+size(patch_3,2));  
            %Compares such distance and performs assignment to 'nearest_neighbor' matrix.
            if distance < nearest_neighbor(i,j,3)
                nearest_neighbor(i,j,1) = nearest_neighbor(i+1,j,1)-1;
                nearest_neighbor(i,j,2) = nearest_neighbor(i+1,j,2);
                nearest_neighbor(i,j,3) = distance;
            end
        end 
        %Computes for the pixel in the right:
        if j < CT-2*length_C && nearest_neighbor(i,j+1,2)-1 > length_C           
            patch_2 = source(nearest_neighbor(i,j+1,1)-length_R:nearest_neighbor(i,j+1,1)+length_R,nearest_neighbor(i,j+1,2)-length_C-1:nearest_neighbor(i,j+1,2)+length_C-1,:);
            %Performs distance between target patch and patch 2:
            distance = 0;
                for x = 1:size(patch_2,1)
                    for y = 1:size(patch_2,2)
                        distance = distance + double((patch_2(x,y)-patch_T(x,y))^2);
                    end
                end
            distance = distance/(size(patch_2,1)+size(patch_2,2)); 
            %Compares such distance and performs assignment to 'nearest_neighbor' matrix.
            if distance < nearest_neighbor(i,j,3)
                nearest_neighbor(i,j,1) = nearest_neighbor(i,j+1,1);
                nearest_neighbor(i,j,2) = nearest_neighbor(i,j+1,2)-1;
                nearest_neighbor(i,j,3) = distance;
            end
        end
        %Step 3: Random search:
        nearest_neighbor = random_search(source,target,patch_R,patch_C,nearest_neighbor,i,j);
    end
end

end