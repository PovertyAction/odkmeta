Stata environment for odkmeta development
=========================================

Follow these steps to set up your Stata environment for `odkmeta` development. At the end, individual source code files should be able to run on their own: there is no need to run `write_ado.do` when working on a single source code file.

Type the following in Stata to install SSC packages used in `odkmeta` itself, the cscript, or other files:

```
ssc install specialexp
ssc install fastcd
ssc install renvars
```

Now set up `fastcd` to run on your computer as follows:

```
* Change the working directory to the location of GitHub/odkmeta on your
* computer.
cd ...
c cur odkmeta
```

After this, the command `c odkmeta` will change the working directory to `GitHub/odkmeta`.

`fastcd` is the name of the SSC package, not the command itself; the command is named `c`. To change the working directory, type `c` in Stata, not `fastcd`. To view the help file, type `help fastcd`, not `help c`.

Next, install [`compdta`](https://github.com/matthew-white/compdta), adding it to a [system directory](http://www.stata.com/help.cgi?sysdir) or your [ado-path](http://www.stata.com/help.cgi?adopath).

Finally, add `odkmeta` to your ado-path:

```
c odkmeta
adopath ++ `"`c(pwd)'"'
```

You may wish to place these lines in your [`profile.do`](http://www.stata.com/support/faqs/programming/profile-do-file/) as follows:

```
local curdir "`c(pwd)'"
c odkmeta
adopath ++ `"`c(pwd)'"'
cd `"`curdir'"'
```
