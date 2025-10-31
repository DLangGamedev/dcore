module main;

import dcore;
import tests.sys;
import tests.process;
import tests.time;
import tests.random;

import std.stdio;

class DCoreApplication
{
    HWND hwnd;
    HDC hdc;
    
    OpenGLVersion glVersion;
    void* glContext;
    
    bool running = true;
    double timer = 0.0;
    enum double dt = 1.0 / 60.0;
    
    this()
    {
        hwnd = createWindow(800, 600, "dcore");
        if (hwnd is null)
        {
            writeln("Failed to create window");
            return;
        }
        
        hdc = GetDC(hwnd);
        glVersion = OpenGLES30;
        glContext = loadOpenGL(hdc, glVersion);
        if (glContext is null)
        {
            writeln("Failed to create OpenGL ES 3.0 context!");
            return;
        }
    }
    
    void run()
    {
        timer = getTimeStep();
        
        while(running)
        {
            dispatchMessage(&dispatchWindowsMessage, cast(void*)this);
            
            double timeStep = getTimeStep();
            timer += timeStep;
            if (timer >= dt)
            {
                timer -= dt;
                glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
                glClear(GL_COLOR_BUFFER_BIT);
                glFlush();
                SwapBuffers(hdc);
            }
        }
    }
}

void dispatchWindowsMessage(MSG* msg, void* userData)
{
    DCoreApplication app = cast(DCoreApplication)userData;
    if (app)
    {
        if (msg.message == WM_QUIT)
        {
            app.running = false;
            return;
        }
    }
}

void main()
{
    dcore.init();
    testSysInfo();
    //testProcess();
    //testTime();
    //testRandom();
    
    DCoreApplication app = new DCoreApplication();
    app.run();
}
