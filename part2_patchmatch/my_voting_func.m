function [ pixel_values_matrix ] = my_voting_func( source,target,ann,bnn,patch_R,patch_C)
[RS, CS, channels_S] = size(source);
[RT, CT, channels_T] = size(target);
length_R = floor(patch_R/2);
length_C = floor(patch_C/2);
pixel_values_matrix = zeros(RT,CT,channels_T);

%Set number of patches in both S and T:
l_S1=RS-2*length_R-1;
l_S2=CS-2*length_C-1;
l_T1=RT-2*length_R-1;
l_T2=CT-2*length_C-1;
num_patches_S = (l_S1)*(l_S2);
num_patches_T = (l_T1)*(l_T2);

%Prepare data for completeness term:
completeness = zeros(RT, CT, channels_T);
completeness_nor = zeros(RT, CT, channels_T);
%Prepare data for coherence term:
coherence = zeros(RT, CT, channels_T);
coherence_nor = zeros(RT, CT, channels_T);

%Completeness (how much information of S there is in T):
for channel = 1:channels_S
    for m = length_R+1:RS-length_R     
        for n = length_C+1:CS-length_C
            patch = double(source(m-length_R:m+length_R,n-length_C:n+length_C,channel));
            patch_T = [ann(m-length_R,n-length_C,1) ann(m-length_R,n-length_C,2)];
            for i = 1:patch_R
                for j = 1:patch_C
                    completeness(patch_T(1)-length_R+i-1,patch_T(2)-length_C+j-1,channel) = completeness(patch_T(1)-length_R+i-1,patch_T(2)-length_C+j-1,channel) + patch(i,j);
                    completeness_nor(patch_T(1)-length_R+i-1,patch_T(2)-length_C+j-1,channel) = completeness_nor(patch_T(1)-length_R+i-1,patch_T(2)-length_C+j-1,channel)+1;
                end
            end
        end
    end
end

%Coherence (how much information in T there is in S):
for channel = 1:channels_T
    for m = 1:RT-2*length_R
        for n = 1:CT-2*length_C
            patch = double(source(bnn(m,n,1)-length_R:bnn(m,n,1)+length_R,bnn(m,n,2)-length_C:bnn(m,n,2)+length_C,channel));
            for i = 1:patch_R
                for j = 1:patch_C
                    coherence(m+i-1,n+j-1,channel) = coherence(m+i-1,n+j-1,channel)+ patch(i,j);
                    coherence_nor(m+i-1,n+j-1,channel) = coherence_nor(m+i-1,n+j-1,channel)+1;
                end
            end
        end
    end
end


%Based on the equation shown in Simakov et al. CVPR’08, to find the unknown 
%pixel value for the voting operation, we compute:
for channel = 1:channels_T
    for m = 1:RT
        for n = 1:CT
            num=1/num_patches_S*completeness(m,n,channel)+1/num_patches_T*coherence(m,n,channel);
            den=(completeness_nor(m,n,channel)/num_patches_S)+(coherence_nor(m,n,channel)/num_patches_T);
            pixel_values_matrix(m,n,channel) = (num)/(den);
        end
    end
end
pixel_values_matrix = uint8(pixel_values_matrix);
end

