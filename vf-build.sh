#!/bin/bash

# Fail fast
set -e

# -----------------------------------------------------------------------
# configure paths

sourcesDir="A  Font Sources"
buildDir="B  Builds"
proofDir="D  Proofs"

ttfDir="$buildDir/VF-TTFs"
woffDir="$buildDir/VF-WOFF2s"

# -----------------------------------------------------------------------
# build TTFs

echo " "
echo "Building VF-TTFs..."

# removing old files
rm -rf "$ttfDir"

# making the ttf directory
mkdir -p "$ttfDir"

# making the ttfs from the Glyphs file
find "$sourcesDir" -path '**/*.glyphs' -print0 | while read -d $'\0' glyphsFile
do
    fileBaseName=${glyphsFile##*/}
    fontmake --glyphs-path "$glyphsFile" --output variable --output-path "$ttfDir/${fileBaseName/.glyphs/-VF.ttf}" --master-dir "{tmp}" --instance-dir "{tmp}" --flatten-components
done

# -----------------------------------------------------------------------
# post-processing TTFS 

# this loops through ttfs and...
find "$ttfDir" -path '*.ttf' -print0 | while read -d $'\0' ttfFile
do
    python "C  Project Files/py/removeMacNames.py" "$ttfFile"
done


# -----------------------------------------------------------------------
# make web fonts

echo " "
echo "Making WOFF2s..."

# removing old files
rm -rf "$woffDir"

# making the woff2 directory
mkdir -p "$woffDir"

# this loops through all the TTFs in the TTF directory and...
find "$ttfDir" -path '*.ttf' -print0 | while read -d $'\0' ttfFile
do
    # Replaces .ttf with .woff2 in the file name
    woff2name=$(basename "${ttfFile/.ttf/.woff2}")
    # ... and compresses them into WOFF2s
    fonttools ttLib.woff2 compress -o "$woffDir/$woff2name" "$ttfFile"
done

# -----------------------------------------------------------------------
# Tests
# The "1>/dev/null 2>&1 || true" stuff is to limit the output in the terminal

echo " "
echo "Running Tests..."

fontbakery check-universal -n --succinct --html "$proofDir/VF-TTFs.html" "$ttfDir/*.ttf" 1>/dev/null 2>&1 || true
