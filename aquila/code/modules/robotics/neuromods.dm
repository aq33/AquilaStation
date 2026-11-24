// AQUILA - neuromody z psychotroniki (Chaotic Onyx code/modules/psychotronics/neuromods.dm, psychoscope.dm), uproszczone.
// Psychoskopem (skaner w ręce, 3 s) skanuje się żywe istoty. Każdy skan nowego osobnika daje szansę na odkrycie neuromodu
// tej formy życia (szansa z neuromodu, jak w Onyksie). Odkryty neuromod psychoskop zapisuje w pustej powłoce neuromodu
// (z protolathe), a powłoka wstrzyknięta człowiekowi (3 s) daje mu na stałe zdolność zeskanowanej istoty.
// W Onyksie neuromod bada się w psychoskopie (research_time) i zapisuje na dyskach, a powłoki ładuje osobna maszyna;
// u nas jest tylko szansa przy skanie i zapis prosto z psychoskopu, bez dysków i maszyny.
// Neuromody: regeneracja w świetle (rośliny), widzenie w ciemności (pająki, ksenomorfy), odporność na zimno (karpie),
// języki (jaszczuroludzie, ćmy, ludzie-rośliny). Telepatii z Onyksu nie ma (u nas to mutacja genetyczna).
// Ikony: istniejące sprite'y skanera i iniektora DNA.

/datum/aq_neuromod
	/// Typ abstrakcyjny, nie trafia na listę
	var/abstract_type = /datum/aq_neuromod
	var/name = "neuromod"
	var/desc = ""
	/// Szansa na odkrycie przy jednym skanie (%)
	var/chance = 25
	/// Typy istot, z których się go odkrywa
	var/list/source_types = list()

/// Raz, przy wstrzyknięciu
/datum/aq_neuromod/proc/on_gain(mob/living/carbon/human/H)
	return

/// Co tick życia
/datum/aq_neuromod/proc/on_life(mob/living/carbon/human/H, delta_time)
	return

/datum/aq_neuromod/light_regeneration
	name = "Regeneracja w świetle"
	desc = "Zmienia strukturę skóry tak, że rany goją się w świetle."
	chance = 25
	source_types = list(/mob/living/basic/killer_tomato)

/datum/aq_neuromod/light_regeneration/on_life(mob/living/carbon/human/H, delta_time)
	var/turf/our_turf = get_turf(H)
	if(our_turf && our_turf.get_lumcount() > 0.4 && (H.getBruteLoss() || H.getFireLoss()))
		H.heal_overall_damage(0.15 * delta_time, 0.15 * delta_time)

/datum/aq_neuromod/night_vision
	name = "Widzenie w ciemności"
	desc = "Przestraja korę wzrokową tak, że oczy widzą w ciemności jak u nocnych łowców."
	chance = 20
	source_types = list(/mob/living/simple_animal/hostile/spider, /mob/living/carbon/alien)

/datum/aq_neuromod/night_vision/on_gain(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_NIGHT_VISION, "aq_neuromod")
	var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
	if(eyes && !eyes.lighting_alpha)
		eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
	H.update_sight()

/datum/aq_neuromod/cold_resistance
	name = "Odporność na zimno"
	desc = "Uczy ciało oszczędzać ciepło tak jak kosmiczne karpie. Mróz nie szkodzi."
	chance = 15
	source_types = list(/mob/living/basic/carp)

/datum/aq_neuromod/cold_resistance/on_gain(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_RESISTCOLD, "aq_neuromod")

/datum/aq_neuromod/language
	abstract_type = /datum/aq_neuromod/language
	chance = 50
	var/datum/language/language

/datum/aq_neuromod/language/on_gain(mob/living/carbon/human/H)
	H.grant_language(language, TRUE, TRUE, LANGUAGE_MIND)

/datum/aq_neuromod/language/draconic
	name = "Język: draconic"
	desc = "Wgrywa w ośrodek mowy język jaszczuroludzi."
	language = /datum/language/draconic
	source_types = list(/datum/species/lizard)

/datum/aq_neuromod/language/moffic
	name = "Język: moffic"
	desc = "Wgrywa w ośrodek mowy język ćmoludzi."
	language = /datum/language/moffic
	source_types = list(/datum/species/moth)

/datum/aq_neuromod/language/sylvan
	name = "Język: sylvan"
	desc = "Wgrywa w ośrodek mowy język ludzi-roślin."
	language = /datum/language/sylvan
	source_types = list(/datum/species/pod)

