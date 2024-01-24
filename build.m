% make sure I'm in the right directory
assert(string(pwd) == "C:\Users\apambrose\Documents\My_Drive\Projects\MATLAB_Projects\matvisa");

% make sure everything is up-to-date and comitted
[~, status] = system("git status -sb");
if contains(status, "behind")
    error("local repo is behind remote, please pull" + status);
elseif contains(status, " M ")
    error("uncomitted changes found" + status)
elseif contains(status, "ahead")
    error("unpushed changes found" + status)
end

% run unit tests
test_results = runtests("tests");
if test_results.Failed > 0
    error("can not build if tests are failing...")
end

% update contents.m
choice = input("what would you like to build? (major, minor, bug, build", "s");
contents = readlines("src\Contents.m");
ver_line = split(contents(2), " ");
ver_str  = ver_line(3);
next_rev = bump_rev(ver_str, choice);
contents(2) = "% Version " + next_rev + " " + string(datetime("today"));
writelines(contents, "src\Contents.m");

% generate new toolbox
UUID = "dec8b9de-af41-45e3-8c4f-af0cc78c2ab4";
options = matlab.addons.toolbox.ToolboxOptions(pwd, UUID);
options.ToolboxName = "MATVISA";
options.ToolboxVersion = next_rev;
options.ToolboxImageFile = "resources\toolbox_logo.png";
options.Summary = "Control your test and measurement equiptment with MATLAB!";
options.Description = "";
options.AuthorName = "Austin Ambrose";
options.AuthorEmail = "austin.p.ambrose@gmail.com";
options.ToolboxGettingStartedGuide = "examples\matvisa_intro.mlx";
options.OutputFile = "bin\matvisa.mltbx";
options.ToolboxFiles = [dir2files("src"), dir2files("examples")];
options.ToolboxMatlabPath = "src"; % folders to add to path
matlab.addons.toolbox.packageToolbox(options);

% commit, push, and release
system("git commit -am 'v" + next_rev);
system("git push");
system("gh release create v"+ next_rev +" ./bin/MATVISA.mltbx")

% cleanup workspace
clear folder UUID options

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

function next_rev = bump_rev(cur_rev, type)
    arguments (Input)
        cur_rev (1,1) string
        type (1,1) string {mustBeMember(type, ["major", "minor", "bug", "build"])}
    end
    arguments (Output)
        next_rev (1,1) string
    end
    rev_struct = str2version(cur_rev);
    switch type
        case "major"
            rev_struct.major = rev_struct.major + 1;
            rev_struct.minor = 0;
            rev_struct.bug = 0;
            rev_struct.build = rev_struct.build + 1;
        case "minor"
            rev_struct.minor = rev_struct.minor + 1;
            rev_struct.bug = 0;
            rev_struct.build = rev_struct.build + 1;
        case "bug"
            rev_struct.bug = rev_struct.bug + 1;
            rev_struct.build = rev_struct.build + 1;
        case "build"
            rev_struct.build = rev_struct.build + 1;
    end
    next_rev = version2str(rev_struct);

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
end

