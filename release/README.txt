includeRnw:
Makes commands for including external .Rnw files.

├── README.txt
├── includeRnw-doc.pdf
├── includeRnw-doc.tex
└── includeRnw.sty

Not tested on Windows!

Quick start:

\documentclass{article}
\usepackage{includeRnw}
\begin{document}
  \includeRnw{path/to/my.Rnw}
\end{document}


Author: Storvik Strauman, Andreas

For bug report, inquires, contributed or anything else:
https://github.com/Strauman/includeRnw/

Licence:

The LaTeX package includeRnw - version v0.1.0 (2018/05/01) - build 11
includeRnw.sty
-------------------------------------------------------------------------------------------
Copyright (c) 2018 by Andreas Storvik Strauman
-------------------------------------------------------------------------------------------
This work may be distributed and/or modified under the
conditions of the LaTeX Project Public License, either version 1.3c
of this license or (at your option) any later version.
The latest version of this license is in
  http://www.latex-project.org/lppl.txt
and version 1.3c or later is part of all distributions of LaTeX
version 2008/05/04 or later.
This work has the LPPL maintenance status `author-maintained'.
This work consists of all files listed in README.txt
