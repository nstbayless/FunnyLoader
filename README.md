# FunnyLoader
The first "bootloader" (launcher selector) for the Panic Playdate

## Installation Instructions
1. Download os-download-x.x.x.py from the [releases](https://github.com/RintaDev5792/FunnyOS) page of FunnyOS
1. Run os-download and follow the instructions. After it is complete, you should have a .pdos and a .pdkey file in the same directory
1. Rename the PlaydateOS.pdos file to a .zip and unzip it
1. Go into the new folder and then /System, and create a folder named "Launchers" inside of it with that exact capitalisation
1. Copy the default Launcher.pdx from /System to /System/Launchers and rename it to "StockLauncher.pdx"
1. Copy your FunnyLauncher.pdx (available from the releases page of this repo) into /System (NOT /LAUNCHERS) and rename it to "Launcher.pdx"
1. Copy your .pdx files for all of the launchers you are using into /System/Launchers
1. Name all of the .pdx files in /System/Launchers how you want them to show up in the FunnyLauncher list
1. Re-zip the PlaydateOS folder, if on macos open a terminal in the folder (not in System, in the root) and run "zip -r ../PlaydateOS-Patched.zip ."
1. Rename your NEW zip to a .pdos
1. Download [Playdate Utility](https://download-cdn.panic.com/playdate_utility/)
1. Open Playdate Utility, and plug in your Playdate to your computer
1. Click "Upgrade Firmware" and select your .pdos and .pdkey file in that order, wait while your playdate "installs system update"

If this at any point freezes or errors out during installation, especially multiple times in a row, you can (as a last resort) hold A+B+MENU+LOCK to enter recovery mode and flash stock OS. FunnyLauncher installations will just about always work when installing from stock OS.

## Usage Instructions
- Upon starting up your playdate for the first time after install, you will be greeted with a list of launchers that you put into the /Launchers directory earlier. If you do not see a list, you done fucked up. Redo installation.  
- Use the UP and DOWN buttons on playdate to navigate the list.   
- Select the launcher you want to use as your default and click B while it is selected. This means that your playdate will automatically boot into that launcher from now on.   
- Press A to launch a launcher (lol).   
- To get back to the list of launchers, open any app where the "home" option is available from the system menu. Then undock your crank and point it away from you (perpendicular to the rest of the unit). Then navigate to the "home" option with the dpad and select it with A. You will now be in the FunnyLoader interface.  
  
- If at any time you have an invalid default or are having other errors, hold LEFT+LOCK+MENU and plug your playdate into a computer. Then delete the /Shared/FunnyLoader folder on the playdate, this will reset your FunnyLoader to default.  
