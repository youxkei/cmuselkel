module gl.color;

import mixins : PROP;
import std.typecons : Tuple;

struct Color
{
    mixin (PROP!(int, "r"));
    mixin (PROP!(int, "g"));
    mixin (PROP!(int, "b"));
    mixin (PROP!(int, "a"));

    invariant()
    {
        assert (0 <= r_ && r_ <= 255);
        assert (0 <= g_ && g_ <= 255);
        assert (0 <= b_ && b_ <= 255);
        assert (0 <= a_ && a_ <= 255);
    }

    Tuple!(float, float, float, float) floatize() @nogc
    {
        return typeof(return)(r_ / 255.0, g_ / 255.0, b_ / 255.0, a_ / 255.0);
    }
}
