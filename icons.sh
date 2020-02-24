
# Copyright 2018 Muhammad Iqbal(iqbalmineraltown.com)
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
# THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#!/bin/bash

targetfolder="./lib"
targetfile="$targetfolder/icon_assets.dart"
regex='s/[-_]([a-z0-9])/\U\1/gi'
stringList=""

echo `pwd`
cd `pwd`

#mkdir -p ./lib/assets
touch $targetfile

touch tmp
echo "class IconAssets {" > $targetfile
for f in `find ./assets -maxdepth 1 -type f`; do
  filename=`echo $f | cut -d'/' -f3 | cut -d'.' -f1`
  varname=`echo $filename | sed -E $regex`
  entry="static const String icon$varname = '${f:2}';"
  stringList+="'${f:2}', "
  echo "     $entry" >> tmp;
done;

echo "     static List<String> assets = [$stringList];" >> $targetfile
sort tmp >> $targetfile

printf '}\n\n' >> $targetfile
rm -f tmp

cd -