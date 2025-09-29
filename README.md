# Description
Simple bash script that puts together multiple tools that allows you to take ScreenShots in wlroots-based compositors.

  > ***Note:*** This has only been tested in Arch Based Distros.
    But there's a good change it works in other distros if you install the dependencies.
# Install using Curl
> :warning: **Warning:** Be careful when running scripts from the internet.

You can run the install script with:
```bash
curl -s -o- https://raw.githubusercontent.com/danielpolov/simplewayshot/refs/heads/main/install.sh | bash
```

# Manual Installation
First install the following dependencies ***(Important)***:
  * grim - Terminal based tool to take screenshots.
  * slurp - Allows to select a region of the screen.
  * zenity - Basic gtk dialog windows.
  * wlr-randr - To Manage display settings.
  * jq - To process JSON output

Quick installation commands:
* From Arch official repositories:
```bash
sudo pacman -S grim slurp zenity wlr-randr jq
```
* If you wanna try Ubuntu/Ubuntu-based:
```bash
sudo apt install grim slurp zenity wlr-randr jq
```
* or Fedora/Fedora-based:
```bash
sudo dnf install grim slurp zenity wlr-randr jq
```

Download the repo:
* Clone the repo
```bash
git clone --depth 1 https://github.com/danielpolov/simplewayshot.git \
$HOME/.local/share/simplewayshot
```
* Jump into folder:
```bash
cd ~/.local/share/simplewayshot
```
* Make ***simplewayshot.sh** executable
```bash
chmod +x ./simplewayshot.sh
```

# How to use
Create a keybind. Example in hyprland:
```plaintext
bind = SUPER SHIFT, D, exec, ~/.local/share/simplewayshot/simplewayshot.sh -o
or
bind = SUPER SHIFT, D, exec, simplewayshot -o #If you installed it with curl
```
Example in SwayWM:
```plaintext
bindsym Mod4+Shift+d ~/.local/share/simplewayshot/simplewayshot.sh -o
or
bindsym Mod4+Shift+d simplewayshot -o #If you installed it with curl
```
When executing it this is what you'll see.
![SimpleWayshot Options](screenshots/simplewayshot.jpg)
