function [bowl] = decideBowl(whichBowlOutput)
% This function takes the bowl array and decides the bowl. And checks some
% things for debugging

if sum(whichBowlOutput) == 1
    % For the first bowl
    if whichBowlOutput(1) == 1
        bowl = 1;
    end
    
    % For the second bowl
    if whichBowlOutput(2) == 1
        bowl = 2;
    end
    
    % For the third bowl 
    if whichBowlOutput(3) == 1
        bowl = 3;
    end
    
else
    fprintf('There is something wrong with the eye-tacking output. Please check it!\n');
    bowl = 5; % This is used for debugging.
end

end

