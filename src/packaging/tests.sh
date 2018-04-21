export testDir="$sourceDir/testing";
export tmpTestDir="$sourceDir/tmpTesting";
function run_tests(){
  rm -r $tmpTestDir;
  mkdir $tmpTestDir;
  cd $tmpTestDir
  cp_to_dir $tmpTestDir "$sourceDir/test.Rnw" "$sourceDir/test.r" $pkgSTY
while [[ $# -gt 0 ]]
do
  cp "$testDir/$1" "$tmpTestDir/$1";
  outHandle "Error in testing: $1" latexmk -pdf "$1" -outdir="./bin" --shell-escape -interaction=nonstopmode -f
  shift
done
}
run_tests "basic.tex"
