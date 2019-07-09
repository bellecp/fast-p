# fast-p

Quickly find and open a pdf among a collection of thousands of unsorted pdfs through fzf (fuzzy finder)

- [Installation on Linux](#installation-on-unix-or-linux-based-systems)
- [Installation on OSX](#installation-on-osx-with-homebrew)
- [Usage](#usage)
- [How to clear the cache?](#how-to-clear-the-cache)
- [Launch with keyboard shortcut in Ubuntu](#launch-with-keyboard-shortcut-in-ubuntu)
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
_The above brew formula is experimental. 
Please report any issues/suggestions/feedback at <https://github.com/bellecp/fast-p/issues/11>_


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
of the tools ``cut``, ``xargs``, ``grep``, ``tr``. This way, we avoid the specifics of the versions of these tools pre-installed on OSX,
and the same ``.bashrc`` code can be used for both OSX and GNU Linux systems.

# Usage

Use the command ``p`` to browse among the PDF files in the current directory and its subdirectories.

The first run of the command will take some time to cache the text extracted from each pdf. Further runs of the command will be much faster since the text extraction will only apply to new pdfs.

# How to clear the cache?

To clear the cache (which contains text extracted from PDF), you can run 'fast-p --clear-cache'. This will safely remove the file located at:
``~/.cache/fast-p-pdftotext-output/fast-p_cached_pdftotext_output.db``

For older versions, please manually delete the cache file found at
``~/.cache/fast-p_cached_pdftotext_output.db``

# Launch with keyboard shortcut in Ubuntu

On Ubuntu desktop (tested in 18.04), one may add a keyboard shortcut to launch a new terminal running the ``p`` command right away.
With the following script, the new terminal window will automatically close after choosing a PDF.

Create a file ``~/.fast-p-rc`` with
```
source .bashrc
p;
sleep 0.15; exit;
```
and in Ubuntu Settings/Keyboard, add a custom shortcut that runs the command
``gnome-terminal -- sh -c "bash --rcfile .fast-p-rc"``.



# See it in action

![illustration of the p command](https://user-images.githubusercontent.com/1019692/34446795-12229072-ecac-11e7-856a-ec0df0de60ae.gif)


# Is the historical bash code still available?

Yes, see https://github.com/bellecp/fast-p/blob/master/p but using the go binary as explained above is recommended for speed and interoperability.

