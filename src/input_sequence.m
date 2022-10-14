function [x] = input_sequence(notes, n, fs)
% input_sequence |  Input sequence generator
%   
%
%   INPUT ARGUMENTS:
%       notes       'notes' struct
%       -> freq      note frequencies [Hz]
%       -> init      initial position of each note [samples]
%       -> end       final position of each note [samples]
%       n            length of sequence [samples]
%       fs           sampling frequency [Hz]
%   
%   OUTPUT ARGUMENTS:
%       x           generated sequence
%  
% 
%   Author: jlnkls
%
%   05.05.2017

%% Params

% Minimum amplitude value
min_val = 0;
% Maximum amplitude value
max_val = 1;

%% Init

% Generated sequence
x = zeros(1,n*fs);

%% Generation

for i=1:length(notes.freq)
    
    %% Triangle wave gneneration
    
    % Frequency
    fw = notes.freq(i);
    % Normalized frequency
    delta = fw/fs;
    % Length
    L = notes.end(i)-notes.init(i)+1;
    % Triangle wave
    [t] = triangle_wave(min_val,max_val,delta,L);
    
    %% Fade
    
    % Length
    fade.length = round(0.03*L);
    
    %%% Fade in
    fade.in = linspace(0,1,fade.length);
    t(1:1+fade.length-1) = ...
        t(1:1+fade.length-1) .* fade.in;
        
    %%% Fade out
    fade.out = linspace(1,0,fade.length);
    t(end-fade.length+1:end) = ...
        t(end-fade.length+1:end) .* fade.out;
    
    %%% Final sequence
    x(notes.init(i):notes.end(i)) = t;
    
end

end