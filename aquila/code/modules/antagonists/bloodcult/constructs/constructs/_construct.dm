// AQUILA - zmiany kultu „Cult 4” (Monkestation/Monkestation2.0#3867, vgstation) nałożone na nasze konstrukty z
// code/modules/mob/living/simple_animal/constructs.dm. Bazowe typy, statystyki i zaklęcia (proc_holder) zostają nasze,
// tu są tylko rzeczy dopisane przez draft: typ konstruktu (limity kultu), poświata „perfect”, oczyszczanie, leczenie promieniem.

/mob/living/simple_animal/hostile/construct
	/// Konstrukt oczyszczany wodą święconą / null rodem: runy przestają być darmowe
	var/purge = FALSE
	/// Doskonali rzemieślnicy, którzy leczą tego konstrukta promieniem
	var/list/healers = list()
	/// Kolor poświaty doskonałych konstruktów
	var/construct_color = COLOR_BLOOD
	/// Poświata i uszkodzenia rysowane jako nakładki (doskonałe konstrukty z vg)
	var/new_glow = FALSE
	/// Rodzaj konstruktu do limitów kultu (/datum/team/cult/proc/CanConvert)
	var/construct_type = "Unknown"

/mob/living/simple_animal/hostile/construct/Initialize(mapload)
	// Zaklęcia z nowego systemu (/datum/action) idą osobno, pętla w core zna tylko proc_holdery
	var/list/action_spells = list()
	for(var/spell in construct_spells)
		if(ispath(spell, /datum/action))
			action_spells += spell
	if(length(action_spells))
		construct_spells = construct_spells - action_spells
	. = ..()
	var/total = length(construct_spells) + length(action_spells)
	var/spellnum = length(construct_spells) + (our_rune ? 1 : 0)
	for(var/spell_type in action_spells)
		var/datum/action/new_spell = new spell_type(src)
		new_spell.Grant(src)
		spellnum++
		var/pos = 2 + spellnum * 31
		if(total >= 4)
			pos -= 31 * (total - 4)
		if(new_spell.button)
			new_spell.button.screen_loc = "6:[pos],4:-2"
			new_spell.button.moved = "6:[pos],4:-2"
	update_icon()

/mob/living/simple_animal/hostile/construct/Login()
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/construct/Move(atom/newloc, direct, glide_size_override)
	. = ..()
	if(length(healers))
		for(var/mob/living/simple_animal/hostile/construct/builder/perfect/P in healers)
			P.move_ray()

/mob/living/simple_animal/hostile/construct/Destroy()
	for(var/mob/living/simple_animal/hostile/construct/builder/perfect/P in healers)
		P.end_ray()
	healers = null
	return ..()

/mob/living/simple_animal/hostile/construct/update_overlays()
	. = ..()
	if(!new_glow)
		return
	var/icon/glowicon = icon(icon, "glow-[icon_state]")
	glowicon.Blend(construct_color, ICON_ADD)
	. += emissive_appearance(glowicon)
	. += mutable_appearance(glowicon)

	var/damage = maxHealth - health
	var/icon/damageicon
	if(damage > (2 * maxHealth / 3))
		damageicon = icon(icon, "[icon_state]_damage_high")
	else if(damage > (maxHealth / 3))
		damageicon = icon(icon, "[icon_state]_damage_low")
	if(damageicon)
		damageicon.Blend(construct_color, ICON_ADD)
		. += emissive_appearance(damageicon)
		. += mutable_appearance(damageicon)

/mob/living/simple_animal/hostile/construct/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(new_glow)
		update_icon()

/// Ektoplazma konstruktów kultu (w drafcie osobny typ do death_drops).
/obj/item/ectoplasm/construct
	name = "krwistoczerwona ektoplazma"
	desc = "Ma ostry, metaliczny zapach."

// Motyw z draftu (THEME_CULT/THEME_HOLY); u nas anielskie konstrukty mają holy = TRUE
/mob/living/simple_animal/hostile/construct
	var/theme = THEME_CULT

/mob/living/simple_animal/hostile/construct/armored/angelic
	theme = THEME_HOLY

/mob/living/simple_animal/hostile/construct/wraith/angelic
	theme = THEME_HOLY

/mob/living/simple_animal/hostile/construct/builder/angelic
	theme = THEME_HOLY
