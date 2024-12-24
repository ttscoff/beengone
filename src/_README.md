# beengone

<!--README--><!--GITHUB-->
![beengone banner image](https://cdn3.brettterpstra.com/uploads/2024/12/beengone-header-rb.webp)<!--END GITHUB-->

[original]: https://xs-labs.com/en/archives/articles/iokit-idle-time/
[v1]: https://brettterpstra.com/2013/02/10/beengone-a-script-friendly-way-to-check-computer-idle-time/

This is a revival of an [old project][v1] of mine, rewritten
for v2.0 with some updates for recent versions of macOS and
with the addition of some command line flags that make
scripting easier. This code is based on
[a post by Jean-David Gadina][original], on which I've
elaborated.

beengone is a (macOS-only) CLI tool that tests how long a
Mac has gone without user input (keyboard or
mouse/trackpad). It detects any movement or keypress,
including modifier keys. Run without arguments, it outputs
the number of seconds the machine has been idle.

Current version: <!--VER-->2.0.8<!--END VER-->

You can print the seconds idle with no newline using `-n`,
simulate input with `-i`, resetting the idle timer.

For ease of scripting, there's a `-m/--minimum=XXX` option
which sets a minimum number of seconds required to pass the
condition. If the idle time is less than the minimum,
beengone returns an error code of 1. If the minimum is met,
it exits successfully with an error code of 0.

You can also pause scripts until a limit with the
`-w/--wait=XXX` flag, avoiding having to loop and check exit
codes. `-w` will always exit 0 once the limit is reached.

Both `-m` and `-w` accept either integer values in seconds,
or strings in the format "Xd Xh Xm Xs", representing days,
hours, minutes, and seconds. Any combination can be used,
and spaces aren't required, e.g. `-w 2m30s`.

```console
Usage: beengone [options]

Print the system idle time in seconds.


Options
    -n, --no-newline      print idle seconds without newline
    -m, --minimum=<str>   test for minimum idle time in
                          seconds, exit 0 or 1 based on
                          condition, accepts strings
                          like "5h 30m" or "1d12h"
    -w, --wait=<str>      wait until the system has been
                          idle for the specified number of
                          seconds, accepts strings
                          like "5h 30m" or "1m30s"
    -i, --input           simulate user input

Other
    -h, --help            show this help message and exit
    -d, --debug           print debugging info
    -v, --version         show version and exit
```

Here's an example in Bash ([link](https://gist.github.com/ttscoff/57c9c73ac665f2074f649ff1fa205330)) using an infinite loop and the `-m`
flag exit code.

<!--JEKYLL{% gist 57c9c73ac665f2074f649ff1fa205330 %}-->

More examples in Bash ([link](https://gist.github.com/ttscoff/150950e0f7191c73cde0780321c7b589)).

<!--JEKYLL{% gist 150950e0f7191c73cde0780321c7b589 %}-->

And here's an example for Fish
([link](https://gist.github.com/ttscoff/8079c8776e8f5e1f32610ba5c4992a6c))
using the `-w` command to block execution until the minimum
idle time is reached.
<!--END README-->

