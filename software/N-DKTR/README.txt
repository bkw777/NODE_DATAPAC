2024 Brian K. White

Two notes about N-DKTR

1 - Warning: Do not run N-DKTR at all if the NODE has arbitrary raw data that isn't
a filesystem made by RAMDSK or the NODE ROM.

It appears to overwrite the first 2 bytes of bank 0 block 0 
with the filesystem formatted flag bytes, immediately on startup,
without asking if it's ok or doing any other kind of sanity check,
without the user invoking any functions or responding to any prompts.

This is fine if the device is supposed to have a filesystem,
but if the device is supposed to have arbitrary raw data,
then the first two bytes of data are destroyed.

Since it happens immediately on startup without asking or giving any chance to prevent it,
the only way to avoid losing data is don't run N-DKTR at all in the first place.

(Or modify N-DKTR to improve that behavior, which should be simple.)

2 - Does not support bank1 or >256k.

It looks like it probably could be added fairly easily.

The interactions with the device appear to all be in plain BASIC
so it should be easy to modify all the OUT129 to OUTX and add code to
select X=129 or X=133.
