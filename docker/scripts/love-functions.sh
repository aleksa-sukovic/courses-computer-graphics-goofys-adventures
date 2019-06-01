#!/bin/bash

lovec()
{
    echo "Compiling..."

    cd /usr/src/app

    # create output dir
    rm -rf dist/linux
    mkdir -p dist/linux

    # create Love bundle
    cd src
    zip -r ../dist/linux/game.love  .
    cd ..

    # create executable
    cat /usr/bin/love dist/linux/game.love > dist/linux/game.out
    chmod +x dist/linux/game.out

    # cleanup
    rm dist/linux/game.love

    echo "Compiled successfully, checkout dist/linux/game.out"
}
