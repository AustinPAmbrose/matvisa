classdef EDUX1052G < matvisa
    
    properties (Dependent)
        % Common Commands
        id     (1,1) string
        status (1,1) struct
        % Root Commands
        is_armed (1,1) logical
        is_running (1,1) logical
        % Waveform Commands - is_running must be false to use these
        waveform_points_mode (1,1) string {mustBeMember(waveform_points_mode, ["NORM", "MAX", "RAW"])}
        waveform_preamble (1,1) struct
        waveform_segmented_count (1,1) double
        waveform_source (1,1) string {mustBeMember(waveform_source,["CHAN1", "CHAN2", "FUNC", "MATH", "FFT", "SBUS1", "ABUS", "EXT"])}
        waveform_source_subs (1,1) string {mustBeMember(waveform_source_subs, ["SUB0", "RX", "MOSI", "SUB1", "TX", "MISO"])}
        waveform_type (1,1) string {mustBeMember(waveform_type, ["NORM", "PEAK", "AVER", "HRES"])}
        waveform_unsigned (1,1) logical
        waveform_format (1,1) string {mustBeMember(waveform_format, ["WORD", "BYTE", "ASCII"])}
        waveform_byteorder (1,1) string {mustBeMember(waveform_byteorder, ["LSBF", "MSBF"])}
        waveform_data (1,1) timetable % <<-- This is the waveform data ()
        % Trigger Commands
        trigger_hfreject (1,1) logical
        trigger_holdoff (1,1) double {mustBeInRange(trigger_holdoff, 60E-9, 10)}
        trigger_sweep (1,1) string {mustBeMember(trigger_sweep, ["AUTO", "NORM"])}
        trigger_edge_coupling (1,1) string {mustBeMember(trigger_edge_coupling, ["AC", "DC", "LFR"])}
        trigger_edge_level (1,1) double
        trigger_edge_slope (1,1) string {mustBeMember(trigger_edge_slope, ["POS", "NEG", "EITH", "ALT"])}
        trigger_edge_source (1,1) string {mustBeMember(trigger_edge_source, ["CHAN1", "CHAN2", "EXT", "LINE", "WGEN"])}
        % Channel Commands
        channel_coupling (1,2) string {mustBeMember(channel_coupling, ["AC", "DC"])}
        channel_display (1,2) logical
        channel_invert (1,2) logical
        channel_offset (1,2) double
        channel_probe (1,2) double
        channel_range (1,2) double
        channel_scale (1,2) double
        % Timebase Commands
        timebase_mode (1,1) string {mustBeMember(timebase_mode, ["MAIN", "WIND", "XY", "ROLL"])}
        timebase_position (1,1) double
        timebase_range (1,1) double
        timebase_reference (1,1) string {mustBeMember(timebase_reference, ["LEFT", "CENTER", "RIGHT", "ROLL"])}
        timebase_scale (1,1) double
        timebase_window_position (1,1) double
        timebase_window_range (1,1) double
        timebase_window_scale (1,1) double
    end
    methods
        % Common Commands
        function id_ = get.id(obj)
            id_ = obj.query("*IDN?"); 
        end
        function status_ = get.status(obj)
            stb = obj.query("*STB?");
            stb = uint8(double(stb));
            status_.TRG  = logical(bitand(stb, 0b00000001)); % trigger occured
            status_.USR  = logical(bitand(stb, 0b00000010)); % 
            status_.MSG  = logical(bitand(stb, 0b00000100));
            % unused = logical(bitand(stb, 0b00001000));
            status_.MAV  = logical(bitand(stb, 0b00010000));
            status_.ESB  = logical(bitand(stb, 0b00100000));
            status_.RQS  = logical(bitand(stb, 0b01000000));
            status_.OPER = logical(bitand(stb, 0b10000000));
        end
        function reset(obj)
            obj.write("*RST"); 
        end
        function clear(obj)
            obj.write("*CLS"); 
        end
        function passed = test(obj)
            cur_timeout = obj.timeout_ms;
            obj.timeout_ms = 20000;
            try 
                switch obj.query("*TST?")
                    case "0"
                        passed = true;
                    case "1"
                        passed = false;
                end
            catch 
            end
            obj.timeout_ms = cur_timeout;
        end
        % Root Commands
        function run(obj)
            obj.write(":RUN"); 
        end
        function single(obj)
            obj.write(":SINGLE"); 
        end
        function stop(obj)
            obj.write(":STOP"); 
        end
        function is_armed_ = get.is_armed(obj)
            is_armed_ = obj.querylogical(":AER?"); 
        end
        function is_running_ = get.is_running(obj)
            condition = obj.query(":OPEREGISTER:CONDITION?");
            condition = uint16(double(condition));
            is_running_ = bitand(condition, 0b0000000000001000) ~= 0;
        end
        function autoscale(obj, channels)
            arguments
                obj
                channels (1,:) int32 {mustBeMember(channels, [1,2])} = [1,2]
            end
            channels = "CHANNEL" + channels;
            channels = join(channels, ",");
            obj.write(":AUTOSCALE " + channels);
        end
        % Waveform Commands
        function waveform_points_mode_ = get.waveform_points_mode(obj)
            waveform_points_mode_ = obj.query("WAVEFORM:POINTS:MODE?");
        end
        function set.waveform_points_mode(obj, waveform_points_mode_)
            obj.write("WAVEFORM:POINTS:MODE " + waveform_points_mode_);
        end
        function waveform_preamble_ = get.waveform_preamble(obj)
            assert(obj.is_running == false, "scope must be stopped to aquire data");
            preamble_buff = obj.query("WAVEFORM:PREAMBLE?");
            preamble_buff = split(preamble_buff, ",");
            preamble_buff = double(preamble_buff);
            waveform_preamble_.format       = preamble_buff(1);
            waveform_preamble_.type         = preamble_buff(2);
            waveform_preamble_.points       = preamble_buff(3);
            waveform_preamble_.count        = preamble_buff(4);
            waveform_preamble_.xincrement   = preamble_buff(5);
            waveform_preamble_.xorigin      = preamble_buff(6);
            waveform_preamble_.xreference   = preamble_buff(7);
            waveform_preamble_.yincrement   = preamble_buff(8);
            waveform_preamble_.yorigin      = preamble_buff(9);
            waveform_preamble_.yreference   = preamble_buff(10);
        end
        function waveform_format_ = get.waveform_format(obj)
            waveform_format_ = obj.query("WAVEFORM:FORMAT?");
        end
        function set.waveform_format(obj, waveform_format_)
            obj.write("WAVEFORM:FORMAT " + waveform_format_);
        end
        function waveform_byteorder_ = get.waveform_byteorder(obj)
            waveform_byteorder_ = obj.query("WAVEFORM:BYTEORDER?");
        end
        function set.waveform_byteorder(obj, waveform_byteorder_)
            obj.write("WAVEFORM:BYTEORDER " + waveform_byteorder_);
        end
        function waveform_segmented_count_ = get.waveform_segmented_count(obj)
            waveform_segmented_count_ = double(obj.query("WAVEFORM:SEGMENTED:COUNT?"));
        end
        function set.waveform_segmented_count(obj, waveform_segmented_count_)
            obj.write("WAVEFORM:SEGMENTED:COUNT " + waveform_segmented_count_);
        end
        function waveform_source_ = get.waveform_source(obj)
            waveform_source_ = obj.query("WAVEFORM:SOURCE?");
        end
        function set.waveform_source(obj, waveform_source_)
             obj.write("WAVEFORM:SOURCE " + waveform_source_);
        end
        function waveform_source_subs_ = get.waveform_source_subs(obj)
            waveform_source_subs_ = obj.query("WAVEFORM:SOURCE:SUBS?");
        end
        function set.waveform_source_subs(obj, waveform_source_subs_)
            obj.write("WAVEFORM:SOURCE:SUBS " + waveform_source_subs_);
        end
        function waveform_unsigned_ = get.waveform_unsigned(obj)
            waveform_unsigned_ = obj.querylogical("WAVEFORM:UNSIGNED?");
        end
        function set.waveform_unsigned(obj, waveform_unsigned_)
            obj.write("WAVEFORM:UNSIGNED " + double(waveform_unsigned_));
        end
        function waveform_data_ = get.waveform_data(obj)
            p = obj.waveform_preamble;
            obj.write("WAVEFORM:DATA?");
            switch p.format
                case 0 % BYTE
                    data = obj.readbinblock();
                    obj.read(); % clear the terminator
                    data = double(data);
                    voltage = (((data - p.yreference)*p.yincrement) + p.yorigin)';
                case 1 % WORD
                    data = obj.readbinblock(); 
                    obj.read(); % clear the terminator
                    data = typecast(uint8(data), 'int16');
                    data = double(data);
                    voltage = (((data - p.yreference)*p.yincrement) + p.yorigin)';
                case 4 % ASCII
                    data = obj.readline();
                    data = split(data, ",");
                    voltage = double(data);
            end
            time = (((0:(p.points-1) - p.xreference)*p.xincrement) + p.xorigin)';
            time = seconds(time);
            waveform_data_ = timetable(time, voltage);
        end
        % Trigger Commands
        function trigger_force(obj)
            obj.write("TRIGGER:FORCE");
        end
        function trigger_hfreject_ = get.trigger_hfreject(obj)
            trigger_hfreject_ = obj.querylogical("TRIGGER:HFREJECT?");
        end
        function set.trigger_hfreject(obj, trigger_hfreject_)
            obj.write("TRIGGER:HFREJECT " + double(trigger_hfreject_));
        end
        function trigger_holdoff_ = get.trigger_holdoff(obj)
            trigger_holdoff_ = double(obj.query("TRIGGER:HOLDOFF?"));
        end
        function set.trigger_holdoff(obj, trigger_holdoff_)
            obj.write("TRIGGER:HOLDOFF " + trigger_holdoff_);
        end
        function trigger_level_asetup(obj)
            % setups the trigger to 50% of the displayed waveform
            obj.write("TRIGGER:LEVEL:ASETUP " + trigger_level_asetup_);
        end
        function trigger_edge_coupling_ = get.trigger_edge_coupling(obj)
            trigger_edge_coupling_ = obj.query("TRIGGER:EDGE:COUPLING?");
        end
        function set.trigger_edge_coupling(obj, trigger_edge_coupling_)
            obj.write("TRIGGER:EDGE:COUPLING " + trigger_edge_coupling_);
        end
        function trigger_sweep_ = get.trigger_sweep(obj)
            trigger_sweep_ = obj.query("TRIGGER:SWEEP?");
        end
        function set.trigger_sweep(obj, trigger_sweep_)
            obj.write("TRIGGER:SWEEP " + trigger_sweep_);
        end
        function trigger_edge_level_ = get.trigger_edge_level(obj)
            trigger_edge_level_ = double(obj.query("TRIGGER:LEVEL?"));
        end
        function set.trigger_edge_level(obj, trigger_edge_level_)
            obj.write("TRIGGER:LEVEL " + trigger_edge_level_);
        end
        function trigger_edge_slope_ = get.trigger_edge_slope(obj)
            trigger_edge_slope_ = obj.query("TRIGGER:EDGE:SLOPE?");
        end
        function set.trigger_edge_slope(obj, trigger_edge_slope_)
            obj.write("TRIGGER:EDGE:SLOPE " + trigger_edge_slope_);
        end
        function trigger_edge_source_ = get.trigger_edge_source(obj)
            trigger_edge_source_ = obj.query("TRIGGER:EDGE:SOURCE?");
        end
        function set.trigger_edge_source(obj, trigger_edge_source_)
            obj.write("TRIGGER:EDGE:SOURCE " + trigger_edge_source_);
        end
        % Channel Commands
        function channel_coupling_ = get.channel_coupling(obj)
            channel_coupling_(1) = obj.query("CHANNEL1:COUPLING?");
            channel_coupling_(2) = obj.query("CHANNEL2:COUPLING?");
        end
        function set.channel_coupling(obj, channel_coupling_)
            obj.write("CHANNEL1:COUPLING " + channel_coupling_(1));
            obj.write("CHANNEL2:COUPLING " + channel_coupling_(2));
        end
        function channel_display_ = get.channel_display(obj)
            channel_display_(1) = obj.querylogical("CHANNEL1:DISPLAY?");
            channel_display_(2) = obj.querylogical("CHANNEL2:DISPLAY?");
        end
        function set.channel_display(obj, channel_display_)
            obj.write("CHANNEL1:DISPLAY " + double(channel_display_(1)));
            obj.write("CHANNEL2:DISPLAY " + double(channel_display_(2)));
        end
        function channel_invert_ = get.channel_invert(obj)
            channel_invert_(1) = obj.querylogical("CHANNEL1:INVERT?");
            channel_invert_(2) = obj.querylogical("CHANNEL2:INVERT?");
        end
        function set.channel_invert(obj, channel_invert_)
            obj.write("CHANNEL1:INVERT " + double(channel_invert_(1)));
            obj.write("CHANNEL2:INVERT " + double(channel_invert_(2)));
        end
        function channel_offset_ = get.channel_offset(obj)
            channel_offset_(1) = double(obj.query("CHANNEL1:OFFSET?"));
            channel_offset_(2) = double(obj.query("CHANNEL2:OFFSET?"));
        end
        function set.channel_offset(obj, channel_offset_)
            obj.write("CHANNEL1:OFFSET " + double(channel_offset_(1)));
            obj.write("CHANNEL2:OFFSET " + double(channel_offset_(2)));
        end
        function channel_probe_ = get.channel_probe(obj)
            channel_probe_(1) = double(obj.query("CHANNEL1:PROBE?"));
            channel_probe_(2) = double(obj.query("CHANNEL2:PROBE?"));
        end
        function set.channel_probe(obj, channel_probe_)
            obj.write("CHANNEL1:PROBE " + double(channel_probe_(1)));
            obj.write("CHANNEL2:PROBE " + double(channel_probe_(2)));
        end
        function channel_range_ = get.channel_range(obj)
            channel_range_(1) = double(obj.query("CHANNEL1:RANGE?"));
            channel_range_(2) = double(obj.query("CHANNEL2:RANGE?"));
        end
        function set.channel_range(obj, channel_range_)
            obj.write("CHANNEL1:RANGE " + channel_range_(1));
            obj.write("CHANNEL2:RANGE " + channel_range_(2));
        end
        function channel_scale_ = get.channel_scale(obj)
            channel_scale_(1) = double(obj.query("CHANNEL1:SCALE?"));
            channel_scale_(2) = double(obj.query("CHANNEL2:SCALE?"));
        end
        function set.channel_scale(obj, channel_scale_)
            obj.write("CHANNEL1:SCALE " + channel_scale_(1));
            obj.write("CHANNEL2:SCALE " + channel_scale_(2));
        end
        % Timebase Commands
        function timebase_mode_ = get.timebase_mode(obj)
            timebase_mode_ = obj.query("TIMEBASE:MODE?");
        end
        function set.timebase_mode(obj, timebase_mode_)
            obj.write("TIMEBASE:MODE " + timebase_mode_);
        end
        function timebase_position_ = get.timebase_position(obj)
            timebase_position_ = double(obj.query("TIMEBASE:POSITION?"));
        end
        function set.timebase_position(obj, timebase_position_)
            obj.write("TIMEBASE:POSITION " + timebase_position_);
        end
        function timebase_range_ = get.timebase_range(obj)
            timebase_range_ = double(obj.query("TIMEBASE:RANGE?"));
        end
        function set.timebase_range(obj, timebase_range_)
            obj.write("TIMEBASE:RANGE " + timebase_range_);
        end
        function timebase_reference_ = get.timebase_reference(obj)
            timebase_reference_ = obj.query("TIMEBASE:REFERENCE?");
        end
        function set.timebase_reference(obj, timebase_reference_)
            obj.write("TIMEBASE:REFERENCE " + timebase_reference_);
        end
        function timebase_scale_ = get.timebase_scale(obj)
            timebase_scale_ = double(obj.query("TIMEBASE:SCALE?"));
        end
        function set.timebase_scale(obj, timebase_scale_)
            obj.write("TIMEBASE:SCALE " + timebase_scale_);
        end
        function timebase_window_position_ = get.timebase_window_position(obj)
            timebase_window_position_ = double(obj.query("TIMEBASE:WINDOW:POSITION?"));
        end
        function set.timebase_window_position(obj, timebase_window_position_)
            obj.write("TIMEBASE:WINDOW:POSITION " + timebase_window_position_);
        end
        function timebase_window_range_ = get.timebase_window_range(obj)
            timebase_window_range_ = double(obj.query("TIMEBASE:WINDOW:RANGE?"));
        end
        function set.timebase_window_range(obj, timebase_window_range_)
            obj.write("TIMEBASE:WINDOW:RANGE " + timebase_window_range_);
        end
        function timebase_window_scale_ = get.timebase_window_scale(obj)
            timebase_window_scale_ = double(obj.query("TIMEBASE:WINDOW:SCALE?"));
        end
        function set.timebase_window_scale(obj, timebase_window_scale_)
            obj.write("TIMEBASE:WINDOW:SCALE " + timebase_window_scale_);
        end

        % class helper methods
        function logical_ = querylogical(obj, str)
            logical_ = obj.query(str);
            logical_ = double(logical_);
            logical_ = logical(logical_);
        end
    end
end