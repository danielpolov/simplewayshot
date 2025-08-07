#!/bin/bash

#Default values
shotname=Screenshot-$(date +'%F_%H-%M-%S').jpg
appname=SimpleWayshot
wheretosave=/tmp/
main_opts=(" --extra-button=Screen" " --extra-button=Region")
main_dir="$(dirname "$(realpath "$0")")"

exec_zen() {

	local -n arr=$3

	zenity --question --text="$1" --title="$2" ${arr[@]} --switch

}

option_to_ss=$(exec_zen "What do you want to ScreenShot" "SimpleWayshot" main_opts)

list_screens() {
	echo $(wlr-randr --json | exec_rofi)
}

save_ss(){
	#Prompts the user with a dialog windows
	#where they can choose the directory and save the SS
	wheretosave=$(zenity --file-selection --save --filename=$shotname 2> /dev/null)
	if [ "$wheretosave" != "/tmp/" ]; then
		mv /tmp/$shotname $wheretosave
		notify-send -i $wheretosave --app-name=$appname "Saving SS as $wheretosave"
	fi
}

#Where the magic happens. using grim to take the Screenshot
#and slurp to get the region of the screen
case $option_to_ss in
	"Screen")
		no_screens=$(wlr-randr --json | awk -F'"' '/name/ {print $4}' | wc -l)
		if [ no_screens -gt 1 ]; then
			list_of_screens=($(wlr-randr --json | awk -F'"' '/name/ {print $4}'))
			list_of_options=()
			for screen in "${list_of_screens[@]}"; do
				list_of_options+=(' --extra-button='"$screen")
			done
			screen_to_ss=$(exec_zen "Which Screen" "SimpleWayshot" list_of_options)
			grim -o $screen_to_ss $wheretosave$shotname
		else
			grim -o $(wlr-randr --json | awk -F'"' '/name/ {print $4}') $wheretosave$shotname
		fi
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

