function [y] = ...
    synth_var_filtering(x, type, fs, fc, k, notes, cutoff_evolution)
% synth_var_filtering |  Synthesizer variable filtering
%
%
%   INPUT ARGUMENTS:
%       x                   input
%       type                synthesizer type
%                           -> 'ladder_transistor'
%                           -> 'ladder_diode'
%                           -> 'korg'
%       fs                  sampling frequency [Hz]
%       fc                  cutoff frequency [Hz]
%       k                   resonance value
%       notes               'notes' struct
%       -> freq             note frequencies [Hz]
%       -> init             initial position of each note [samples]
%       -> end              final position of each note [samples]
%       cutoff_evolution    evolution of cutoff (function)
%       -> adsr             ADSR
%       -> linear           linear function
%       -> exponential      exponential function
%       -> logarithmic      logarithmic function
%
%   OUTPUT ARGUMENTS:
%       y                   output response
%
%
%   Author: jlnkls
%
%   05.05.2017

%% Params

% Sampling period
Ts = 1/fs;

%%% Resonance type (fixed or variable)

if (length(k) == 1)
    
    k_vector = k*ones(size(x));
    
elseif (length(k) ~= length(x))
    
    disp ('Not a valid resonance length');
    disp ('Please input one of the following:');
    disp('-> fixed resonance: length(k) == 1');
    disp('-> variable resonance: length(k) == length(x)');
    
    return;
    
else    % (length(k) == length(x))

    k_vector = k;
    
end


%%% Synth type
if (strcmp(type,'ladder_transistor'))
    
    % Number of poles
    poles = 4;
    
    % Vector range
    vector.range = 1;
    
    % Matrix B
    B = eye(poles);
    
elseif (strcmp(type,'ladder_diode'))
    
    % Number of poles
    poles = 4;
    
    % Vector range
    vector.range = 1;
    
    % Matrix B
    B = eye(poles);
    
elseif (strcmp(type,'korg'))
    
    % Number of poles
    poles = 2;
    
    % Vector range
    vector.range = (1:poles);
    
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

%% Init

% Output
y = zeros(size(x));

% Output vector
u_in_prev = zeros(poles,1);
% Input - previous sample
x_i_prev = 0;


% fc limits
adsr.min_val = fc(1);
adsr.max_val = fc(2);


%% Cutoff evolution

fc_vector = zeros(size(x));

for i=1:length(notes.freq)
    
    %% Triangle wave generation
    
    % Length
    L = notes.end(i)-notes.init(i)+1;
    
    if (strcmp(cutoff_evolution,'adsr'))
        
        %%% ADSR vector
        adsr.a = round(L/6);
        adsr.d = round(L/4);
        adsr.s = round(round(adsr.max_val*0.8));
        adsr.r = round(L/6);
        
        v = [ ...
            linspace(adsr.min_val, adsr.max_val, adsr.a), ...        % Attack
            linspace(adsr.max_val, adsr.s, adsr.d), ...              % Delay
            linspace(adsr.s, adsr.s, L-(adsr.a+adsr.d+adsr.r)), ...  % Sustain
            linspace(adsr.s, adsr.min_val, adsr.r), ...              % Release
            ];
        
    elseif (strcmp(cutoff_evolution,'linear'))
        
        %%% Linear vector
        v = [linspace(adsr.min_val,adsr.max_val,round(L/2)), ...
            linspace(adsr.max_val,adsr.min_val,round(L/2))];
        
    elseif (strcmp(cutoff_evolution,'exponential'))
        
        %%% Exponential vector
        v = [linspace(adsr.max_val,adsr.min_val,round(L/2)), ...
            linspace(adsr.min_val,adsr.max_val,round(L/2))];
        
    elseif (strcmp(cutoff_evolution,'logarithmic'))
        
        %%% Logarithmic vector
        v1 = -logspace(log10(adsr.max_val),log10(adsr.min_val),round(L/2));
        v1 = v1 + max(abs(v1));
        
        v2 = -logspace(log10(adsr.min_val),log10(adsr.max_val),round(L/2));
        v2 = v2 + max(abs(v2));
        
        v = [v1, v2];
        
    else
        
        disp ('Not a valid cutoff evolution');
        disp ('Please input one of the following:');
        disp('-> adsr');
        disp('-> linear');
        disp('-> exponential');
        disp('-> logarithmic');
        
        return;
        
    end
    
    %%% Final sequence
    fc_vector(notes.init(i):notes.init(i)+length(v)-1) = v;
    
end


%% Filtering

for n=1:length(x)
    
    
    %%% Synth type
    if (strcmp(type,'ladder_transistor'))
        
        % Matrix A
        A = [ -1, 0, 0, -k_vector(n); ...
            1, -1, 0, 0; ...
            0, 1, -1, 0; ...
            0, 0, 1, -1];
        
    elseif (strcmp(type,'ladder_diode'))
        
        
        % Matrix A
        A = [ -1, 1, 0, -k_vector(n); ...
            1/2, -1, 1/2, 0; ...
            0, 1/2, -1, 1/2; ...
            0, 0, 1/2, -1];
        
    elseif (strcmp(type,'korg'))
        
        % Matrix A
        A = [ -1, -k_vector(n); ...
            1, (k_vector(n)-1)];
        
    end
    
    
    % Cutoff frequency
    fc = fc_vector(n);
    omega = (2*pi).*fc;
    
    % Antitransformed cutoff pulsation
    omega_hat = (2/Ts)*tan(omega*Ts/2);
    
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