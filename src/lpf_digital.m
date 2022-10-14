%   An insight into Filters in Music Synthesizers
%
%   LPF: Digital Frequency Response
%
%   Author: jlnkls
%
%   28.04.2017

clc;
clear all;
close all;

%% Params

% Sampling period
fs = 44.1e3;
Ts = 1/fs;
% Evaluation points
n = fs*16;
% Cutoff frequencies
fc = [100, 200, 500, 1e3, 2e3, 5e3];
omega = (2*pi).*fc;
% Legend
colors = {[255, 26, 26], ...    % red
    [230, 230, 0], ...          % yellow
    [63, 81, 181], ...          % blue
    [0, 200, 83], ...           % green
    [233, 30, 99]...            % pink
    [230, 81, 0], ...           % orange
    };
legendCell = cellstr(num2str(fc', '$f_c = %-d \\ Hz$'));
% Line width
linewidth.line = 5;
linewidth.cross = 2;

%% Init

b_tf = cell(1,length(omega));
a_tf = cell(1,length(omega));

G = cell(1,length(omega));
freq = cell(1,length(omega));

%% Generation of G(z)

for i=1:length(omega)
    
    % Antitransformed pulsation
    omega_hat = (2/Ts) * tan((omega(i)*Ts)/2);
    
    % Parameters
    b0 = ( (Ts*omega_hat) / ((Ts*omega_hat)+2) );
    a1 = ( ((Ts*omega_hat)-2) / ((Ts*omega_hat)+2) );
    
    % Transfer function
    b_tf{i} = b0*[1,1];
    a_tf{i} = [1,a1];
    
    [G{i}, freq{i}] = freqz(b_tf{i},a_tf{i},n,fs);
    
    % Plots
    figure(1);
    semilogx(freq{i},20*log10(abs(G{i})),'Color',colors{i}/255, ...
        'LineWidth',linewidth.line);
    xlim([20 20e3]);
    ylim([-60 10]);
    hold on;
    fnd = find(freq{i}==fc(i));
    hx = plot(fc(i),20*log10(abs(G{i}(fnd))),'+','Color','black', ...
        'MarkerSize',9,'LineWidth',linewidth.cross);
    set(get(get(hx,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','off');
    hold on;
    
end

%% Plotting

% Labels
figure(1);
xlabel('$f \ \left[Hz\right]$','Interpreter','LaTeX');
ylabel('$G\left(f\right) \ \left[dB\right]$','Interpreter','LaTeX');
title('\textbf{1-pole digital LPF: Frequency response}','Interpreter','LaTeX');
set(gca,'TickLabelInterpreter','LaTeX')
set(gca,'XMinorGrid','On','YMinorGrid','On');
set(gca,'FontSize',16)
h_leg = legend(legendCell,'Location','southwest');
set(h_leg,'Interpreter','LaTeX')
set(h_leg,'FontSize',20);

% Full screen
set(gcf,'Position',get(0,'Screensize'));

% Expand Axes to Fill Figure
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

% Specify Figure Size and Page Size
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

% Print
print(gcf, '-dpdf', '../fig/lpf_digital.pdf');