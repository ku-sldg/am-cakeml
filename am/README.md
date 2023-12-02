# Platform specific attestation managers #

## Contents ##

- [`CommTypes.sml`](CommTypes.sml)&mdash;types for requests and responses as
  well as conversion functions to and from JSON format.

Top Level File: CoplandCommUtil.sml
This file requires these functions to be implemented:
    - socketDispatch target-id ...
    - socketDispatchApp target-id ...

Those functions are implemented differently per platform:
    - For the Posix environment, see SocketCommUtil.sml
    - For the seL4 environment, see seL4CommUtil.sml
