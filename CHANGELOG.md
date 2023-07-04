### v1.1.0

#### Minor
 - update version of net-ssh to 7.1.0 due to update of openssh version to >3.0.0

### v1.0.2

#### Minor
 - Custom error class added. Will be used to output more detailed error messages on SSH errors.
 - SSH key authentication fixed. It is now possible to use SSH keys within the SSH module call directly, instead of preconfigure them in the environment file.


### v1.0.1

#### Minor
 - Internal gem dependencies fixed


### v1.0.0

#### Major
 - `spectre/ssh` was extracted from `spectre-core` into this package

#### Minor
 - Unit tests added