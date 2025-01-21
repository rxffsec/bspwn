#! /bin/bash -

#modded

help_and_exit() {
  cat <<-EOF
  Usage: scregcp [-h|-s|-c] [<screenshots_base_folder>]

  Take screenshot of a whole screen or a specified region,
  save it to a specified folder (current folder is default)
  and copy it to a clipboard.

    -h   - print help and exit
    -r   - take a screenshot of a screen region
    -rc  - copy region to clipbard (doesn't save)
    scc.sh /path/to/save/ <- to directly save full screen
EOF
    exit 0
}

basefolder="${2}"
filepath=${basefolder}$( date '+%Y-%m-%d_%H-%M-%S' )_screenshot.png

while test $# -gt 0; do
  case "$1" in
    -h|--help*)
      help_and_exit
      ;;

# selects a region and saves
   -r)
	import ${filepath}; xclip -selection clipboard -target image/png -i < ${filepath}; notify-send -u low 'screenshot region saved'	
	shift
	;;
# selects a region and copies to clipboard    
    -rc)
	import ${filepath}; xclip -selection clipboard -target image/png -i < ${filepath}; rm ${filepath}; notify-send -u low 'screenshot region saved to clipboard'
	shift
	;;
# anything else	
    *)
      if [[ $1 =~ ^\- ]] ; then
        echo "error: unknown flag '$1'"
        help_and_exit
      fi
# saves full screenshot
      base_folder="${1}"
	filepath=${basefolder}$( date '+%Y-%m-%d_%H-%M-%S' )_screenshot.png
	import ${filepath}
	notify-send -u low 'screenshot saved'
	shift
      ;;
  esac
done

####################################################################
#basefolder="./"
#savefile=true
#region=false
#params="-window root"
#
#while test $# -gt 0; do
#  case "$1" in
#    -h|--help*)
#      help_and_exit
#      ;;
# -r|--region*)
#      params=""
#      shift
#      ;;
#    -c|--clipboard-only*)
#      savefile=false
#      shift
#      ;;
## anything else	
#    *)
#      if [[ $1 =~ ^\- ]] ; then
#        echo "error: unknown flag '$1'"
#        help_and_exit
#      fi
# saves full screenshot
#      base_folder="${1}"
#	import ${filepath}
#	shift
#      ;;
#  esac
#done
#
#filepath=${base_folder}$( date '+%Y-%m-%d_%H-%M-%S' )_screenshot.png
#import ${params} ${filepath}
#xclip -selection clipboard -target image/png -i < ${file_path}
#if [ "$savefile" = false ] ; then
#  rm ${file_path}
#fi

