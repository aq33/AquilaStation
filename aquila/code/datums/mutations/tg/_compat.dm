// AQUILA - brakujące kawałki tg dla mutacji z tgstation

// --- Traity z tg ---
// Wartości jak w tg. Rdzeń (mob.dm, human.dm, human_helpers.dm) sprawdza je po tekście, bo te pliki są przed aquila.dm.

/// Nie umie czytać ani pisać (mutacja Illiterate)
#define TRAIT_ILLITERATE "illiterate"
/// Umie czytać, nawet jeśli normalnie nie umie (mutacja Clever, np. małpa)
#define TRAIT_LITERATE "literate"
/// Umie używać zaawansowanych narzędzi (mutacja Clever)
#define TRAIT_ADVANCEDTOOLUSER "advancedtooluser"
/// Umie zwinąć pajęczynę w tkaninę (mutacja Webbing Production)
#define TRAIT_WEB_WEAVER "web_weaver"
/// Nie czuje bólu. U nas nie ma systemu bólu, więc na razie tylko znacznik (razem z TRAIT_IGNOREDAMAGESLOWDOWN)
#define TRAIT_ANALGESIA "analgesia"

/// Sekundy na jedno wywołanie on_life() mutacji (tick Life to 2 s)
#define TGMUT_LIFE_SECONDS 2
/// tg SPT_PROB dla on_life(): szansa na sekundę przeliczona na jeden tick Life
#define TGMUT_SPT_PROB(prob_per_second) (prob(100 * (1 - (1 - (prob_per_second) / 100) ** TGMUT_LIFE_SECONDS)))

// --- Samogłoski do mutacji mowy (z polskimi) ---
#define TGMUT_VOWELS list("a", "ą", "e", "ę", "i", "o", "ó", "u", "y")
#define TGMUT_CONSONANTS list("b", "c", "ć", "d", "f", "g", "h", "j", "k", "l", "ł", "m", "n", "ń", "p", "q", "r", "s", "ś", "t", "v", "w", "x", "z", "ź", "ż")

// --- Pig Latin (tg: code/__HELPERS/text.dm) ---

/// Przerabia każde słowo zdania na pig latin, zachowuje interpunkcję na końcu
/proc/piglatin_sentence(text)
	var/text_length = length_char(text)
	text = lowertext(text)
	var/punctuation = ""
	var/static/list/punctuation_hit_list = list("!", "?", ".", "-")
	for(var/letter_index in text_length to 1 step -1)
		var/letter = copytext_char(text, letter_index, letter_index + 1)
		if(!(letter in punctuation_hit_list))
			break
		punctuation = letter + punctuation
	text = copytext_char(text, 1, (text_length + 1) - length_char(punctuation))
	var/list/new_words = list()
	for(var/word in splittext(text, " "))
		new_words += piglatin_word(word)
	text = capitalize(jointext(new_words, " "))
	return text + punctuation

/// Jedno słowo na pig latin
/proc/piglatin_word(word)
	if(length_char(word) <= 1)
		return word
	var/first_letter = copytext_char(word, 1, 2)
	var/first_two_letters = copytext_char(word, 1, 3)
	var/first_is_vowel = (first_letter in TGMUT_VOWELS)
	var/second_is_vowel = (copytext_char(word, 2, 3) in TGMUT_VOWELS)
	if(first_is_vowel)
		return word + pick("yay", "way", "hay")
	if(second_is_vowel)
		return copytext_char(word, 2) + first_letter + "ay"
	return copytext_char(word, 3) + first_two_letters + "ay"

// --- Pliki tekstów mutacji (wkompilowane w rsc, bo deploy kopiuje tylko strings/) ---

/// Zwraca listę z pliku JSON mutacji tg, klucz key
/proc/tgmut_strings(file_key, key)
	var/static/list/cache = list()
	if(!cache[file_key])
		var/raw
		switch(file_key)
			if("heckacious")
				raw = file2text('aquila/strings/mutations/tg/heckacious.json')
			if("ork")
				raw = file2text('aquila/strings/mutations/tg/ork_replacement.json')
		cache[file_key] = raw ? json_decode(raw) : list()
	var/list/data = cache[file_key]
	return data[key] || list()

