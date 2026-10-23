// NTSL na serwerach telekomunikacji (Yogstation, przez Monkestation/Monkestation2.0#2199).
// Hook w core: receive_information() w code/game/machinery/telecomms/machines/server.dm woła Compiler.Run().

/// Maximum amount of characters that can be in a script
#define NTSL_MAX_CHARACTERS 15000

/// The server's radio, used by broadcast() in NTSL
/obj/item/radio/server

/obj/item/radio/server/can_receive(frequency, levels)
	return FALSE // The server's radio isn't for receiving, it's for outputting.

/obj/machinery/telecomms/server
	/// The compiler that compiles and runs the code
	var/datum/TCS_Compiler/Compiler
	/// TRUE if the code runs every time a signal is picked up
	var/autoruncode = FALSE
	/// Stored memory, for mem() in NTSL
	var/list/memory = list()
	/// The code to compile
	var/rawcode = ""
	/// The last compiled code
	var/compiledcode = ""
	/// Allows the server to talk on the radio, via broadcast() in NTSL
	var/obj/item/radio/server/server_radio
	/// Marks the last time an NTSL script called remote_signal() from this server, to stop spam
	var/last_signal = 0
	var/list/compile_warnings = list()
	COOLDOWN_DECLARE(compile_cooldown)

/obj/machinery/telecomms/server/Initialize(mapload)
	Compiler = new()
	Compiler.Holder = src
	server_radio = new()
	return ..()

/obj/machinery/telecomms/server/Destroy()
	Compiler?.garbage_collect()
	QDEL_NULL(Compiler)
	QDEL_NULL(server_radio)
	memory = null
	return ..()

/// Adds a non-speech entry (like a script error) to the server logs
/obj/machinery/telecomms/server/proc/add_entry(content, input)
	var/datum/comm_log_entry/log = new
	var/identifier = num2text(rand(-1000, 1000) + world.time)
	log.name = "[input] ([rustg_hash_string(RUSTG_HASH_MD5, identifier)])"
	log.input_type = input
	log.parameters["message"] = content
	log.parameters["language"] = /datum/language/common
	log_entries.Add(log)
	if(length(log_entries) >= 400)
		log_entries.Cut(1, 2)

/// Compiles rawcode, returns a list of errors or a text message
/obj/machinery/telecomms/server/proc/compile(mob/user = usr)
	if(QDELETED(Compiler))
		return
	if(!length(trim(rawcode)))
		return "Brak kodu do kompilacji."
	// Polish letters are fine, control characters and HTML brackets are not
	if(!reject_bad_ntsl_text(rawcode, ascii_only = FALSE, require_pretty = FALSE, allow_newline = TRUE, allow_code = TRUE))
		rawcode = null
		return "Kod zawiera niedozwolone znaki."
	var/code_length = length_char(rawcode)
	if(code_length > NTSL_MAX_CHARACTERS)
		rawcode = null
		return "Przekroczony limit znaków: [code_length]/[NTSL_MAX_CHARACTERS]"
	if(!COOLDOWN_FINISHED(src, compile_cooldown))
		return "Serwery się ładują, poczekaj chwilę."
	var/list/compileerrors = Compiler.Compile(rawcode)
	COOLDOWN_START(src, compile_cooldown, 2 SECONDS)
	if(!length(compileerrors) && (compiledcode != rawcode))
		log_telecomms("NTSL: [key_name(user)] uploaded code to [id] [loc_name(src)]: [rawcode]")
		compiledcode = rawcode
	return compileerrors

#undef NTSL_MAX_CHARACTERS