/// typ -> wspólna instancja
GLOBAL_LIST_INIT(aq_neuromods, aq_init_neuromods())

/proc/aq_init_neuromods()
	. = list()
	for(var/datum/aq_neuromod/mod_type as anything in subtypesof(/datum/aq_neuromod))
		if(initial(mod_type.abstract_type) == mod_type)
			continue
		.[mod_type] = new mod_type

/// Neuromody, które da się odkryć z tej istoty
/proc/aq_neuromods_for(mob/living/target)
	. = list()
	for(var/mod_type in GLOB.aq_neuromods)
		var/datum/aq_neuromod/mod = GLOB.aq_neuromods[mod_type]
		for(var/source in mod.source_types)
			if(ispath(source, /datum/species))
				if(ishuman(target))
					var/mob/living/carbon/human/H = target
					if(istype(H.dna?.species, source))
						. += mod
						break
			else if(istype(target, source))
				. += mod
				break

/mob/living/carbon/human
	/// AQUILA - wstrzyknięte neuromody (typy)
	var/list/aq_neuromods

/mob/living/carbon/human/proc/aq_add_neuromod(mod_type)
	var/datum/aq_neuromod/mod = GLOB.aq_neuromods[mod_type]
	if(!mod || (mod_type in aq_neuromods))
		return FALSE
	LAZYADD(aq_neuromods, mod_type)
	mod.on_gain(src)
	return TRUE

/mob/living/carbon/human/Life()
	. = ..()
	if(!LAZYLEN(aq_neuromods) || QDELETED(src) || stat == DEAD)
		return
	for(var/mod_type in aq_neuromods)
		var/datum/aq_neuromod/mod = GLOB.aq_neuromods[mod_type]
		mod?.on_life(src, SSMOBS_DT)

// --- Psychoskop ---

/obj/item/aq_psychoscope
	name = "psychoskop"
	desc = "Skaner psychotroniczny. Odczytuje wzorce nerwowe żywych istot i odkrywa z nich neuromody, które zapisuje w powłokach neuromodów."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer"
	w_class = WEIGHT_CLASS_SMALL
	/// Zeskanowane osobniki (słabe referencje), żeby nie skanować w kółko tego samego
	var/list/scanned_refs = list()
	/// Odkryte neuromody (typy)
	var/list/unlocked = list()

/obj/item/aq_psychoscope/examine(mob/user)
	. = ..()
	if(length(unlocked))
		var/list/names = list()
		for(var/mod_type in unlocked)
			var/datum/aq_neuromod/mod = GLOB.aq_neuromods[mod_type]
			names += mod.name
		. += "<span class='notice'>Odkryte neuromody: [english_list(names, and_text = " i ")].</span>"
	else
		. += "<span class='notice'>Nie odkryto jeszcze żadnego neuromodu. Zeskanuj żywe istoty.</span>"
	. += "<span class='notice'>Przyłóż do pustej powłoki neuromodu, żeby zapisać w niej odkryty neuromod.</span>"

/obj/item/aq_psychoscope/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !isliving(target) || target == user)
		return
	INVOKE_ASYNC(src, PROC_REF(scan), target, user)

/obj/item/aq_psychoscope/proc/scan(mob/living/target, mob/user)
	if(target.stat == DEAD)
		to_chat(user, "<span class='warning'>Martwy mózg nie ma wzorców do odczytu.</span>")
		return FALSE
	user.visible_message("<span class='notice'>[user] skanuje [target] psychoskopem.</span>", "<span class='notice'>Skanujesz [target]...</span>")
	if(!do_after(user, 3 SECONDS, target = target))
		return FALSE
	return record_scan(target, user)

/// Zapis skanu. Zwraca odkryty neuromod albo null.
/obj/item/aq_psychoscope/proc/record_scan(mob/living/target, mob/user, force_unlock = FALSE)
	var/ref = REF(target)
	if(ref in scanned_refs)
		to_chat(user, "<span class='warning'>Ten osobnik jest już zeskanowany. Potrzeba innego.</span>")
		return
	scanned_refs += ref
	var/list/possible = aq_neuromods_for(target)
	if(!length(possible))
		to_chat(user, "<span class='notice'>Wzorce nerwowe [target] nie zawierają niczego nowego.</span>")
		return
	for(var/datum/aq_neuromod/mod as anything in possible)
		if(mod.type in unlocked)
			continue
		if(force_unlock || prob(mod.chance))
			unlocked += mod.type
			playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
			to_chat(user, "<span class='notice'>Odkryto neuromod: [mod.name]!</span>")
			return mod
	to_chat(user, "<span class='notice'>Skan zapisany, ale nie wystarczył do odkrycia neuromodu. Zeskanuj innego osobnika.</span>")

