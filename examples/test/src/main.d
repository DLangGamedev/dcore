module main;

import dcore;
import tests.sys;
import tests.process;
import tests.time;
import tests.random;

import core.sys.windows.windows;

import std.stdio;

extern(C)
{
    alias f_EngineCreate = double function();
    alias f_EngineUpdate = double function(double);
    alias f_EngineGetTimeStep = double function();
    alias f_WindowCreate = double function(double, double, double, double, double);
    alias f_WindowDispatch = double function();
    alias f_WindowIsShowing = double function(double);
    alias f_WindowGetHandle = double function(double);
    
    __gshared nothrow @nogc
    {
        f_EngineCreate EngineCreate;
        f_EngineUpdate EngineUpdate;
        f_EngineGetTimeStep EngineGetTimeStep;
        f_WindowCreate WindowCreate;
        f_WindowDispatch WindowDispatch;
        f_WindowIsShowing WindowIsShowing;
        f_WindowGetHandle WindowGetHandle;
    }
}

void main() {
    dcore.init();
    
    testSysInfo();
    testProcess();
    testTime();
    testRandom();
    
    SharedLib xtreme3d = openLibrary("xtreme3d.dll");
    
    EngineCreate = cast(f_EngineCreate)getFunctionPointer(xtreme3d, "EngineCreate");
    EngineUpdate = cast(f_EngineUpdate)getFunctionPointer(xtreme3d, "EngineUpdate");
    EngineGetTimeStep = cast(f_EngineGetTimeStep)getFunctionPointer(xtreme3d, "EngineGetTimeStep");
    WindowCreate = cast(f_WindowCreate)getFunctionPointer(xtreme3d, "WindowCreate");
    WindowDispatch = cast(f_WindowDispatch)getFunctionPointer(xtreme3d, "WindowDispatch");
    WindowIsShowing = cast(f_WindowIsShowing)getFunctionPointer(xtreme3d, "WindowIsShowing");
    WindowGetHandle = cast(f_WindowGetHandle)getFunctionPointer(xtreme3d, "WindowGetHandle");
    
    EngineCreate();
    double window = WindowCreate(0, 0, 800, 600, 0);
    HWND hwnd = cast(HWND)cast(size_t)WindowGetHandle(window);
    HDC hdc = GetDC(hwnd);
    auto context = loadOpenGL(hdc, OpenGLES30);
    if (context is null)
    {
        writeln("Failed to create OpenGL ES 3.0 context!");
        return;
    }
    
    bool running = true;
    double timer = 0.0;
    double dt = 1.0 / 60.0;
    
    while(running)
    {
        WindowDispatch();
        
        double timeStep = EngineGetTimeStep();
        timer += timeStep;
        if (timer >= dt)
        {
            timer -= dt;
            running = cast(bool)WindowIsShowing(window);
            EngineUpdate(dt);
            
            glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
            glClear(GL_COLOR_BUFFER_BIT);
            glFlush();
            SwapBuffers(hdc);
        }
    }
}
