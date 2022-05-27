#!/bin/bash

# Fail fast
set -e

# -----------------------------------------------------------------------
# configure paths

sourcesDir="A  Font Sources"
buildDir="B  Builds"
proofDir="D  Proofs"

otfDir="$buildDir/OTFs"
ttfDir="$buildDir/TTFs"
woffDir="$buildDir/WOFFs"

# -----------------------------------------------------------------------
# build OTFs

echo "Building OTFs..."

# removing old files
rm -rf "$otfDir"

# making the otf directory
mkdir -p "$otfDir"

# making the otf files from the glyphs file
find "$sourcesDir" -path '**/*.glyphs' -print0 | while read -d $'\0' glyphsFile
do
    fontmake --glyphs-path "$glyphsFile" --output otf --interpolate --output-dir "$otfDir" --master-dir "{tmp}" --instance-dir "{tmp}" --overlaps-backend pathops --subroutinizer cffsubr --flatten-components
done

# -----------------------------------------------------------------------
# post-processing OTFS 

# this loops through otfs and applies PS hinting to them
find "$otfDir" -path '*.otf' -print0 | while read -d $'\0' otfFile
do
    psautohint --all "$otfFile"
    gftools fix-nameids "$ttfFile" --drop-mac-names
done

# -----------------------------------------------------------------------
# build TTFs

echo " "
echo "Building TTFs..."

# removing old files
rm -rf "$ttfDir"

# making the ttf directory
mkdir -p "$ttfDir"

# making the ttfs from the glyphs file
find "$sourcesDir" -path '**/*.glyphs' -print0 | while read -d $'\0' glyphsFile
do
    fontmake --glyphs-path "$glyphsFile" --output ttf --interpolate --output-dir "$ttfDir" --master-dir "{tmp}" --instance-dir "{tmp}" --overlaps-backend pathops --flatten-components -a "--no-info --stem-width-mode=nnn"
done

# -----------------------------------------------------------------------
# post-processing TTFS 

# this loops through otfs and uses the TTFAutoHinter to autohint them
find "$ttfDir" -path '*.ttf' -print0 | while read -d $'\0' ttfFile
do
    gftools fix-hinting "$ttfFile"
    gftools fix-nameids "$ttfFile" --drop-mac-names
done


# -----------------------------------------------------------------------
# make web font

echo " "
echo "Making WOFF2s..."

# removing old files
rm -rf "$woffDir"

# making the ttf directory
mkdir -p "$woffDir"

find "$ttfDir" -path '*.ttf' -print0 | while read -d $'\0' ttfFile
do
    # Replaces .ttf with .woff2 in the ttf file name
    woff2name=$(basename "${ttfFile/.ttf/.woff2}")

    fonttools ttLib.woff2 compress -o "$woffDir/$woff2name" "$ttfFile"
done


# -----------------------------------------------------------------------
# Tests
# The "1>/dev/null 2>&1 || true" stuff is to limit the output in the terminal

echo " "
echo "Running Tests..."

fontbakery check-universal -n --succinct --html "$proofDir/OTFs.html" "$otfDir/*.otf" 1>/dev/null 2>&1 || true
fontbakery check-universal -n --succinct --html "$proofDir/TTFs.html" "$otfDir/*.ttf" 1>/dev/null 2>&1 || true
