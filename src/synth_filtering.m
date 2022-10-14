function [y] = synth_filtering(x, type, fs, fc, k)
% synth_filtering |  Synthesizer filtering
%   
%
%   INPUT ARGUMENTS:
%       x           input
%       type        synthesizer type
%                   -> 'ladder_transistor'
%                   -> 'ladder_diode'
%                   -> 'korg'
%       fs          sampling frequency [Hz]
%       fc          cutoff frequency [Hz]
%       k           resonance value
%   
%   OUTPUT ARGUMENTS:
%       y           output response
%  
% 
%   Author: jlnkls
%
%   28.04.2017

%% Params

% Sampling period
Ts = 1/fs;
% Cutoff frequency
omega = (2*pi).*fc;

%%% Synth type
if (strcmp(type,'ladder_transistor'))
    
    % Number of poles
    poles = 4;
    
    % Vector range
    vector.range = 1;
    
    % Matrix A
    A = [ -1, 0, 0, -k; ...
        1, -1, 0, 0; ...
        0, 1, -1, 0; ...
        0, 0, 1, -1];
    
    % Matrix B
    B = eye(poles);
    
elseif (strcmp(type,'ladder_diode'))
    
    % Number of poles
    poles = 4;
    
    % Vector range
    vector.range = 1;
    
    % Matrix A
    A = [ -1, 1, 0, -k; ...
        1/2, -1, 1/2, 0; ...
        0, 1/2, -1, 1/2; ...
        0, 0, 1/2, -1];
    
    % Matrix B
    B = eye(poles);
    
elseif (strcmp(type,'korg'))
    
    % Number of poles
    poles = 2;
    
    % Vector range
    vector.range = (1:poles);
    
    % Matrix A
    A = [ -1, -k; ...
        1, (k-1)];
    
    % Matrix B
    B = [1, 0; ...
        0, 0];
    
else
    
    disp ('Not a valid type');
    disp ('Please input one of the following:');
    disp('-> ladder_transistor');
    disp('-> ladder_diode');
    disp('-> korg');
    
    return;
    
end

% Vector
vector.value = zeros(poles,1);

%% Filter

% Antitransformed cutoff pulsation
omega_hat = (2/Ts)*tan(omega*Ts/2);

%% Init

% Output
y = zeros(size(x));

% Output vector
u_in_prev = zeros(poles,1);
% Input - previous sample
x_i_prev = 0;


%% Filtering

for n=1:length(x)
    
    % Terms
    term{1} = (eye(poles)-(omega_hat*Ts*A/2));
    term{2} = (eye(poles)+(omega_hat*Ts*A/2));
    term{3} = (omega_hat*Ts/2);
    
    % Vector
    vector.value(vector.range) = x(n)+x_i_prev;
    
    if (strcmp(type,'korg'))
        vector.value(2) = vector.value(1);
    end
    
    % Output vector
    u_in = (term{1}) \ ...
        ( (term{2}*u_in_prev) + (term{3}*B*vector.value) );
    
    % Output sequence
    y(n) = u_in(poles);
    
    % Update
    u_in_prev = u_in;
    x_i_prev = x(n);
    
end


end