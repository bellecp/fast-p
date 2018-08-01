# This file is kept only for historical reasons.  
# It is recommended to use the go binary and the installatoin procedure
# describe at https://github.com/bellecp/fast-p

## Installation
# - install ``pdftotext``. This comes with the texlive distribution on linux or with poppler on OSX.
# - install ``fzf``: https://github.com/junegunn/fzf
# - install ``xxhash``: https://github.com/Cyan4973/xxHash
# - install ``GNU grep``,  ``ag`` (silver searcher)
# - clone the repository: ``$ git clone https://github.com/bellecp/fast-p.git`` 
# - add a line ``source fast-p/p`` to your .bashrc or .bash_profile
# - Run the command ``p``. The first run of the command will take some time to
# cache the text extracted from each pdf. Further runs of the command will be
# much faster since the text extraction will only apply to new pdfs.
#
## Usage
#
# Run the command ``p`` and start typing keywords to search for pdf.
# Type "enter" to view the pdf in the default viewer

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
        | awk 'BEGIN {FS="\t"; OFS="\t"}; !seen[$1]++ {print $1, $2}' \
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
            <(cat $CACHEDLIST | awk 'BEGIN {FS="\t"; OFS="\t"}; {print $1}') \
            <(cat $PDFLIST | awk 'BEGIN {FS="\t"; OFS="\t"}; {print $1}') \
            | join -t '	' - $PDFLIST \
            | awk 'BEGIN {FS="\t"; OFS="\t"}; !seen[$1]++ {print $1, $2}' \
            | \
            while read -r LINE; do
                local CACHE
                IFS="	"; set -- $LINE;
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
    | awk 'BEGIN {FS="\t"; OFS="\t"}; {print $2}'  \
    | sed 's/\([ \o47()"&;\\]\)/\\\1/g;s/\o15/\\r/g'  \
    | xargs $open > /dev/null 2> /dev/null

}
