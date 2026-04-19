case "$TERM" in
    screen*) PROMPT_COMMAND='echo -ne "\033k\033\0134\033k`basename ${PWD}`\033\0134"'
esac
alias grep='grep --exclude-dir=__pycache__ --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=docs'
alias pygrep='grep --include=*.py  --exclude=*.pyc'
alias hgrep='grep --include=*.html --include=*.tag --include=*.tpl --exclude=*~'
alias jgrep='grep --include=*.js --include=*.jsx --exclude=*.map --exclude=yarn.lock'
alias mgrep='pygrep --exclude=0*.py --exclude=tests/'
alias arst='setxkbmap us'
alias asdf='setxkbmap us -v colemak'
alias dc='docker-compose'
alias rescreen='screen -X eval "chdir $PWD"'
export EDITOR='emacs'
export VISUAL='emacs'

function cfp {
    cd ~/laddr/;
    for i in `hgrep $1 * -rl`;
    do
        $2 ~/_laddr/$i;
    done
}
function cfpa {
    cd ~/laddr/;
    for i in `grep $1 * -rl`;
    do
        $2 ~/_laddr/$i;
    done
}
function gitdeletebranch {
   git branch -d $1
   git push origin :$1
}

export STATIC_ROOT=.static/;

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

function tt {
    if [ ! -f $1 ]; then
        echo "File not found!"
        return
    fi
    NAME=$1
    CMD=tmux # set to echo for debug
    $CMD kill-session -t $NAME
    $CMD new -s $NAME -d

    cat $1| while read LINE;
    do
        # ignore everything after the first "#". Any line that doesn't match a file is considered a comment
        IFS='#' read -ra PARTS <<< "$LINE"
        FNAME=`trim ${PARTS[0]}`
        if [[ ! -f $FNAME ]]; then continue; fi

        # split by slashes and grab last folder as tmux window name
        wname="uN"
        if [[ "$FNAME" =~ ([^/])/[^/]+$ ]]; then
            wname="${BASH_REMATCH[1]}"
        fi
        $CMD new-window -n $wname emacs $FNAME
    done
    $CMD kill-window -t :0 # kill first window since it's empty
    $CMD a
}

function e {
    if command -v deactivate > /dev/null; then deactivate; fi
    if [[ -d .venv ]]; then source .venv/bin/activate; fi
    if [[ -d ../.venv ]]; then source ../.venv/bin/activate; fi

    if [[ -e .envrc ]]; then source .envrc; fi
}
function e2 {
    if [[ -d .e2 ]]; then source .e2/bin/activate; fi
    if [[ -d .venv2 ]]; then source .venv2/bin/activate; fi
}

