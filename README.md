# includeRnw
v0.1.0 2018/05/01 - build 11

## Installation
Included in both TeXLive and MiKTeX.

`tlmgr install includeRnw`
### Manual installation
Download includeRnw.zip:
## Usage
```
\documentclass{article}
\input{includeRnw}
\makeatletter
\begin{document}
\includeRnw{/path/to/file.Rnw}
\end{document}
```

You can send the `h`-option to prevent it from building the Rnw, and only including the already knitted file:
```
\includeRnw[h]{/path/to/file.Rnw}
```
