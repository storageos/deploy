# Benchmark StorageOS with FIO

This FIO tests aim to give you guidance when testing StorageOS based on
synthetic benchmarks. FIO results differ according to the test profiles,
environment where it runs or by entropy itself.

The following FIO options are used to create different test profiles.

## Tests parameters

Options available in [FIO man page](https://linux.die.net/man/1/fio).

The profiles for testing use the following options to tune FIO.
- Size

   Total size of I/O for this job. fio will run until this many bytes have been
   transferred, unless limited by other options (runtime, for instance).
   
- Runtime + timebased

   Number of seconds that the tests run. If the files are completely read or
   written. The same workload will be repeated as many times as runtime
   allows.
   
- IOEngine

    Defines how the job issues I/O. For this profile we use `libaio` for Linux
    native asynchronous I/O.
    
- Direct IO

    Non-buffered I/O (usually O_DIRECT). For this profile we ensure that the
    I/O doesn't report operations based on OS caches.
    
- IODepth

    Number of I/O units to keep in flight against the file.
    
- BlockSize (bs)

    Block size for I/O units.
    
- Generator
    
    Fio supports the different engines for generating IO offsets for random IO.
    We are using tausworthe: Strong 2^88 cycle random number generator.
    
- Distribution
    
    By default, fio will use a completely uniform random distribution when
    asked to perform random IO. Sometimes it is useful to skew the distribution
    in specific ways, ensuring that some parts of the data is more hot than
    others. Fio includes the following distribution models: random Uniform
    random distribution.
    
- R/W frequency 
    
    Mixed I/O, random reads and writes, in a $RANDOM distribution, ensuring a
    random distribution to enforce that some parts of the data is not hotter
    than others.
    
- R/W distribution 
    
    - Percentage of a mixed workload that should be reads
    - Percentage of a mixed workload that should be writes

- Log avg msec

    Set to 250ms. FIO will log an entry in the iops, latency, or bw log for every IO
    that completes. When writing to the disk log, that can quickly grow to a very
    large size. Setting this option makes fio average the each log entry over the
    specified period of time

- Group Reporting
    
    Display per-group reports instead of per-job when numjobs is specified.


## Trigger and Generate tests

Follow the README for the following set of tests:

- [Local volumes](./local-volumes)
- [Remote and local volumes randomly distributed](./remote-local-volumes)
