# includeRnw
@@VERSION @@DATE - build @@BUILD

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
```
\includeRnw[h]{/path/to/file.Rnw}
```
