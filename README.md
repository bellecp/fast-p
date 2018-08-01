# fast-p

Quickly find and open a pdf among a collection of thousands of unsorted pdfs through fzf (fuzzy finder)

# Installation

1. __Requirements.__ Make sure the following requirements are satisfied:
    - install ``pdftotext``. This comes with the texlive distribution on linux or with poppler on OSX.
    On ubuntu, ``sudo apt-get install poppler-utils`` . On OSX, ``brew install poppler``.
    - install ``fzf``: https://github.com/junegunn/fzf
    - install ``GNU grep``,  ``ag`` (silver searcher)

2. __Install binary__. Do either one of the two steps below:
    a. __Compile from source with ``go`` and ``go get``.__
    With a working ``golang`` installationm, do ``go get github.com/bellecp/fast-p``.
    It will fetch the code and its dependencies,
    compile and create an executable ``fast-p`` in the ``/bin`` folder of your go
    installation, typically ``~/go/bin``. Make sure the command ``fast-p`` can be
    found (for instance, add ``~/go/bin`` to your ``$PATH``.)
    b. __Install the binary.__ Download the binary that corresponds to your
    architecture at https://github.com/bellecp/fast-p/releases and make sure that
    the command ``fast-p`` can be found. Darwin is meant for OSX.  For instance,
    put the binary file ``fast-p`` in ``~/custom/bin`` and add ``export
    PATH=~/custom/bin:$PATH`` to your ``.bashrc``.

3.Next, add the following code to your ``.bashrc``
```
p () {
    ag -U -g ".pdf$" \
    | fast-p \
    | fzf --read0 --reverse -e -d $'\t'  \
        --preview-window down:80% --preview '
            v=$(echo {q} | tr " " "|"); 
            echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
        ' \
    | cut -z -f 1 -d $'\t' | tr -d '\n' | xargs -r --null $open
}

```

# Usage

Use the command ``p`` to browse among your pdfs.
The first run of the command will take some time to cache the text extracted from each pdf. Further runs of the command will be much faster since the text extraction will only apply to new pdfs.


# Is the historical bash code still available?

Yes, see https://github.com/bellecp/fast-p/blob/master/p but using the go binary as explained above is recommended for speed and interoperability.

