/datum/config_entry/flag/rp_filter_enabled

/// config.txt points INVOKE_YOUTUBEDL at the repo's .\yt-dlp.exe, which runs only on Windows.
/// On Linux use ./yt-dlp next to the game when it is there, otherwise yt-dlp from PATH.
/datum/config_entry/string/invoke_youtubedl/ValidateAndSet(str_val)
	if(world.system_type == UNIX)
		str_val = replacetext(str_val, ".\\yt-dlp.exe", fexists("yt-dlp") ? "./yt-dlp" : "yt-dlp")
	return ..()
