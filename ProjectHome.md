<font color='#1d773b'><b>KEDR</b></font> is a framework for dynamic (runtime and post factum) analysis of Linux kernel modules, including device drivers, file system modules, etc. The components of KEDR operate on a kernel module chosen by the user. They can intercept the function calls made by the module and, based on that, detect memory leaks, simulate resource shortage in the system as well as other uncommon situations, save the information about the function calls to a kind of "trace" for future analysis by the user-space tools.

For the present, KEDR is provided for 32- and 64-bit x86 systems.

KEDR can be used in the development of kernel modules (as a component of QA system) as well as when analyzing the kernel failures on a user's system (technical support). Certification systems and other automated verification systems for kernel-mode software can also benefit from it.

---


### Downloads ###

Latest release: [KEDR 0.5](https://www.dropbox.com/s/1q8b4gjchq3mdz3/kedr-0.5.tar.bz2)

You can also use the latest code [from the repository](http://code.google.com/p/kedr/source/checkout). Bug fixes get there first, as well as support for newer kernel versions.

### More Info ###

If you are looking for a step-by-step tutorial that allows to quickly learn how to use KEDR to monitor function calls, simulate memory allocation failures and detect memory leaks, then [here it is](kedr_manual_getting_started.md).

If you have questions, suggestions, proposals, etc., concerning KEDR
framework, feel free to join ["kedr-discuss" Google Group](http://groups.google.com/group/kedr-discuss) and write us a message. Note that only the members of that group may post messages there.

Detailed description of the framework is available in the [Reference Manual](kedr_manual.md). The [slides](https://www.dropbox.com/s/xiij7ty9ahuc0nv/KEDR_Slides_LinuxCon2011.pdf) from the presentation about KEDR could be helpful too.

The following information may also be useful:
  * [Problems Found](Problems_Found.md) - some of the problems in kernel modules revealed by KEDR tools
  * [Known issues](Known_Issues.md) in the framework
  * HowTos:
    * [Using KEDR with Autotest](HowTo_Autotest_Basics.md) - how to use KEDR in conjunction with [Autotest](http://autotest.github.com/)
    * [KEDR and Chromium OS](HowTo_Chromium_OS.md) - how to build KEDR for [Chromium OS](http://www.chromium.org/chromium-os)
    * [How to build KEDR for another kernel](HowTo_Another_Kernel.md) on the same machine or for another machine with the same architecture
  * [Tips and Tricks](Tips_and_Tricks.md)
  * Comparison with similar systems:
    * [KEDR (LeakCheck) and Kmemleak](KEDR_And_Kmemleak.md)
    * [KEDR (Fault Simulation) and Fault Injection framework](KEDR_And_Fault_Injection.md)
