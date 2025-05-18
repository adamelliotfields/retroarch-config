# retroarch-config

[RetroArch](https://github.com/libretro/RetroArch) stuff for Windows.

## Scripts

- [`install.ps1`](./scripts/install.ps1) - Symlinks the contents of [`retroarch`](./retroarch/) to a provided RetroArch installation.
- [`mirror.ps1`](./scripts/mirror.ps1) - Wrapper around [`robocopy /mir`](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy) with `-WhatIf` support.
- [`uninstall.ps1`](./scripts/uninstall.ps1) - Undoes `install.ps1`.

## Cores

Each has a configuration override (`.cfg`), core option (`.opt`), and shader preset (`.slangp`) file:

- [Beetle PCE](./retroarch/config/Beetle%20PCE/)
- [Beetle Saturn](./retroarch/config/Beetle%20Saturn/)
- [Dolphin](./retroarch/config/dolphin-emu/)
- [FinalBurn Neo](./retroarch/config/FinalBurn%20Neo/)
- [Flycast](./retroarch/config/Flycast/)
- [Geolith](./retroarch/config/Geolith/)
- [Mupen64Plus-Next](./retroarch/config/Mupen64Plus-Next/)
- [Nestopia](./retroarch/config/Nestopia/)
- [Opera](./retroarch/config/Opera/)
- [PCSX-ReARMed](./retroarch/config/PCSX-ReARMed/)
- [PicoDrive](./retroarch/config/PicoDrive/)
- [PPSSPP](./retroarch/config/PPSSPP/)
- [ProSystem](./retroarch/config/ProSystem/)
- [Snes9x](./retroarch/config/Snes9x/)
- [SwanStation](./retroarch/config/SwanStation/)
- [Virtual Jaguar](./retroarch/config/Virtual%20Jaguar/)

## Shaders

I made two shader presets inspired by [`xbr-lv3-2xsal-lv2-aa`](https://github.com/libretro/slang-shaders/blob/master/presets/xbr-xsal/xbr-lv3-2xsal-lv2-aa.slangp) and [`4xsal-level2-crt`](https://github.com/libretro/slang-shaders/blob/master/edge-smoothing/xsal/4xsal-level2-crt.slangp):

- [`2xbrz-deblur-mask-bright`](./retroarch/shaders/2xbrz-deblur-mask-bright.slangp)
- [`lanczos-mask-bright`](./retroarch/shaders/lanczos-mask-bright.slangp)

The first uses [`2xBRZ`](https://github.com/libretro/slang-shaders/blob/master/edge-smoothing/xbrz/shaders/2xbrz.slang) to scale the image. I found `freescale` too smooth on a larger screen, and `6x` too expensive for an iGPU. Since the result is blurred from bilinear filtering, I then use hyllian's [`deblur-luma`](https://github.com/libretro/slang-shaders/blob/master/deblur/shaders/deblur-luma.slang). The luma variant focuses on brightness differences between pixels, which helps with sharpness.

For cores that do internal scaling, I use [`lanczos2-5-taps`](https://github.com/libretro/slang-shaders/blob/master/interpolation/shaders/lanczos2-5-taps.slang) interpolation instead.

Finally, both apply torridgristle's [`SinPhosphor`](https://github.com/libretro/slang-shaders/blob/master/crt/shaders/dotmask.slang) mask and [`Brighten`](https://github.com/libretro/slang-shaders/blob/master/crt/shaders/torridgristle/Brighten.slang) pass.

## Notes

I install to `/RetroArch-Win64` so I can run `winget upgrade retroarch` to update.
