module drawable.drawable;

interface Drawable
{
    void drawOuter(float x, float y) @nogc;
    void drawInner(float x, float y) @nogc;
}
