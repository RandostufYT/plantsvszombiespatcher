
# Plants vs Zombies Patcher

This Patcher uses QuickBMS by Luigi Auriemma under GPL-2.0 license.
Web: https://aluigi.altervista.org/quickbms.htm

## Features
- NSIS based
- Patches game (unpacking main.pak file)
- Creates main.pak backup
- No administrator privileges required (unless the game is installed in system directories)
- Clean and fully automatic function (no need of creating / deleting files manually)
- Creates unpatcher file reverting applied changes
- Option to bring back old Disco Zombie (Michael Jackson Zombie)


## Authors

- [@marcinolak](https://www.github.com/marcinolak)


## Installation

This software requires no installation. It's fully portable.
    
## FAQ

#### Where should I put this patcher for it to work?

You can run this application wherever you want. For example, in the main game folder (recommended) or on the desktop. The patcher can automatically recognize the main.pak file and if it is not in the patcher.exe directory, it will ask for the location.

#### Why this patcher looks like installer? You said there is no installation required...

This patcher is based on NSIS (Nullsoft Scriptable Install System) "a professional open source system to create Windows installers" that's why it looks like installer. HOWEVER it DOES NOT install anything at all!

#### It doesn't work!

It's very likely you're trying to process game files installed in system directory not portable game version. Try to run patcher.exe with elevated privileges.


## License

[GPL-2.0 license](https://choosealicense.com/licenses/gpl-2.0/)

