# fast-p
Quickly find and open a pdf among a collection of thousands of unsorted pdfs through fzf (fuzzy finder)


## Installation

- install ``pdftotext``
- install ``fzf``: https://github.com/junegunn/fzf
- install ``xhash``: https://github.com/Cyan4973/xxHash
- install ``grep``, ``ack`` and ``ag`` (silver searcher)
- clone the repository: ``$ git clone https://gist.github.com/29f57de478b309f8956b5b342f5e51bd.git ~/fast-p/`` 
- add ``source fast-p/p`` to your .bashrc or .bash_profile
- Run the command ``p``. The first run of the command will take some time to cache the text extracted from each pdf. Further runs of the command will be much faster since the text extraction will only apply to new pdfs.


## Usage

- Run the command ``p`` and start typing keywords to search for pdf.
- Type "enter" to view the pdf in the default viewer
