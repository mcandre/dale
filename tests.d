import dl;

unittest {
    auto xs = [1, 2, 3];

    void oneMore() {
        xs ~= [4];
    }

    deps(&oneMore);

    assert(xs == [1, 2, 3, 4]);
}
