% make sure everything is up-to-date

% make sure everything is committed

% run tests

% generate new toolbox
folder = string(fileparts(mfilename("fullpath")));
UUID = "dec8b9de-af41-45e3-8c4f-af0cc78c2ab4";
options = matlab.addons.toolbox.ToolboxOptions(folder, UUID);
options.ToolboxName = "MATVISA";
options.ToolboxVersion = "0.0.0.2";
options.ToolboxImageFile = "resources\toolbox_logo.png";
options.Summary = "Control your test and measurement equiptment with MATLAB!";
options.Description = "";
options.AuthorName = "Austin Ambrose";
options.AuthorEmail = "austin.p.ambrose@gmail.com";
options.ToolboxGettingStartedGuide = "examples\matvisa_intro.mlx";
options.OutputFile = folder + "\" + "bin\matvisa.mltbx";
options.ToolboxFiles = [dir2files("src"), dir2files("examples")];
options.ToolboxMatlabPath = "src"; % folders to add to path
matlab.addons.toolbox.packageToolbox(options);
clear folder UUID options

% create a new github release

function files = dir2files(directory)
    arguments (Input)
        directory (1,1) string
    end
    arguments (Output)
        files (1,:) string
    end
    % returns all files in a relative directory, recursive
    folder = string(fileparts(mfilename("fullpath")));
    files = dir(folder + "\" + directory + "\**\?*");
    files = string({files.folder}) + "\" + string({files.name});
end

function version = str2version(str)
    buff = split(str, ".");
    buff = double(buff);
    buff = uint32(buff);
    version.major = buff(1);
    version.minor = buff(2);
    version.bug   = buff(3);
    version.build = buff(4);
end

function str = version2str(version)
    major = string(version.major);
    minor = string(version.minor);
    bug   = string(version.bug);
    build = string(version.build);
    str = join([major minor bug build], ".");
end

