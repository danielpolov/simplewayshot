# Description
Simple bash script to take screenshots in wayland.

  > ***Note:*** This is been tested in Arch based distros. 
  
# Install
First install the following dependencies ***(Important)***:
  * grim - Terminal based tool to take screenshots.
  * slurp - Allows to select a region of the screen.
  * zenity - Basic gtk dialog windows.
  * wlr-randr - To Manage display settings.
  * rofi-waylad - To display options to the user in a simple menu.

Quick installation commands:
  * From Arch official repositories:
    ```bash
    sudo pacman -S grim slurp zenity wlr-randr
    ```
  * From the AUR:
    ```bash
    yay -S rofi-wayland
    ```
Get the repo:
  * Jump where you want the repo to be installed. Eg:
    ```bash
    cd $HOME/.config
    ```
  * Clone the repo
    ```bash
    git clone https://github.com/danielpolov/simplewayshot.git
    ```
  * Jump into folder:
    ```bash
    cd simplewayshot
    ```
  * Make ***simplewayshot.sh** executable
    ```bash
    chmod +x ./simplewayshot.sh
    ```
# How to use
Create a keybind. Example in hyprland:
  ```plaintext
  bind = SUPER SHIFT, D, exec, path/to/simplewayshot.sh
  ```
This will execute the bash script and prompt you with a rofi menu.
