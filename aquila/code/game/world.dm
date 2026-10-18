/// Our auxmos.dll (see tools/auxmos/README.md) pins itself, so a reboot or a stopped world can no longer unload it
/// from under its own worker threads (that crashed DreamDaemon). The library now outlives the world: this drops
/// everything the world put in it, so the next world in the same process starts as clean as a fresh load.
/// Called from /world/Reboot() and /world/Del(); nothing may touch atmos afterwards.
/// The Linux build (libauxmos.so) is upstream's: it has no reset proc, and calling it there would runtime and abort the reboot.
/// If libauxmos.so is ever rebuilt with our patch (which pins it on Linux too), drop the Windows check, or the next world gets stale ids.
/// Logging is already shut down here, so breadcrumbs go straight to this file. A "start" without a "done" means the reset hung.
#define AUXMOS_RESET_LOG "data/logs/auxmos_reset.log"

/world/proc/auxmos_cleanup()
	if(system_type == MS_WINDOWS)
		rustg_file_append("[time_stamp("YYYY-MM-DD hh:mm:ss")] auxmos reset start\n", AUXMOS_RESET_LOG)
		__auxmos_reset()
		rustg_file_append("[time_stamp("YYYY-MM-DD hh:mm:ss")] auxmos reset done\n", AUXMOS_RESET_LOG)

#undef AUXMOS_RESET_LOG

/// Marker file the server watchdog (aquila/tools/server_watchdog.ps1) waits for.
#define WATCHDOG_RESTART_MARKER "data/watchdog_restart"

/// BYOND 516 tears down a played world in quadratic time (a queue drained from slot 0 every time),
/// so a soft reboot hangs DreamDaemon for minutes. Under the watchdog (it sets AQUILA_WATCHDOG) the world
/// leaves a marker instead; the watchdog kills the process and starts a fresh one.
/// /world/Del() never calls this, so a normal shutdown leaves no marker and the server stays off.
/world/proc/request_watchdog_restart()
	if(!world.GetConfig("env", "AQUILA_WATCHDOG"))
		return
	rustg_file_write("[time_stamp("YYYY-MM-DD hh:mm:ss")]", WATCHDOG_RESTART_MARKER)

#undef WATCHDOG_RESTART_MARKER
