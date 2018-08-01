---
name: Bug report
about: Create a report to help us improve

---

**Describe the bug**
A concise description of what the bug is and the expected behavior.

**To Reproduce**
Steps to reproduce the behavior:
1. Do '...'
2. 

**Versions and OS.**
Describe your OS and provide the output of the following commands:
- ``bash --version``
- ``grep --version``
- ``ag --version``
- ``xargs --version``
- ``pdftotext -v``

**Filenames.**
Is the behavior correct when run from a directory with only PDFs that have ASCII filenames?
Do you identify special characters in filenames that may cause the issue?

**pdftotext.**
Try the command ``pdftotext -f 1 -l 2 some_of_your_pdf.pdf`` with some of your PDF. Does it extract the first two pages as expected?
