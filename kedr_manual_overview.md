

# Overview #

## General ##


KEDR is a system for the analysis of Linux [kernel modules](kedr_manual_glossary#Glossary.md) (including
but not limited to device drivers and file system modules) in
runtime. The types of analysis that can be performed with KEDR vary from simply
collecting the statistics on the kernel functions used by a particular
module to revealing subtle errors in the module via fault simulation
techniques - and may go even beyond that in the future.



KEDR framework will probably be useful mostly for the developers and
maintainers of kernel modules. It could also be used in the automated verification systems for kernel-mode software (for example, in the certification systems for Linux drivers, etc.), where, among other things, a kernel module is subjected to a series of tests to estimate its reliability.



One of the main goals of KEDR is to provide a reliable runtime analysis
engine for Linux kernel modules, easy to use and easy to build custom
applications upon.



Currently, there is a variety of tools, in-kernel or standalone, that allow
analyzing the kernel modules: Kmemcheck, Kmemleak, Fault Injection framework, SystemTap, LTTng, various
debugging facilities and so forth. Many of these tools operate on the
kernel as a whole rather than on a particular module. KEDR may
complement such systems well because it allows to analyze the kernel
modules chosen by the user and strives to affect other parts of the kernel
as little as possible.



The ideas behind KEDR are really not very new. One could mention at least
two other systems that analyze the selected kernel modules in runtime and help
reveal problems in these: [Microsoft Driver Verifier for Windows](http://msdn.microsoft.com/en-us/library/ff545448(VS.85).aspx)
and "Impostor" ("API Swapping") facilities used
by [SUSE YES Tools for Linux](http://developer.novell.com/devnet/yes/). Both systems seem to monitor the operation of a target
module including its interaction with the rest of the kernel.



At the core of KEDR lies its ability to intercept function calls made by
the target kernel module. If the module uses a function exported by the kernel
proper or by some other module, KEDR can instrument the calls to this
function in the target module. This allows to find out the values of
arguments the function was called with, the value it returned, etc. This also
allows to alter the execution of the target module, for example, to simulate a
situaton when memory allocation fails or to allocate memory from some
special tracked pool instead of the default one and so on.


<blockquote><font><b><u>Note</u></b></font>

Note that KEDR is not generally a tool to analyze the interaction between a low-level device driver and the hardware the driver services.<br>
<br>
</blockquote>

## Types of Analysis KEDR Supports ##


Currently, KEDR provides tools for the following kinds of analysis:


<ul><li>

<a href='kedr_manual_using_kedr#Detecting_Memory_Leaks.md'>Checking for memory leaks</a>
The appropriate components of KEDR keep track of various memory allocation and<br>
deallocation operations made by the target module. After the target module<br>
has unloaded, KEDR generates a report listing the memory blocks that have<br>
been allocated but not freed by that module along with a call stack for each of the<br>
corresponding memory allocation calls.<br>
<br>
</li>
<li>

<a href='kedr_manual_using_kedr#Fault_Simulation.md'>Fault simulation</a>
KEDR forces some of the calls made by the target module fail. In fact,<br>
KEDR simulates the failure without actually calling the respective<br>
<a href='kedr_manual_glossary#Target_function.md'>target function</a>. The scenarios<br>
(the calls to which functions must fail in what conditions) can be<br>
controlled and customized by the user.<br>
<br>
</li>
<li>

<a href='kedr_manual_using_kedr#Call_Monitoring_(Call_Tracing).md'>Call monitoring (call tracing)</a>
During the operation of the module under analysis, the information is<br>
collected about the calls to <a href='kedr_manual_glossary#Target_function.md'>target functions</a>: arguments, return values, etc. This information can be<br>
saved to a file (<i>trace</i>) for future analysis in the user space.<br>
<br>
<br>
<br>
This is similar to what <a href='http://sourceforge.net/projects/strace/'>strace</a>
utility does for user-space applications.<br>
<br>
</li>
</ul>

Other types of analysis can be implemented with the help of KEDR. See
["Implementing Custom Types of Analysis"](kedr_manual_extend#Implementing_Custom_Types_of_Analysis.md) for more information and examples.


## System Requirements ##


KEDR system supports Linux kernel versions 2.6.32 or newer. Of all kernel
facilities it relies upon, tracing facilities (implementation of ring
buffer, etc.) currently have the highest requirements for the version of
the kernel.



For the present time, only x86 and x86-64 architectures are supported.


<blockquote><font><b><u>Note</u></b></font>

Note that, in its <a href='kedr_manual_overview#Common_Use_Case.md'>common use case</a>,<br>
KEDR does not rely on <i>kernel probes</i> (KProbes) to do<br>
its work. It just employs instruction decoding facilities used to<br>
implement KProbes. So it can operate even on the systems where support for<br>
kernel probes is disabled in the kernel.<br>
<br>
</blockquote>

## Common Use Case ##


Here is what a common use case for the runtime analysis of a kernel module with
KEDR may look like. This is just "a big picture", see ["Getting Started"](kedr_manual_getting_started#Getting_Started.md) for a more detailed description of the operations
executed at each step.

The steps listed below can be performed manually or perhaps by a user-space
application.


<ol><li>

At the beginning, the target module is not loaded.<br>
<br>
</li>
<li>

The user loads the core components of KEDR system along with the appropriate plugins<br>
(<a href='kedr_manual_glossary#Payload_module.md'>payload modules</a>) and specifies the<br>
name of the target module. KEDR begins watching for the target module to load.<br>
<br>
</li>
<li>

The user loads the target module or plugs in a device that as the system<br>
knows, should be handled by the target module. Or (s)he does something else<br>
that results in loading of the target module.<br>
<br>
<br>
<br>
When the target module is loaded but before it begins to perform its<br>
initialization, KEDR detects that and hooks into the target module<br>
(instruments it) for the payload modules to be able to work.<br>
<br>
</li>
<li>

The user performs actions on the target module: operates on the<br>
corresponding device or a partition with a given file system, etc. At the<br>
same time, the payload modules collect the information about the<br>
operation of the module, perform fault simulation, etc.<br>
<br>
<br>
<br>
The tests checking various operations with the kernel module can also be run at<br>
this step. The goal is to make the module execute all the paths in its<br>
code that the user wants to check.<br>
<br>
</li>
<li>

The user unloads the target module.<br>
<br>
</li>
<li>

The user analyzes the results output by the payload modules and decides whether<br>
the target module behaved as it was required.<br>
<br>
</li>
<li>

If it is necessary to analyze the target module once more (may be, perform<br>
a different type of checks, etc.), the process can be repeated. When the<br>
components of KEDR are no longer needed, they can be unloaded.<br>
<br>
</li>
</ol>
<blockquote><font><b><u>Note</u></b></font>

Currently, KEDR framework provides no means to analyze an already loaded,<br>
initialized and running target module.<br>
<br>
</blockquote>

## Key Technologies KEDR Relies Upon ##


The core components of KEDR have been developed based on the technologies
heavily used in the kernel itself, for example:


<ul><li>

<i>notification system</i>;<br>
<br>
</li>
<li>

<i>instruction decoding facilities</i> used in the kernel<br>
to implement KProbes;<br>
<br>
</li>
<li>

<i>tracing support</i> (namely, the implementation of a<br>
special <i>ring buffer</i> - the basis of various data<br>
collection systems used in the kernel;<br>
<br>
</li>
<li>

<i>debugfs</i> file system as the mechanism for data exchange between<br>
the kernel space and the user space.<br>
<br>
</li>
</ul>
## Limitations ##


The ideas KEDR is based upon and the technologies it currently uses impose
some limitations on what it can do.


<ul><li>

KEDR operates on the binary interface used by a target module (ABI rather<br>
than API) like many other runtime analysis systems. This not bad per se<br>
but one of the consequences of this is that KEDR cannot detect, for example,<br>
a call to <code>kmalloc()</code> because it is usually a macro or an<br>
inline function rather than an ordinary function. Sometimes this can be<br>
inconvenient. KEDR, however, <b>can</b> detect the calls to<br>
<code>__kmalloc()</code>, <code>kmem_cache_alloc()</code> and other<br>
functions to which <code>kmalloc()</code> eventually expands.<br>
<br>
</li>
<li>

KEDR can only detect the calls directly made from the target kernel module. This<br>
is because it is only the target module that is instrumented by KEDR, the<br>
rest of the kernel is not affected.<br>
<br>
<br>
<br>
Suppose the target module calls function <code>create_foo()</code> exported<br>
by some other module or by the kernel proper. Let that function allocate memory for<br>
some structure with <code>kmalloc()</code>, initialize the structure and<br>
return a pointer to it. In this case, KEDR is unaware that a memory<br>
allocation has taken place. You need to tell KEDR explicitly to intercept<br>
the calls to <code>create_foo()</code> too to be able to track this.<br>
<br>
</li>
<li>

Currently, KEDR allows to analyze only one kernel module at a time.<br>
<br>
</li>
<li>

The tools built using KEDR framework can operate only on the calls made by the target module. Although it is enough in many cases, sometimes it is not. For example, a detector of data race conditions would require information not only about the calls to locking functions or the like but also about memory read and write operations which KEDR cannot track.<br>
<br>
</li>
</ul>
## Reporting Bugs and Asking Questions ##


If you have found a problem in KEDR or in this manual, please report it to [our bug tracker](http://code.google.com/p/kedr/issues/).



If you have questions about KEDR, feature requests, ideas on how to make KEDR better, or just anything else concerning KEDR to discuss, feel free to post to our mailing list: [kedr-discuss](http://groups.google.com/group/kedr-discuss). We appreciate your feedback.
