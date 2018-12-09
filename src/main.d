// CLI tinyrick tool

import dl;

import core.stdc.stdlib;
import std.format;
import std.getopt;
import std.stdio;

bool listTasks;
bool showVersion;

// Show short CLI spec
void usage(string program, GetoptResult opts) {
    defaultGetoptPrinter(
        format("Usage: %s [OPTIONS]", program),
        opts.options
    );
}

// Show version information
void banner() {
    writefln("dale %s", DALE_VERSION);
}

// CLI entrypoint
version(APP) {
    void main(string[] args) {
        immutable program = args[0];

        getopt(
            args,
            "list|l", &listTasks,
            "version|v", &showVersion
        );

        if (showVersion) {
            banner();
            exit(0);
        }

        auto subcommand = ["run", "--config", DALE_FEATURE, "--"];

        if (listTasks) {
            exec("dub", subcommand ~= ["-l"]);
        } else {
            exec("dub", subcommand ~= args);
        }
    }
}
