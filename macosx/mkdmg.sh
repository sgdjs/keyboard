#!/bin/sh -x

# store the current dir. The image will be stored here.
OUT=$PWD
VERSION=$1

if [ -z "$VERSION" ]
then
  echo "il faut un numéro de version"
  exit 1
fi

# make a temp dir to create the... temp files
mkdir tmp
pushd tmp

# get the last version
svn export svn://svn.tuxfamily.org/svnroot/dvorak/svn/pilotes/trunk pilotes
pushd pilotes/macosx

rm -f "$OUT/fr-dvorak-bepo-macosx-$VERSION.dmg"
hdiutil create "$OUT/tmp/fr-dvorak-bepo-macosx-$VERSION.dmg" -size 13m -fs HFS+ -volname "fr-dvorak-bépo ($VERSION)"
dev_handle=`hdiutil mount "$OUT/tmp/fr-dvorak-bepo-macosx-$VERSION.dmg" | fgrep "fr-dvorak-b" | cut -f 1`

# generate the alt confs
python generate_alt.py

# use the icon for the volume
ditto -rsrcFork fr-dvorak-bepo.icns "/Volumes/fr-dvorak-bépo ($VERSION)/.VolumeIcon.icns"
/Developer/Tools/SetFile -a C "/Volumes/fr-dvorak-bépo ($VERSION)"

# copy tho licenses
cp ../CC-SA-BY.txt ../GFDL.txt  "/Volumes/fr-dvorak-bépo ($VERSION)"

# copy the bundle and the readmes
cp -R fr-dvorak-bepo.bundle LISEZ_MOI.txt READ_ME.txt "/Volumes/fr-dvorak-bépo ($VERSION)"

hdiutil detach $dev_handle
hdiutil convert -imagekey zlib-level=9 -format UDZO "$OUT/tmp/fr-dvorak-bepo-macosx-$VERSION.dmg" -o "$OUT/fr-dvorak-bepo-macosx-$VERSION.dmg"

popd
popd
# and remove the temp dir
rm -rf tmp
