
/datum/bloodcult_ritual/altar
	name = "Przygotuj ołtarz"
	desc = "wznieś ołtarz...<br>rozłóż wokół odpowiednie akcesoria...<br>a potem wbij w niego rytualny nóż..."

	ritual_type = "altar"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	var/required_candles = 0
	var/required_tomes = 0
	var/required_runes = 0
	var/required_pylons = 0
	var/required_animal = 0
	var/required_humanoid = 0
	var/required_cultblade = 0

	keys = list("altar_plant")

/datum/bloodcult_ritual/altar/key_found(obj/structure/cult/altar/altar)
	var/mob/user = owner?.owner?.current
	if (!istype(altar))
		return FALSE

	var/valid = TRUE
	var/found_candles = 0
	for (var/obj/item/candle/blood/CB in range(1, altar))
		if (CB.lit)
			found_candles++
	if (found_candles < required_candles)
		to_chat(user, span_cult("Potrzeba więcej zapalonych krwawych świec...") )
		valid = FALSE

	var/found_tomes = 0
	for (var/obj/item/tome/T in range(1, altar))
		found_tomes++
	if (found_tomes < required_tomes)
		to_chat(user, span_cult("Potrzeba więcej tajemnych ksiąg...") )
		valid = FALSE

	var/found_runes = 0
	for (var/obj/effect/new_rune/R in range(1, altar))
		found_runes++
	if (found_runes < required_runes)
		to_chat(user, span_cult("Potrzeba więcej run...") )
		valid = FALSE

	var/found_pylons = 0
	for (var/obj/structure/cult/pylon/P in range(1, altar))
		found_pylons++
	if (found_pylons < required_pylons)
		to_chat(user, span_cult("Musisz zbudować dodatkowe pylony...") )
		valid = FALSE

	var/found_animal = FALSE
	var/found_humanoid = FALSE
	if(altar.has_buckled_mobs())
		var/mob/M = altar.buckled_mobs[1]
		if (ishuman(M))
			found_humanoid = TRUE
		if (ismonkey(M) || isanimal(M))
			found_animal = TRUE
	if (required_animal && !found_animal)
		to_chat(user, span_cult("Musisz nadziać na niego zwierzę...") )
		valid = FALSE
	if (required_humanoid && !found_humanoid)
		to_chat(user, span_cult("Musisz nadziać na niego humanoida...") )
		valid = FALSE

	var/obj/item/melee/B = altar.blade
	if (required_cultblade && !istype(B))
		to_chat(user, span_cult("Na koniec: zwykły rytualny nóż tu nie wystarczy. Wykuj lepsze narzędzie...") )
		valid = FALSE

	return valid
