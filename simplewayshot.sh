#!/usr/bin/env bash

#initial values
shotname=Screenshot-$(date +'%F_%H-%M-%S').png
appname=SimpleWayshot
where_to_save=/tmp/
main_opts=(" --extra-button=Screen" " --extra-button=Region")
main_dir="$(dirname "$(realpath "$0")")"

zenity_opts() {
	local -n screens=$3
	zenity --question --text="$1" --title="$2" ${screens[@]} --switch
}

clean_tmp() {
	rm /tmp/$shotname
}

#Prompts the user with a dialog window
#where they can choose the directory to save the ScreenShot
save_ss(){
	where_to_save=$(zenity --file-selection --save --filename=$shotname 2> /dev/null)
	if [ -z "$where_to_save" ]; then
		clean_tmp
		notify_user_cancel "You didn't select a Directory. Nothing was saved."
		return
	fi
	if [ -w "$(dirname "$where_to_save")" ]; then
		mv /tmp/$shotname $where_to_save
		notify-send -i $where_to_save --app-name=$appname "Saving SS as $where_to_save"
		return
	fi
	zenity --error --title="Fatal Error" --text="You do not have the correct permissions."
	save_ss
}

notify_user_cancel(){
	notify-send -i dialog-cancel --app-name=$appname "$1"
}

#Where the magic happens. using grim to take the Screenshot
#slurp to get the region of the screen
#zenity to show the GTK dialog
take_ss_options(){
	local option_to_ss=$(zenity_opts "What do you want to ScreenShot" $appname main_opts)
	case $option_to_ss in
		"Screen")
			local no_screens=$(wlr-randr --json | jq 'map(select((.enabled? // .active? // .connected?) == true)) | length')
			local screen_to_ss=""
			if [ no_screens -gt 1 ]; then
				local list_of_screens=($(wlr-randr --json | jq -r '.[] | select(.enabled? // .connected? // .active?) | .name'))
				local list_of_options=()
				for screen in "${list_of_screens[@]}"; do
					list_of_options+=(' --extra-button='"$screen")
				done
				screen_to_ss=$(zenity_opts "Which Screen" $appname list_of_options)
			else
				screen_to_ss=$(wlr-randr --json | awk -F'"' '/name/ {print $4}')
			fi
			if [ -n "$screen_to_ss" ]; then
				grim -o $screen_to_ss $where_to_save$shotname 2> /dev/null
				save_ss
			else
				notify_user_cancel "You didn't select a Screen. Nothing was saved."
			fi
			;;
		"Region")
			take_ss_region
			;;
		*)
			#If the user closes the dialog, this will be executed
			notify_user_cancel "Exiting SimpleWayshot. No ss was taken."
			;;
	esac
}

take_ss_screen() {
	grim $where_to_save$shotname
	save_ss
}

take_ss_region() {
	local region=$(slurp 2> /dev/null)
	if [ -n "$region" ]; then
		grim -g "$region" $where_to_save$shotname
		save_ss
	else
		notify_user_cancel "You din't select a Region. Nothing was saved."
	fi
}

show_help() {
	cat <<EOF
	Usage: ${0##*/} [OPTIONS]
	You can use one of the following options.
	
	Options:
	-h,   Show this help message
	-s,   Uses the main screen to take the screenshot
	-r,   Select a region to take the ScreenShot
	-o,   Launches Zenity with two options(Screen or Region). If you have multiple screens, the screen option will prompt you with a list to select the one you want.
	
	Examples:
	${0##*/} -o
EOF
}

main() {
	while getopts 'sroh' OPTION; do
		case "$OPTION" in
			s)
				take_ss_screen
				;;
			r)
				take_ss_region
				;;
			o)
				take_ss_options
				;;
			h)
				show_help
				;;
			*)
				zenity --error --text="Invalid Option" --title="SimpleWayshot"
		esac
	done
}

main "$@"

