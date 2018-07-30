## Installation


#### requirements

- install ``pdftotext``. This comes with the texlive distribution on linux or with poppler on OSX.
- install ``fzf``: https://github.com/junegunn/fzf
- install ``GNU grep`` and ``ag`` (silver searcher)

#### Install binary

Download the binary that corresponds to your architecture at https://github.com/bellecp/fast-p/releases
and make sure that the command ``fast-p`` can be found.

For instance, put the binary file ``fast-p`` in ``~/go/bin`` and add
``export PATH=~/gobin;$path`` to your ``.bashrc``.

#### Next, add the following code to your .bashrc

```
p () {
    ag -U -g ".pdf$" \
    | fast-p \
    | fzf --read0 --reverse -e -d $'\t'  \
        --preview-window down:80% --preview '
            v=$(echo {q} | tr " " "|"); 
            echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
        ' \
    | cut -z -f 1 -d $'\t' | tr -d '\n' | xargs --null open
}

```


Use the command ``p`` to browse among your pdfs.
The first run of the command will take some time to cache the text extracted from each pdf. Further runs of the command will be much faster since the text extraction will only apply to new pdfs.
