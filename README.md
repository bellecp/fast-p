# fast-p
Quickly find and open a pdf among a collection of thousands of unsorted pdfs through fzf (fuzzy finder)


## Installation

- install ``pdftotext``. This comes with the texlive distribution on linux or with poppler on OSX.
- install ``fzf``: https://github.com/junegunn/fzf
- install ``xxhash``: https://github.com/Cyan4973/xxHash
- install ``grep``, ``ack`` and ``ag`` (silver searcher)
- clone the repository: ``$ git clone https://github.com/bellecp/fast-p.git`` 
- add a line ``source fast-p/p`` to your .bashrc or .bash_profile
- Run the command ``p``. The first run of the command will take some time to cache the text extracted from each pdf. Further runs of the command will be much faster since the text extraction will only apply to new pdfs.


## Usage

- Run the command ``p`` and start typing keywords to search for pdf.
- Type "enter" to view the pdf in the default viewer
