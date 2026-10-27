// AQUILA - warstwa zgodności obszaru „rdzeń” kultu krwi (antag, drużyna, krew, rytuały, Zaćmienie).
// Helpery, których nie mamy w bazie (Bee ~ tg 2020), a których potrzebuje rdzeń kultu.

/// TRUE, jeśli mob nie ma krwi, z której kult mógłby korzystać (gatunek NOBLOOD, cecha TRAIT_NO_BLOOD albo brak krwi w ogóle).
/// Zastępuje HAS_TRAIT(mob, TRAIT_NOBLOOD) z tg.
/proc/cult_has_no_blood(mob/living/target)
	if(!istype(target))
		return TRUE
	if(HAS_TRAIT(target, TRAIT_NO_BLOOD))
		return TRUE
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(NOBLOOD in human_target.dna?.species?.species_traits)
			return TRUE
	return !target.get_blood_id()

/// Nowy odczynnik krwi z danymi danego moba (u nas dna.blood_type to nazwa, a dane daje get_blood_data()).
/// Runy czytają z niego data["blood_type"], więc zawsze je ustawiamy.
/proc/cult_blood_reagent(mob/living/source)
	var/datum/reagent/blood/blood = new()
	if(istype(source))
		var/list/blood_data = source.get_blood_data(/datum/reagent/blood)
		if(islist(blood_data))
			blood.data = blood_data
		blood.color = source.get_blood_color()
	return blood

/// Odczynnik krwi z plamy na podłodze (typ krwi bierzemy z jej DNA).
/proc/cult_blood_reagent_from_decal(obj/effect/decal/cleanable/blood/splatter)
	var/datum/reagent/blood/blood = new()
	if(!istype(splatter))
		return blood
	var/list/blood_dna = splatter.return_blood_DNA()
	if(length(blood_dna))
		blood.data["blood_DNA"] = blood_dna[length(blood_dna)]
		blood.data["blood_type"] = blood_dna[blood_dna[length(blood_dna)]]
	blood.color = splatter.color
	return blood

/// Ile jednostek krwi da się jeszcze zebrać ze świeżej plamy (stare, zaschnięte plamy nic nie dają).
/obj/effect/decal/cleanable/blood/proc/cult_blood_amount()
	if(is_old)
		return 0
	return round(bloodiness * 25 / BLOOD_AMOUNT_PER_DECAL)

/// Zabiera z plamy tyle krwi, ile zużył rytuał.
/obj/effect/decal/cleanable/blood/proc/cult_use_blood(amount)
	bloodiness = max(0, bloodiness - (amount * BLOOD_AMOUNT_PER_DECAL / 25))

// ---- czerwone oczy kultystów (tg: /datum/element/cult_eyes) ----

/datum/antagonist/cult
	/// Kolor oczu sprzed czerwonych oczu kultu, przywracany po dekonwersji
	var/original_eye_color

/datum/antagonist/cult/proc/give_cult_eyes()
	var/mob/living/carbon/human/human_owner = owner?.current
	if(!ishuman(human_owner) || HAS_TRAIT(human_owner, CULT_EYES))
		return
	original_eye_color = human_owner.eye_color
	human_owner.eye_color = BLOODCULT_EYE
	human_owner.dna?.update_ui_block(DNA_EYE_COLOR_BLOCK)
	ADD_TRAIT(human_owner, CULT_EYES, CULT_TRAIT)
	human_owner.update_body()

/datum/antagonist/cult/proc/remove_cult_eyes(mob/living/target)
	var/mob/living/carbon/human/human_target = target
	if(!ishuman(human_target) || !HAS_TRAIT(human_target, CULT_EYES))
		return
	REMOVE_TRAIT(human_target, CULT_EYES, CULT_TRAIT)
	human_target.eye_color = original_eye_color || initial(human_target.eye_color)
	human_target.dna?.update_ui_block(DNA_EYE_COLOR_BLOCK)
	human_target.update_body()

// ---- Zaćmienie: czerwony parallax ----
// Warstwę szczelin (rifts) dokłada integracja: bloodcult_eclipse_parallax(client) z hooka w create_parallax.
// Rdzeń przy starcie i końcu Zaćmienia odświeża wszystkich już połączonych klientów: szczeliny + czerwone gwiazdy.

/// Czy na stacji trwa teraz Zaćmienie kultu (lub Nar'Sie już tu jest).
/proc/bloodcult_eclipse_active()
	if(GLOB.eclipse?.eclipse_start_time && !GLOB.eclipse.eclipse_finished)
		return TRUE
	return SShell_universe?.hell_time

/// Barwi (albo odbarwia) warstwy parallaxu jednego klienta i dokłada/zdejmuje szczeliny. Nie przebudowuje ekranu.
/// Integracja woła to z bloodcult_eclipse_parallax(), żeby nowi klienci też dostali czerwone niebo.
/proc/bloodcult_color_parallax(client/target)
	if(!target || !length(target.parallax_layers_cached))
		return
	var/eclipse = bloodcult_eclipse_active()
	if(eclipse)
		bloodcult_add_rifts(target)
	else
		for(var/atom/movable/screen/parallax_layer/rifts/rift in target.parallax_layers_cached)
			target.parallax_layers_cached -= rift
			target.screen -= rift
			qdel(rift)
	for(var/atom/movable/screen/parallax_layer/layer as anything in target.parallax_layers_cached)
		if(istype(layer, /atom/movable/screen/parallax_layer/rifts))
			continue
		if(eclipse)
			layer.add_atom_colour(BLOODCULT_ECLIPSE_PARALLAX_COLOR, ADMIN_COLOUR_PRIORITY)
		else
			layer.remove_atom_colour(ADMIN_COLOUR_PRIORITY, BLOODCULT_ECLIPSE_PARALLAX_COLOR)

/// Barwi parallax klienta i przebudowuje mu go na ekranie (start/koniec Zaćmienia).
/proc/bloodcult_update_client_parallax(client/target)
	if(!target || !length(target.parallax_layers_cached))
		return
	bloodcult_color_parallax(target)
	var/mob/viewer = target.mob
	if(viewer?.hud_used)
		viewer.hud_used.remove_parallax(viewer)
		viewer.hud_used.create_parallax(viewer)

/// Odświeża parallax wszystkich klientów.
/proc/bloodcult_update_all_parallax()
	for(var/client/target as anything in GLOB.clients)
		bloodcult_update_client_parallax(target)
		CHECK_TICK

// ---- duchy po zniszczeniu Krwawego Kamienia (vg: observer.decultify()) ----
// Ducha kultu robi narsie_act() z _compat/integration.dm (zapisuje appearance_backup).

/mob/dead/observer/proc/bloodcult_decultify()
	if(!appearance_backup)
		return
	for(var/datum/action/cooldown/blood_doodle/doodle in actions)
		doodle.Remove(src)
		qdel(doodle)
	appearance = appearance_backup
	appearance_backup = null
	invisibility = GLOB.observer_default_invisibility
