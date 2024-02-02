%% Test 1: Make sure matvisa.find() works
ids = matvisa.find();
assert(~isempty(ids));

%% Test2: Capture Noise From EDUX1052G
% connect to the scope
instrument_id = matvisa.find("USB?*"); % if this is your only USB instrument
scope = EDUX1052G(instrument_id);      % EDUX1052G inherits the matvisa constructor
scope.flush();                         % a good 'just-in-case' practice
scope.reset();                         % start in a known state

% setup the trigger
scope.trigger_sweep = "NORM";          % only trigger when conditions are met
scope.trigger_edge_level = 1;          % 1V is fine for the demo signal

% setup the timebase
scope.timebase_reference = "LEFT";     % personal preference
scope.timebase_range = 3e-3;           % 3ms is 3 cycles of the demo signal

% setup channel 1
scope.channel_display(1) = true;       % make sure channel 1 is on
scope.channel_scale(1) = 500E-3;       % get the best resolution out of our signal
scope.channel_offset = 1.25;           % move the waveform down so it fits

% capture the demo signal
scope.single();
while(scope.is_armed == false); end    % wait for the trigger to arm
while(scope.is_running == true); end   % wait for the scope to come to a stop
scope.waveform_source = "CHAN1";       % this is the channel to pull data from
scope.waveform_format = "WORD";        % transfer the data as int16's
my_data = scope.waveform_data;         % retreive the data

% plot the waveform
plot(my_data.time, my_data.voltage);