# Running

cd into this folder

```
del my_design.vpp
C:\iverilog\bin\iverilog.exe -s counter_tb -o my_design.vvp counter_tb.v counter.v
C:\iverilog\bin\vvp.exe my_design.vvp
```

## Working with vvp

vpp will simulate the specified module until it encounters a $finish primitive.
It will not exit but the vvp.exe application keeps running and waits for
user input on the command line.

Typing help will list all commands. The command finish terminates vvp.exe

The vvp output looks like this:

```
vvp.exe my_design.vvp
At time                    0, value = xx (x)
At time                   17, value = 00 (0)
At time                   35, value = 01 (1)
At time                   45, value = 02 (2)
At time                   55, value = 03 (3)
At time                   57, value = 00 (0)
At time                   75, value = 01 (1)
At time                   85, value = 02 (2)
At time                   95, value = 03 (3)
At time                  105, value = 04 (4)
At time                  115, value = 05 (5)
At time                  125, value = 06 (6)
At time                  135, value = 07 (7)
At time                  145, value = 08 (8)
At time                  155, value = 09 (9)
At time                  165, value = 0a (10)
counter_tb.v:10: $stop called at 168 (1s)
** VVP Stop(0) **
** Flushing output streams.
** Current simulation time is 168 ticks.
>
```

vvp itself does not output a whole lot. Most of the output stems from the
$monitor() primitive in the testbench.

$monitor() started in the initial process and it will execute whenever it's
inputs change. One input is time and the other is value.

Value changes when the clock changes (all 5 ticks) and when the explicitly
changes the reset signal. All these changes combined together yield the
following ticks where data is changed:

tick 0 - initial values are set, this means that the reset signal is set to 0.
The counter module does not initialize it's internal state. As a consequence,
the internal state remains undefined which is displayed as xx.

The clk keeps inverting every 5 ticks (always #5 clk = !clk;) but since
the counter is in a non-initialized state (xx) there is no change to it's
value and the $monitor() primitive is not detecting a value change and hence
no output occurs on the command line.

At tick #17, the reset signal is set high and the counter initializes to
valid values. Once initialized, every clock tick causes the timer to count
or reset and hence after #17 there may be an output at least every 5 ticks.
Since at #17, the counter is kept in reset, not value change occurs as the
counter is kept at internal value 0.

#11 ticks after tick #17, the reset signal is turned low and the counter starts
to count. #17 + #11 is #28. At #30, the counter starts to count at 0 and
no value change is detected by the $monitor. AT #35 the counter counts to 1
and $monitor picks up a real value change!

At #17 + #11 + #29 = #57, the counter is reset again and kept in reset
until #17 + #11 + #29 + #11 = #68.

That is why between #57 and #70 there is no change printed to the console.
Beginning with #70 the counter starts to count at 0 which again is no value
change. Begining at #75 there is the first value change to 1.

At #17 + #11 + #29 + #11 + #100 = #168 the simulation is stopped because
the testbanch calls the $finish primitive.
