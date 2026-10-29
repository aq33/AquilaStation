# Patched auxmos.dll

`auxmos.dll` in the repo root is [covertcorvid/auxmos](https://github.com/covertcorvid/auxmos) `v2.5.2-b` with the reboot patches (`auxmos-2.5.2-b.patch`, `byondapi-0.4.7.patch`). `libauxmos.so` gets only the crash patches (see "Linux build" below). The reboot patch also pins the library on Linux (`RTLD_NODELETE`), so if `libauxmos.so` is ever rebuilt with it, remove the `system_type == MS_WINDOWS` check in `aquila/code/game/world.dm` at the same time. Otherwise the next world keeps stale string and gas ids.

## Why

When a world reboots or is stopped, BYOND unloads every `call_ext` library, but the DreamDaemon process keeps running. auxmos leaves its rayon worker threads parked inside its own code. When one of them wakes up, it jumps into unmapped memory and DreamDaemon crashes with `0xC0000005` in `auxmos.dll_unloaded`. The Windows Event Log shows this crash, usually a minute or two into the next round.

## What the patch does

- `src/lifecycle.rs`: the library pins itself on first use (`GetModuleHandleExW(PIN)`), so it stays loaded, along with its threads, until DreamDaemon exits. It also exports `/proc/__auxmos_reset`, which a world calls as it ends (`/world/Reboot()`, `/world/Del()`) to throw away its gas mixtures, turfs, gases, reactions, callbacks and caches. The next world then starts with a clean library. Resetting at the start of the next world is too late, because gas mixtures already exist during global init.
- `byondapi-0.4.7.patch`: `byond_string!` cached string ids forever. The patched cache is invalidated by the reset, because a new world (especially after a recompile) can give the same string a different id.

## Rebuilding

You need rustup (toolchain `1.80.0` with target `i686-pc-windows-msvc`), the Visual Studio C++ Build Tools and LLVM (`LIBCLANG_PATH`).

```bash
git clone --branch v2.5.2-b https://github.com/covertcorvid/auxmos && cd auxmos
cp -r ~/.cargo/registry/src/*/byondapi-0.4.7 vendor/byondapi   # after one `cargo fetch`
git apply ../tools/auxmos/auxmos-2.5.2-b.patch
git -C vendor/byondapi apply ../../../tools/auxmos/byondapi-0.4.7.patch
# Short CARGO_TARGET_DIR: deep paths break the MSVC linker (260 character limit).
CARGO_TARGET_DIR=C:/auxmos-target LIBCLANG_PATH="C:/Program Files/LLVM/bin" \
  cargo +1.80.0 rustc --target=i686-pc-windows-msvc --release --features "katmos citadel_reactions" -- -C target-cpu=native
```

Copy `C:/auxmos-target/i686-pc-windows-msvc/release/auxmos.dll` to the repo root. If you add or rename hooks, regenerate the bindings with `cargo t --target=i686-pc-windows-msvc --features "katmos citadel_reactions" generate_binds` and update `code/__DEFINES/bindings.dm`.

## Linux build

On BYOND 516 (Linux) `Byond_LastError()` crashes libbyond with "BUG: Crashing due to an illegal operation!". byondapi calls it whenever a read fails, and auxmos reads `air` from turfs in its queued callbacks (`update_visuals()` and gas reactions in `src/turfs/processing.rs`). A turf with visible gas that became a wall between the queueing and the callback has no `air` var, so DreamDaemon died in `/proc/process_atmos_callbacks` (round 6534: build mode walls in the plasma left by a fire).

- `byondapi-0.4.7-lasterror.patch`: `Error::get_last_byond_error()` returns `UnknownByondError` without calling `Byond_LastError()`, so a failed read is a normal error again.
- `auxmos-2.5.2-b-stale-turf.patch`: both callbacks first check that the turf is still in the turf map (`update_air_ref(-1)` removes walls), so they do not read `air` from a wall at all.

`build_linux.sh` builds `libauxmos.so` on the server with these two patches and the features of the upstream Linux release (`katmos`), and copies it to the repo root. Run it from the repo:

```bash
sudo apt install git curl build-essential g++-multilib libclang-dev
./tools/auxmos/build_linux.sh
```

Both patches also apply on top of the reboot patches, so `auxmos.dll` can get them the next time it is rebuilt. CI keeps testing the upstream `libauxmos.so` (`tools/ci/install_auxmos.sh`).
