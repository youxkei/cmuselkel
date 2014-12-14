module app;

import drawable.circle : Circle;
import gl.check : glCheck;
import sprite.sprite;

import std.algorithm : endsWith;
import std.math;
import core.memory : GC;
import core.thread;

import derelict.opengl3.gl;
import derelict.sdl2.sdl;

void initModules()
{
    foreach(moduleInfo; ModuleInfo)
    {
        foreach(clazz; moduleInfo.localClasses)
        {
            if (clazz.toString().endsWith(".static_this"))
            {
                auto instance = clazz.create();
            }
        }
    }
}

void draw() @nogc
{
    foreach (sprite; Sprite.pool)
    {
        sprite.drawOuter();
    }

    foreach (sprite; Sprite.pool)
    {
        sprite.drawInner();
    }

    foreach_reverse (i , sprite; Sprite.pool)
    {
        if (i == 0)
        {
            sprite.x += 3 * cos(sprite.angle);
            sprite.y += 3 * sin(sprite.angle);
            sprite.angle += 0.01;
        }
        else
        {
            sprite.x = Sprite.pool[i - 1].x;
            sprite.y = Sprite.pool[i - 1].y;
        }
    }
}

void doMainLoop(SDL_Window* window) //@nogc
{
    SDL_Event sdlEvent;
    loop : while(true)
    {
        while (SDL_PollEvent(&sdlEvent))
        {
            if (sdlEvent.type != SDL_WINDOWEVENT)
            {
                continue;
            }

            if (sdlEvent.window.event == SDL_WINDOWEVENT_CLOSE)
            {
                break loop;
            }
        }

        glCheck!glClear(GL_COLOR_BUFFER_BIT);
        draw();
        glCheck!glFlush();

        SDL_GL_SwapWindow(window);
        Thread.sleep(1.seconds);
    }
}

void main()
{
    DerelictGL3.load();
    DerelictSDL2.load();

    SDL_Init(SDL_INIT_VIDEO);
    scope(exit) SDL_Quit();

    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);

    SDL_Window* window = SDL_CreateWindow("hogegl", 0, 0, 1280, 960, SDL_WINDOW_OPENGL | SDL_WINDOW_HIDDEN);
    scope(exit) SDL_DestroyWindow(window);

    SDL_GLContext glContext = SDL_GL_CreateContext(window);
    scope(exit) SDL_GL_DeleteContext(glContext);

    DerelictGL3.reload();

    glCheck!glClearColor(0, 0, 0, 1);
    glCheck!glEnable(GL_BLEND);

    initModules();

    foreach (i; 0 .. 32)
    {
        with(Sprite())
        {
            x = 128;
            y = 128;
            angle = 0;
            Circle c;
            with(c = Circle())
            {
                radius = 8;
                lineWeight = 4;
                color.r = 255;
                color.g = 0;
                color.b = 0;
                color.a = 255;
            }
            drawable = c;
        }
    }

    SDL_ShowWindow(window);

    GC.collect();
    doMainLoop(window);
}
