# Goofy's Adventures

This is simple 2D platformer game built for my *Computer Graphics* college course.

## Main Idea

Main idea was to learn basic principles of 2D game development.

Since I was new to everything related to computer graphics, this was a great chance to learn this unexplored segment.

I decided to use Lua programming language paired with Love framework. This turned out to be a great choice since it allowed me to rapidly develop my idea.

## How to set-up ?
The following commands will build and run Docker image.

Docker image is configure to run indefinitely, so you can execute interactive bash process against running container anytime to gain full control.

1. `cd docker`
2. `docker-compose build`
3. `docker-compose up`
4. `docker exec -it $(docker ps -qf "name=love") bash`
5. `lovec`

This will compile Your game. Executable can be found in `dist/linux/game.out`
    
    Please note that directory `/usr/src/app/src` should contain `main.lua` file representing Your game.

## What have I learned ?
1. Lua programming language
2. Love framework
3. Bump, Anim8, Advanced Tiled Loader libraries for Lua & Love
4. Math and physics behind 2D platformer games
5. Principles of computer graphics

## Images

![Level 1](https://api.pcloud.com/getpubthumb?code=XZt1HN7Z36U317nHtwBFFvQU1cA9MRxtXR2y&linkpassword=undefined&size=640x506&crop=0&type=auto)

![Level 2](https://api.pcloud.com/getpubthumb?code=XZEeHN7Zk0z8ERJBqAXYe8mrT543Vus83I8V&linkpassword=undefined&size=640x506&crop=0&type=auto)

### Credits

Assets for this game were not made by me. All credits goes to [ZiNGOT](http://opengameart.org/content/gfxlib-fuzed).