/obj/item/aq_neuromod_shell
	name = "pusta powłoka neuromodu"
	desc = "Iniektor z pustą matrycą nerwową. Psychoskop może w niej zapisać odkryty neuromod."
	icon = 'icons/obj/device.dmi'
	icon_state = "dnainjector0"
	w_class = WEIGHT_CLASS_TINY
	/// Zapisany neuromod (typ /datum/aq_neuromod)
	var/stored

/obj/item/aq_neuromod_shell/update_icon_state()
	icon_state = stored ? "dnainjector" : "dnainjector0"
	return ..()

/obj/item/aq_neuromod_shell/proc/load(mod_type)
	stored = mod_type
	var/datum/aq_neuromod/mod = GLOB.aq_neuromods[mod_type]
	name = "powłoka neuromodu ([mod.name])"
	desc = "Iniektor z neuromodem: [mod.desc]"
	update_icon()

/obj/item/aq_neuromod_shell/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/aq_psychoscope))
		return ..()
	var/obj/item/aq_psychoscope/scope = I
	if(stored)
		to_chat(user, "<span class='warning'>W tej powłoce już jest neuromod.</span>")
		return TRUE
	if(!length(scope.unlocked))
		to_chat(user, "<span class='warning'>Psychoskop nie ma jeszcze żadnego odkrytego neuromodu.</span>")
		return TRUE
	var/list/choices = list()
	for(var/mod_type in scope.unlocked)
		var/datum/aq_neuromod/mod = GLOB.aq_neuromods[mod_type]
		choices[mod.name] = mod_type
	var/picked = input(user, "Który neuromod zapisać?", "Zapis neuromodu") as null|anything in choices
	if(!picked || stored || !user.is_holding(I))
		return TRUE
	load(choices[picked])
	to_chat(user, "<span class='notice'>Zapisujesz neuromod w powłoce.</span>")
	return TRUE

/obj/item/aq_neuromod_shell/attack(mob/living/M, mob/living/user)
	if(!ishuman(M) || user.combat_mode)
		return ..()
	if(!stored)
		to_chat(user, "<span class='warning'>Powłoka jest pusta.</span>")
		return
	var/mob/living/carbon/human/H = M
	if(!H.aq_can_have_cyberpsychosis())
		to_chat(user, "<span class='warning'>Neuromod potrzebuje żywego, organicznego mózgu.</span>")
		return
	user.visible_message("<span class='warning'>[user] przykłada [src] do karku [H].</span>", "<span class='notice'>Przykładasz [src] do karku [H == user ? "swojego" : "[H]"].</span>")
	if(!do_mob(user, H, 3 SECONDS) || !stored)
		return
	inject(H, user)

/obj/item/aq_neuromod_shell/proc/inject(mob/living/carbon/human/H, mob/user)
	var/datum/aq_neuromod/mod = GLOB.aq_neuromods[stored]
	if(!H.aq_add_neuromod(stored))
		to_chat(user, "<span class='warning'>[H] ma już ten neuromod.</span>")
		return FALSE
	playsound(H, 'sound/items/hypospray.ogg', 40, TRUE)
	to_chat(H, "<span class='notice'>Po karku rozlewa się chłód, a w głowie coś się przestawia: [lowertext(mod.name)].</span>")
	H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 150)
	stored = null
	name = initial(name)
	desc = initial(desc)
	update_icon()
	return TRUE

/datum/design/aq_psychoscope
	name = "Psychoskop"
	desc = "Skaner wzorców nerwowych do odkrywania neuromodów."
	id = "aq_psychoscope"
	build_type = PROTOLATHE
	construction_time = 60
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2000, /datum/material/silver = 1000, /datum/material/uranium = 500)
	build_path = /obj/item/aq_psychoscope
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_neuromod_shell
	name = "Powłoka neuromodu"
	desc = "Pusty iniektor na neuromod."
	id = "aq_neuromod_shell"
	build_type = PROTOLATHE
	construction_time = 30
	materials = list(/datum/material/glass = 1000, /datum/material/silver = 300)
	build_path = /obj/item/aq_neuromod_shell
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/techweb_node/adv_biotech/New()
	. = ..()
	design_ids += list("aq_psychoscope", "aq_neuromod_shell")
