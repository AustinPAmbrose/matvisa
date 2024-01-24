folder = string(fileparts(mfilename("fullpath")));
UUID = "dec8b9de-af41-45e3-8c4f-af0cc78c2ab4";
options = matlab.addons.toolbox.ToolboxOptions(folder, UUID);
options.ToolboxName = "MATVISA";
options.ToolboxVersion = "0.0.0.2";
options.ToolboxImageFile = "resources/toolbox_logo.png";
options.Summary = "Control your test and measurement equiptment with MATLAB!";
options.Description = "";
options.AuthorName = "Austin Ambrose";
options.AuthorEmail = "austin.p.ambrose@gmail.com";
options.ToolboxGettingStartedGuide = "examples/matvisa_intro.mlx";
options.OutputFile = folder + "/" + "bin/matvisa.mltbx";
options.ToolboxFiles = [dir2files("src")]
options.ToolboxMatlabPath = "src";
matlab.addons.toolbox.packageToolbox(options);
clear folder UUID options

function files = dir2files(directory)
    % returns all files in a relative directory
    % dir2files is recursive
    files = dir(folder + directory + "/**/?*");
    files = string({files.folder}) + "/" + string({files.name});
end

