classdef matvisa < handle
    properties (Constant, Hidden)
        % this loads the visa library the first time matvisa is called
        VISA_LIB = NET.addAssembly("NationalInstruments.Visa")
        VISA_MANAGER = NationalInstruments.Visa.ResourceManager()
    end
    properties
        visa (1,1) NationalInstruments.Visa.Session
        terminator (1,:) char {mustBeNonempty} = newline
    end
    properties (Dependent)
        baud (1,1) int32
        timeout_ms (1,1) int32
    end
    methods 
        % getters and setters for dependent properties
        function timeout_ms_ = get.timeout_ms(obj)
            timeout_ms_ = obj.visa.TimeoutMilliseconds;
        end
        function set.timeout_ms(obj, timeout_ms_)
            obj.visa.TimeoutMilliseconds = timeout_ms_;
        end
        function baud_ = get.baud(obj)
            baud_ = obj.visa.BaudRate;
        end
        function set.baud(obj, baud_)
            obj.visa.BaudRate = baud_;
        end
    end
    methods (Static)
        function visa_list = find(filter)
            % get a list of available instruments
            % you can use ? and * as wildcards
            arguments (Input)
                filter (1,1) string = "?*"  
            end
            arguments (Output)
                visa_list (1,:) string
            end
            try
                resources = matvisa.VISA_MANAGER.Find(filter);
                visa_list = string(resources);
            catch
                error("no visa devices found");
            end
        end
    end
    methods
        % constructor
        function obj = matvisa(resource_id)
            arguments (Input)
                resource_id (1,1) string
            end
            % connect to an instrument
            obj.visa = matvisa.VISA_MANAGER.Open(resource_id);
        end
        % destructor
        function delete(obj)
            obj.visa.Dispose();
        end 
        % wrapper functions
        function write(obj, bytes)
            arguments
                obj
                bytes (1,:) char
            end
            obj.visa.RawIO.Write(bytes);
        end
        function bytes = read(obj, count)
            arguments (Input)
                obj
                count (1,:) int32 {mustBeScalarOrEmpty} = []
            end
            arguments (Output)
                bytes (1,:) char
            end
            % reads until end-of-message, or until count is satisfied
            try
                if isempty(count)
                    bytes = char(uint8(obj.visa.RawIO.Read()));
                else
                    bytes = char(uint8(obj.visa.RawIO.Read(count)));
                end
            catch
                error("Read operation timed out (probably)");
            end
        end
        function writeline(obj, str)
            arguments (Input)
                obj
                str (1,1) string
            end
            % writes a string to the instrument, and appends a terminator
            obj.write(str + obj.terminator);
        end
        function str = readline(obj)
            arguments (Output)
                str (1,1) string
            end
            % reads termination character OR end
            obj.visa.TerminationCharacter = int8(obj.terminator(end));
            obj.visa.TerminationCharacterEnabled = true;
            str = "";
            try
                while true
                    % because VISA only supports one termination character,
                    % we need to keep reading until we've found the entire
                    % terminator sequence (CRLF, or something else weird)
                    str = str + obj.read();
                    if endsWith(str, obj.terminator); break; end
                end
                str = strrep(str, obj.terminator, "");
            catch ME
                % disable the terminator, even if an error occurs
                obj.visa.TerminationCharacterEnabled = false;
                error("matvisa read() likely timed out");
            end
            % disable the terminator
            obj.visa.TerminationCharacterEnabled = false;
        end
        function str_out = query(obj, str_in)
            arguments (Input)
                obj
                str_in (1,1) string
            end
            arguments (Output)
                str_out (1,1) string
            end
            obj.writeline(str_in);
            str_out = obj.readline();
        end
        function flush(obj)
            obj.visa.Clear();
        end
        % "While a man lives he wins no greater honor than footwork
        % and the skill of hands can bring him."
        function writebinblock(obj, bytes)
           arguments
                obj
                bytes (1,:) char
           end
           len = length(bytes);
           len = char(string(len));
           len_meta = string(length(len));
           obj.write(['#' len_meta len bytes]);
        end
        function bytes = readbinblock(obj)
           arguments (Output)
                bytes (1,:) char
           end
           assert(obj.read(1) == '#', "first character was not '#'");
           len_meta = obj.read(1);          % "5" as string
           len_meta = str2double(len_meta); % 5 as double
           len = obj.read(len_meta);        % "50000" as string
           len = str2double(len);           % 50000 as double
           bytes = obj.read(len);           % The binary data
        end
    end
end