// AQUILA - krwawe robaki: zmiany w systemie krwi i HUD-y (port z tgstation#93787)
// U nas krew to zwykły var blood_volume, więc modyfikatory objętości i syntetyczność krwi z tg są zrobione tutaj.

/mob/living
	/// Jak bardzo syntetyczna jest krew tego moba (0-1), np. po przetoczeniu krwi z worka. Zanika z czasem.
	var/blood_synth_content = 0
	/// Mnożnik objętości krwi pokazywanej na skanerach i HUD-ach. Robak w nosicielu ustawia go tak,
	/// żeby pełne zdrowie robaka wyglądało jak normalny poziom krwi.
	var/shown_blood_multiplier = 1

/// Jak syntetyczna jest krew moba (0-1). Krew zwierząt i małp zawsze jest syntetyczna, żeby robaki musiały polować na ludzi.
/mob/living/proc/get_blood_synth_content()
	if(!ishuman(src))
		return 1
	return clamp(blood_synth_content, 0, 1)

/// Miesza syntetyczną krew z krwią moba, liczy średnią ważoną
/mob/living/proc/mix_synth_blood(old_volume, added_volume, added_synth)
	if(!ishuman(src) || added_volume <= 0)
		return
	var/total = old_volume + added_volume
	if(total <= 0)
		return
	blood_synth_content = clamp((old_volume * blood_synth_content + added_volume * added_synth) / total, 0, 1)

/// Objętość krwi, którą widać na skanerach, w opisie i na HUD-ach
/mob/living/proc/get_shown_blood_volume()
	return blood_volume * shown_blood_multiplier

/mob/living/Life(seconds, times_fired)
	. = ..()
	if(QDELETED(src))
		return
	// Dziesięć minut, żeby krew przestała być całkiem syntetyczna
	if(blood_synth_content > 0 && stat != DEAD)
		blood_synth_content = max(blood_synth_content - (seconds || 2) / 600, 0)
	if(length(GLOB.blood_worm_blood_hud.hudusers))
		blood_hud_set_status()

/mob/living/carbon/get_blood_data(blood_id)
	. = ..()
	if(!islist(.))
		return
	var/synth = get_blood_synth_content()
	if(synth > 0)
		.[BLOOD_DATA_SYNTH_CONTENT] = synth

/datum/reagent/blood/on_merge(list/mix_data, amount)
	// Holder dodaje objętość przed on_merge, więc stara objętość to volume - amount
	var/old_synth = data?[BLOOD_DATA_SYNTH_CONTENT] || 0
	var/added_synth = mix_data?[BLOOD_DATA_SYNTH_CONTENT] || 0
	if((old_synth || added_synth) && amount && volume > 0)
		if(!data)
			data = list()
		var/old_volume = max(volume - amount, 0)
		data[BLOOD_DATA_SYNTH_CONTENT] = clamp((old_volume * old_synth + amount * added_synth) / volume, 0, 1)
	return ..()

/datum/reagent/blood/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	var/old_volume = L?.blood_volume
	. = ..()
	if(!L || L.blood_volume <= old_volume)
		return
	L.mix_synth_blood(old_volume, L.blood_volume - old_volume, data?[BLOOD_DATA_SYNTH_CONTENT] || 0)

/obj/item/reagent_containers/blood/Initialize(mapload)
	. = ..()
	// Krew z worków jest w połowie syntetyczna: dwie lodówki krwi nie wyhodują całego stada dorosłych robaków
	var/datum/reagent/blood/pack_blood = reagents?.has_reagent(/datum/reagent/blood)
	if(pack_blood)
		LAZYINITLIST(pack_blood.data)
		pack_blood.data[BLOOD_DATA_SYNTH_CONTENT] = 0.5

// Nosiciel robaka nie regeneruje krwi i nie dusi się od jej braku: krew to zdrowie robaka
/mob/living/carbon/human/handle_blood()
	if(HAS_TRAIT(src, TRAIT_BLOOD_WORM_HOST))
		return
	return ..()

// HUD-y

/// Poziom krwi wszystkich żywych, widoczny dla robaków
GLOBAL_DATUM_INIT(blood_worm_blood_hud, /datum/atom_hud/data/blood_worm_blood, new)
/// Ikona robaka nad robakami i ich nosicielami, widoczna dla stada
GLOBAL_DATUM_INIT(blood_worm_team_hud, /datum/atom_hud/data/blood_worm_team, new)

/datum/atom_hud/data/blood_worm_blood
	hud_icons = list(BLOOD_WORM_BLOOD_HUD)

/datum/atom_hud/data/blood_worm_team
	hud_icons = list(BLOOD_WORM_TEAM_HUD)

/mob/living/prepare_huds()
	hud_possible |= list(BLOOD_WORM_BLOOD_HUD, BLOOD_WORM_TEAM_HUD)
	. = ..()
	var/image/blood_image = hud_list[BLOOD_WORM_BLOOD_HUD]
	blood_image?.icon = 'aquila/icons/obj/blood_worm.dmi'
	var/image/team_image = hud_list[BLOOD_WORM_TEAM_HUD]
	if(team_image)
		team_image.icon = 'aquila/icons/obj/blood_worm.dmi'
		team_image.icon_state = "hud_blood_worm"

/mob/living/Initialize(mapload)
	. = ..()
	GLOB.blood_worm_blood_hud.add_to_hud(src)

/mob/living/Destroy()
	GLOB.blood_worm_blood_hud.remove_from_hud(src)
	GLOB.blood_worm_team_hud.remove_from_hud(src)
	return ..()

/mob/living/proc/blood_hud_set_status()
	var/image/holder = hud_list?[BLOOD_WORM_BLOOD_HUD]
	if(!holder)
		return
	if(blood_volume <= 0 || !get_blood_id())
		holder.icon_state = ""
		return
	var/blood_level = (get_shown_blood_volume() / BLOOD_VOLUME_NORMAL) * 100
	switch(blood_level)
		if(87.5 to INFINITY)
			holder.icon_state = "hudblood100"
		if(62.5 to 87.5)
			holder.icon_state = "hudblood75"
		if(37.5 to 62.5)
			holder.icon_state = "hudblood50"
		if(12.5 to 37.5)
			holder.icon_state = "hudblood25"
		else
			holder.icon_state = "hudblood0"

/// Daje albo zabiera HUD krwi zależnie od TRAIT_BLOOD_HUD
/mob/living/proc/update_blood_worm_hud_sight()
	if(HAS_TRAIT(src, TRAIT_BLOOD_HUD))
		GLOB.blood_worm_blood_hud.add_hud_to(src)
	else
		GLOB.blood_worm_blood_hud.remove_hud_from(src, TRUE)
