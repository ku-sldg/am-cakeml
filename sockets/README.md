# Status
Sockets should be working with the newest version of the compiler (`cake --version` = Tue Jan 22 00:49:08 2019 UTC).

# Misc
- If you need to terminate your program early, use Ctl+c. Using Ctl+z will result in the sockets not closing properly, and the program will likely fail to reacquire the socket port on the next execution (restarting fixes the issue).
