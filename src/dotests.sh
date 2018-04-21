#/bin/bash
# --- Variables --- #
export sourceDir=`pwd`;
export testDir="$sourceDir/testing";
export tmpTestDir="$sourceDir/testresults";
export prehooksDir="$testDir/prehooks";
export posthooksDir="$testDir/posthooks";
export pkgSTY="$tmpTestDir/includeRnw.sty";
# --- for latexmk logging --- #
export max_print_line=1000
export error_line=254
export half_error_line=238
# --- Verification --- #
if [ ! -d "$testDir" ];then
  echo "Failed to find test directory. Are you sure you are in the right directory? src/";
  exit 1;
fi
# --- HELPER FUNCTIONS --- #
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

#--- TEST FUNCTIONS ---#
function make_sty(){
  # Make .sty-file
  cat packaging/packagehead.tex > $pkgSTY;
  latexpand --keep-comments --makeatletter texpack.tex >> $pkgSTY;
}
function copy_sty(){
  cp ../includeRnw.sty $pkgSTY;
}
function ready_test_directory(){
  if [ -d "$tmpTestDir" ];then
    rm -r $tmpTestDir;
  fi
  # Copy of testing/ directory
  cp -r $testDir $tmpTestDir;
  # We don't need the hooks
  rm -r $tmpTestDir/prehooks &>/dev/null
  rm -r $tmpTestDir/posthooks &>/dev/null
  perl -pe "s/(\\\\makeat(?:letter|other))//" -i $pkgSTY
  perl -pe "s/^\s*%!TEX.*//" -i $pkgSTY
  cd $tmpTestDir
  mkdir "pdf/";
  cp_to_dir $tmpTestDir $pkgSTY &> /dev/null
}
function run_tests(){
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
}
function test_shell_escape(){
  cd $tmpTestDir;
  rm -rf bin/
  echo "Trying to build basic.tex without shell-escape"
  latexmk -pdf "basic.tex" -outdir="./bin" -interaction=nonstopmode &>tmpout
  exit_code=$?
  if [ $exit_code -eq 0 ]; then
    echo "Building without shell-escape didn't fail!";
    echo "Run:"
    echo 'latexmk -outdir="./bin" -C; latexmk -pdf "basic.tex" -outdir="./bin"'
    exit 1;
  else
    echo "As expected: building without shell-escape failed";
    echo "Here are all instances of @@PACKAGE in output";
    cat tmpout | grep "@@PACKAGE";
  fi
  rm tmpout;
}
function finalize_result_dir(){
  mkdir code/
  mv * code/ &> /dev/null
  cp code/includeRnw.sty ./
  mv code/pdf ./
}
# make_sty
ready_test_directory
run_tests
test_shell_escape
finalize_result_dir
