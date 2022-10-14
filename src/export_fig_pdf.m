function [] = export_fig_pdf(chart, name, Legend, xLabel, yLabel, ...
    xLim, yLim, Title, FontSize)
% export_fig_pdf |  Exporting figure as PDF
%
%
%   INPUT ARGUMENTS:
%       chart       chart (figure)
%       name        file name
%       Legend      legend cell array
%       xLabel      xlabel string
%       yLabel      ylabel string
%       xLim        xlim limits
%       yLim        ylim limits
%       Title       title string
%       FontSize    font size
%
%   OUTPUT ARGUMENTS:
%       ~
%
%
%   Author: jlnkls
%
%   28.04.2017

%% Labels
xlabel(xLabel,'Interpreter','LaTeX');
ylabel(yLabel,'Interpreter','LaTeX');

%% Title
title(Title,'Interpreter','LaTeX');

%% Limits
xlim(xLim);
ylim(yLim);

%% Ticks in chart
set(chart,'TickLabelInterpreter','LaTeX')

%% Grids
set(chart,'XMinorGrid','On','YMinorGrid','On');

%% Font size
set(chart,'FontSize',FontSize)

%% Legend
h_leg = legend(Legend,'Location','southwest');
set(h_leg,'Interpreter','LaTeX')
set(h_leg,'FontSize',FontSize);

%% Full screen
set(gcf,'Position',get(0,'Screensize'));

%% Expand Axes to Fill Figure
ax = chart;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%% Specify Figure Size and Page Size
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

%% Print
print(gcf, '-dpdf', [name,'.pdf']);

end