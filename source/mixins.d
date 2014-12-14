module mixins;

template PROP(T, string name)
{
    import std.string: format;

    enum PROP =
        "private %s %s_;".format(T.stringof, name) ~
        "static if (!is(typeof(%s)))".format(name) ~
        "{"
            "@property %s %s(){return %s_;}".format(T.stringof, name, name) ~
        "}"

        "static if (!is(typeof(%s=%s.init)))".format(name, T.stringof) ~
        "{"
            "@property void %s(%s val){%s_ = val;}".format(name, T.stringof, name) ~
        "}"
    ;
}

mixin template POOLIZE(size_t max)
{
    import std.range : Cycle, cycle;

    static assert(__traits(compiles, new typeof(this)()));

    public static typeof(this)[] pool;
    private static Cycle!(typeof(this)[]) buffer;

    static this()
    {
        pool = new typeof(this)[](max);
        buffer = cycle(pool);

        foreach (i; 0 .. max)
        {
            pool[i] = new typeof(this)();
        }
    }

    static typeof(this) opCall()
    {
        typeof(this) instance = buffer.front;
        buffer.popFront();
        return instance;
    }
}
