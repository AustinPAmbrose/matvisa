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

MATVISA is a MATLAB wrapper for the visa library distributed by National Instruments (NI-VISA). NI-VISA allows you to control test and measurement equiptment with software.

MATLAB added direct support for .NET assemblies in R2009a, which lets you access libraries like `NationalInstruments.Visa.dll` from MATLAB! MATVISA makes the library available to MATLAB and wraps it.


<!-- GETTING STARTED -->
## Getting Started
### Prerequisites

MATVISA will only work on computers running Windows. Check if your machine is supported by running the following command:
  ```matlab
  NET.isNETSupported()
  ```

### Installation

1. Download the latest version of NI-VISA from [ni.com](https://www.ni.com/en/support/downloads/drivers/download.ni-visa.html)
2. Install MATVISA from the MATLAB Add-On Explorer **OR** run the following command in MATLAB to install the MATVISA toolbox:
  ```matlab
  eval(webread(https://raw.githubusercontent.com/AustinPAmbrose/matvisa/main/install.m));
  ```

## Usage
### Summary
```matlab
% CLASSES ----------------------------------------------------------------------------------------------------------------------
obj = matvisa(resource_id);               % - connects to instruments by their resource id's
  % resource_id (1,1) string                - a resource ID for a connected instrument, e.g "ASRL6::INSTR" for COM 6
  % obj (1,1) matvisa                       - a new matvisa instance

% PROPERTIES -------------------------------------------------------------------------------------------------------------------
baud (1,1) int32                          % - baud rate for serial devices
terminator (1,:) char {mustBeNonempty}    % - terminator character(s) for writeline() and readline(), default is sprintf('\n')
timeout_ms (1,1) int32                    % - sets the timeout in miliseconds for read() and readline()

% METHODS ----------------------------------------------------------------------------------------------------------------------
visa_list = find(filter)                  % - a static method that finds all connected instruments
  % filter    (1,1) string                  - optional regular expression to filter resource id's, e.g "USB?*", default is "?*"
  % visa_list (1,:) string                  - a list of all available resources

write(bytes)                              % - writes raw data to the instrument (characters/ uint8's)
  % bytes (1,:) char                        - bytes to be written to the instrument, as is, without any modification

bytes = read(count)                       % - reads 
  % count (1,:) int32 {mustBeScalarOrEmpty} - optional number of bytes to be read from the instrument, default is all
  % bytes (1,:) char                        - bytes read from the instrument, as is, without any modification

writeline(str)
  
str = readline()
```

### Examples

   ```matlab
   % find all available instruments with the `find()` method
   resource_ids = matvisa.find();

   % connect to an instrument by passing a resource id to `matvisa()`
   scope = matvisa("USB0::0x2A8D::0x039B::CN61381404::INSTR");
   
   % send commands and read responses with the `write()` and `read()` methods
   scope.write("*IDN?");    % sends '*IDN', and nothing else
   response = scope.read(); % only stops reading when 488.2 end-of-message is received
    % NOTE: `write()` coerces its input to a `char` array, and `read()` will return a `char` array
   
   % for non 488.2 devices (eg. serial) use the `terminator` / `baud` properties and `writeline()` / `readline()` methods 
   serial = matvisa("ASRL6::INSTR");
   serial.baud = 115200;
   serial.terminator = sprintf("\r\n"); % configure terminator as CR/LF, default is LF
   serial.writeline("*IDN?");           % actually sends '*IDN?\r\n'
   response = serial.readline();        % reads until '\r\n' or timeout (terminator removed from response)
   ```
   _NOTE: `writeline()` coerces its input to a `string` and `readline()` will return a `string`_

MATVISA also provides a `query()` method, which is equivilent to calling `writeline()`, then `readline()`.
   ```matlab
   scope = matvisa("USB0::0x2A8D::0x039B::CN61381404::INSTR");
   scope.terminator = sprintf("\n"); % this is already the default, but I'm just being verbose
   response = scope.query("*IDN?");
   ```
You can optionally pass an integer to the `read()` method to read a certain number of bytes
   ```matlab
   scope.write("*IDN?");
   scope.read(4); % for my Keysight scope, this returns 'KEYS'
   ```
If you leave data in the receive buffer after a partial read, use the `flush()` method to clear it.
   ```matlab
   scope.flush(); % probably a good idea before new write operations too...
   ```
Set a timeout for the `read()` and `readline()` methods with the `timeout_ms` property
   ```matlab
   scope.timeout_ms = 1000; % read() and readline() will timeout (and throw an error) after 1 second
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
