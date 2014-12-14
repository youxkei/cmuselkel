module sprite.sprite;

import drawable.drawable;
import mixins;

class Sprite
{
    mixin POOLIZE!32;

    float x, y, angle;
    Drawable drawable;

    void drawOuter() @nogc
    {
        if (drawable) drawable.drawOuter(x, y);
    }

    void drawInner() @nogc
    {
        if (drawable) drawable.drawInner(x, y);
    }
}
