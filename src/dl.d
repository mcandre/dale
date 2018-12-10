/** Common build patterns */

import core.stdc.stdlib;
import std.algorithm;
import std.file;
import std.functional;
import std.process;
import std.range;
import std.stdio;

/** Dale API version */
immutable DALE_VERSION = "0.0.1";

/** Dub configuration toggle to prevent dale scripts from bundling
    with regular project artifacts. */
immutable DALE_FEATURE = "shi_sha";

/** An attribute for registering tasks. */
immutable TASK = "task";

/** Environment name controlling verbosity */
immutable DALE_VERBOSE_ENVIRONMENT_NAME = "VERBOSE";

/** Any procedure, such as compiling a source code file or deleting a directory glob. */
alias Task = void delegate();

/** A map of task names to implementations; */
alias TaskTable = Task[string];

/** Crude dependency tree */
bool[Task] DALE_DEPENDENCY_CACHE;

/** Crude phony set */
bool[Task] DALE_PHONY_TASKS;

/** Query common host binary suffix */
string binarySuffix() {
    version(windows) {
        return ".exe";
    } else {
        return "";
    }
}

/** Declare a dependency on a task that may panic */
void deps(Task task) {
    immutable phony = (task in DALE_PHONY_TASKS) !is null;
    immutable hasRun = (task in DALE_DEPENDENCY_CACHE) !is null;

    if (phony || !hasRun) {
        task();

        DALE_DEPENDENCY_CACHE[task] = true;
    }
}

/** Declare a dependency on a task that may panic */
void deps(void function() task) {
    deps(toDelegate(task));
}

/** Declare tasks with no obviously cacheable artifacts. */
void phony(Task[] tasks) {
    foreach(task; tasks) {
        DALE_PHONY_TASKS[task] = true;
    }
}

/** Declare tasks with no obviously cacheable artifacts. */
void phony(void function()[] tasks) {
    phony(tasks.map!(toDelegate).array);
}

/** Hey genius, avoid executing commands whenever possible! Look for D libraries instead.

    Executes the given program with the given arguments.
    Returns a handle to the process. */
auto execMut(string program, string[] arguments = []) {
    if (environment.get(DALE_VERBOSE_ENVIRONMENT_NAME) !is null) {
        writefln("%s %s", program, join(arguments, " "));
    }

    return pipeProcess(
        [program] ~ arguments,
        cast(Redirect)7, // https://dlang.org/library/std/process/pipe_process.html
        environment.toAA()
    );
}

/** Hey genius, avoid executing commands whenever possible! Look for D libraries instead.

    Executes the given program with the given arguments.
    Returns a handle to the process's stdout.
    Panics if the command exits with a failure status. */
auto execStdout(string program, string[] arguments = []) {
    if (environment.get(DALE_VERBOSE_ENVIRONMENT_NAME) !is null) {
        writefln("%s %s", program, join(arguments, " "));
    }

    auto execution = pipeProcess(
        [program] ~ arguments,
        Redirect.stdout,
        environment.toAA()
    );

    assert(wait(execution.pid) == 0);
    return execution.stdout;
}

/** Hey genius, avoid executing commands whenever possible! Look for D libraries instead.

    Executes the given program with the given arguments.
    Returns a handle to the process's stdout.
    Panics if the command exits with a failure status. */
auto execStderr(string program, string[] arguments = []) {
    if (environment.get(DALE_VERBOSE_ENVIRONMENT_NAME) !is null) {
        writefln("%s %s", program, join(arguments, " "));
    }

    auto execution = pipeProcess([program] ~ arguments,
        Redirect.stderr,
        environment.toAA()
    );

    assert(wait(execution.pid) == 0);
    return execution.stderr;
}

/** Convenience function for reading an entire UTF-8 file. */
string readUTF8(File f) {
    string s;

    foreach(ubyte[] buf; f.byChunk(1024)) {
        s ~= buf;
    }

    return s;
}

/** Hey genius, avoid executing commands whenever possible! Look for D libraries instead.

    Executes the given program with the given arguments.
    Returns the process's stdout content as a UTF-8 string.
    Panics if the command exits with a failure status. */
auto execStdoutUTF8(string program, string[] arguments = []) {
    auto childStdout = execStdout(program, arguments);
    return readUTF8(childStdout);
}

/** Hey genius, avoid executing commands whenever possible! Look for D libraries instead.

    Executes the given program with the given arguments.
    Returns the process's stderr content as a UTF-8 string.
    Panics if the command exits with a failure status. */
auto execStderrUTF8(string program, string[] arguments = []) {
    auto childStderr = execStderr(program, arguments);
    return readUTF8(childStderr);
}

/** Hey genius, avoid executing commands whenever possible! Look for D libraries instead.

    Executes the given program with the given arguments.
    Returns the status value.
    Panics if the command could not run to completion. */
auto execStatus(string program, string[] arguments = []) {
    if (environment.get(DALE_VERBOSE_ENVIRONMENT_NAME) !is null) {
        writefln("%s %s", program, join(arguments, " "));
    }

    auto execution = pipeProcess(
        [program] ~ arguments,
        cast(Redirect) 0,
        environment.toAA()
    );

    return wait(execution.pid);
}

/** Hey genius, avoid executing commands whenever possible! Look for D libraries instead.

    Executes the given program with the given arguments.
    Panics if the command exits with a failure status. */
void exec(string program, string[] arguments = []) {
    assert(execStatus(program, arguments) == 0);
}

/** Register tasks with CLI entrypoint,
    Given CLI arguments,
    A default task name,
    And an array of all available task names. */
void loadTasks(string[] args, string defaultTaskName, TaskTable taskTable) {
    auto argsRest = args[1..args.length]; // Drop program name

    if (argsRest.length == 0) {
        argsRest = [defaultTaskName];
    }

    foreach (arg; argsRest) {
        switch (arg) {
        case "-l":
        case "--list":
            writeln("Registered tasks:\n");

            foreach (taskName; taskTable.byKey()) {
                writefln("* %s", taskName);
            }

            exit(0);
            break;
        default:
            if (arg !in taskTable) {
                writefln("Unknown task %s", arg);
                exit(1);
            }

            taskTable[arg]();
        }
    }
}

/** Register all annotated TASKs in the caller module,
    Given CLI arguments and a default task. */
template yyyup(alias args, alias defaultTaskName) {
    const char[] yyyup = "
    import std.functional;
    import std.traits;

    TaskTable taskTable;

    foreach(memberName; __traits(allMembers, mixin(__MODULE__))) {
        static if (hasUDA!(__traits(getMember, mixin(__MODULE__), memberName), TASK)) {
            Task task = toDelegate(&__traits(getMember, mixin(__MODULE__), memberName));
            taskTable[memberName] = task;
        }
    }

    loadTasks(" ~ args ~ ", \"" ~ defaultTaskName ~ "\", taskTable);";
}
