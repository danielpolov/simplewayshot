#!/bin/bash

#Default values
shotname=Screenshot-$(date +'%F_%H-%M-%S').jpg
appname=SimpleWayshot
where_to_save=/tmp/
main_opts=(" --extra-button=Screen" " --extra-button=Region")
main_dir="$(dirname "$(realpath "$0")")"

exec_zen() {
	local -n arr=$3
	zenity --question --text="$1" --title="$2" ${arr[@]} --switch
}

clean_tmp() {
	rm /tmp/$shotname
}

#Prompts the user with a dialog windows
#where they can choose the directory and save the SS
save_ss(){
	where_to_save=$(zenity --file-selection --save --filename=$shotname 2> /dev/null)
	if [ -w "$(dirname "$where_to_save")" ]; then
		if [ "$where_to_save" != "" ]; then
			mv /tmp/$shotname $where_to_save
			notify-send -i $where_to_save --app-name=$appname "Saving SS as $where_to_save"
		else
			notify_user_cancel "You didn't select a Directory. Nothing was saved."
		fi
	else
		clean_tmp
		zenity --error --title="Fatal Error" --text="You do not have the correct permissions."
	fi
}

notify_user_cancel(){
	notify-send -i dialog-cancel --app-name=$appname "$1"
}

option_to_ss=$(exec_zen "What do you want to ScreenShot" "SimpleWayshot" main_opts)
#Where the magic happens. using grim to take the Screenshot
#and slurp to get the region of the screen
case $option_to_ss in
	"Screen")
		no_screens=$(wlr-randr --json | awk -F'"' '/name/ {print $4}' | wc -l)
		screen_to_ss=""
		if [ no_screens -gt 1 ]; then
			list_of_screens=($(wlr-randr --json | awk -F'"' '/name/ {print $4}'))
			list_of_options=()
			for screen in "${list_of_screens[@]}"; do
				list_of_options+=(' --extra-button='"$screen")
			done
			screen_to_ss=$(exec_zen "Which Screen" "SimpleWayshot" list_of_options)
		else
			screen_to_ss=$(wlr-randr --json | awk -F'"' '/name/ {print $4}')
		fi
		if [ "$screen_to_ss" != "" ]; then
			grim -o $screen_to_ss $where_to_save$shotname 2> /dev/null
			save_ss
		else
			notify_user_cancel "You didn't select a Screen. Nothing was saved."
		fi
		;;
	"Region")
		region=$(slurp 2> /dev/null)
		if [ "$region" != "" ]; then
			grim -g "$region" $where_to_save$shotname
			save_ss
		else
			notify_user_cancel "You din't select a Region. Nothing was saved."
		fi
		;;
	*)
		#Checks if the user cancelled the action or not
		notify_user_cancel "Exiting SimpleWayshot. No ss was taken."
		;;
esac

