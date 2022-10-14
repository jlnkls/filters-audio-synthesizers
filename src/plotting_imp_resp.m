%   An insight into Filters in Music Synthesizers
%
%   Synth filters - plotting impulse responses
%
%   Author: jlnkls
%
%   28.04.2017

clc;
clear all;
close all;

%% Params

% Filter types
type = {'ladder_transistor'; 'ladder_diode'; 'korg'};

% Impulse response duration
N = 1;

% Sampling frequency
fs = 44.1e3;

% Input sequence -> impulse (Kronecker's delta)
x = [1; zeros((N*fs)-1,1)];

% Cutoff frequencies
fc = [100, 200, 500, 1e3, 2e3, 4e3, 8e3, 14e3, 16e3, 18e3];

% Resonance
r = [0, 0.1, 0.3, 0.5, 0.7, 0.9, 0.95];
k{1} = 4.*r;
k{2} = [0, 4, 8, 10, 12, 14, 16];
k{3} = 2.*r;

% Colors

colors.k = {[255, 26, 26], ...  % red
    [255, 193, 7], ...          % yellow
    [63, 81, 181], ...          % blue
    [0, 200, 83], ...           % green
    [255, 102, 163]...          % pink
    [0, 179, 161], ...          % turquoise
    [115, 77, 38], ...          % brown
    [156, 39, 176], ...         % purple
    [230, 81, 0], ...           % orange
    [191, 191, 191], ...        % grey
    };

colors.fc = {[255, 26, 26], ...  % red
    [63, 81, 181], ...          % blue
    [0, 200, 83], ...           % green
    [156, 39, 176], ...         % purple
    [58, 158, 158], ...         % grey
    [233, 30, 99]...            % pink
    [255, 193, 7], ...          % yellow
    };

%% Output params

% Names
output.names = {'Transistor ladder filter'; 'Diode ladder filter'; ...
    'Korg filter'};

% Figure indices
output.idx = [1, 2];

% Cutoff - magnitude values
output.cross = [-12, -30.85, -6];

% Legends
output.Legend.fc = cellstr(num2str(fc', '$f_c = %-d \\ Hz$'));

% Axis labels
output.xLabel = '$f \ \left[Hz\right]$';
output.yLabel = '$H\left(f\right) \ \left[dB\right]$';

% Axis limits
output.xLim = [20, 20e3];
output.yLim = [-60, 21];

% Font size
output.FontSize = 16;

% Line width
output.linewidth.line = 5;
output.linewdith.cross = 2;

%% Impulse responses

for z=1:length(type)
    
    %% Figures with fixed k
    
    for i=1:length(fc)
        
        [h] = synth_filtering(x, type{z}, fs, fc(i), 0);
        
        % Plotting
        
        figure(output.idx(1));
        semilogx(0:fs-1,20*log10(abs(fft(h,fs))), ...
            'Color',colors.k{i}/255,'LineWidth',output.linewidth.line);
        xlim(output.xLim);
        ylim(output.yLim);
        hold on;
        hx = plot(fc(i),output.cross(z),'+','Color','black', ...
            'MarkerSize',9,'LineWidth',output.linewdith.cross);
        set(get(get(hx,'Annotation'),'LegendInformation'), ...
            'IconDisplayStyle','off');
        
    end
    
    
    %% Figures with fixed fc
    
    for i=1:length(k{z})
        
        [h] = synth_filtering(x, type{z}, fs, 1e3, k{z}(i));
        
        % Plotting
        
        figure(output.idx(2));
        semilogx(0:fs-1,20*log10(abs(fft(h,fs))), ...
            'Color',colors.fc{i}/255,'LineWidth',output.linewidth.line);
        xlim(output.xLim);
        ylim(output.yLim);
        hold on;
        hx = plot(1e3,output.cross(z),'+','Color','black', ...
            'MarkerSize',9,'LineWidth',output.linewdith.cross);
        set(get(get(hx,'Annotation'),'LegendInformation'), ...
            'IconDisplayStyle','off');
        
    end
    
    %% Output
    
    % Fixed fc
        
    output.fc = strjoin(arrayfun(@(fc) num2str(fc/1e3),fc, ...
        'UniformOutput',false),'-');
    output.fc = strrep(output.fc,'.',',');
    output.fc = ['(',output.fc,')'];
    
    output.name.fc = ['../fig/',type{z},'_fc_fixed'];
    
    output.Title.fc = ['\textbf{',output.names{z}, ...
        ': frequency response for different crossover values} ($k=', ...
        num2str(0),'$)'];
    
    figure(output.idx(1));
    export_fig_pdf(gca, output.name.fc, output.Legend.fc, ...
        output.xLabel, output.yLabel, output.xLim, output.yLim, ...
        output.Title.fc, output.FontSize)
    
    pause(0.5);
    
    % Fixed k
    
    output.Legend.k = cellstr(num2str(k{z}', '$k = %1.1f$'));
    
    output.k = strjoin(arrayfun(@(k) num2str(k),z, ...
        'UniformOutput',false),'-');
    output.k = strrep(output.k,'.',',');
    output.k = ['(',output.k,')'];
    
    output.name.k = ['../fig/',type{z},'_k_fixed'];
    
    output.Title.k = ['\textbf{',output.names{z}, ...
        ': frequency response for different resonance values} ', ...
        '(${f}_{c} = ',num2str(1),' \ kHz$)'];
    
    figure(output.idx(2));
    export_fig_pdf(gca, output.name.k, output.Legend.k, ...
        output.xLabel, output.yLabel, output.xLim, output.yLim, ...
        output.Title.k, output.FontSize)
    
    pause(0.5);
    
    % Update figure indices
    
    output.idx = output.idx+2;
    
end
