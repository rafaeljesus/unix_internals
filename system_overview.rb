puts """

Chapter 1 - 3

Processes Have ID's

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

FYI: Ruby's Process.pid maps to getpid(2) (section 2 of getpid man pages)

Global Var exists to hold the current value of the PID
  -> Accessed with $$ (Bash and Perl support this too)
  -> Typing out Process.pid is more expressive...


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


Before STDIN, the program needed keyboard drivers for all of the keyboards it wanted to support.

If the program wanted to print something to the screen it needed to be able to manipulate pixels.

puts STDIN.fileno
puts STDOUT.fileno
puts STDERR.fileno

Gives:

0
1
2

Fd's are the core of network programming using sockets, pipes, etc and also at the core of FS operations.

As such, they are used by every running process and are at the core of most of the beefy stuff in computing.

Many methods on Ruby's IO class map to the same name:

open(2), close(2), read(2), write(2), pipe(2), fysnc(2), stat(2) among others.



































































































































































"""
