# async-mvar

async_mvar provides a single module - `Async_mvar`. This module is analagous is
a port of Lwt's `Lwt_mvar`. The main difference is that `Async_mvar` doesn't
support cancelling puts. This is because async's deferred do not support native
cancelling like Lwt's threads.
