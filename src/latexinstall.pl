#!/usr/bin/perl
# Installs missing latex packages automagically using latexmk
# To use:
# Move latexinstall.pl (this file) to the same directory
# as the .tex file you want to build
# Make this file executable by running the command:
# chmod +x latexinstall.pl
# then run this file by
# ./latexinstall.pl main.tex
use strict;
use warnings;
use File::Spec;

my $texFile=$ARGV[0];
unless($texFile){
  die "Usage: ./latexinstall.pl texfile.tex";
}

my $pFindFile=qr/! LaTeX Error: File \`(.*?).sty' not found./;

sub execSilent{
  my ($command) = @_;
  open(OLDERR, ">&STDERR");
  open(STDERR, ">>/tmp/tmp.spderr") or die "Can't dup stdout";
  select(STDOUT); $| = 1;     # make unbuffered
  print OLDERR "";  #this fixed an error about OLDERR not being used

  my $contents=`$command`;

  close(STDERR);
  open(STDERR, ">&OLDERR");
  return $contents;
}
my $previousPackage;
# die "END"
while(1){
  my $latexMKContents=execSilent("pdflatex -interaction=nonstopmode -halt-on-error -output-directory _build --shell-escape $texFile");
  # print "$latexMKContents";
  $latexMKContents=~/$pFindFile/;
  unless ($1){
    print "Couldn't find packages that needed install";
    exit 0;
  }
  my $package=$1;
  print "Installing $package\n";
  my $tlmgrCmd=execSilent "sudo tlmgr install $package 2>&1";
  # print "$tlmgrCmd\n";
  # print "$1\n";
  if ($tlmgrCmd=~/(error)/mg){
    print "Couldn't find package $package. Searching texlive\n";
    my $search=execSilent("sudo tlmgr search --global --file $package.sty");
    print "Search returned this\n----\n";
    print "$search\n----\n";
    $search=~/^((?!tlmgr)[^:]+):/;
    if($search=~/^([^:]+):$/mg){
      print "Installing $1 instead:\n";
      my $tlmgrCmd=execSilent "sudo tlmgr install $1 2>&1";
      if($tlmgrCmd=~/(error)/mg){
        print "$tlmgrCmd";
        print "Didn't work. Exiting...\n";
        last;
      }
    }else{
      die "Couldn't find requested package";
    }
  }
  if($previousPackage==$package){
    die "Tried to install same package more than once";
  }
  $previousPackage=$package
}
# my $inputFile=$ARGV[0];
# unless ($inputFile){
#   die "Add file to build";
# }
# print $OUTPUT $output;
# close $OUTPUT
#
# # print "$inputFile\n";
# system("latexmk -outdir=bin -interaction=nonstopmode main.tex");
# # ! LaTeX Error: File `xstring.sty' not found.
