module gl.program;

import gl.check;

import std.typetuple: TypeTuple;
import derelict.opengl3.gl;

class Program
{
    GLuint program;
    GLuint[string] attributeLocation;
    GLuint[string] uniformLocation;

    this(string vertexSource, string fragmentSource, string[] attributes, string[] uniforms)
    {
        GLuint vertexShader = createVertexShader(vertexSource);
        scope (exit) glCheck!glDeleteShader(vertexShader);

        GLuint fragmentShader = createFragmentShader(fragmentSource);
        scope (exit) glCheck!glDeleteShader(fragmentShader);

        program = createProgram(vertexShader, fragmentShader);

        bind();

        foreach (attribute; attributes)
        {
            GLuint location = glCheck!glGetAttribLocation(program, attribute.ptr);
            attributeLocation[attribute] = location;
            glCheck!glEnableVertexAttribArray(location);
        }

        foreach (uniform; uniforms)
        {
            uniformLocation[uniform] = glCheck!glGetUniformLocation(program, uniform.ptr);
        }
    }

    void bind() @nogc
    {
        glCheck!glUseProgram(program);
    }

    void setAttribute(string attribute, GLint size, float[] data) @nogc
    {
        bind();

        GLuint* location = attribute in attributeLocation;
        glCheck!glVertexAttribPointer(*location, size, GL_FLOAT, false, 0, data.ptr);
    }

    void setUniform(string uniform, float[] data) @nogc
    {
        bind();

        GLuint* location = uniform in uniformLocation;
        glCheck!glUniformMatrix4fv(*location, 1, false, data.ptr);
    }

    void setUniform(string uniform, float data) @nogc
    {
        bind();

        GLuint* location = uniform in uniformLocation;
        glCheck!glUniform1f(*location, data);
    }

    void setUniform(string uniform, TypeTuple!(float, float, float, float) data) @nogc
    {
        bind();

        GLuint* location = uniform in uniformLocation;
        glCheck!glUniform4f(*location, data);
    }
}

private:

GLuint createProgram(GLuint vertexShader, GLuint fragmentShader)
{
    GLuint program = glCheck!glCreateProgram();

    glCheck!glAttachShader(program, vertexShader);
    glCheck!glAttachShader(program, fragmentShader);

    glCheck!glLinkProgram(program);

    GLint linkStatus;
    glCheck!glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);

    if (!linkStatus)
    {
        static exception = new immutable(Exception)("Link failed");
        throw exception;
    }

    return program;
}

enum ShaderKind { VERTEX, FRAGMENT }

GLuint createShader(ShaderKind shaderKind)(string src)
{
    GLuint shader;

    with(ShaderKind) final switch(shaderKind)
    {
        case VERTEX:
            shader = glCheck!glCreateShader(GL_VERTEX_SHADER);
            break;
        case FRAGMENT:
            shader = glCheck!glCreateShader(GL_FRAGMENT_SHADER);
            break;
    }

    const char* srcPtr = src.ptr;
    glCheck!glShaderSource(shader, 1, &srcPtr, null);
    glCheck!glCompileShader(shader);

    GLint compileStatus;
    glCheck!glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);

    if (!compileStatus)
    {
        throw new Exception("Compilation failed");
    }

    return shader;
}

alias createVertexShader = createShader!(ShaderKind.VERTEX);
alias createFragmentShader = createShader!(ShaderKind.FRAGMENT);
