# includeRnw
v0.0.1 2018/04/20 - build 3

Usage:
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
`\includeRnw[h]{/path/to/file.Rnw}`
