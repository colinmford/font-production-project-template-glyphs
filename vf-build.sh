#!/bin/bash

# Fail fast
set -e

# -----------------------------------------------------------------------
# configure paths

sourcesDir="A  Font Sources"
buildDir="B  Builds"
proofDir="D  Proofs"

otfDir="$buildDir/VF-OTFs"
ttfDir="$buildDir/VF-TTFs"
woffDir="$buildDir/VF-WOFFs"

# -----------------------------------------------------------------------
# build OTFs

echo "Building OTFs..."

# removing old files
rm -rf "$otfDir"

# making the otf directory
mkdir -p "$otfDir"

# making the otf files from the designspace file
find "$sourcesDir" -path '**/*.glyphs' -print0 | while read -d $'\0' glyphsFile
do
    fileBaseName=${glyphsFile##*/}
    fontmake --glyphs-path "$glyphsFile" --output variable-cff2 --output-path "$otfDir/${fileBaseName/.glyphs/-VF.otf}" --master-dir "{tmp}" --instance-dir "{tmp}" --subroutinizer cffsubr --flatten-components
done

# -----------------------------------------------------------------------
# post-processing OTFS 

# this loops through otfs and applies dsig fix to them
find "$otfDir" -path '*.otf' -print0 | while read -d $'\0' otfFile
do
    gftools fix-dsig --autofix "$otfFile"
done

# -----------------------------------------------------------------------
# build TTFs

echo " "
echo "Building TTFs..."

# removing old files
rm -rf "$ttfDir"

# making the ttf directory
mkdir -p "$ttfDir"

# making the ttfs from the designspace file
find "$sourcesDir" -path '**/*.glyphs' -print0 | while read -d $'\0' glyphsFile
do
    fileBaseName=${glyphsFile##*/}
    fontmake --glyphs-path "$glyphsFile" --output variable --output-path "$ttfDir/${fileBaseName/.glyphs/-VF.ttf}" --master-dir "{tmp}" --instance-dir "{tmp}" --flatten-components
done

# -----------------------------------------------------------------------
# post-processing TTFS 

# this loops through otfs and applies dsig fix to them
find "$ttfDir" -path '*.ttf' -print0 | while read -d $'\0' ttfFile
do
    gftools fix-dsig --autofix "$ttfFile"
    gftools fix-nonhinting "$ttfFile" "$ttfFile"
    rm "${ttfFile/.ttf/-backup-fonttools-prep-gasp.ttf}"
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

fontbakery check-universal -n --succinct --html "$proofDir/VF-OTFs.html" "$otfDir/*.otf" 1>/dev/null 2>&1 || true
fontbakery check-universal -n --succinct --html "$proofDir/VF-TTFs.html" "$otfDir/*.ttf" 1>/dev/null 2>&1 || true
