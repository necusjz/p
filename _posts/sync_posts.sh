#!/usr/bin/env bash

rm *.md
cp -r ../../Hexo/source/_posts/*.md ./

git add *.md
git commit -m "synchronize _posts"
git push
