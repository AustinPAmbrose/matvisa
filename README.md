<!-- PROJECT LOGO -->
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

MATVISA is a MATLAB wrapper for the visa library distributed by [National Instruments](ni.com) (NI-VISA). NI-VISA allows you to control test and measurement equiptment with software.

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
1. Find all available instruments with the static `find()` method
   ```matlab
    resource_ids = matvisa.find();
   ```
3. Connect to an instrument by passing a resource id to `matvisa()`
   ```matlab
   scope = matvisa("USB0::0x2A8D::0x039B::CN61381404::INSTR");
   ```
5. Send commands and read responses with the `writeline()` and `readline()` methods
   ```matlab
   scope.writeline("*IDN?");
   response = scope.readline();
   ```
6. You can also use the `query()` method to write and read in one operation
   ```matalab
   response = scope.query("*IDN?");
   ```
6. Set a timeout for the read method with the `timeout_ms` property
   ```matlab
   scope.timeout_ms = 1000; % readline() will timeout after 1 second
   ```
8. Send and receive uint8 data with the `write()` and `read()` methods
9. For serial ports, set the baud rate by chan

_Use `matvisa.help()`

## Roadmap

- [ ] Support for mac os

See the [open issues](https://github.com/AustinPAmbrose/matvisa/issues) for a full list of proposed features (and known issues).

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<!-- CONTACT -->
## Contact

Austin Ambrose - [@twitter_handle](https://twitter.com/twitter_handle) - austin.p.ambrose@gmail.com

Project Link: [https://github.com/AustinPAmbrose/matvisa](https://github.com/AustinPAmbrose/matvisa)
