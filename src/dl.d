// Common build patterns

import core.stdc.stdlib;
import std.algorithm;
import std.array;
import std.functional;
import std.process;
import std.stdio;
import std.typetuple;

// Dale API version
immutable DALE_VERSION = "0.0.1";

// Dub configuration toggle to prevent dale scripts from bundling
// with regular project artifacts.
immutable DALE_FEATURE = "shi_sha";

// Environment name controlling verbosity
immutable DALE_VERBOSE_ENVIRONMENT_NAME = "VERBOSE";

// Any procedure, such as compiling a source code file or deleting a directory glob.
alias Task = void delegate();

// A map of task names to implementations;
alias TaskTable = Task[string];

// Crude dependency tree
bool[Task] DALE_DEPENDENCY_CACHE;

// Crude phony set
bool[Task] DALE_PHONY_TASKS;

// Query common host binary suffix
string binarySuffix() {
    version(windows) {
        return ".exe";
    } else {
        return "";
    }
}

// Declare a dependency on a task that may panic
void deps(Task task) {
    auto phony = (task in DALE_PHONY_TASKS) !is null;
    auto hasRun = (task in DALE_DEPENDENCY_CACHE) !is null;

    if (phony || !hasRun) {
        task();

        DALE_DEPENDENCY_CACHE[task] = true;
    }
}

// Declare a dependency on a task that may panic
void deps(void function() task) {
    deps(toDelegate(task));
}

// Declare tasks with no obviously cacheable artifacts.
void phony(Task[] tasks) {
    foreach(task; tasks) {
        DALE_PHONY_TASKS[task] = true;
    }
}

// Declare tasks with no obviously cacheable artifacts.
void phony(void function()[] tasks) {
    phony(tasks.map!(toDelegate).array);
}

// Hey genius, avoid executing commands whenever possible! Look for D libraries instead.
//
// Executes the given program with the given arguments.
// Returns the command object.
auto execMut(string program, string[] arguments = []) {
    if (environment.get(DALE_VERBOSE_ENVIRONMENT_NAME) !is null) {
        writefln("%s %s", program, join(arguments, " "));
    }

    return execute([program] ~ arguments);
}

// Hey genius, avoid executing commands whenever possible! Look for D libraries instead.
//
// Executes the given program with the given arguments.
// Returns the output object.
// Panics if the command exits with a failure status.
auto execOutput(string program, string[] arguments = []) {
    auto execution = execMut(program, arguments);
    assert(execution.status == 0);
    return execution.output;
}

// Hey genius, avoid executing commands whenever possible! Look for D libraries instead.
//
// Executes the given program with the given arguments.
// Returns the status.
// Panics if the command could not run to completion.
auto execStatus(string program, string[] arguments = []) {
    auto execution = execMut(program, arguments);
    return execution.status;
}

// Hey genius, avoid executing commands whenever possible! Look for D libraries instead.
//
// Executes the given program with the given arguments.
// Panics if the command exits with a failure status.
auto exec(string program, string[] arguments = []) {
    assert(execStatus(program, arguments) == 0);
}

// Register tasks with CLI entrypoint,
// Given CLI arguments,
// A default task name,
// And an array of all available task names.
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
            auto task = taskTable[arg];

            if (task is null) {
                writefln("Unknown task %s", arg);
                exit(1);
            }

            task();
        }
    }
}

// Query available tasks with implementations in a module.
template getTaskTable(alias moduleName) {
    alias memberNames = __traits(allMembers, moduleName);

    template isTask(alias memberName) {
        enum isTask = is(typeof(__traits(getMember, moduleName, memberName)) == Task);
    }

    alias taskNames = Filter!(isTask, memberNames);

    template nameTaskTuple(alias memberName) {
        Task task = __traits(getMember, moduleName, memberName);
        alias nameTaskTuple = tuple(name, task);
    }

    alias taskTable = taskNames
        .map(nameImplTuple)
        .assocArray;
}

// Register available tasks with CLI entrypoint,
// Given a CLI arguments binding
// and a default task binding.
template yyyup(alias args, alias defaultTaskName) {
    alias yyyup = loadTasks(args, defaultTaskName, getTaskTable(__MODULE__));
}
