#!/bin/zsh

#Default values
shotname=Screenshot-$(date +'%F_%H-%M-%S').jpg
appname=Wayshot
wheretosave=/tmp/

exec_rofi() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Options' \
		-mesg 'SS Options' \
		-theme $HOME/.config/simplewayshot/rofi-theme/style-2.rasi
}

show_options() {
	echo -e "Screen\nRegion" | exec_rofi
}

option_to_ss=$(show_options)

list_screens() {
	echo $(wlr-randr --json | exec_rofi
}

save_ss(){
	#Prompts the user with a dialog windows
	#where they can choose the directory and save the SS
	wheretosave=$(zenity --file-selection --save --filename=$shotname 2> /dev/null)
	if [ "$wheretosave" != "/tmp/" ]; then
		mv /tmp/$shotname $wheretosave
		notify-send -i $wheretosave --app-name=$appname "Saving ss in as $wheretosave"
	fi
}

#Where the magic happens. using grim to take the Screenshot
#and slurp to get the region of the screen
case $option_to_ss in
	"Screen")
		no_screens=$(wlr-randr --json | awk -F'"' '/name/ {print $4}' | wc -l)
		[ $no_screens -gt 1 ] && grim -o $list_screens $wheretosave$shotname ||	grim -o $(wlr-randr --json | awk -F'"' '/name/ {print $4}') $wheretosave$shotname
		save_ss
		;;
	"Region")
		grim -g "$(slurp)" $wheretosave$shotname
		save_ss
		;;
	*)
		#Checks if the user canceled the action or not
		notify-send -i dialog-cancel --app-name=$appname "Exiting SimpleWayshot, no ss was taken"
		;;
esac
