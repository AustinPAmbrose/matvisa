classdef matvisa < handle
    properties (Constant)
        % this is where NI-VISA was installed on my machine ¯\_(ツ)_/¯
        VISA_LOCATION = "C:\Program Files\IVI Foundation\VISA\Microsoft.NET\Framework64\**\NationalInstruments.Visa.dll"
    end
    properties
        visa (1,1) NationalInstruments.Visa.Session
    end
    properties (Dependent)
        baud
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
    end
    methods (Static)
        function init()
            % make the NI VISA assembly visible to MATLAB
            % this will fail for mac os and some windows machines
            persistent isinit; if isempty(isinit); isinit = false; end
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
            NET.addAssembly([ni_visa.folder '\' ni_visa.name]);
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
            persistent resource_manager;
            if isempty(resource_manager)
                resource_manager = NationalInstruments.Visa.ResourceManager;
            end
            try
                resources = resource_manager.Find(filter);
            catch
                error("no visa devices found, which is weird :/");
            end
            visa_list = string(resources);
        end
    end
    methods
        % constructor
        function obj = matvisa(resource_id)
            % connect to an instrument
            persistent resource_manager;
            if isempty(resource_manager)
                resource_manager = NationalInstruments.Visa.ResourceManager;
            end
            obj.visa = resource_manager.Open(resource_id);
        end
        % wrapper functions
        function writeline(obj,str)
            obj.visa.FormattedIO.WriteLine(str);
        end
        function write(obj, data)
            obj.visa.Raw
        end
        function str = readline(obj)
            str = obj.visa.RawIO.ReadString(); 
        end
        function out=query(obj,in)
            obj.writeline(in);
            out = obj.readline();
        end
        function flush(obj)
            obj.visa.Clear();
        end
    end
end