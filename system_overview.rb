puts """

Chapter 1 - 3

Processes Have ID's (PIDS)

To check the current process of IRB we can run:

'puts Process.pid'

#{NOTE:

  'PID = Generic representation of a process.
    - Not tied to any aspect of the content of a process
    - Therefore can be referenced by any programming language.'
}

Using the PID to trace process details.
---------------------------------------

Open two terminals:

Terminal 1: Run IRB, then run: Process.pid
        This will give a number...enter this into the second terminal.

Terminal 2: Run ps -p < pid from Terminal 1 >

Output:

PID TTY           TIME CMD
37839 ttys002    0:00.10 irb


Man Pages:
  Section 1: Bash Commands
  Section 2: System Calls
  Section 3: C Library Functions
  Section 4: Special Files


PIDs in the Real World

Knowledge of the PID isn't all that useful.

PIDs can be found in log files.

System Calls

$$ vs. Process.pid

  FYI: Ruby's Process.pid maps to getpid(2) (section 2 of getpid man pages)

  Global Var exists to hold the current value of the PID
    -> Accessed with $$ (Bash and Perl support this too)
    -> Typing out Process.pid is more expressive...

---------------------------------------------------------------------------------------------------------

Chapter 4.

Processes Have Parents

Every process on a Nix system has a parent process.
  -> Everything is a process
  -> Processes refer to their parent as 'ppid' (parent pid)
  -> Most of the time, parent process for a given process
     is the process that invoked it.
  -> Parent of Bash is Terminal.app (starts bash process)

The parent of the new bash process from Terminal 2 above
will be Terminal.app (macos)

If we invoke gem list(1) from bash,
then bash is the parent process.

#{NOTE:
'Kernel deals only in pids. To get the
 current parent process in irb:
  puts Process.ppid

  Then in another terminal:

  Output:

  ps -p <ppid>
    PID TTY           TIME CMD
  33617 ttys002    0:00.30 -bash
'

}

Not a lot of uses for ppid in the real world.
-> Important for detecting daemon processes.

System Calls

Ruby's Process.ppid maps to getppid(2)

---------------------------------------------------------------------------------------------------------

Chapter 5.

Processes Have File Descriptors

PIDS : Running Processes :: File Descriptors : Open Files

Everything is a file.
  -> Devices
  -> Sockets
  -> Pipes
  -> Files
...All are files.

Since these are all files, we can refer to them as resources.
Moving onwards, file will be meant in the traditional sense of files in an fs.



Descriptors Represent Resources
-------------------------------
Anytime we open a resource in a running process, it is assigned a file descriptor.

File descriptors are native to the processes they are bound to. Live by the process, die by the process.
-> They can be shared only between related processes.

Resources that are open act similarly; they are closed when the process exits.

There are special semantics when sharing file descriptors in a process that gets forked.

#{NOTE: 'In Ruby open file resources are represented by the IO class.
         -> Any IO object can have an associated file descriptor number.
         To get to them use:

        ->   IO#fileno

        For example in irb:

        a =  File.open('/etc/passwd')
        returns a file object ->  #<File:/etc/passwd>

        Then:

          puts a.fileno
          #=> 12
'
}

As seen above, 12 is the unique number.
The Kernel uses this number to keep track of any resources the process is using.

What happens when we have multiple resources open?

passwd = File.open('/etc/passwd')
puts passwd.fileno
-> Gives 12

hosts = File.open('/etc/hosts')
puts hosts.fileno

-> Gives 13

passwd.close
-> returns nothing but the file descriptor (or fd for short)
   is released for the next opened resource to use, like so:

null = File.open('/dev/null')
null.fileno

-> Gives 12

KEY TAKEAWAYS
-------------
1. Fd descriptors are assigned the lowest unused value.

2. Once a resource is closed, an fd becomes available again.

3. Closed resources are not given a file descriptor.

Since a closed file has no reason to interact with the hardware, Kernel has no reason to keep track of it.

File descriptors are sometimes called open file descriptors. As opposed to a closed one? Misnomerous.

Trying to read a file descriptor from a closed file will raise an exception.

IOError: closed stream

STD Streams:

STDIN: provides a generic way to read input from keyboard device or pipes.

STDOUT and STDERR: provide generic ways to write output to monitors, files, printers, etc.
   -> This was an innovation of UNIX
   -> Before STDIN, the program needed keyboard drivers for all of the keyboards it wanted to support.
   -> If the program wanted to print something to the screen it needed to be able to manipulate pixels.

fd, stdin, stdout, stderr = file descriptor files

puts STDIN.fileno
puts STDOUT.fileno
puts STDERR.fileno

Gives:

0
1
2

Can look here in the filesystem:

     /dev/fd/#
     /dev/stdin
     /dev/stdout
     /dev/stderr

Fd's are the core of network programming using sockets, pipes, etc and also at the core of FS operations.

As such, they are used by every running process and are at the core of most of the beefy stuff in computing.

Many methods on Ruby's IO class map to the same name:

open(2), close(2), read(2), write(2), pipe(2), fysnc(2), stat(2) among others.

For example:
  - Ruby IO Class : Actual Target File :: Ruby open : system call open

---------------------------------------------------------------------------------------------------------
Chapter 6.

Processes Have Resource Limits

Notice how when we open files, the fileno keeps increasing so the question is...
Q. How many file descriptors can one process have?

A. Depends on the system configuration, but what matters is that there are
   resource limits imposed on a process by the kernel.

Finding said limits
  - Using Ruby we can find the maximum number of allowed file descriptors.

  #get resource limit = getrlimit
  p Process.getrlimit(:NOFILE)

  The :NOFILE symbol is the param for the number of files...above command returns an array:
    ->  [256, 9223372036854775807]

  256 is the soft limit for the number of file descriptors
  9223372036854775807 is the hard limit of file descriptors

  Soft limit: 256
   - 1). isn't really a true limit...
   - 2). 256 meaning: if one process opens more than 256 files then an exception is raised
   - 3). YOU CAN CHANGE THIS LIMIT IF YOU WANT TO

  Hard Limit: 9223372036854775807
  That big number is actually a representation of INFINITY from the constant:
    ->  Process::RLIMIT_INFINITY
    -> Check this number on the system to be sure
    -> Not likely that you could open up 9223372036854775807 files without hardware limitations

  Quintessentially...
    ->  We can open as many files as we'd like, once we bump the soft limit for our needs.

  Basically any process iis able to change its own soft limit.
  But to bump the hard limit? You must be a privileged user or have permissions to do so.

  We can change the limits by reading the documentation at systctl(8)

  man 8 sysctl == get or set kernel state.

  $ sysctl -a = outputs all of the currently non-opaque values and variables
    Output:
      machdep.xcpm.qos_txfr: 1
      machdep.xcpm.deep_idle_count: 0
      machdep.xcpm.deep_idle_last_stats: n/a

  $ sysctl -d -a = outputs just the description of the variables without the values
    Output:
      machdep.xcpm.qos_txfr:
      machdep.xcpm.deep_idle_count:
      machdep.xcpm.deep_idle_last_stats:

    Maybe useful for creating a blank template, passing in different values until something works
    Quantum Problem....1124 variables...find the hard problem of how many permutations of this file exists.

  sysctl -a -e = outputs all vars set with equal signs instead of colons...useful for feeds into sysctl utils

  Max number of processes allowed on a system:
  $ sysctl kern.maxproc
    Output:
      kern.maxproc: 1064

  TO SET VALUES (Example):
    $ sysctl kern.maxprocperuid=1000



Bump the soft limit for the current process in Ruby
---------------------------------------------------
Process.setrlimit(:NOFILE, 4096) .... shows -> nil
Process.getrlimit(:NOFILE)... shows -> [4096, 4096]

- This set a new limit for the number of open files
- When we ask for that limit again, both limits were set to 4096

- We can pass an optional third value to Process.setrlimit
  specifying a new hard limit.

- Lowering the hard limit as done previously is irreversible (once it comes down, no go back up)
  -> THOUGHT...do we really need a maximum at that ridiculously large integer for IRB??? Probably not.



COMMON WAY TO RAISE SOFT LIMIT OF A SYSTEM RESOURCE TO BE EQUAL WITH THE HARD LIMIT
-----------------------------------------------------------------------------------
Process.setrlimit(:NOFILE, Process.getrlimit(:NOFILE)[1])


Exceeding the limit
-------------------
#{NOTE:
  '
    Exceeding the soft limit will raise Errno::EMFILE (Exceed max file)
  '
}

In irb:
- We test the above exception by setting the max number of file descriptors to 3
- We know this will fail because STDIN, STDOUT, STDERR (standard streams family)
  are occupying the first 3 file descriptors by default.

Process.setrlimit(:NOFILE, 3)
File.open('/dev/null')


We can't even get to the /dev/null part because irb will crash as calling the command
means to access the file containing the Process Class and execute the functions for
which then the exception is raised:

...Too many open files @ rb_sysopen... Errno::EMFILE...

Other Resources
---------------
Can use these same methods to check and modify limits on other system resources.

COMMON ONES ARE:
  1). Max number of simultaneous processes allowed for the current user:
      -> Process.getlimit(:NPROC)  number of processes.

  2). Largest size file that can be created:
      -> Process.getlimit(:FSIZE)

  3). Max size of the stack segment of the process.
      -> Processs.getlimit(:STACK)

  4). To see more, view documentation for Process.getrlimit

REAL WORLD
----------
Needing to modify limits for system resources is an uncommon need for most programs.

For specialized tools, these modifications can be important.

One use case is any process needing to handle 1000's of concurrent network connections

  Example: httperf(1) = this is an http performance tool. A command like

          $ httperf --hog --sever www --num-conn 5000

  will ask httperf(1) to create 5000 concurrent connections.

  This will be a problem on our system due to its default soft limit, so httperf(1)
  will need to nump its soft limit before it can properly do its testing.

  Remember that these limits are gettng modified on a per process basis.

  Another real world case is where you execute third party code and you need to keep it
  within certain constraints.

  > You could set limits for processes running that code
  > Revoke permissions to change them,
    ...Hence ensuring that they don't use more resources than you allow for them


System Calls Analogy
--------------------

Process.getlimit : Process.setlimit :: getlimit(2) : setlimit(2)

---------------------------------------------------------------------------------------------------

Chapter 7: Processes Have an Environment

Environment refers to environment variables (env vars)

 - Env vars are key value pairs that hold data for a process.

THOUGHT:
  Design Patterns Thinking...is this is what a configuration file is for??? Kind of? Maybe? Must investigate.

Every process inherits env vars from their parents. These env vars are SET by parent processes.
Env vars are per process and are global to each process.

Simple example of setting an env var in bash:

$ MESSAGE='hello unix' ruby -e 'puts ENV['MESSAGE']'














































































































































"""
