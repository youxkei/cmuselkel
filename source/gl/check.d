module gl.check;

import std.traits : ParameterTypeTuple;
import derelict.opengl3.gl;

debug
{
    auto glCheck(alias Func, string file = __FILE__, int line = __LINE__)(ParameterTypeTuple!Func args) @nogc
    {
        scope(exit)
        {
            GLenum errorCode = glGetError();

            if (errorCode != GL_NO_ERROR)
            {
                static invalidEnum =      new immutable(Exception)("GL_INVALID_ENUM", file, line);
                static invalidValue =     new immutable(Exception)("GL_INVALID_VALUE", file, line);
                static invalidOperation = new immutable(Exception)("GL_INVALID_OPERATION" ,file, line);
                static stackOverflow =    new immutable(Exception)("GL_STACK_OVERFLOW" ,file, line);
                static stackUnderflow =   new immutable(Exception)("GL_STACK_UNDERFLOW" ,file, line);
                static outOfMemory =      new immutable(Exception)("GL_OUT_OF_MEMORY" ,file, line);
                static unknown =          new immutable(Exception)("Unknown error" ,file, line);

                switch (errorCode)
                {
                    case GL_INVALID_ENUM:
                        throw invalidEnum;

                    case GL_INVALID_VALUE:
                        throw invalidValue;

                    case GL_INVALID_OPERATION:
                        throw invalidOperation;

                    case GL_STACK_OVERFLOW:
                        throw stackOverflow;

                    case GL_STACK_UNDERFLOW:
                        throw stackUnderflow;

                    case GL_OUT_OF_MEMORY:
                        throw outOfMemory;

                    default:
                        throw unknown;
                }
            }
        }

        return Func(args);
    }
}
else
{
    alias glCheck(alias Func) = Func;
}
