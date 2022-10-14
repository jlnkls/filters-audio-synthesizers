function [y] = triangle_wave(min_val,max_val,delta,L)
% triangle_wave  |  Generation of triangle wave
%   
%
%   INPUT ARGUMENTS:
%       min_val     Minimum value of the wave
%       max_val     Maximum value of the wave
%       delta       Increase between values
%       L           Length of the wave
%   
%   OUTPUT ARGUMENTS:
%       y           Triangle wave
%  
% 
%   Author: jlnkls
%
%   31.01.2017

%% Frequency of the triangle wave
freq = 1/((length(min_val:delta:max_val)*2));

%% Normalized triangle wave (-1,1)
y = sawtooth(2*pi*freq*(1:L),0.5);

%% Normalized triangle wave (0,1)
y = (y/2) + 0.5;

%% De-normalized triangle wave (min_val, max_val)
y = (y*(max_val-min_val))+(min_val);

end