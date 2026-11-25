/**
 * „Ważne wspomnienia” z tg (code/datums/memory/key_memories.dm).
 *
 * These memories aren't particularly special or interesting, but occuply an important role
 * in conveying information to the user about something important they need to check semi-often
 *
 * AQUILA: kod uplinka i kod atomówki zostają w notatkach antagonisty (antag_memory), jak było,
 * więc nie mają tu typów. Klucza serwera wiadomości nie mamy.
 */
/datum/memory/key
	story_value = STORY_VALUE_KEY
	memory_flags = MEMORY_FLAG_NOMOOD|MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS

/// Your bank account ID, can't get into it without it
/datum/memory/key/account
	var/remembered_id

/datum/memory/key/account/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	remembered_id,
)
	src.remembered_id = remembered_id
	return ..()

/datum/memory/key/account/get_names()
	return list("Numer konta bankowego: [remembered_id].")

/datum/memory/key/account/get_starts()
	return list(
		"[protagonist_name] napina ostatnie szare komórki i z dumą pokazuje swoje szczęśliwe liczby: [remembered_id]",
		"[remembered_id]. Te liczby, co one znaczą!?",
	)

/// The code to the captain's spare ID, ONLY give to the real captain.
/datum/memory/key/captains_spare_code
	var/safe_code

/datum/memory/key/captains_spare_code/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	safe_code,
)
	src.safe_code = safe_code
	return ..()

/datum/memory/key/captains_spare_code/get_names()
	return list("Kod do złotego sejfu z zapasową kartą kapitana: [safe_code].")

/datum/memory/key/captains_spare_code/get_starts()
	return list(
		"[protagonist_name] mocuje się z sejfem w ścianie, aż w końcu wpisuje [safe_code]",
		"[safe_code][rand(0,9)]. Te liczby, co one znaczą!?", // Same as the account code
	)

/// Tracks what medicines someone with the "allergies" quirk is allergic to
/datum/memory/key/quirk_allergy
	memory_flags = MEMORY_FLAG_NOMOOD|MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS|MEMORY_NO_STORY // No story for this
	var/allergy_string

/datum/memory/key/quirk_allergy/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	allergy_string,
)
	src.allergy_string = allergy_string
	return ..()

/datum/memory/key/quirk_allergy/get_names()
	return list("Uczulenie na: [allergy_string].")

/datum/memory/key/quirk_allergy/get_starts()
	return list("[protagonist_name] kicha po zetknięciu z czymś z listy: [allergy_string]")

/// Tracks what kind of item the quirk user's heirloom is
/datum/memory/key/quirk_heirloom
	var/heirloom_name

/datum/memory/key/quirk_heirloom/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	heirloom_name,
)
	src.heirloom_name = heirloom_name
	return ..()

/datum/memory/key/quirk_heirloom/get_names()
	return list("Rodzinna pamiątka: [heirloom_name].")

/datum/memory/key/quirk_heirloom/get_starts()
	return list(
		"[protagonist_name] dostaje w spadku rodzinną pamiątkę ([heirloom_name]) od drogiego krewnego",
		"[protagonist_name] znajduje rodzinną pamiątkę ([heirloom_name]) w dawno zapomnianych pudłach",
		"[protagonist_name] kradnie rodzinną pamiątkę ([heirloom_name]) niegodnemu krewnemu",
	)

/// Tracks what brand a smoker quirk user likes
/datum/memory/key/quirk_smoker
	memory_flags = MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS // Does not have nomood
	var/preferred_brand

/datum/memory/key/quirk_smoker/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	preferred_brand,
)
	src.preferred_brand = preferred_brand
	return ..()

/datum/memory/key/quirk_smoker/get_names()
	return list("Ulubione papierosy: [preferred_brand].")

/datum/memory/key/quirk_smoker/get_starts()
	return list(
		"[protagonist_name] pustoszy zapasy papierosów ([preferred_brand])",
		"[protagonist_name] kupuje paczkę papierosów ([preferred_brand])",
		"[protagonist_name] rozpaczliwie szuka papierosów ([preferred_brand])",
	)

/datum/memory/key/quirk_smoker/get_moods()
	return list("[memorizer] [mood_verb] i zapala kolejnego.")

/// Tracks what beverage an alcoholic quirk user likes
/datum/memory/key/quirk_alcoholic
	memory_flags = MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS // Does not have nomood
	var/preferred_brandy //haha, get it because brandy is a type of alcohol wow!

/datum/memory/key/quirk_alcoholic/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	preferred_brandy,
)
	src.preferred_brandy = preferred_brandy
	return ..()

/datum/memory/key/quirk_alcoholic/get_names()
	return list("Ulubiony trunek: [preferred_brandy].")

/datum/memory/key/quirk_alcoholic/get_starts()
	return list(
		"[protagonist_name] opróżnia butelkę ([preferred_brandy]) jednym haustem",
		"[protagonist_name] kupuje skrzynkę butelek ([preferred_brandy])",
		"[protagonist_name] rozpaczliwie szuka trunku ([preferred_brandy])",
	)

/datum/memory/key/quirk_alcoholic/get_moods()
	return list("[memorizer] [mood_verb] i pociąga kolejny łyk ([preferred_brandy]).")

/// Wyrok więźnia (u nas z eventu przewozu więźnia, w tg z profesji więźnia)
/datum/memory/key/permabrig_crimes
	var/crimes

/datum/memory/key/permabrig_crimes/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	crimes,
)
	src.crimes = crimes
	return ..()

/datum/memory/key/permabrig_crimes/get_names()
	return list("Wyrok za: [crimes].")

/datum/memory/key/permabrig_crimes/get_starts()
	return list(
		"ochrona aresztuje postać, którą jest [protagonist_name], za: [crimes]",
		"[protagonist_name] popełnia przestępstwo: [crimes]",
	)
