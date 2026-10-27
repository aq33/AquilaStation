GLOBAL_VAR_INIT(rune_words_initialized, FALSE)
GLOBAL_LIST_INIT(rune_words, list())
GLOBAL_LIST_INIT(rune_words_english, list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide"))
GLOBAL_LIST_INIT(rune_words_rune, list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "mgar", "balaq", "karazet", "geeri"))
GLOBAL_LIST_INIT(rune_words_icons, list("rune-1", "rune-2", "rune-4", "rune-8", "rune-16", "rune-32", "rune-64", "rune-128", "rune-256", "rune-512"))

/datum/rune_word
	var/english		= "word"//don't change those
	var/display_name	= "słowo" // AQUILA - polska nazwa słowa pokazywana graczom (english to klucz)
	var/rune		= "zek'kon"
	var/icon		= 'aquila/icons/bloodcult/uristrunes.dmi'
	var/icon_state	= ""
	var/color//used by path rune markers
	var/offset_x	= 0
	var/offset_y	= 0

/proc/initialize_rune_words()
	if (GLOB.rune_words_initialized)
		return
	for(var/subtype in subtypesof(/datum/rune_word))
		var/datum/rune_word/new_word = new subtype()
		GLOB.rune_words[new_word.english] = new_word
	GLOB.rune_words_initialized = 1

/// AQUILA - polska nazwa słowa (ścieżki) po kluczu english, np. "travel" -> "Podróż (ire)"
/proc/rune_word_display_name(english)
	initialize_rune_words()
	var/datum/rune_word/word = GLOB.rune_words[english]
	if(!word)
		return english
	return "[word.display_name] ([word.rune])"

/// AQUILA - lista do wyboru dla gracza: polska nazwa => klucz english
/proc/rune_word_display_list(list/english_keys)
	. = list()
	for(var/english in english_keys)
		.[rune_word_display_name(english)] = english

/datum/rune_word/travel
	english		= "travel"
	display_name	= "Podróż"
	rune		= "ire"
	icon_state	= "rune-1"
	color 		= "yellow"
	offset_x	= 6
	offset_y	= -5

/datum/rune_word/blood
	english		= "blood"
	display_name	= "Krew"
	rune		= "ego"
	icon_state	= "rune-2"
	color 		= "maroon"
	offset_x	= 0
	offset_y	= 5

/datum/rune_word/join
	english		= "join"
	display_name	= "Złączenie"
	rune		= "nahlizet"
	icon_state	= "rune-4"
	color 		= "green"
	offset_x	= 2
	offset_y	= 1

/datum/rune_word/hell
	english		= "hell"
	display_name	= "Piekło"
	rune		= "certum"
	icon_state	= "rune-8"
	color 		= "red"
	offset_x	= 0
	offset_y	= 10

/datum/rune_word/destroy
	english		= "destroy"
	display_name	= "Zniszczenie"
	rune		= "veri"
	icon_state	= "rune-16"
	color 		= "purple"
	offset_x	= 10
	offset_y	= 3

/datum/rune_word/technology
	english		= "technology"
	display_name	= "Technika"
	rune		= "jatkaa"
	icon_state	= "rune-32"
	color 		= "blue"
	offset_x	= -10
	offset_y	= 1

/datum/rune_word/self
	english		= "self"
	display_name	= "Jaźń"
	rune		= "mgar"
	icon_state	= "rune-64"
	color 		= null
	offset_x	= -6
	offset_y	= -9

/datum/rune_word/see
	english		= "see"
	display_name	= "Widzenie"
	rune		= "balaq"
	icon_state	= "rune-128"
	color 		= "fuchsia"
	offset_x	= 10
	offset_y	= -11

/datum/rune_word/other
	english		= "other"
	display_name	= "Inny"
	rune		= "karazet"
	icon_state	= "rune-256"
	color 		= "teal"
	offset_x	= -8
	offset_y	= 8

/datum/rune_word/hide
	english		= "hide"
	display_name	= "Ukrycie"
	rune		= "geeri"
	icon_state	= "rune-512"
	color 		= "silver"
	offset_x	= -2
	offset_y	= -1
