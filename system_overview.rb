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




"""
