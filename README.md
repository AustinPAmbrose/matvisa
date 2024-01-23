[![View MATVISA on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/158106-matvisa)
<br />
<div align="center">
  <a href="https://github.com/github_username/repo_name">
    <img src="resources/logo.svg" alt="Logo" width="800" height="80">
  </a>

  <p align="center">
    Control your test and measurement equiptment with MATLAB
    <br />
    <a href="https://github.com/github_username/repo_name/issues">Report Bug</a>
    ·
    <a href="https://github.com/github_username/repo_name/issues">Request Feature</a>
  </p>
</div>

```matlab
>> matvisa.find()

ans = 

  1×3 string array

    "USB0::0x2A8D::0x039B::CN61381404::INSTR"    "ASRL6::INSTR"    "ASRL7::INSTR"

>> scope = matvisa("USB0::0x2A8D::0x039B::CN61381404::INSTR");
>> scope.writeline("*IDN?");
>> scope.readline()

ans = 

    "KEYSIGHT TECHNOLOGIES,EDUX1052G,CN61381404,02.11.2020062221"
```


<!-- ABOUT THE PROJECT -->
## About The Project

MATVISA is a MATLAB wrapper for the visa library distributed by National Instruments (NI-VISA). The NI-VISA library allows you to control test and measurement equiptment like oscilloscopes, function generators, multimeters, etc.

MATVISA is a bare-bones version of MATLAB's _Instrument Control_ toolbox.

<!-- GETTING STARTED -->
## Getting Started
### System Requirements

- **OPERATING SYSTEM:** MATVISA will only work on computers running Windows. Use this command to check for support:
  ```matlab
  NET.isNETSupported()
  ```
- **NET ENVIRONMENT:** MATVISA requires MATLAB to use the .NET Framework. Check your NET environment with:
  ```matlab
  dotnetenv()
  ```

### Installation

1. Download the latest version of NI-VISA from [ni.com](https://www.ni.com/en/support/downloads/drivers/download.ni-visa.html)
2. Install MATVISA from the MATLAB Add-On Explorer **OR** from the matlab file exchanges

## Usage
### Summary
```matlab
% CLASSES ----------------------------------------------------------------------------------------------------------------------
obj = matvisa(resource_id);               % - connects to instruments by their resource id's
  % resource_id (1,1) string                - a resource ID for a connected instrument, e.g "ASRL6::INSTR" for COM 6
  % obj (1,1) matvisa                       - a new matvisa instance

% PROPERTIES -------------------------------------------------------------------------------------------------------------------
baud % (1,1) int32                          - baud rate for serial devices
terminator % (1,:) char {mustBeNonempty}    - terminator character(s) for writeline() and readline(), default is sprintf('\n')
timeout_ms % (1,1) int32                    - sets the timeout in miliseconds for read() and readline()

% METHODS ----------------------------------------------------------------------------------------------------------------------
visa_list = find(filter)                  % - a static method that finds all connected instruments
  % filter    (1,1) string                  - optional regular expression to filter resource id's, e.g "USB?*", default is "?*"
  % visa_list (1,:) string                  - a list of all available resources

write(bytes)                              % - writes raw data to the instrument, without a terminator
  % bytes (1,:) char                        - bytes sent to the instrument

bytes = read(count)                       % - reads until end-of-message, or until count is satisfied
  % count (1,:) int32 {mustBeScalarOrEmpty} - optional number of bytes to be read from the instrument, default is all
  % bytes (1,:) char                        - bytes read from the instrument

writeline(str)                            % - writes string to instrument, with terminator appended
  % str (1,1) string                        - string sent to the instrument
  
str = readline()                          % - reads a string from the instrument, until the terminator
  % str (1,1) string                      % - string read from the instrument, with terminator removed

str_out = query(str_in)                   % performs writeline(str_in), and returns str_out = readline()
  % str_in (1,1) string                   % string sent to the instrument
  % str_out (1,1) string                  % string read from the instrument

flush()                                   % clears any remaining data in the input & output buffers
```

### Examples

   ```matlab
   % read an oscilloscope's identification string
   resource_ids = matvisa.find();
   scope = matvisa("USB0::0x2A8D::0x039B::CN61381404::INSTR");
   scope.write("*IDN?");    % sends '*IDN', and nothing else
   response = scope.read(); % only stops reading when 488.2 end-of-message is received
   
   % for non 488.2 devices (e.g serial) use the terminator / baud properties and writeline() / readline() methods 
   serial = matvisa("ASRL6::INSTR");
   serial.baud = 115200;
   serial.terminator = sprintf("\r\n"); % configure terminator as CR/LF, default is LF
   serial.writeline("*IDN?");           % actually sends '*IDN?\r\n'
   response = serial.readline();        % reads until '\r\n' or timeout (terminator removed from response)

   % use query to save a line of code
   scope = matvisa("USB0::0x2A8D::0x039B::CN61381404::INSTR");
   response = scope.query("*IDN?"); % equivilent to writeline() & readline()
   
   % read the first 4 bytes of the oscilloscopes identification string
   scope.write("*IDN?");
   scope.read(4); % for my Keysight scope, this returns 'KEYS'
   scope.flush(); % clear the read buffer for the next call to read()

   % set a read timeout
   scope.timeout_ms = 1000; % read() and readline() will throw an error after 1 second
   ```

_Use `matvisa.help()` to open the NI-VISA documentation_

## Roadmap
- [ ] Add a 'getting_started.mlx' script
- [ ] Add `readbinblock()` and `writebinblock()` methods
- [ ] Support for mac os

See the [open issues](https://github.com/AustinPAmbrose/matvisa/issues) for a full list of proposed features (and known issues).

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<!-- CONTACT -->
## Contact

Austin Ambrose - [@twitter_handle](https://twitter.com/twitter_handle) - austin.p.ambrose@gmail.com

Project Link: [https://github.com/AustinPAmbrose/matvisa](https://github.com/AustinPAmbrose/matvisa)
