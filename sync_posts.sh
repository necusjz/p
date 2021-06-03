#!/usr/bin/env bash

dir="_posts"

rm -fr $dir/*
cp -r ../BLOG/source/$dir/* $dir/

git add $dir
git commit -m "synchronize _posts"
git push
