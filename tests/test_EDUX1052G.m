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
scope.trigger_edge_level = 20E-3;      % with nothing connected, this shouldn't trigger

% setup the timebase
scope.timebase_reference = "LEFT";
scope.timebase_range = 100E-9;

% setup the channel
scope.channel_display(1) = true;
scope.channel_scale(1) = 5E-3;         % just trying to measure some noise

% setup the waveform module
scope.waveform_source = "CHAN1";
scope.waveform_format = "WORD";

% capture the noise
scope.run();
scope.trigger_force();
scope.stop();
my_data = scope.waveform_data(); % this is always a hard one to implement
                                 % need to prevent this from hanging under
                                 % certain conditions
% plot the waveform
plot(my_data.time, my_data.voltage);