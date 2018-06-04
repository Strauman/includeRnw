# includeRnw
v0.0.2 2018/04/29 - build 10

Usage:
Included in both TeXLive and MiKTeX.
`tlmgr install includeRnw`

Download includeRnw.zip:

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