function derp {
    if [[ $1 = "gulp" ]] || [[ $1 = "watch" ]]
    then
        pkill gulp
    fi

    if [[ $1 = "grep" ]]
    then
        for DIR in unrest under-construction tw ih drop lablackey media txrx.org unrest_comments under-construction;
        do
            grep $2 $DIR/* -r
        done
        return
    fi

    for DIR in unrest under-construction tw ih dh #`ls`
    do
        if [ -f $DIR/.git/config ] && grep "bare...false" $DIR/.git/config > /dev/null
        then
            if [[ $1 = "hash" ]]
            then
                echo $DIR @ `cd $DIR;git rev-parse HEAD;cd ..`
            elif [[ $1 = "pull" ]]
            then
                echo pulling $DIR
                cd $DIR; git pull & cd ..
            fi
        fi
        if [ -f $DIR/gulpfile.js ]
        then
            if [[ $1 = "gulp" ]]
            then
                cd $DIR; gulp & cd ..
            elif [[ $1 = "watch" ]]
            then
                cd $DIR; gulp watch & cd ..
            fi
        fi
    done
    wait
}

function eemacs {
    DNE=()
    if ! test -f $1;
    then
        echo "first file must exist!"
        return 1
    fi

    for FILE in $*;
    do
        if test -f "$FILE"
        then emacs $FILE;
        else DNE+=($FILE)
        fi
    done
    for FILE in $DNE;
    do
        echo "Missing: $FILE"
    done
}

function git-next {
    # step forward in git to next commit (only works if history is linear)
    git checkout $(git rev-list --topo-order HEAD..towards | tail -1)
}

function git-temp-staging {
    BRANCH=`git rev-parse --abbrev-ref HEAD`
    echo Attempting to deploy $BRANCH to temp-staging
    git push origin $BRANCH:temp-staging -f
}

alias gcut="cut -d: -f1|sort -u"

function awssh {
    ssh -i ~/.ssh/AWS-prod.pem ec2-user@$1
}

function udssh {
    ssh -i ~/.ssh/Underdogio.pem ec2-user@$1
}

function runcpp {
    rm -f _$NAME.exe
    NAME="${1%.cpp}"
    g++ $1 -o _$NAME.exe
    ./_$NAME.exe
}

function bdiff {
    mv .gitattributes __gitattributes
    touch .gitattributes
    git diff
    mv __gitattributes .gitattributes
}

function png2svg {
    FNAME=$(basename -- "$1")
    extension="${FNAME##*.}"
    FNAME="${FNAME%.*}"

    png2pnm $1
    potrace $FNAME.pnm -s
    rm $FNAME.pnm
}

function png2pnm {
    FNAME=$(basename -- "$1")
    extension="${FNAME##*.}"
    FNAME="${FNAME%.*}"

    convert $1 -background white -alpha remove -alpha off $FNAME.pnm
}

function git-prune-branches {
    local current merged
    current=$(git branch --show-current)
    merged=$(git branch --merged | sed 's/^[* ]*//' | xargs -n1)

    local -a names ages flags
    while IFS= read -r branch; do
        [[ "$branch" == "$current" ]] && continue
        [[ -z "$branch" ]] && continue
        local age flag
        age=$(git log -1 --format='%cr' "$branch" 2>/dev/null || echo "unknown")
        if grep -qxF "$branch" <<< "$merged"; then
            flag="-d (merged)"
        else
            flag="-D (NOT merged)"
        fi
        names+=("$branch")
        ages+=("$age")
        flags+=("$flag")
    done < <(git for-each-ref --sort=committerdate --format='%(refname:short)' refs/heads/)

    if [[ ${#names[@]} -eq 0 ]]; then
        echo "No branches to delete (only $current exists)."
        return 0
    fi

    echo ""
    echo "Local branches (current: $current):"
    echo "---"
    for j in "${!names[@]}"; do
        printf "  %2d) %-40s  %-20s  %s\n" $((j+1)) "${names[$j]}" "${ages[$j]}" "${flags[$j]}"
    done
    echo ""

    local input
    read -rp "Enter branch numbers to delete (space/comma separated, or q to quit): " input
    [[ "$input" == "q" || -z "$input" ]] && echo "Aborted." && return 0

    local -a selections to_delete delete_ages delete_flags
    IFS=', ' read -ra selections <<< "$input"
    for sel in "${selections[@]}"; do
        [[ -z "$sel" ]] && continue
        if ! [[ "$sel" =~ ^[0-9]+$ ]] || (( sel < 1 || sel > ${#names[@]} )); then
            echo "Invalid selection: $sel"
            return 1
        fi
        local idx=$((sel - 1))
        to_delete+=("${names[$idx]}")
        delete_ages+=("${ages[$idx]}")
        delete_flags+=("${flags[$idx]}")
    done

    if [[ ${#to_delete[@]} -eq 0 ]]; then
        echo "No branches selected."
        return 0
    fi

    echo ""
    echo "Branches flagged for deletion:"
    echo "---"
    for j in "${!to_delete[@]}"; do
        printf "  %-40s  %-20s  %s\n" "${to_delete[$j]}" "${delete_ages[$j]}" "${delete_flags[$j]}"
    done
    echo ""
    local confirm
    read -rp "Are you sure? (y/Y to confirm): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        return 0
    fi

    for j in "${!to_delete[@]}"; do
        local branch="${to_delete[$j]}"
        if [[ "${delete_flags[$j]}" == *"merged"* ]]; then
            git branch -d "$branch"
        else
            git branch -D "$branch"
        fi
    done
    echo "Done."
}

function statusall {
    local do_push=false
    if [ "$1" = "--push" ]; then do_push=true; fi
    local clean=()
    local pushed=()
    for dir in ~/projects/*/; do
        if [ -d "$dir/.git" ]; then
            local name=$(basename "$dir")
            local status=$(git -C "$dir" status -s)
            local unpushed=$(git -C "$dir" log --oneline @{u}..HEAD 2>/dev/null)
            if [ -z "$status" ] && [ -z "$unpushed" ]; then
                clean+=("$name")
            else
                echo "=== $name ==="
                [ -n "$status" ] && echo "$status"
                if [ -n "$unpushed" ]; then
                    if $do_push; then
                        local push_output
                        push_output=$(git -C "$dir" push 2>&1)
                        if [ $? -eq 0 ]; then
                            echo "  **pushed**"
                            pushed+=("$name")
                        else
                            echo "$push_output"
                        fi
                    else
                        echo "  unpushed:"
                        echo "$unpushed" | sed 's/^/    /'
                    fi
                fi
                echo
            fi
        fi
    done
    if [ ${#pushed[@]} -gt 0 ]; then
        echo "=== pushed ==="
        printf '    %s\n' "${pushed[@]}"
    fi
    if [ ${#clean[@]} -gt 0 ]; then
        echo "=== no changes ==="
        printf '    %s\n' "${clean[@]}"
    fi
}

