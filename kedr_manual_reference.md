

# KEDR Reference #

## API for Payload Modules ##


This section describes the interface that the KEDR core provides for the [payload modules](kedr_manual_glossary#Payload_module.md).


<blockquote><font><b><u>Important</u></b></font>

When interacting with the KEDR core, the payload modules should rely only on<br>
the API described here. Other types, functions, macros, constants, etc.,<br>
that can be found in the headers and the source files of KEDR system are for<br>
internal use only and subject to change.<br>
<br>
</blockquote>

### Header File ###


The API is declared in the header file that a payload module should #include:


```
#include <kedr/core/kedr.h>
```

### struct kedr\_function\_call\_info ###


Represents information about a particular function call which is passed to [pre handlers](kedr_manual_glossary#Pre_handler.md), [replacement function](kedr_manual_glossary#Replacement_function.md) and [post handlers](kedr_manual_glossary#Post_handler.md) in addition to the parameters of the target function.


```
struct kedr_function_call_info
{
    void *return_address; 
};
```


Currently this structure has only one field, `return_address`. This is the address of the location right after the call to target function (i.e. the address of the next machine instruction). This value should be used instead of builtin\_return\_address(0) in the [pre handlers](kedr_manual_glossary#Pre_handler.md), [replacement functions](kedr_manual_glossary#Replacement_function.md) and [post handlers](kedr_manual_glossary#Post_handler.md). This is because these functions are actually called by a trampoline function rather than directly from the place where the target is called. What is usually needed, however, is not the return address of a handler but rather the return address of the target function (to output call stack, etc.).


### struct kedr\_pre\_pair ###


Defines a [pre handler](kedr_manual_glossary#Pre_handler.md).


```
struct kedr_pre_pair
{
    void *orig; 
    void *pre; 
};
```


`orig` - address of the [target function](kedr_manual_glossary#Target_function.md) the calls to which are to be intercepted.



`pre` - address of the [pre handler](kedr_manual_glossary#Pre_handler.md) that should be called before the target function. Pre handler takes the same parameters as the target function plus an additional parameter of type `struct kedr_function_call_info *`. Pre handler does not return value.



Example:


```
/*
 * Function foo() has the following signature:
 *
 *  long foo(int a, void *p);
 */

void 
pre_foo(int a, void *p, struct kedr_function_call_info *call_info)
{
    /* ... */
};

struct kedr_pre_pair pre_foo_pair = {
    (void *)&foo,
    (void *)&pre_foo
};
```

### struct kedr\_post\_pair ###


Defines a [post handler](kedr_manual_glossary#Post_handler.md).


```
struct kedr_post_pair
{
    void *orig; 
    void *post; 
};
```


`orig` - address of the [target function](kedr_manual_glossary#Target_function.md) the calls to which are to be intercepted.



`post` - address of the [post handler](kedr_manual_glossary#Post_handler.md) which should be called after the target function. Post handler takes the same parameters as target function plus a parameter of the same type as the return value of the target function (if it is non-void) plus an additional parameter of type `struct kedr_function_call_info *`. Post handler does not return value.



Examples:


```
/*
 * Function foo() has the following signature:
 *
 *  long foo(int a, void *p);
 */

void 
post_foo(int a, void *p, long ret_val, 
    struct kedr_function_call_info *call_info)
{
    /* ... */
};

struct kedr_post_pair post_foo_pair = {
    (void *)&foo,
    (void *)&post_foo
};
```

```
/*
 * Function bar() has the following signature:
 *
 *  void bar(int a, void *p);
 */

void 
post_bar(int a, void *p, struct kedr_function_call_info *call_info)
{
    /* ... */
};

struct kedr_post_pair post_bar_pair = {
    (void *)&bar,
    (void *)&post_bar
};
```

### struct kedr\_replace\_pair ###


Defines a [replacement function](kedr_manual_glossary#Replacement_function.md).


```
struct kedr_replace_pair
{
    void *orig; 
    void *replace; 
};
```


`orig` - address of the [target function](kedr_manual_glossary#Target_function.md) the calls to which are to be intercepted.



`replace` - address of the [replacement function](kedr_manual_glossary#Replacement_function.md) which should be called **instead** of the target function. Replacement function takes the same parameters as the target function plus an additional parameter of type `struct kedr_function_call_info *`. Replacement function should return value of the same type as the target function.



Examples:


```
/*
 * Function foo() has the following signature:
 *
 *  long foo(int a, void *p);
 */

long 
replace_foo(int a, void *p, struct kedr_function_call_info *call_info)
{
    /* ... */
};

struct kedr_replace_pair replace_foo_pair = {
    (void *)&foo,
    (void *)&replace_foo
};
```

```
/*
 * Function bar() has the following signature:
 *
 *  void bar(int a, void *p);
 */

void 
replace_bar(int a, void *p, struct kedr_function_call_info *call_info)
{
    /* ... */
};

struct kedr_replace_pair replace_bar_pair = {
    (void *)&bar,
    (void *)&replace_bar
};
```

### struct kedr\_payload ###


Represents a payload module from the point of view of the KEDR core.


```
struct kedr_payload
{
    struct module *mod;
    struct kedr_replace_pair *replace_pairs;
    struct kedr_pre_pair *pre_pairs;
    struct kedr_post_pair *post_pairs;
    void (*target_load_callback)(struct module *);
    void (*target_unload_callback)(struct module *);
};
```


`mod` - the payload module itself. This field is usually
initialized with `THIS_MODULE` value.



`replace_pairs` - array of [replacement function definitions](kedr_manual_reference#struct_kedr_replace_pair.md). This array should be terminated by element with `orig` field set to NULL. NULL value of `replace_pairs` is equivalent to an empty array.



`pre_pairs` - array of [pre handler definitions](kedr_manual_reference#struct_kedr_pre_pair.md). This array should be terminated by element with `orig` field set to NULL. NULL value of `pre_pairs` is equivalent to an empty array.



`post_pairs` - array of [post handler definitions](kedr_manual_reference#struct_kedr_post_pair.md). This array should be terminated by element with `orig` field set to NULL. NULL value of `post_pairs` is equivalent to an empty array.



`target_load_callback` and `target_unload_callback`. If
not NULL, these callbacks are called by KEDR core after the target module is loaded (but
before it begins its initialization) and, respectively, when the target module
has done cleaning up and is about to unload. The callbacks are passed the
pointer to the target module as an argument. If a callback is NULL, it is
ignored.


<blockquote><font><b><u>Note</u></b></font>

Note that if the target module fails to initialize itself (and its init function returns an error as a result) and <code>target_unload_callback</code> is not NULL, this callback will be called nevertheless.<br>
<br>
</blockquote>


Each payload module has usually a single global instance of `struct kedr_payload` structure
and passes its address when registering and unregistering itself with the
KEDR core.



Example:


```
/* Pre handlers and the corresponding target functions */
static struct kedr_pre_pair pre_pairs[] = {
    { (void *)&_copy_to_user, (void *)&pre__copy_to_user},
    { (void *)&_copy_from_user, (void *)&post__copy_from_user},
    { NULL,}
};

/* Post handlers and the corresponding target functions */
static struct kedr_post_pair post_pairs[] = {
    { NULL, }
};


/* Replacement functions and the corresponding target functions */
static struct kedr_replace_pair replace_pairs[] = {
    { (void *)&capable, (void *)repl_capable},
    { NULL,}
};


static struct kedr_payload payload = {
    .mod                    = THIS_MODULE,
    .pre_pairs              = pre_pairs,
    .post_pairs             = post_pairs,
    .replace_pairs          = replace_pairs,
    .target_load_callback   = NULL,
    .target_unload_callback = NULL
};
```

### kedr\_payload\_register() ###

```
int 
kedr_payload_register(struct kedr_payload *payload);
```


This function registers a payload module with the KEDR core.



`payload` is the address of the `kedr_payload`
instance identifying the payload module (see ["struct kedr\_payload"](kedr_manual_reference#struct_kedr_payload.md)).



The function returns 0 if successful, an error code otherwise (the general
rules of the kernel functions apply here too).



The function is usually called in the init function of the payload module.


### kedr\_payload\_unregister() ###

```
void 
kedr_payload_unregister(struct kedr_payload *payload);
```


This function unregisters the payload module from the KEDR core. After
this is done, KEDR no longer uses this payload module (unless the latter
registers itself again).



`payload` should be the same address as it was in the corresponding
call to [kedr\_payload\_register()](kedr_manual_reference#kedr_payload_register().md).



The function is usually called in the cleanup (exit) function of the payload
module.


### kedr\_target\_module\_in\_init() ###

```
int
kedr_target_module_in_init(void);
```


This function returns nonzero if the target module is currently loaded and
is executing its init function at the moment, 0 otherwise.



In fact, the function just checks whether the target module has already
dropped its `".init.*"` sections (what the modules
do after they have completed their initialization). Therefore the function
will always return 0 if the init function was not marked as
`"__init"` in the
target module. This should not be a big problem though.



This function can be useful to implement particular fault simulation
scenarios (like "fail everything after init"), etc.



Note however that there is a chance that the target module will complete
its initialization after kedr\_target\_module\_in\_init() has determined that
the target is in init but before the return value of
kedr\_target\_module\_in\_init() is used. It is up to the user of the target
module to ensure that no request is made to the module until its
initialization is properly handled.



It is allowed to call this function from atomic context.


### functions\_support\_register() ###

```
int 
functions_support_register(void);
```


This function loads the trampoline functions for the target functions processed by the payload module. It should be called before the first call to `kedr_payload_register`.



This function is defined in auxiliary source file for the payload module rather than in KEDR core module itself. Because of this, it is needed to declare this function as `extern` in the source file where it is used:


```
extern int functions_support_register(void);
```


The function returns 0 if successful, an error code otherwise (the general
rules of the kernel functions apply here too).



The function is usually called in the init function of the payload module.


### functions\_support\_unregister() ###

```
void 
functions_support_unregister(void);
```


This function unloads trampolines which has loaded by `functions_support_register`. It should be called after the last call to `kedr_payload_unregister`.



This function is defined in auxiliary source file for the payload module rather than in KEDR core module itself. Because of this, it is needed to declare this function as `extern` in the source file where it is used:


```
extern void functions_support_unregister(void);
```


The function is usually called in the cleanup (exit) function of the payload module.


### A Stub of a Payload Module ###


Here is what a simple payload module may look like (this is a stub rather
than a real module, of course).


```
/* Module: stub_payload
 * 
 * Target kernel functions: 
 * 
 *   unsigned long kfoo(void *) 
 *   void *kbar(void *, unsigned int) 
 *   int kbaz(void)
 *
 * The replacement functions provided by this module have the same 
 * signatures as the respective target functions, but different names. */
/* ===================================================================== */

#include <linux/module.h>
#include <linux/init.h>

MODULE_AUTHOR("<Some name here>");
MODULE_LICENSE("<Some license here>");
/* ===================================================================== */

#include <kedr/base/common.h>
/* #include other necessary header files here */
/* ===================================================================== */

/* Handlers of the intercepted calls */
static void
post_kfoo(void *arg, unsigned long ret_val)
{
    /* Process the result of function, dump data to a trace, etc. */
    trace_function_call(arg, ret_val);
}

static void *
repl_kbar(void *arg, unsigned int n)
{
/* The replacement function is not required to call the target function at 
 * all. It is up to the provider of the replacement function.
 */
    if (n >= SOME_THRESHOLD) {
        return NULL; /* simulate a failure without actually calling kbar()*/
    } else {
        return kbar(arg, n);
    }
}

static int
repl_kbaz(void)
{
/* The replacement function is not required to do anything at all. */
    return 777;
}

/* ===================================================================== */

/* Replacement functions and the corresponding target functions */
static kedr_replace_pair replace_pairs[] = {
    { (void *)&kbar, (void *)&repl_kbar},
    { (void *)&kbaz, (void *)&repl_kbaz},
    {NULL,} /* the end "marker" element */
};

/* Post handlers and the corresponding target functions */
static kedr_post_pair post_pairs[] = {
    { (void *)&kfoo, (void *)&post_kfoo},
    {NULL,} /* the end "marker" element */
};

/* Pre handlers are not used by this payload */

/* Definition of struct kedr_payload */
static struct kedr_payload payload = {
    .mod                    = THIS_MODULE,
    .replace_pairs          = replace_pairs,
    .post_pairs             = post_pairs,
    .pre_pairs              = NULL,
    .target_load_callback   = NULL,
    .target_unload_callback = NULL
};
/* ===================================================================== */

/* Import the functions that load and unload trampolines */
extern int functions_support_register(void);
extern void functions_support_unregister(void);

static void
stub_payload_cleanup_module(void)
{
    kedr_payload_unregister(&payload);

    functions_support_unregister();

    /* do other cleanup work */
}

static int __init
stub_payload_init_module(void)
{
    int result;

    /* initialize other necessary facilities */

    result = functions_support_register();
    if(result) return result;
    
    result = kedr_payload_register(&payload);
    if(result)
    {
        functions_support_unregister();
        return result;
    }
    
    return 0;
}

module_init(kedr_cm_user_space_access_init_module);
module_exit(stub_payload_cleanup_module);
/* ===================================================================== */
```

## Creating Trampolines ##


This section describes how to create <i><a href='kedr_manual_glossary#Trampoline.md'>trampolines</a></i> for [target functions](kedr_manual_glossary#Target_function.md) intercepted by the payload modules.


### Why Trampolines Are Needed ###


The main purpose of [trampolines](kedr_manual_glossary#Trampoline.md) is to make it possible to use two or more payload modules simultaneously no matter whether some of the target functions they process are the same or not.



This allows to perform several kinds of operations on the target module at the same time. For example, while fault simulation is turned on, KEDR can also do call monitoring to obtain a trace of calls to the functions affected by fault simulation as well as any other calls of interest. In addition, KEDR can now perform memory leak detection and fault simulation simultaneously. You can also use the standard payload modules provided by KEDR in conjunction with almost any custom payload module (as long as no more than one of these modules defines a [replacement function](kedr_manual_glossary#Replacement_function.md) for a given target function; [pre handlers](kedr_manual_glossary#Pre_handler.md) and [post handlers](kedr_manual_glossary#Post_handler.md) are not limited in this way though). Note that a payload module may not even know that other payload modules are working at the same time.


### How to Define Trampolines ###


The source code of the trampolines is created automatically from the special data file by [kedr\_gen tool](kedr_manual_extend#Using_Code_Generator_to_Create_Custom_Modules.md). Such data file should be written for each payload module and should contain information about the target functions processed by this payload module.



Here we describe what information the data file should provide.



At the global scope, the data file may contain only a single parameter:

<ul><li><b>header</b>

the #include directives necessary to use the target functions of interest.</li>
</ul>



For each target function, a group should be prepared. Each group should contain definitions of the following parameters:

<ul><li><b>function.name</b>

name of the target function</li>
<li><b>returnType</b>

return type of the target function if it is not void, otherwise do not define this parameter at all</li>
<li><b>arg.type</b>

(multi-valued) types of the arguments of the target function, starting with the first one. If the function has no arguments, do not define this parameter at all.</li>
<li><b>arg.name</b>

(multi-valued) names of the arguments of the target function, starting with the first one. If the function has no arguments, do not define this parameter at all.</li>
</ul>






### A Stub of the Data File Describing the Targets ###


Here is an example of a data file describing the target functions `int foo(void *p)` and `void bar(int x, int y, const char *str)`. The source code of the trampolines can be generated for these functions from this file. It is assumed that `foo()` and `bar()` are defined in `<foo.h>` and `<bar.h>` headers, respectively.


```
header =>>
#include <foo.h>
#include <bar.h>
<<

[group]
    # Name and return type of the target function
    function.name = foo
    returnType = int

    # Names and types of the arguments of the target function
    arg.type = void *
    arg.name = p
    
# End of the group of definitions for foo().

[group]
    # Name and return type of the target function
    function.name = bar

    # Names and types of the arguments of the target function
    arg.type = int
    arg.name = x

    arg.type = int
    arg.name = y

    arg.type = const char *
    arg.name = str

# End of the group of definitions for bar().
```

### Generating the Source Code of the Trampolines ###


To generate the file with the source code of the trampolines from a data file, use the following command:

```
<kedr_install_dir>/lib/kedr/kedr_gen <kedr_install_dir>/share/kedr/templates/function_support.c \
    datafile > functions_support.c
```

A file named _functions\_support.c_ will be created as a result. This file can then be used when building the payload module.


## Standard Payloads for Call Monitoring ##


This section describes the payload modules for call monitoring (call tracing) provided by KEDR.


### List of Functions ###


Here is a full list of the payload modules that currently may be used for call monitoring, and the lists of the functions processed by each module. A function name in square brackets indicates that this function may or may not be exported on each particular system, and if it is exported, it will be processed. Only one of the functions separated by a slash is expected to be exported by the kernel, that function will be processed.




<ul><li><b>kedr_cm_cmm.ko:</b>
<ul><li><code>__kmalloc</code></li>
<li><code>krealloc</code></li>
<li><code>__krealloc</code></li>
<li><code>kfree</code></li>
<li><code>kzfree</code></li>
<li><code>kmem_cache_alloc</code></li>
<li><code>[kmem_cache_alloc_notrace]</code></li>
<li><code>[kmem_cache_alloc_trace]</code></li>
<li><code>kmem_cache_free</code></li>
<li><code>__get_free_pages</code></li>
<li><code>get_zeroed_page</code></li>
<li><code>free_pages</code></li>
<li><code>[__kmalloc_node]</code></li>
<li><code>[kmem_cache_alloc_node]</code></li>
<li><code>[kmem_cache_alloc_node_notrace]</code></li>
<li><code>[kmem_cache_alloc_node_trace]</code></li>
<li><code>[__alloc_pages_nodemask]</code></li>
<li><code>[alloc_pages_current]</code></li>
<li><code>[__free_pages]</code></li>
<li><code>[alloc_pages_exact]</code></li>
<li><code>[free_pages_exact]</code></li>
<li><code>[alloc_pages_exact_nid]</code></li>
<li><code>[kmalloc_order_trace]</code></li>
</ul></li>
<li><b>kedr_cm_uaccess.ko:</b>
<ul><li><code>copy_to_user/_copy_to_user</code></li>
<li><code>copy_from_user/_copy_from_user</code></li>
<li><code>strndup_user</code></li>
<li><code>memdup_user</code></li>
</ul></li>
<li><b>kedr_cm_mutexes.ko:</b>
<ul><li><code>__mutex_init</code></li>
<li><code>[mutex_lock]</code></li>
<li><code>[mutex_lock_interruptible]</code></li>
<li><code>[mutex_lock_killable]</code></li>
<li><code>mutex_trylock</code></li>
<li><code>mutex_unlock</code></li>
</ul></li>
<li><b>kedr_cm_spinlocks.ko:</b>
<ul><li><code>_spin_lock_irqsave/_raw_spin_lock_irqsave</code></li>
<li><code>_spin_unlock_irqrestore/_raw_spin_unlock_irqrestore</code></li>
<li><code>_spin_lock/_raw_spin_lock</code></li>
<li><code>_spin_lock_irq/_raw_spin_lock_irq</code></li>
<li><code>_spin_unlock/_raw_spin_unlock</code></li>
<li><code>_spin_unlock_irq/_raw_spin_unlock_irq</code></li>
</ul></li>
<li><b>kedr_cm_waitqueue.ko:</b>
<ul><li><code>__wake_up</code></li>
<li><code>init_waitqueue_head/__init_waitqueue_head</code></li>
<li><code>prepare_to_wait</code></li>
<li><code>finish_wait</code></li>
<li><code>remove_wait_queue</code></li>
<li><code>add_wait_queue</code></li>
<li><code>add_wait_queue_exclusive</code></li>
</ul></li>
<li><b>kedr_cm_capable.ko:</b>
<ul><li><code>capable</code></li>
</ul></li>
<li><b>kedr_cm_vmm.ko:</b>
<ul><li><code>vmalloc</code></li>
<li><code>__vmalloc</code></li>
<li><code>vmalloc_user</code></li>
<li><code>vmalloc_node</code></li>
<li><code>vmalloc_32</code></li>
<li><code>vmalloc_32_user</code></li>
<li><code>vfree</code></li>
<li><code>[vzalloc]</code></li>
<li><code>[vzalloc_node]</code></li>
</ul></li>
<li><b>kedr_cm_schedule.ko:</b>
<ul><li><code>schedule</code></li>
<li><code>[preempt_schedule]</code></li>
<li><code>_cond_resched</code></li>
<li><code>schedule_timeout</code></li>
<li><code>schedule_timeout_uninterruptible</code></li>
<li><code>schedule_timeout_interruptible</code></li>
<li><code>io_schedule</code></li>
<li><code>cond_resched_lock/__cond_resched_lock</code></li>
</ul></li>
<li><b>kedr_cm_mem_util.ko:</b>
<ul><li><code>kstrdup</code></li>
<li><code>kstrndup</code></li>
<li><code>kmemdup</code></li>
<li><code>[call_rcu]</code></li>
<li><code>[call_rcu_sched]</code></li>
<li><code>[kfree_call_rcu]</code></li>
<li><code>[add_to_page_cache_lru]</code></li>
<li><code>[add_to_page_cache_locked]</code></li>
<li><code>[posix_acl_alloc]</code></li>
<li><code>[posix_acl_clone]</code></li>
<li><code>[posix_acl_from_mode]</code></li>
<li><code>[match_strdup]</code></li>
</ul></li>
</ul>


<blockquote><font><b><u>Note</u></b></font>

Note that <code>*call_rcu*</code> functions are currently processed only if the system provides <code>kfree_rcu</code>. This is because it can be necessary to track this way to free the target module's data too.<br>
<br>
</blockquote>

## Standard Fault Simulation Payloads ##

### List of Functions ###


Here is a full list of the payload modules that currently can be used for fault simulation, and the lists of the functions for which fault simulation is implemented by each module. For each function, the parameters that can be used in a fault simulation scenario are described.



A function name in square brackets indicates that this function may or may not be exported on each particular system, and if it is exported, it will be processed. Only one of the functions separated by a slash is expected to be exported by the kernel, that function will be processed.



Unless the opposite is stated explicitly, the name of the fault simulation point is the same as the name of the target function this point is used for.


<ul><li><b>kedr_fsim_capable.ko</b>
<ul><li><code>capable</code></li>
</ul>
Fault simulation point for this function provides <code>cap</code> parameter of type <code>int</code> for a fault simulation scenario.<br>
</li>
<li><b>kedr_fsim_uaccess.ko</b>
<ul><li><code>copy_to_user</code>/<code>_copy_to_user</code>; no matter which of these functions is exported by the kernel, the name of the fault simulation point is <code>copy_to_user</code></li>
<li><code>copy_from_user</code>/<code>_copy_from_user</code>; no matter which of these functions is exported by the kernel, the name of the fault simulation point is <code>copy_from_user</code></li>
<li><code>strndup_user</code></li>
<li><code>memdup_user</code></li>
</ul>
Fault simulation points for these functions do not provide additional parameters for a fault simulation scenario.<br>
</li>
<li><b>kedr_fsim_cmm.ko</b>
<ul><li><code>__kmalloc</code></li>
<li><code>krealloc</code></li>
<li><code>__krealloc</code></li>
<li><code>kmem_cache_alloc</code></li>
<li><code>[kmem_cache_alloc_notrace]</code></li>
<li><code>[kmem_cache_alloc_trace]</code></li>
<li><code>__get_free_pages</code></li>
<li><code>get_zeroed_page</code></li>
<li><code>[__kmalloc_node]</code></li>
<li><code>[kmem_cache_alloc_node]</code></li>
<li><code>[kmem_cache_alloc_node_notrace]</code></li>
<li><code>[kmem_cache_alloc_node_trace]</code></li>
<li><code>[__alloc_pages_nodemask]</code></li>
<li><code>[alloc_pages_current]</code></li>
<li><code>[alloc_pages_exact]</code></li>
<li><code>[alloc_pages_exact_nid]</code></li>
<li><code>[kmalloc_order_trace]</code></li>
</ul>
All these functions use a shared fault simulation point named <code>kmalloc</code> that provides the following parameters for a fault simulation scenario: <code>size</code> (of type <code>size_t</code>) and <code>flags</code> (of type <code>gfp_t</code>).<br>
</li>
<li><b>kedr_fsim_mem_util.ko</b>
<ul><li><code>kstrdup</code></li>
<li><code>kstrndup</code></li>
<li><code>kmemdup</code></li>
<li><code>[posix_acl_alloc]</code></li>
<li><code>[posix_acl_clone]</code></li>
<li><code>[posix_acl_from_mode]</code></li>
<li><code>[match_strdup]</code></li>
</ul>
Fault simulation points for these functions do not provide additional parameters for a fault simulation scenario except for <code>posix_acl_*</code> functions similar to <code>__kmalloc</code> in this respect.<br>
</li>
<li><b>kedr_fsim_vmm.ko</b>
<ul><li><code>vmalloc</code></li>
<li><code>__vmalloc</code></li>
<li><code>vmalloc_user</code></li>
<li><code>vmalloc_node</code></li>
<li><code>vmalloc_32</code></li>
<li><code>vmalloc_32_user</code></li>
<li><code>[vzalloc]</code></li>
<li><code>[vzalloc_node]</code></li>
</ul>
All these functions use a shared fault simulation point named <code>vmalloc</code> that provides no additional parameters for a fault simulation scenario.<br>
</li>
</ul>
## Standard Fault Simulation Scenarios ##

### Common Fault Simulation Scenario ###


A scenario named "common" may be set for any fault simulation point. Features of this scenario are described in ["Fault Simulation"](kedr_manual_using_kedr#Fault_Simulation.md) in detail. The scenario is implemented by the module `kedr_fsim_indicator_common.ko`.


### Fault Simulation Scenario for Memory Allocation Functions ###


A scenario named "kmalloc" is intended to be used for the functions that allocate kernel memory. It accepts two parameters: `size_t` `size` and `gfp_t` `flags`. One can view them as the size of a memory block requested for allocation and the allocation flags, but the scenario itself does not make any assumptions about the meaning of these parameters.



This scenario derives its functionality from "common" scenario described above and has also the following features:

<ul><li>
variables <code>size</code> and <code>flags</code> can be used in the expression; they refer to the corresponding parameters of the scenario.<br>
<blockquote></li>
<li>
several constants corresponding to the allocation flags can be used in the expression: <code>GFP_NOWAIT</code>, <code>GFP_KERNEL</code>, <code>GFP_USER</code>, <code>GFP_ATOMIC</code>. The values of this constants are the same as the values of the corresponding macros in the kernel code.<br>
</li>
</ul></blockquote>



This scenario is implemented by the module `kedr_fsim_indicator_kmalloc.ko`.


### Fault Simulation Scenario for capable() ###


A scenario named "capable" is intended to be used for `capable()` function. It accepts one parameter: `int` `cap`. One can view it is a parameter of `capable()` function, but the scenario itself does not make any assumptions about the meaning of this parameter.



This scenario derives functionality from "common" scenario described above and has also the following features:

<ul><li>
variable <code>cap</code> can be used in the expression; it refers to the corresponding parameter of the scenario.<br>
<blockquote></li>
<li>
several constants defining the particilar capabilities such as <code>CAP_SYS_ADMIN</code> can be used in the expression. The values of these constants are the same as the values of the corresponding macros in the kernel code.<br>
</li>
</ul></blockquote>



This scenario is implemented by the module `kedr_fsim_indicator_capable.ko`.


## API for Fault Simulation ##


This section describes the interface provided for creating and using [fault simulation points](kedr_manual_glossary#Fault_simulation_point.md) as the code branching points and [fault simulation indicators](kedr_manual_glossary#Fault_simulation_indicator.md) as the scenarios for such branching.


<blockquote><font><b><u>Note</u></b></font>

Although this API is used by KEDR in the payload modules for fault simulation, the API can be used without KEDR core and payloads.<br>
<br>
</blockquote>

### Kernel module providing API ###


API described in that section is provided by the kernel module `kedr_fault_simulation.ko`, placed in ``/usr/local/lib/modules/`uname -r`/misc`` directory.


### Header file ###


The API is declared in a header file that a module implementing fault simulation points or indicators should #include:


```
#include <kedr/fault_simulation/fault_simulation.h>
```

### Fault Simulation Point ###


A registered [fault simulation point](kedr_manual_glossary#Fault_simulation_point.md) is represented by `struct kedr_simulation_point`.


```
struct kedr_simulation_point;
```


Each fault simulation point has a unique name. For each point, there is a subdirectory in `kedr_fault_simulation/points` in debugfs filesystem. The name of this subdirectory is the same as the name of the point itself. The files in that subdirectory can be used to control the scenarios for this point.



When it is needed to decide which branch of code should be executed, one should call `kedr_fsim_point_simulate()`. This function will return an integer value according to the scenario set for this point, this value can then be used for branching.


### Format of the Data Passed from a Point to the Scenario ###


When call `kedr_fsim_point_simulate`, one should also pass the parameters for the fault simulation scenario. The format is expected to be a struct containing fields of possibly different types. It can be encoded in a string with a comma-separated ordered list of these types. E.g. a string `"int*,long"` encodes the parameters of the corresponding types:

```
struct 
{
    int *val1;
    long val2;
};
```

The absence of parameters for scenario is encoded by an empty string ("").


### kedr\_fsim\_point\_register() ###


Registers the fault simulation point, making it available for code branching in the target module and for managing its scenarios from the kernel space and the user space.


```
struct kedr_simulation_point *
kedr_fsim_point_register(const char *point_name,
	const char *format_string);
```


`point_name` - name of the fault simulation point.



`format_string` - a string that encodes the parameters passed to a scenario for that point. `NULL` is effectively the same as an empty string. It means that no parameters are passed to the scenarios. It is the caller of `kedr_fsim_point_simulate`, who is responsible for passing parameters in the correct format.



Returns the descriptor of the registered fault simulation point. On error, returns `NULL`.


### kedr\_fsim\_point\_unregister() ###


Unregisters the fault simulation point, making its name free for use.


```
void kedr_fsim_point_unregister(struct kedr_simulation_point *point);
```


`point` - the registered fault simulation point.


### kedr\_fsim\_point\_simulate() ###


Gets the value according to the scenario set for the point (nonzero - simulate a failure, 0 - do not).


```
int kedr_fsim_point_simulate(struct kedr_simulation_point *point,
    void *user_data);
```


`point` - registered fault simulation point.



`user_data` - parameters for the scenario. The format of these parameters should match `format_string` used when the point was registered.



Returns an integer value according to the scenario set for that point. If no scenario is set, returns `0`.



If function returns non-zero, `kedr_fsim_fault_message` function should be called for set message describing fault is simulated. Description of last fault simulated may be read from file `<debugfs-mount-point>/kedr_fault_simulation/last_fault`.


### Fault Simulation Indicator ###


A registered [fault simulation indicator](kedr_manual_glossary#Fault_simulation_indicator.md) is represented by `struct kedr_simulation_indicator`.


```
struct kedr_simulation_indicator;
```


Each fault simulation indicator has unique name.  For each indicator, there is a subdirectory in `kedr_fault_simulation/indicators` in debugfs filesystem. The name of this subdirectory is the same as the name of the indicator itself. The files in that subdirectory can be used to control the indicator.



Actually, each fault simulation indicator is a generator of the scenarios. When one sets a scenario for a particular fault simulation point (via `kedr_fsim_point_set_indicator` function or by writing to the `current_indicator` file), the corresponding indicator is used to "instantiate" a scenario set for that point. After that moment, the scenario becomes independent on the other scenarios that might be set using this indicator.



To make it clearer, let us consider a simple scenario <i>"simulate failure every second call"</i>. When this scenario is set for a particular point, one would expect that `kedr_fsim_point_simulate` will return nonzero when called the second time, the forth time and so on. Imagine then, that after the third call to `kedr_fsim_point_simulate`, this scenario is additionally set for another point. So, the first call to `kedr_fsim_point_simulate` for the second point would return nonzero if the scenario is shared by the two points, which is usually not what is desirable.



Now, instead of setting the scenario for the points directly, we will use the fault simulation indicator. For the first point, this indicator will create scenario <i>"simulate failure every second call"</i>. When applied to another point, the indicator will create **another** scenario, with its own local call counter. So according to this scenario, `kedr_fsim_point_simulate` will return nonzero when called the second time, the forth time and so on **independently** on the first point and its scenario.



Another feature of the fault simulation indicators is that one indicator may create different scenarios according to some parameters. These parameters are passed to the scenario generator function of the indicator, when the indicator is applied to the point. E.g., an indicator may generate scenarios like <i>"simulate failure every <code>n</code>th call"</i>, where `n` is a parameter of the generator function.


### kedr\_fsim\_indicator\_register() ###


Registers the fault simulation indicator, making it available for generating scenarios for the fault simulation points.


```
struct kedr_simulation_indicator *
kedr_fsim_indicator_register(const char *indicator_name,
	int (*simulate)(void *indicator_state, void *user_data),
    const char *format_string,
    int (*create_instance)(void **indicator_state, const char *params, struct dentry *control_directory),
    void (*destroy_instance)(void *indicator_state)
);
```


`indicator_name` - name of the indicator.



`simulate` - callback function that implements the scenario of the indicator.
`indicator_state` parameter of this function is set to the object created by `create_instance` callback. `user_data` - the data from the fault simulation point passed to scenario. The function should return integer value corresponding to this scenario.



`format_string` - string containing the encoded format of the data that will be provided by the fault simulation point to the scenario (see ["Format of the Data Passed from a Point to the Scenario"](kedr_manual_reference#Format_of_the_Data_Passed_from_a_Point_to_the_Scenario.md)). `NULL` is effectively the same as an empty string and means that the scenario expects no parameters. The more parameters scenario uses, the more complex the scenario can become but the fewer points will be able to use this scenario.



`create_instance` - callback function to generate a new scenario. This function may set `indicator_state` pointer and this pointer will be passed to `simulate` and `destroy_instance` callbacks. If not set, this pointer is expected to be `NULL`. `params` is a null-terminated string containing the parameters of the created scenario, or `NULL`. The function may interpret this parameter in an arbitrary way. `control_directory` is a directory of the fault simulation point (in debugfs filesystem) for which the scenario is created. The function may create some files in this directory as the means to control the scenario. Note that this directory already contains files `current_indicator` and `format_string`. The function should return 0 if the scenario has been created successfully or a negative error code in case of error.



`destroy_instance` - callback function for destroying the scenario, created by `create_instance`. `indicator_state` parameter is the same as the one set by `create_instance`.



The function returns an identifier of the newly created fault simulation indicator or `NULL` in case of error.


### kedr\_fsim\_indicator\_unregister() ###


Unregisters the indicator, making its name free for use. Also deletes all existing scenarios created with this indicator.


```
void kedr_fsim_indicator_unregister(struct kedr_simulation_indicator *indicator);
```


`indicator` - identifier of the fault simulation indicator, created previously via `kedr_fsim_indicator_register`.


### kedr\_fsim\_point\_set\_indicator() ###


Creates a new scenario using the given fault simulation indicator and set this scenario for the given fault simulation point.


```
int kedr_fsim_point_set_indicator(const char *point_name,
    const char *indicator_name, const char *params);
```


`point_name` - name of the point the scenario is created for.



`indicator_name` - name of the indicator used to create the scenario.



`params` - parameters of the new scenario (will be passed to the indicator's `create_instance` function).



The function returns 0 if the new scenario has been created and set successfully. On error, negative error code is returned.



The function returns error if the fault simulation point does not provide all parameters needed for the scenario or provides them in incorrect order. To put it simple, the function returns error if `format_string` of the indicator is not a substring of the `format_string` of the point.



If another scenario has been set for the point before this function is called, that scenario will be removed and destroyed before the new scenario is created (so, there is no collision for the files in point's control directory).


### kedr\_fsim\_point\_clear\_indicator() ###


Removes (unsets) and destroys the scenario set for the fault simulation point. If no scenario is set for the point, does nothing.


```
int kedr_fsim_point_clear_indicator(const char *point_name);
```


`point_name` - name of the fault simulation point for which a scenario should be cleared.



The function returns `0` on success and negative error code on failure.



This function is called indirectly when a fault simulation point is unregistered or when the fault simulation indicator that created this scenario is unregistered.


### kedr\_fsim\_fault\_message() ###


Write message described fault simulated. Should be called after `kedr_fsim_point_simulate` return non-zero.


```
int kedr_fsim_fault_message(const char *fmt);
```


Message is writed in the snprintf-like format. Function returns 1 if message was truncated while written, 0 otherwise.



Message describing last fault simulated may be read from `<debugfs-mount-point>/kedr_fault_simulation/last_fault` file.


### KEDR\_FSIM\_FAULT\_MESSAGE\_LEN ###


Length of fault message which is garanteed to be written without truncation. See also function `kedr_fsim_fault_message`.


```
#define KEDR_FSIM_FAULT_MESSAGE_LEN 100
```

### Control File `format_string` ###


For each registered point, there is a file in the point's control directory that reflects the format of the data this point passes to the scenario.



`<debugfs-mount-point>/kedr_fault_simulation/<point-name>/format_string`



Reading from this file returns a string containing the encoded format of the data this point passes to the scenario.


### Control File `current_indicator` ###


For each registered point, there is a file in the point's control directory that reflects information about the current scenario for the point and allows to set another scenario.



`<debugfs-mount-point>/kedr_fault_simulation/<point-name>/current_indicator`



Reading from this file returns the name of the scenario currently set for the point (more precisely, the name of the indicator used to create this scenario). If no scenario is set for the point, `none` is returned.



Writing to this file sets a new scenario for the point. Everything before the first space in the written sequence is treated as a name of the indicator, which is used for create a new scenario. Everything after the first space is treated as a parameter string for the new scenario. If there are no spaces in the written sequence, the whole sequence is treated as name of the indicator, and no parameters are passed for the new scenario. Writing a special name `none` forces clearing the scenario.




```
.../points# echo indicator1 param1 param2 > point1/current_indicator
```

is effectively the same as

```
kedr_fsim_point_set_indicator("point1", "indicator1", "param1 param2");
```





```
.../points# echo indicator2 > point2/current_indicator
```

is effectively the same as

```
kedr_fsim_point_set_indicator("point2", "indicator2", NULL);
```





```
.../points# echo none > point3/current_indicator
```

is effectively the same as

```
kedr_fsim_point_clear_indicator("point3");
```



### Control File `last_fault` ###


Contains the information about the last simulated fault.



`<debugfs-mount-point>/kedr_fault_simulation/last_fault`



Reading from this file returns a string that was written by the last `kedr_fsim_fault_message` call or `none` if no calls to `kedr_fsim_fault_message` had been made since `kedr_fault_simulation` module was loaded.
