/** CLI tinyrick tool */

import dl;

import core.stdc.stdlib;
import std.format;
import std.getopt;
import std.stdio;
import std.typecons;

/** Flag to enable task listing */
private bool listTasks;

/** Flag to enable version banner */
private bool showVersion;

/** Show short CLI spec */
void usage(string program, GetoptResult opts) {
    defaultGetoptPrinter(
        format("Usage: %s [OPTIONS]", program),
        opts.options
    );
}

/** Show version information */
void banner() {
    writefln("dale %s", DALE_VERSION);
}

/** CLI entrypoint */
void main(string[] args) {
    auto argsRest = args[1..args.length]; // Drop program name

    immutable program = args[0];

    auto spec = tuple(
        "list|l", &listTasks,
        "version|v", &showVersion
    );

    try {
        auto opts = getopt((args ~ spec).expand);

        if (opts.helpWanted) {
            usage(program, opts);
            exit(0);
        }

        if (showVersion) {
            banner();
            exit(0);
        }

        auto subcommand = ["run", "--config", DALE_FEATURE, "--"];

        if (listTasks) {
            exec("dub", subcommand ~= ["-l"]);
        } else {
            exec("dub", subcommand ~= argsRest);
        }
    } catch (GetOptException e) {
        usage(program, getopt(([program, "-h"] ~ spec).expand));
        exit(1);
    }
}
