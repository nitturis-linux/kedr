# Problems in Kernel Modules Found by KEDR #

The examples of real problems in the Linux kernel modules found with the help of KEDR-based tools are shown below.

| **Component** | **Problem Summary** | **Reported to** | **Status** |
|:--------------|:--------------------|:----------------|:-----------|
| [Linux kernel](http://kernel.org/), Ext4 FS module | NPD when using sb->s\_fs\_info during clean-up after a failed mount | Kernel Bug Tracker, [bug #26752](https://bugzilla.kernel.org/show_bug.cgi?id=26752) | confirmed, fixed in the kernel version 2.6.39-rc1 |
| [Linux kernel](http://kernel.org/), Ext4 FS module | Calling kfree() for uninitialized pointer in ext4\_mb\_init\_backend() | Kernel Bug Tracker, [bug #30872](https://bugzilla.kernel.org/show_bug.cgi?id=30872) | confirmed, fixed in the kernel version 2.6.39-rc1 |
| [VirtualBox](http://www.virtualbox.org/), Guest Additions | Memory leak in sf\_lookup | VirtualBox bug tracker, [ticket #7705](http://www.virtualbox.org/ticket/7705) | confirmed, fixed in VirtualBox 3.2.12 |
| [VirtualBox](http://www.virtualbox.org/), Guest Additions  | g\_vbgldata.mutexHGCMHandle is never destroyed | VirtualBox bug tracker, [ticket #7720](http://www.virtualbox.org/ticket/7720) | confirmed, fixed in VirtualBox 3.2.12 |
| [VirtualBox](http://www.virtualbox.org/), Guest Additions | Possible memory leak in sf\_follow\_link | VirtualBox bug tracker, [ticket #8185](http://www.virtualbox.org/ticket/8185) | confirmed, fixed in VirtualBox 4.0.4 |
| [Linux kernel](http://kernel.org/), FAT FS module | Memory allocation failure is not handled in fat\_cache\_add() | Kernel Bug Tracker, [bug #24622](https://bugzilla.kernel.org/show_bug.cgi?id=24622) | confirmed, fixed in the kernel version 3.0 |
| [Linux kernel](http://kernel.org/), ath5k module (wireless networking) | Memory kcalloc'ed in ath5k\_eeprom\_convert\_pcal\_info`_``*`() is not always kfree'd | Kernel Bug Tracker, [bug #32722](https://bugzilla.kernel.org/show_bug.cgi?id=32722) | confirmed, fixed in the kernel version 3.0 |
| [Linux kernel](http://kernel.org/), ath5k module (wireless networking) | (ath5k) Not all elements of chinfo`[`pier`]`.pd\_curves`[``]` are freed | Kernel Bug Tracker, [bug #32942](https://bugzilla.kernel.org/show_bug.cgi?id=32942) | confirmed, fixed in the kernel version 3.0 |
| [Linux kernel](http://kernel.org/), ath5k module (wireless networking) | (ath5k) sc->ah is allocated in ath5k\_init\_softc() but is not freed | Kernel Bug Tracker, [bug #37592](https://bugzilla.kernel.org/show_bug.cgi?id=37592) | confirmed, fixed in the kernel version 3.1-rc1 |
| [Linux kernel](http://kernel.org/), Btrfs module | Possible memory leak in btrfs kernel module during xfstests test 002 | Kernel Bug Tracker, [bug #47101](https://bugzilla.kernel.org/show_bug.cgi?id=47101) | not confirmed yet |
| [Linux kernel](http://kernel.org/), Ext4 FS module | ext4\_fill\_super() reports success even if ext4\_mb\_init() fails | ext4 mailing list: [thread](http://thread.gmane.org/gmane.comp.file-systems.ext4/34743) | confirmed |
| [Linux kernel](http://kernel.org/), XFS module | 'xfs\_uuid\_table' allocated in xfs\_uuid\_mount() is never freed | Kernel Bug Tracker, [bug #48651](https://bugzilla.kernel.org/show_bug.cgi?id=48651) | not confirmed yet |