// --- Zaklęcie pocisku: kopia yog/_compat.dm (pointed/projectile) pod lokalną nazwą, żeby nie kolidować ---

/datum/action/cooldown/spell/pointed/tg_projectile
	/// Jakim pociskiem strzelamy
	var/obj/item/projectile/projectile_type
	/// Ile strzałów na jedno włączenie celowania
	var/projectile_amount = 1
	/// Ile strzałów zostało
	var/current_amount = 0
	/// Ile pocisków na jeden strzał
	var/projectiles_per_fire = 1

/datum/action/cooldown/spell/pointed/tg_projectile/New(Target)
	. = ..()
	if(projectile_amount > 1)
		unset_after_click = FALSE

// Pociskiem można strzelić w cokolwiek, także we własne pole
/datum/action/cooldown/spell/pointed/tg_projectile/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/tg_projectile/on_activation(mob/on_who)
	. = ..()
	current_amount = projectile_amount

/datum/action/cooldown/spell/pointed/tg_projectile/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(projectile_amount > 1 && current_amount)
		StartCooldown(cooldown_time * ((projectile_amount - current_amount) / projectile_amount))
		current_amount = 0

/datum/action/cooldown/spell/pointed/tg_projectile/cast(atom/cast_on)
	. = ..()
	if(!isturf(owner.loc))
		return FALSE
	var/turf/caster_turf = get_turf(owner)
	var/turf/caster_front_turf = get_step(owner, owner.dir)
	fire_projectile(cast_on)
	owner.newtonian_move(get_dir(caster_front_turf, caster_turf))
	if(current_amount <= 0)
		unset_click_ability(owner, refund_cooldown = FALSE)
	return TRUE

/datum/action/cooldown/spell/pointed/tg_projectile/after_cast(atom/cast_on)
	. = ..()
	// Zostały strzały, więc bez odnowienia
	if(current_amount > 0)
		reset_spell_cooldown()

/datum/action/cooldown/spell/pointed/tg_projectile/proc/fire_projectile(atom/target)
	current_amount--
	for(var/i in 1 to projectiles_per_fire)
		var/obj/item/projectile/to_fire = new projectile_type(get_turf(owner))
		ready_projectile(to_fire, target, owner, i)
		if(QDELETED(to_fire))
			continue
		to_fire.fire()
	return TRUE

/datum/action/cooldown/spell/pointed/tg_projectile/proc/ready_projectile(obj/item/projectile/to_fire, atom/target, mob/user, iteration)
	to_fire.firer = owner
	to_fire.fired_from = get_turf(owner)
	to_fire.preparePixelProjectile(target, owner)

// --- Przywołanie przedmiotu (tg /datum/action/cooldown/spell/conjure_item), wersja uproszczona ---

/datum/action/cooldown/spell/conjure_item
	/// Co tworzymy
	var/atom/movable/item_type
	/// Czy przy nowym rzuceniu usuwamy poprzednio stworzone rzeczy
	var/delete_old = TRUE
	/// Rzeczy stworzone przez to zaklęcie
	var/list/datum/weakref/item_refs

/datum/action/cooldown/spell/conjure_item/Destroy()
	if(delete_old)
		for(var/datum/weakref/ref as anything in item_refs)
			var/atom/movable/thing = ref.resolve()
			if(!QDELETED(thing))
				qdel(thing)
	item_refs = null
	return ..()

/datum/action/cooldown/spell/conjure_item/cast(atom/cast_on)
	. = ..()
	if(delete_old)
		for(var/datum/weakref/ref as anything in item_refs)
			var/atom/movable/thing = ref.resolve()
			if(!QDELETED(thing))
				qdel(thing)
		item_refs = null
	var/atom/movable/created = make_item(cast_on)
	if(created)
		LAZYADD(item_refs, WEAKREF(created))

/datum/action/cooldown/spell/conjure_item/proc/make_item(atom/cast_on)
	var/turf/spawn_turf = get_turf(cast_on)
	if(!spawn_turf)
		return
	var/atom/movable/created = new item_type(spawn_turf)
	if(isitem(created) && iscarbon(cast_on))
		var/mob/living/carbon/carbon_caster = cast_on
		carbon_caster.put_in_hands(created)
	return created
