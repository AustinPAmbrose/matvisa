classdef matvisa < handle
    properties (Constant)
        % this is where NI-VISA was installed on my machine ¯\_(ツ)_/¯
        VISA_LOCATION = "C:\Program Files\IVI Foundation\VISA\Microsoft.NET\Framework64\**\NationalInstruments.Visa.dll"
        VISA_DOCUMENTATION = "C:\Program Files\IVI Foundation\VISA\Microsoft.NET\Framework64\**\Documentation\NINETVISA.chm"
    end
    properties
        visa (1,1) % NationalInstruments.Visa.Session
        terminator (1,:) char {mustBeNonempty} = newline;
    end
    properties (Dependent)
        baud (1,1) int32
        timeout_ms (1,1) int32
    end
    properties (Hidden)
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
        % initialization and management
        function init()
            % make the NI VISA assembly visible to MATLAB
            % this will fail for mac os and some windows machines
            persistent isinit; if isempty(isinit); isinit = false; end
            if isinit; return; end
            if NET.isNETSupported == false
                error("Couldn't find .NET support on this computer" + ...
                    "See MATLAB .NET documentation.");
            end
            % locate the NI VISA dll
            ni_visa = dir(matvisa.VISA_LOCATION);
            if isempty(ni_visa)
                error("Could not find NI-VISA in:" + newline +...
                    matvisa.VISA_LOCATION + newline + ...
                    "Make sure you install NI-VISA from ni.com");
            end
            % add the NI VISA to MATLAB if its not already
            warning("off", "MATLAB:NET:AddAssembly:nameConflict");
            NET.addAssembly([ni_visa(1).folder '\' ni_visa(1).name]);
            warning("on", "MATLAB:NET:AddAssembly:nameConflict");
            isinit = true;
        end
        function visa_list = find(filter)
            % get a list of available instruments
            arguments (Input)
                filter (1,1) string {mustBeMember(filter, [...
                    "?*", "ASRL?*INSTR", ...
                    "GPIB?*", "GPIB?*INSTR", "GPIB?*INTFC", ...
                    "PXI?*", "PXI?*BACKPLANE", "PXI?*INSTR", ...
                    "TCPIP?*", "TCPIP?*INSTR", "TCPIP?*SOCKET", ...
                    "USB?*", "USB?*INSTR", "USB?*RAW", ...
                    "VXI?*", "VXI?*BACKPLANE", "VXI?*INSTR"])} = "?*";  
            end
            arguments (Output)
                visa_list (1,:) string
            end
            matvisa.init()
            try
                resources = matvisa.manager.Find(filter);
            catch
                error("no visa devices found, which is weird :/");
            end
            visa_list = string(resources);
        end
        function manager_ = manager()
            % get an instance of a resource manager
            persistent manager;
            if isempty(manager)
                manager = NationalInstruments.Visa.ResourceManager;
            end
            manager_ = manager;
       end
        function help()
            % open documentation for NI-VISA
            doc = dir(matvisa.VISA_DOCUMENTATION);
            doc = ['"' doc(1).folder '\' doc(1).name '"'];
            doc = join(doc);
            system ("explorer " + doc);
        end
    end
    methods
        % constructor
        function obj = matvisa(resource_id)
            % connect to an instrument
            matvisa.init();
            obj.visa = matvisa.manager.Open(resource_id);
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
                error("There's a solid chance the read operation timed out");
            end
        end
        function writeline(obj, str)
            arguments
                obj
                str (1,1) string
            end
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
            while true
                % because VISA only supports one termination character,
                % we need to keep reading until we've found the entire
                % terminator sequence (CRLF, or something else weird)
                str = str + obj.read();
                if endsWith(str, obj.terminator); break; end
            end
            str = strrep(str, obj.terminator, "");
            obj.visa.TerminationCharacterEnabled = false;
        end
        function str_out = query(obj, str_in)
            obj.writeline(str_in);
            str_out = obj.readline();
        end
        function flush(obj)
            obj.visa.Clear();
        end
        % "While a man lives he wins no greater honor than footwork
        % and the skill of hands can bring him."
    end
end