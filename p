
p () {
    local DIR open CACHEDLIST PDFLIST
    PDFLIST="/tmp/fewijbbioasBBBB"
    CACHEDLIST="/tmp/fewijbbioasAAAA"
    DIR="${HOME}/.cache/pdftotext"
    mkdir -p "${DIR}"
    touch "$DIR/NOOP"
    if [ "$(uname)" = "Darwin" ]; then
        open=open
    else
        open="gio open"
    fi

    # escale filenames
    # compute xxh sum
    # replace separator by tab character
    # sort to prepare for join
    # remove duplicates
    ag -U -g ".pdf$"| sed 's/\([ \o47()"&;\\]\)/\\\1/g;s/\o15/\\r/g'  \
        | xargs xxh64sum \
        | sed 's/  /\t/' \
        | sort \
        | gawk '!seen[$1]++ {print $1, $2}' FS='\t' OFS='\t' \
        >| $PDFLIST

    # printed (hashsum,cached text) for every previously cached output of pdftotext
    # remove full path
    # replace separator by tab character
    # sort to prepare for join
    grep "" ~/.cache/pdftotext/* \
        | sed 's=.*cache/pdftotext/==' \
        | sed 's/:/\t/' \
        | sort \
        >| $CACHEDLIST

    {
        echo " "; # starting to type query sends it to fzf right away
        join -t '	' $PDFLIST $CACHEDLIST; # already cached pdfs
        # Next, apply pdftotext to pdfs that haven't been cached yet
        comm -13 \
            <(cat $CACHEDLIST | gawk  '{print $1}' FS='\t' OFS='\t') \
            <(cat $PDFLIST | gawk '{print $1}' FS='\t' OFS='\t') \
            | join -t '	' - $PDFLIST \
            | gawk '!seen[$1]++ {print $1, $2}' FS='\t' OFS='\t' \
            | \
            while read -r LINE; do
                local CACHE
                IFS=$'\t'; set -- $LINE;
                CACHE="$DIR/$1"
                pdftotext -f 1 -l 2 "$2" - 2>/dev/null | tr "\n" "__" >| $CACHE
                echo -e "$1	$2	$(cat $CACHE)"
            done
} | fzf --reverse -e -d '\t'  \
    --with-nth=2,3 \
    --preview-window down:80% \
    --preview '
v=$(echo {q} | tr " " "|");
echo {2} | grep -E "^|$v" -i --color=always;
echo {3} | tr "__" "\n" | grep -E "^|$v" -i --color=always;
' \
    | gawk '{print $2}' FS='\t' \
    | sed 's/\([ \o47()"&;\\]\)/\\\1/g;s/\o15/\\r/g'  \
    | xargs $open > /dev/null 2> /dev/null

}
