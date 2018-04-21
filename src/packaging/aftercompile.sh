#!/bin/bash
## texpack did add_to_CTANDir $docPDF $docTEX $pkgSTY $sourceDir/README.txt
function cp_to_dir(){
dir=$1
shift;
while [[ $# -gt 0 ]]
do
  outHandle "Error in copying $1 to $dir" cp -f "$1" "$dir/"
  shift
done
}
function make_github_readme(){
  rm "$mainDir/README.md.bak"
  mv "$mainDir/README.md" "$mainDir/README.md.bak"
  cp -f "$sourceDir/$packageSettingsDir/README.template.md" "$mainDir/README.md"
  add_version_vars_to "$mainDir/README.md"
}
function readme_tree(){
  pushd . > /dev/null
  cd "$CTANDir"
  file_structure=`tree . | awk "NR > 1" | sed '$d'`
  pattern="s/\#FILES/$file_structure/"
  perl -p -e "$pattern or next;" -i "$CTANDir/README.txt"
  popd > /dev/null
}
function finalize_paths(){
  cd "$mainDir"
  rm -rf "$mainDir/$CTANDirBase"
  mv "$CTANDir" "$mainDir"
  rm "$packagename.zip"
  outHandle "Error in zipping $packagename.zip" zip "$packagename.zip" -r "./$CTANDirBase"
  if [ -d "release" ]; then
    rm -rf "release"
  fi
  mv -f "$CTANDirBase" "release"
}
cd $sourceDir
rm -rf "$mainDir/$packagename/"
readme_tree
make_github_readme
finalize_paths
cp $pkgSTY $mainDir;

echo "v${version}"
echo "b${build}"
