# fast-p

Quickly find and open a pdf among a collection of thousands of unsorted pdfs through fzf (fuzzy finder)

- [Installation](#installation)
- [Usage](#usage)
- [See it in action](#see-it-in-action)
- [Is the historical bash code still available?](#is-the-historical-bash-code-still-available)

# Installation

1. __Requirements.__ Make sure the following requirements are satisfied:
    - install ``pdftotext``. This comes with the texlive distribution on linux or with poppler on OSX.
    On ubuntu, ``sudo apt-get install poppler-utils`` . On OSX, ``brew install poppler``.
    - install ``fzf``: https://github.com/junegunn/fzf
    - install ``GNU grep``,  ``ag`` (silver searcher)

2. __Install binary__. Do either one of the two steps below:
    - __Compile from source with ``go`` and ``go get``.__
    With a working ``golang`` installation, do 
    ```go get github.com/bellecp/fast-p```
    It will fetch the code and its dependencies,
    compile and create an executable ``fast-p`` in the ``/bin`` folder of your go
    installation, typically ``~/go/bin``. Make sure the command ``fast-p`` can be
    found (for instance, add ``~/go/bin`` to your ``$PATH``.)
    - Or: __Use the precompiled binary for your architecture.__ Download the binary that corresponds to your
    architecture at https://github.com/bellecp/fast-p/releases and make sure that
    the command ``fast-p`` can be found. Darwin is meant for OSX.  For instance,
    put the binary file ``fast-p`` in ``~/custom/bin`` and add ``export
    PATH=~/custom/bin:$PATH`` to your ``.bashrc``.

3. __Tweak your .bashrc__. Add the following code to your ``.bashrc``
```
p () {
    local open
    if [ "$(uname)" = "Darwin" ]; then
        open=open       # on OSX, "open" opens a pdf in preview
    else
        open=xdg-open   # this will open pdf file withthe default PDF viewer on KDE, xfce, LXDE and perhaps on other desktops.
    fi
    
    interactive_find() {
    # bash func to return the found pdf file name/path
        ag -U -g ".pdf$" \
        | fast-p \
        | fzf --read0 --reverse -e -d $'\t'  \
            --preview-window down:80% --preview '
                v=$(echo {q} | tr " " "|"); 
                echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
            ' \
        | gcut -z -f 1 -d $'\t' | tr -d '\n' | xargs -I F echo "F"
    }
    
    last_found_pdf=$(interactive_find) # store the last found pdf in the variable
    echo $last_found_pdf
    open $last_found_pdf
}

```
- You may replace ``ag -U -g ".pdf$"`` with another command that returns a list of pdf files.
- You may replace ``open=...`` by your favorite PDF viewer, for instance ``open=evince`` or ``open=okular``.

# Usage

Use the command ``p`` to browse among the PDF files in the current directory and its subdirectories.

The first run of the command will take some time to cache the text extracted from each pdf. Further runs of the command will be much faster since the text extraction will only apply to new pdfs.

# See it in action

![illustration of the p command](https://user-images.githubusercontent.com/1019692/34446795-12229072-ecac-11e7-856a-ec0df0de60ae.gif)


# Is the historical bash code still available?

Yes, see https://github.com/bellecp/fast-p/blob/master/p but using the go binary as explained above is recommended for speed and interoperability.

