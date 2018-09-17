# fast-p

Quickly find and open a pdf among a collection of thousands of unsorted pdfs through fzf (fuzzy finder)

- [Installation on Linux](#installation-on-unix-or-linux-based-systems)
- [Installation on OSX](#installation-on-osx-with-homebrew)
- [Usage](#usage)
- [See it in action](#see-it-in-action)
- [Is the historical bash code still available?](#is-the-historical-bash-code-still-available)

# Installation on Unix or Linux based systems

1. __Requirements.__ Make sure the following requirements are satisfied:
    - install ``pdftotext``. This comes with the texlive distribution on linux,
    On ubuntu, ``sudo apt-get install poppler-utils`` . 
    - install ``fzf``: https://github.com/junegunn/fzf
    - install ``GNU grep``,  ``ag`` (silver searcher).

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
    the command ``fast-p`` can be found. For instance,
    put the binary file ``fast-p`` in ``~/custom/bin`` and add ``export
    PATH=~/custom/bin:$PATH`` to your ``.bashrc``.

3. __Tweak your .bashrc__. Add the following code to your ``.bashrc``
```
p () {
    open=xdg-open   # this will open pdf file withthe default PDF viewer on KDE, xfce, LXDE and perhaps on other desktops.

    ag -U -g ".pdf$" \
    | fast-p \
    | fzf --read0 --reverse -e -d $'\t'  \
        --preview-window down:80% --preview '
            v=$(echo {q} | tr " " "|"); 
            echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
        ' \
    | cut -z -f 1 -d $'\t' | tr -d '\n' | xargs -r --null $open > /dev/null 2> /dev/null
}

```
- You may replace ``ag -U -g ".pdf$"`` with another command that returns a list of pdf files.
- You may replace ``open=...`` by your favorite PDF viewer, for instance ``open=evince`` or ``open=okular``.

# Installation on OSX with homebrew

1. Install [homebrew](https://brew.sh/) and  __run__
```
brew install bellecp/fast-p/fast-pdf-finder
```
_This is experimental. Please report any issues/suggestions/feedback at <https://github.com/bellecp/fast-p/issues/11>_


2. __Tweak your .bashrc__. Add the following code to your ``.bashrc``
```
p () {
    local open
    open=open   # on OSX, "open" opens a pdf in preview
    ag -U -g ".pdf$" \
    | fast-p \
    | fzf --read0 --reverse -e -d $'\t'  \
        --preview-window down:80% --preview '
            v=$(echo {q} | gtr " " "|"); 
            echo -e {1}"\n"{2} | ggrep -E "^|$v" -i --color=always;
        ' \
    | gcut -z -f 1 -d $'\t' | gtr -d '\n' | gxargs -r --null $open > /dev/null 2> /dev/null
}

```
- You may replace ``ag -U -g ".pdf$"`` with another command that returns a list of pdf files.
- You may replace ``open=...`` by your favorite PDF viewer, for instance ``open=evince`` or ``open=okular``.

__Remark:__ On OSX, we use the command line tools ``gcut``, ``gxargs``, ``ggrep``, ``gtr`` which are the GNU versions
of the tools ``cut``, ``xargs``, ``grep``, ``tr``. This way, we avoid the versions of these tools pre-installed on OSX
the same ``.bashrc`` code can be used for OSX and Linux systems.

# Usage

Use the command ``p`` to browse among the PDF files in the current directory and its subdirectories.

The first run of the command will take some time to cache the text extracted from each pdf. Further runs of the command will be much faster since the text extraction will only apply to new pdfs.

# See it in action

![illustration of the p command](https://user-images.githubusercontent.com/1019692/34446795-12229072-ecac-11e7-856a-ec0df0de60ae.gif)


# Is the historical bash code still available?

Yes, see https://github.com/bellecp/fast-p/blob/master/p but using the go binary as explained above is recommended for speed and interoperability.

