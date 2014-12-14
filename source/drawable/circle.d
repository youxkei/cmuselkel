module drawable.circle;

import mixins : POOLIZE;
import drawable.drawable;
import gl.color : Color;
import gl.program : Program;
import gl.check : glCheck;
import derelict.opengl3.gl;

class Circle : Drawable
{
    mixin POOLIZE!1024;

    invariant()
    {
        assert (radius > 0);
        assert (lineWeight > 0);
    }

    public
    {
        float radius = 1;
        float lineWeight = 1;
        Color color;

        void drawOuter(float x, float y) @nogc
        {
            outerProgram.bind();

            setVertices(this);

            outerProgram.setAttribute("position", 2, vertices);
            outerProgram.setUniform("x", x);
            outerProgram.setUniform("y", y);
            outerProgram.setUniform("radius", radius);
            outerProgram.setUniform("lineWeight", lineWeight);
            outerProgram.setUniform("color", color.floatize().field);

            glCheck!glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

            glCheck!glDrawArrays(GL_POLYGON, 0, 4);
        }

        void drawInner(float x, float y) @nogc
        {
            outerProgram.bind();

            setVertices(this);

            outerProgram.setAttribute("position", 2, vertices);
            innerProgram.setUniform("x", x);
            innerProgram.setUniform("y", y);
            innerProgram.setUniform("radius", radius);
            innerProgram.setUniform("lineWeight", lineWeight);
            innerProgram.setUniform("color", color.floatize().field);

            glCheck!glBlendFunc(GL_ZERO, GL_SRC_ALPHA);

            glCheck!glDrawArrays(GL_POLYGON, 0, 4);
        }
    }

    static private
    {
        float[] vertices = [0, 0, 0, 0, 0, 0, 0, 0];

        Program outerProgram;
        Program innerProgram;

        void setVertices(Circle circle) @nogc
        {
            float radius = circle.radius + circle.lineWeight;

            vertices[0] = -radius;
            vertices[1] = -radius;

            vertices[2] = -radius;
            vertices[3] =  radius;

            vertices[4] =  radius;
            vertices[5] =  radius;

            vertices[6] =  radius;
            vertices[7] = -radius;
        }
    }
}

enum vertexShader =
q{
    attribute vec2 position;
    varying vec2 coord;
    uniform float x;
    uniform float y;
    uniform mat4 projectionMatrix;

    void main(void)
    {
        mat4 modelViewMatrix = mat4(1.0);
        modelViewMatrix[3].xy = vec2(x, y);
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 0.0, 1.0);
        coord = position;
    }
};

enum outerFragmentShader =
q{
    varying vec2 coord;
    uniform float radius;
    uniform float lineWeight;
    uniform vec4 color;

    void main(void) {
        float diff = distance(coord, vec2(0));

        float ratio =  1.0 - smoothstep(radius, radius + lineWeight, diff);

        gl_FragColor = vec4(color.xyz, color.w * ratio);
    }
};

enum innerFragmentShader =
q{
    varying vec2 coord;
    uniform float radius;
    uniform float lineWeight;
    uniform vec4 color;

    void main(void) {
        float diff = distance(coord, vec2(0));

        float ratio =  smoothstep(radius - lineWeight, radius, diff);

        gl_FragColor = vec4(color.xyz, color.w * ratio);
    }
};

float[16] orthogonalMatrix(float left,   float right,
                           float bottom, float top,
                           float near,   float far) pure nothrow @safe @nogc
{
    float[16] matrix;
    float dx = right - left;
    float dy = top - bottom;
    float dz = far - near;

    matrix[ 0] =  2.0f / dx;
    matrix[ 5] =  2.0f / dy;
    matrix[10] = -2.0f / dz;
    matrix[12] = -(right + left) / dx;
    matrix[13] = -(top + bottom) / dy;
    matrix[14] = -(far + near) / dz;
    matrix[15] =  1.0f;
    matrix[ 1] = matrix[ 2] = matrix[ 3] = matrix[ 4] =
    matrix[ 6] = matrix[ 7] = matrix[ 8] = matrix[ 9] = matrix[11] = 0.0f;

    return matrix;
}

class static_this
{
    this()
    {
        string[] attributes = ["position"];
        string[] uniforms = ["x", "y", "radius", "lineWeight", "projectionMatrix", "color"];

        Circle.outerProgram = new Program(vertexShader, outerFragmentShader, attributes, uniforms);
        Circle.innerProgram = new Program(vertexShader, innerFragmentShader, attributes, uniforms);

        float[] projectionMatrix = orthogonalMatrix(0, 1280, 960, 0, -1, 1);

        Circle.outerProgram.setUniform("projectionMatrix", projectionMatrix);
        Circle.innerProgram.setUniform("projectionMatrix", projectionMatrix);
    }
}
