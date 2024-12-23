# beengone


![beengone banner image](https://cdn3.brettterpstra.com/uploads/2024/12/beengone-header-rb.webp)


Current version: 2.0.7

beengone is a CLI tool that tests how long a Mac has gone
without user input (keyboard or mouse/trackpad). It detects
any movement or keypress, including modifier keys. Run
without arguments, it outputs the number of seconds the
machine has been idle.

You can print the seconds idle with no newline using `-n`.

For use in scripting, there's a `--minimum/-m` option which
sets a minimum number of seconds required to pass the
condition. If the idle time is less than minimum, beengone
returns an error code of 1. If the minimum is met, it exits
successfully with an error code of 0.

Here's an example in Bash ([link](https://gist.github.com/ttscoff/57c9c73ac665f2074f649ff1fa205330)).



And here's an example for Fish ([link](https://gist.github.com/ttscoff/8079c8776e8f5e1f32610ba5c4992a6c)).



