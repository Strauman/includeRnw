#/bin/bash
# --- Variables --- #
export sourceDir=`pwd`;
export testDir="$sourceDir/testing";
export tmpTestDir="$sourceDir/testresults";
export prehooksDir="$testDir/prehooks";
export posthooksDir="$testDir/posthooks";
# --- for latexmk logging --- #
export max_print_line=1000
export error_line=254
export half_error_line=238
# --- Verification --- #
if [ ! -d "$testDir" ];then
  echo "Failed to find test directory. Are you sure you are in the right directory? src/";
  exit 1;
fi
# --- FUNCTIONS --- #
function outHandle(){
  # Usage:
  # outHandle "ERROR-MSG" command with args
  errMsg=$1;
  ${@:2:${#}} >tmpstdout 2>tmpstderror
  exitCode=$?
  if [ $exitCode -ne 0 ]; then
    if [ -f "tmpstdout" ];then
      echo "OUT:";
      cat tmpstdout;
    fi
    if [ -f "tmpstderror" ];then
      echo "ERR:";
      cat tmpstderror;
    fi
    rm tmpstderror > /dev/null 2>&1;
    rm tmpstdout > /dev/null 2>&1;
    echo "$errMsg ($exitCode)"
    exit 1;
    echo "... continuing ..."
  fi
  rm tmpstderror > /dev/null 2>&1;
  rm tmpstdout > /dev/null 2>&1;

}
function errHandle(){
  # Usage:
  # outHandle "ERROR-MSG" command with args
  errMsg=$1;
  ${@:2:${#}} 2> tmpstderror
  exitCode=$?
  if [ $exitCode -ne 0 ]; then
    if [ -f "tmpstderror" ];then
      echo "ERR:";
      cat tmpstderror;
    fi
    if [ -f "tmpstderror" ];then
      rm tmpstderror;
    fi
    echo "$errMsg ($exitCode)";
    exit 1;
    echo "... continuing ...";
  fi
  if [ -f "tmpstdout" ];then
    rm tmpstderror;
  fi

}
function cp_to_dir(){
dir=$1
shift;
while [[ $# -gt 0 ]]
do
  cp -f "$1" "$dir/"
  shift
done
}
# Latexpand
function run_tests(){
  if [ -d "$tmpTestDir" ];then
    rm -r $tmpTestDir;
  fi
  # Copy of testing/ directory
  cp -r $testDir $tmpTestDir;
  # We don't need the hooks
  rm -r $tmpTestDir/prehooks &>/dev/null
  rm -r $tmpTestDir/posthooks &>/dev/null
  # Make .sty-file
  export pkgSTY="$tmpTestDir/includeRnw.sty";
  cat packaging/packagehead.tex > $pkgSTY;
  latexpand --keep-comments --makeatletter texpack.tex >> $pkgSTY;
  perl -pe "s/(\\\\makeat(?:letter|other))//" -i $pkgSTY
  perl -pe "s/^\s*%!TEX.*//" -i $pkgSTY
  cd $tmpTestDir
  mkdir "pdf/";
  cp_to_dir $tmpTestDir $pkgSTY &> /dev/null
  for texfile in $tmpTestDir/*.tex; do
    rm -rf knitrout > /dev/null;
    filename=${texfile##*/};
    filebase=${filename%.tex};
    echo "Making $filebase.pdf"
    if [ -f "$prehooksDir/$filebase.sh" ];then
      echo "Running pre-hook: $filebase.sh";
      errHandle "Error in prehook $filebase.sh" $prehooksDir/$filebase.sh
    fi
    outHandle "Latexmk of $texfile failed" latexmk -pdf "$texfile" -outdir="./bin" --shell-escape -interaction=nonstopmode -f
    cp "bin/$filebase.pdf" ./pdf/;
  done
  mkdir code/
  mv * code/ &> /dev/null
  cp code/includeRnw.sty ./
  mv code/pdf ./
}
run_tests
