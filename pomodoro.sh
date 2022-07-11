#!/bin/bash
# POMODORO in YA TerMINAL ;)

RET=''

function pomo {
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    ORANGE='\033[0;33m'
    printf "${ORANGE}POMODORO in YA TERMINAL${NC}\n"

    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo "usage: pomo       25 minute cycle"
        echo -e "   or: pomo [break]['_message_']  see options below\n"
        echo "Options:"
        echo "  d: timer duration in minutes"
        echo "  s: 05 minute break"
        echo "  l:  15 minute break"
        echo "  message: Your message to display"
        return
    fi

    if [[ "$1" == "-v" ]] || [[ "$1" == "--version" ]]; then
        echo -e "${ORANGE}POMODORO TIMER BY RUKSHAN"
        echo "  v: 1.0.0.1"
        echo "  twitter: @justruky"
        echo "  blog: rukshn.github.io"
        echo -e "  email: arkruka[@]gmail.com"
        return
    fi

    TITLE="POMODORO TIMER"
    MESSAGE=""
    # ICON="face-cool"
    ICON="audio-volume-medium"
    BEEP="_alarm 400 200"
    TIMER=1500
    SESSION=false

    while :
    do
        case "$1" in
        -d | --duration)
            TIMER=$(($2*60))
            shift 2
            ;;
        -l | --long-break)
            MESSAGE="Long is break over, back to work"
            TIMER=1200
            shift
            ;;
        -s | --short-break)
            MESSAGE="Short is break over, back to work"
            TIMER=300
            shift
            ;;
        -r | --rounds)
          SESSION=true
          shift 2
          ;;
        -*)
          echo "Error: Unknown option: $1" >&2
          return 1
          ;;
        *)  # No more options
          break
          ;;
        esac
    done

    if [ -n "$1" ]; then
        MESSAGE="$1"
    elif [ -z "$MESSAGE" ]; then
        MESSAGE="It's time to take a break"
    fi

    # LINUX users
    if [[ "$(uname)" == "Linux" ]]; then
        RET="sleep $TIMER && notify-send \"$TITLE\" \"$MESSAGE\" --icon=$ICON && $BEEP "
    # MAC users
    elif [[ "$(uname)" == "Darwin" ]]; then
        RET="sleep $TIMER && terminal-notifier -message '$MESSAGE' -title 'Pomodoro' --subtitle '$TITLE' && $BEEP "
    else
        RET="";
    fi

    if [ "$SESSION" = false ]; then
      echo -e "${RED}ROUNDS SET FOR $(($TIMER/60)) MINUTES"
      eval "($RET &)"
    fi
}

pomo_session() {
    pomo $@
    POMO=$RET
    pomo -s -r 0
    POMO_BREAK_SHORT=$RET
    pomo -l -r 0
    POMO_BREAK_LONG=$RET
    ROUNDS=0
    EACH=4

    if [ $1 == "-r" ]; then
        ROUNDS=$(($2*$EACH))
    elif [ $3 == "-r" ]; then
        ROUNDS=$(($4*$EACH))
    fi

    CMD=""

    # Loop X times
    echo -e "${RED}POMODORO TIMER LOOP $ROUNDS"
    for ((i = 1; i <= $ROUNDS; i++)); do
        CMD="$CMD $POMO &&"
        if [ $((i%$EACH)) -eq 0 ]; then
            CMD="$CMD $POMO_BREAK_LONG &&"
        else
            CMD="$CMD $POMO_BREAK_SHORT &&"
        fi
    done

    CMD="${CMD::-1}"

    eval "($CMD)"
}

_alarm() {
    if [[ "$(uname)" == "Linux" ]]; then
        paplay notification.ogg
    elif [[ "$(uname)" == "Darwin" ]]; then
        say -v bells 'beep'
    fi
}
