puts """

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




"""
