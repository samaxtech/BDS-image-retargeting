function [res, ann, bnn] = my_search_and_vote(source, target, niters, m, n, resultFolder, sceneName)
% img: Source image 
% res: Target image (input is initial estimate of target image and output is the target image after seach and vote operation.)
% niters: Number of iterations of search and vote to be performed
% ann: Nearest-Neighbour field (hxwx3, int32) mapping res -> img
% bnn: Nearest-Neighbour field (hxwx3, int32) mapping img -> res
        ann = my_nn_naive(source,target,m,n);
        bnn = my_nn_naive(target,source,m,n);
        res = my_voting_func(source,target,ann,bnn,m,n);
end
