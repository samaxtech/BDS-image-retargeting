function [res, ann, bnn] = my_search_and_vote_pm(source, target, niters, m, n, resultFolder, sceneName)

for k = 1:niters
    if(k==1)
        ann = my_nn_patchmatch(target, source, m,n,[]); 
        bnn = my_nn_patchmatch(source, target, m,n,[]);     
    else
        ann = my_nn_patchmatch(res, source, m,n,ann); 
        bnn = my_nn_patchmatch(source, res, m,n,bnn); 
    end 
    res = double(my_voting_func(source,target, ann, bnn,m,n)); 
end


