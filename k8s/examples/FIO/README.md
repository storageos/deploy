# Benchmark StorageOS with FIO

These FIO tests are presented to give guidance when testing synthetic
benchmarks on StorageOS. FIO results vary according to test profiles, the test
environment and are not necessarily deterministic.

The following FIO options are used to create different test profiles.

## Tests parameters

Options available are listed here [FIO man page](https://linux.die.net/man/1/fio).

The profiles for testing use the following options to tune FIO.
- Size

   Total size of I/O for this job. FIO will run until this many bytes have been
   transferred, unless limited by other options (runtime, for instance).
   
- Runtime + timebased

   Number of seconds that the tests run. If files are completely read or
   written, the same workload will be repeated as many times as runtime seconds
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
    
    FIO supports different engines for generating IO offsets for random IO.
    We are using tausworthe: Strong 2^88 cycle random number generator.
    
- Distribution
    
    By default, FIO will use a completely uniform random distribution when
    asked to perform random IO. Sometimes it is useful to skew the distribution
    in specific ways, ensuring that some parts of the data are more hot than
    others. FIO includes the following distribution models: random, zipf, pareto,
    normal, zoned, and zoned_abs
    
- R/W Pattern
    
    Type of I/O pattern. Set to random reads and writes, in a $RANDOM
    distribution, to enforce that some parts of the data is not hotter than
    others.
    
- R/W Distribution
    
    - Percentage of a mixed workload that should be reads
    - Percentage of a mixed workload that should be writes

- Log avg msec

    Set to 250ms. FIO will log an entry in the iops, latency, or bw log for every IO
    that completes. When writing to the disk log, this can quickly grow to a very
    large size. Setting this option makes FIO average the each log entry over the
    specified period of time

- Group Reporting
    
    Display per-group reports instead of per-job when numjobs is specified.


## Trigger and Generate tests

Follow the README for the following set of tests:

- [Local volumes](./local-volumes)
- [Remote and local volumes randomly distributed](./remote-local-volumes)
