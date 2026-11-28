// AQUILA - Kod Żandarmerii (pomysł z CEV Eris, code/modules/mob/language/codespeak.dm: kody „10-42 Bravo” losowane na rundę).
// Język, który Żandarmeria zna od stanowiska: dla reszty meldunek brzmi jak ciąg kodów, które co rundę znaczą co innego.

/// Ziarno kodów na rundę: te same słowa dają te same kody tylko w tej rundzie
GLOBAL_VAR_INIT(aq_police_code_seed, "[rand(1, 999999)]")

/datum/language/police_code
	name = "Kod Żandarmerii"
	desc = "Meldunki Żandarmerii nadawane kodami (np. „10-42 Bravo”). Kody zmieniają się co rundę i zna je tylko Żandarmeria."
	key = "7"
	default_priority = 0
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD
	icon_state = "codespeak"

/datum/language/police_code/scramble(input)
	var/lookup = check_cache(input)
	if(lookup)
		return lookup
	var/static/list/phonetic = list("Alfa", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Kilo", "Lima", "Mike", "Oscar", "Papa", "Romeo", "Sierra", "Tango", "Victor", "Whiskey", "Zulu")
	var/static/list/prefixes = list("10", "20", "13", "0")
	var/list/words = splittext(input, " ")
	var/list/codes = list()
	for(var/i in 1 to length(words) step 3)
		var/chunk = jointext(words.Copy(i, min(i + 3, length(words) + 1)), " ")
		var/hash = md5("[GLOB.aq_police_code_seed]|[lowertext(chunk)]")
		var/a = text2num(copytext(hash, 1, 3), 16)
		var/b = text2num(copytext(hash, 3, 5), 16)
		var/c = text2num(copytext(hash, 5, 7), 16)
		codes += "[prefixes[(a % length(prefixes)) + 1]]-[(b % 99) + 1] [phonetic[(c % length(phonetic)) + 1]]"
	. = jointext(codes, ", ")
	var/input_ending = copytext_char(input, -1)
	if(input_ending in list("!", "?", "."))
		. += input_ending
	add_to_cache(input, .)

/// Żandarmeria (dział ochrony) zna kod od stanowiska
/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	if(isliving(H) && (departments & DEPARTMENT_BITFLAG_SECURITY))
		H.grant_language(/datum/language/police_code, TRUE, TRUE, LANGUAGE_MIND)
