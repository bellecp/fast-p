## Installation


#### requirements

- install ``pdftotext``. This comes with the texlive distribution on linux or with poppler on OSX.
- install ``fzf``: https://github.com/junegunn/fzf
- install ``GNU grep`` and ``ag`` (silver searcher)

#### Install binary

Do either one of the two steps below:

1. _Install the binary._ Download the binary that corresponds to your architecture at https://github.com/bellecp/fast-p/releases
and make sure that the command ``fast-p`` can be found. Darwin is meant for OSX.
For instance, put the binary file ``fast-p`` in ``~/custom/bin`` and add
``export PATH=~/custom/bin:$PATH`` to your ``.bashrc``.

2. _Compile from source with ``go`` and ``go get``._
``go get github.com/bellecp/fast-p`` will fetch the code and its dependencies, compile and create an executable ``fast-p`` in the ``/bin`` 
folder of your go installation, typically ``~/go/bin``. Make sure the command ``fast-p`` can be found (for instance, add ``~/go/bin`` to your ``$PATH``.)

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
