/// The words (or tones really) the gizmo voice interface can listen for. Limit to 2 characters (or it breaks because im cringe)
GLOBAL_LIST_INIT(gizmo_words, world.file2list("strings/gizmo_words.txt"))

/// Listen to the tones and send the sequence to the puzzle datum
/datum/component/gizmo_voice
	var/datum/gizmo_puzzle/puzzle
	/// they're not really words but you get it
	var/static/list/active_words = list()

/datum/component/gizmo_voice/Initialize(datum/gizmo_puzzle/puzzle)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/movable/movable = parent
	movable.become_hearing_sensitive(type)
	RegisterSignal(movable, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))

	src.puzzle = puzzle

	if(!active_words.len)
		generate_active_words()

/datum/component/gizmo_voice/Destroy(force, silent)
	puzzle = null
	return ..()

/// Pick the activate keywords
/datum/component/gizmo_voice/proc/generate_active_words()
	var/list/possible_words = list()
	// AQUILA: odfiltrowujemy puste linie i wszystko, co nie ma dokładnie 2 znaków
	for(var/word in GLOB.gizmo_words)
		if(length(word) == 2)
			possible_words += lowertext(word)
	for(var/i in 1 to puzzle.cryptic_pulse.len)
		if(!length(possible_words))
			break
		active_words += pick_n_take(possible_words)

/// Listen to a message, and pick out the puzzle words
/datum/component/gizmo_voice/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	if(hearing_args[HEARING_SPEAKER] == parent)
		return

	var/haystack = hearing_args[HEARING_RAW_MESSAGE]
	if(!istext(haystack))
		return
	//aquila: całe słowa zamiast fragmentów tekstu - sylaby typu "na", "po", "do" siedzą w prawie każdym polskim zdaniu
	var/list/matched_words = list()
	for(var/token in splittext(lowertext(haystack), regex(@"[^a-ząćęłńóśźż0-9]+")))
		if(token in active_words)
			matched_words += token

	if(!length(matched_words))
		return

	for(var/i in 1 to length(matched_words))
		// Only send feedback for the last speech packet
		var/no_feedback = i != length(matched_words)
		// When solved, accept no further packets from this
		if(puzzle.on_pulse(active_words.Find(matched_words[i]), hearing_args[HEARING_SPEAKER], parent, no_feedback = no_feedback) == GIZMO_PUZZLE_SOLVED)
			return
