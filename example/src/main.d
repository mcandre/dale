/** CLI utility for addition by two, wowzers! */

import arithmancy;

import core.stdc.stdlib;
import std.format;
import std.getopt;
import std.stdio;
import std.typecons;

/** Flag to specify numbers */
private int n;

/** Show short CLI spec */
void usage(string program, GetoptResult opts) {
    defaultGetoptPrinter(
        format("Usage: %s [OPTIONS]", program),
        opts.options
    );
}

/** CLI entry point */
version(APP) {
    void main(string[] args) {
        immutable program = args[0];

        auto spec = tuple(
            std.getopt.config.required,
            "n", "an integer", &n
        );

        try {
            auto opts = getopt((args ~ spec).expand);

            if (opts.helpWanted) {
                usage(program, opts);
                exit(0);
            }

            writefln("%d", addTwo(n));
        } catch (GetOptException e) {
            usage(program, getopt(([program, "-h"] ~ spec).expand));
            exit(1);
        }
    }
}
