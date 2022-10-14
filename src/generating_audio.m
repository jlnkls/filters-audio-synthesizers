%   An insight into Filters in Music Synthesizers
%
%   Synth filters - generating audio output
%
%   Author: jlnkls
%
%   05.05.2017

clc;
clear all;
close all;

%% Input sequence

% Sampling frequency
fs = 44.1e3;
% Sequence length
n = 8;

% Notes -> frequencies
notes.freq = [392, 392, 466.16, 392, 349.23, 311.13, 261.63, 261.63, ...
    261.63, 155.56, 155.56, 174.61, 155.56, 174.61, 196.00, 196.00, ...
    196.00, 196.00];

% Notes -> initial sample positions
notes.init = round([1, 373, 748, 1220, 1471, 1700, 1976, 2326, 2710, ...
    3993, 4375, 4751, 5222, 5479, 5708, 5985, 6320, 6709] .* 10e-4 * fs);

% Notes -> final sample positions
notes.end = round([361, 734, 1207, 1466, 1695, 1957, 2310, 2701, 3988, ...
    4360, 4703, 5201, 5451, 5684, 5978, 6315, 6699, 7985] .* 10e-4 * fs);

% Input sequence
[x] = input_sequence(notes, n, fs);
% Normalization
x = x/max(abs(x));
% Exporting
audiowrite(['../audio/','original.ogg'],x,fs);

%% Filtering

% Filter types
type = {'ladder_transistor'; 'ladder_diode'; 'korg'};

% Cutoff evolutions
cutoff.evolution = {'adsr', 'linear', 'exponential', 'logarithmic'};

% Cutoff frequencies
fc = [20, (fs/2)];

% Resonance
r = [0, 0.1, 0.3, 0.5, 0.7, 0.9, 0.95];
k{1} = 4.*r;
k{2} = [0, 4, 8, 10, 12, 14, 16];
k{3} = 2.*r;

k_vector = cell(1,length(type));

% Resonance indices
resonance.indices = [1, 4, 7];

% Filtering
for i=1:length(type)
    
    % Variable resonance
    k_vector{i} = [linspace(k{i}(1),k{i}(end),round(0.43*length(x))), ...
        k{i}(end)*ones(1, ...
        round(length(x)-(2*round(0.43*length(x))))), ...
        linspace(k{i}(end), k{i}(1), round(0.43*length(x)))];

    for z=1:length(cutoff.evolution)
        
        for q=1:length(resonance.indices)
            
            %%% Fixed k
            
            % Output sequence
            [y] = synth_var_filtering(x, type{i}, fs, fc, ...
                k{i}(resonance.indices(q)), notes, cutoff.evolution{z});
            
            % Normalization
            y = y/(max(abs(y)));
            
            % Exporting
            audiowrite(['../audio/',type{i},'_',cutoff.evolution{z}, ...
                '_k_',num2str(k{i}(resonance.indices(q))), ...
                '_fc_var','.ogg'],y,fs);
            
            %%% Variable k

            % Output sequence
            [y] = synth_var_filtering(x, type{i}, fs, fc, ...
                k_vector{i}, notes, cutoff.evolution{z});
            
            % Normalization
            y = y/(max(abs(y)));
            
            % Exporting
            audiowrite(['../audio/',type{i},'_',cutoff.evolution{z}, ...
                '_k_var', ...
                '_fc_var','.ogg'],y,fs);
            
        end
        
    end
    
end