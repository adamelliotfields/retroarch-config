# retroarch-config

My settings and shader presets for RetroArch on Windows.

## Installation

In an admin shell, run `install.ps1 -Path <path_to_retroarch>` to symlink the configs to your RetroArch installation:

```powershell
# clone in ~/.retroarch
git clone https://github.com/adamelliotfields/retroarch-config.git $Env:UserProfile\.retroarch

# link the configs
.retroarch\install.ps1 -Path $Env:ProgramFiles\RetroArch
```
