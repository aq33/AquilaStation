// AQUILA - health analyzer window, port of PowerfulBacon-2/AuriStation#15 (HealthAnalyzer.tsx) on our damage model.
// The body outline shows how alive the patient is, injuries are grouped per limb, charts show the pulse, oxygen,
// blood and total damage. Auri's pain, consciousness and injury trees don't exist here, so the data comes from
// plain damage, our wounds, bleeding, organs, traumas and diseases.
// Health mode on carbons opens the window; chemical mode, simple mobs and clumsy users keep the old chat scan.
// The button in the top right corner of the window (or alt-click) switches the analyzer to the old text mode and back.

/obj/item/healthanalyzer
	/// The mob shown in the window
	var/datum/weakref/ui_target
	/// Old chat scan instead of the window
	var/text_mode = FALSE

/obj/item/healthanalyzer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt+klik przełącza między oknem a trybem tekstowym (teraz: [text_mode ? "tekst" : "okno"]).</span>"

/obj/item/healthanalyzer/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return ..()
	toggle_text_mode(user)

/obj/item/healthanalyzer/proc/toggle_text_mode(mob/user)
	text_mode = !text_mode
	to_chat(user, "<span class='notice'>Przełączasz [src] na [text_mode ? "tryb tekstowy" : "okno"].</span>")
	if(text_mode)
		SStgui.close_uis(src)

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)
	if(text_mode || scanmode != 0 || !iscarbon(M) || HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB))
		return ..()
	flick("[icon_state]-scan", src)
	playsound(src, 'sound/effects/fastbeep.ogg', 10)
	user.visible_message("<span class='notice'>[user] analizuje funkcje życiowe [M].</span>", \
		"<span class='notice'>Analizujesz funkcje życiowe [M].</span>")
	ui_target = WEAKREF(M)
	ui_interact(user)
	add_fingerprint(user)

/obj/item/healthanalyzer/ui_state(mob/user)
	return new /datum/ui_state/hands_state/health_analyzer(src)

/obj/item/healthanalyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HealthAnalyzer", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/healthanalyzer/ui_data(mob/user)
	var/mob/living/carbon/target = ui_target?.resolve()
	if(!istype(target))
		return list("target" = null)
	return get_health_analyzer_data(user, target, advanced)

/obj/item/healthanalyzer/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/target = ui_target?.resolve()
	if(action == "print_chat" && istype(target))
		healthscan(usr, target, advanced = advanced)
		return TRUE
	if(action == "text_mode")
		toggle_text_mode(usr)
		if(istype(target))
			healthscan(usr, target, advanced = advanced)
		return TRUE

/proc/aq_injury(name, heal_text, damage = null, severity = 2)
	var/list/injury = list("name" = name, "heal_text" = heal_text, "severity" = severity)
	if(!isnull(damage))
		injury["damage"] = damage
	return injury

/proc/get_health_analyzer_data(mob/user, mob/living/carbon/target, advanced)
	var/list/data = list()
	var/fake_dead = HAS_TRAIT(target, TRAIT_FAKEDEATH)
	var/dead = target.stat == DEAD || fake_dead
	data["target"] = target.name
	data["is_dead"] = dead
	data["consciousness"] = dead ? -1 : clamp((target.health - HEALTH_THRESHOLD_DEAD) / (target.maxHealth - HEALTH_THRESHOLD_DEAD), 0, 1)
	var/total_damage = target.getBruteLoss() + target.getFireLoss() + target.getToxLoss() + target.getOxyLoss() + target.getCloneLoss()
	data["damage"] = clamp(total_damage / target.maxHealth * 100, 0, 200)
	// Jak w trybie tekstowym: krwawe robaki ukrywają ubytek krwi, a Maskarada wampira pokazuje pełny poziom
	var/masquerade = HAS_TRAIT(target, TRAIT_MASQUERADE)
	var/shown_blood = masquerade ? BLOOD_VOLUME_NORMAL : target.get_shown_blood_volume()
	var/obj/item/organ/heart/heart = target.getorganslot(ORGAN_SLOT_HEART)
	var/circulation = 0
	if(!dead && heart?.beating && !(heart.organ_flags & ORGAN_FAILING))
		circulation = clamp(shown_blood / BLOOD_VOLUME_NORMAL, 0, 1.1) * (1 - 0.5 * heart.damage / heart.maxHealth)
	if(!dead && HAS_TRAIT(target, TRAIT_NO_BLOOD))
		circulation = 1
	data["circulation"] = circulation
	data["oxygenation"] = dead ? 0 : clamp(1 - target.getOxyLoss() / 100, 0, 1)
	data["blood_volume"] = shown_blood
	data["blood_type"] = health_analyzer_blood_type(target)
	data["blood_compatible"] = target.dna?.blood_type ? jointext(get_safe_blood(data["blood_type"]), ", ") : null
	data["body_temperature"] = "[round(target.bodytemperature - T0C, 0.1)] °C ([round(target.bodytemperature * 1.8 - 459.67, 0.1)] °F)"
	data["species"] = null
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		data["species"] = "[target.dna.species.name][human_target.health_analyzer_is_mutant() ? " (mutant)" : ""]"
	if(target.getStaminaLoss())
		data["stamina"] = advanced ? "[round(target.stamina?.loss_as_percent)]%" : "wyczerpany"
	data["quirks"] = length(target.roundstart_quirks) ? target.get_trait_string() : null
	data["brain_activity"] = advanced ? "[(200 - target.getOrganLoss(ORGAN_SLOT_BRAIN)) / 2]%" : null
	data["genetic_stability"] = (advanced && target.has_dna()) ? "[target.dna.stability]%" : null
	data["time_of_death"] = null
	if(target.tod && (target.stat == DEAD || (fake_dead && !advanced)))
		data["time_of_death"] = "[target.tod], [DisplayTimeText(round(world.time - target.timeofdeath))] temu"
	data["senses"] = advanced ? health_analyzer_senses(target) : null
	var/list/implants = list()
	for(var/obj/item/organ/cyberimp/implant in target.internal_organs)
		if(implant.status == ORGAN_ROBOTIC && !implant.syndicate_implant)
			implants += capitalize(implant.name)
	data["implants"] = implants

	var/list/reagents = list()
	for(var/datum/reagent/reagent as anything in target.reagents?.reagent_list)
		reagents += list(list("name" = reagent.name, "colour" = reagent.color, "volume" = round(reagent.volume, 0.1)))
	data["reagents"] = reagents
	data["stomach"] = target.stomach_ui_data() // port BeeStation/BeeStation-Hornet#14340: połknięte czeka w żołądku (stomach_contents.dm)
	data["surgeries"] = advanced ? target.get_surgery_progress() : null

	// Whole body
	var/list/body = list()
	if(dead)
		if(target.is_defib_possible())
			body += list(aq_injury("Zgon", "Defibrylacja"))
		else
			body += list(aq_injury("Zgon, nie do defibrylacji", "Napraw serce i mózg, potem defibrylacja; albo klonowanie"))
	else if(heart && !heart.beating)
		body += list(aq_injury("Zatrzymanie akcji serca", "Defibrylacja"))
	if(target.is_bleeding())
		body += list(aq_injury("Krwawienie", "Bandaż, uciskanie, kauteryzacja", target.get_bleed_rate_string()))
	else if(target.is_bandaged())
		body += list(aq_injury("Opatrzone krwawienie", "Goi się samo", null, 1))
	if(shown_blood < BLOOD_VOLUME_SAFE && !HAS_TRAIT(target, TRAIT_NO_BLOOD))
		body += list(aq_injury("Niski poziom krwi", "Transfuzja, sól fizjologiczna, żelazo", round(shown_blood / BLOOD_VOLUME_NORMAL * 100)))
	if(target.getToxLoss())
		body += list(aq_injury("Toksyny", "Węgiel aktywny, antytoksyny", round(target.getToxLoss(), 0.1)))
	if(target.getOxyLoss())
		body += list(aq_injury("Niedotlenienie", "Tlen, salbutamol, deksalina", round(target.getOxyLoss(), 0.1)))
	if(target.getCloneLoss())
		body += list(aq_injury("Uszkodzenia komórkowe", "Kriokomora, syntetyczne ciało", round(target.getCloneLoss(), 0.1)))
	// Promieniowanie z Bee#13442: natężenie (%) z komponentu, uszkodzenia genetyczne z konsoli DNA
	var/datum/component/irradiated/irradiated_component = target.GetComponent(/datum/component/irradiated)
	if(irradiated_component)
		var/irradiation_name = advanced ? "Napromieniowanie (od [DisplayTimeText(world.time - irradiated_component.beginning_of_irradiation, 5)])" : "Napromieniowanie"
		body += list(aq_injury(irradiation_name, "Kwas pentetowy, jodek potasu", advanced ? round(irradiated_component.intensity) : null))
	var/datum/status_effect/genetic_damage/genetic_damage = target.has_status_effect(/datum/status_effect/genetic_damage)
	if(genetic_damage)
		body += list(aq_injury(advanced ? "Uszkodzenia genetyczne" : genetic_damage.get_scan_text(FALSE), "Nieuleczalne zwykłymi metodami, z czasem mijają", advanced ? round(genetic_damage.total_damage / genetic_damage.minimum_before_tox_damage * 100, 0.1) : null, 1))
	if(HAS_TRAIT(target, TRAIT_HUSK))
		body += list(aq_injury("Wysuszone ciało (husk)", "Syntetyczne ciało, leczenie oparzeń"))
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.bodytemperature >= BODYTEMP_HEAT_DAMAGE_LIMIT)
			body += list(aq_injury("Przegrzanie", "Chłodzenie"))
		else if(human_target.bodytemperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
			body += list(aq_injury("Wychłodzenie", "Ogrzanie"))
	if(!target.getorganslot(ORGAN_SLOT_BRAIN))
		body += list(aq_injury("Brak mózgu", "Przeszczep mózgu"))
	if(advanced && target.has_horror_inside())
		body += list(aq_injury("Pasożyt w okolicy czaszki", "Operacja manipulacji organami głowy"))
	if(advanced && target.hallucinating())
		body += list(aq_injury("Halucynacje", "Haloperidol, odpoczynek"))
	var/obj/item/organ/liver/liver = target.getorganslot(ORGAN_SLOT_LIVER)
	if(istype(liver) && target.cirrhosis_scan_text())
		body += list(aq_injury("Marskość wątroby", "Abstynencja i przeszczep wątroby", "[round(liver.cirrhosis)]%"))
	for(var/datum/brain_trauma/trauma as anything in target.get_traumas())
		var/cure = "Nieznane"
		switch(trauma.resilience)
			if(TRAUMA_RESILIENCE_BASIC)
				cure = "Mannitol, odpoczynek"
			if(TRAUMA_RESILIENCE_SURGERY)
				cure = "Operacja mózgu"
			if(TRAUMA_RESILIENCE_LOBOTOMY)
				cure = "Lobotomia"
		body += list(aq_injury(capitalize(trauma.scan_desc), cure))
	for(var/datum/disease/disease as anything in target.diseases)
		if(disease.visibility_flags & HIDDEN_SCANNER)
			continue
		body += list(aq_injury("[disease.name] ([disease.form], [disease.spread_text])", disease.cure_text || "Nieznane", "[disease.stage]/[disease.max_stages]"))

	var/list/injuries = list("body" = body)
	// Rany pokazane na sylwetce: strefa -> rany (nazwa, ciężkość 1-3, czy opatrzona)
	var/list/wounds = list()
	for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/list/part = list()
		var/obj/item/bodypart/limb = target.get_bodypart(zone)
		if(!limb)
			part += list(aq_injury("Brak kończyny", "Przyszycie kończyny albo proteza"))
		else
			if(limb.brute_dam)
				part += list(aq_injury("Obrażenia fizyczne", "Nici, bikarydyna, proszek hemostatyczny", round(limb.brute_dam, 0.1)))
			if(limb.burn_dam)
				part += list(aq_injury("Oparzenia", "Siatka, kelotan, sulfadiazyna srebra", round(limb.burn_dam, 0.1)))
			for(var/datum/wound/wound as anything in limb.wounds)
				part += list(aq_injury(wound.name, wound.treat_text, null, wound.treated ? 1 : 2))
				LAZYADD(wounds[zone], list(list("name" = wound.name, "type" = wound.wound_type, "severity" = wound.severity, "treated" = wound.treated)))
			for(var/obj/item/embedded as anything in limb.embedded_objects)
				part += list(aq_injury("Tkwi w ciele: [embedded.name]", "Wyciągnij ręką albo hemostatem"))
			for(var/obj/item/bullet_fragment/fragment in limb)
				part += list(aq_injury("Pocisk w ciele", "Operacja usuwania ciał obcych"))
		for(var/obj/item/organ/organ as anything in target.internal_organs)
			if(check_zone(organ.zone) != zone || !organ.damage) // oczy, usta i pachwina należą do głowy i klatki
				continue
			var/failing = organ.organ_flags & ORGAN_FAILING
			part += list(aq_injury("[capitalize(organ.name)] [failing ? "niewydolny" : "uszkodzony"]", "Operacja, leki na narząd", advanced ? round(organ.damage) : null, failing ? 2 : 1))
		injuries[zone] = part
	data["injuries"] = injuries
	data["wounds"] = wounds
	return data

/// Grupa krwi jak w trybie tekstowym: rasy z inną substancją zamiast krwi pokazują jej nazwę
/proc/health_analyzer_blood_type(mob/living/carbon/target)
	var/blood_id = target.get_blood_id()
	if(!blood_id || !target.dna)
		return null
	if(blood_id == /datum/reagent/blood)
		return target.dna.blood_type
	var/datum/reagent/substance = GLOB.chemical_reagents_list[blood_id]
	return substance ? substance.name : "[blood_id]"

/// Stan oczu i uszu (tryb zaawansowany), te same progi co w trybie tekstowym
/proc/health_analyzer_senses(mob/living/carbon/target)
	var/list/senses = list()
	var/list/ear_problems = list()
	var/obj/item/organ/ears/ears = target.getorganslot(ORGAN_SLOT_EARS)
	if(!istype(ears))
		ear_problems += "brak uszu"
	else if(HAS_TRAIT_FROM(target, TRAIT_DEAF, GENETIC_MUTATION))
		ear_problems += "genetycznie głuchy"
	else if(HAS_TRAIT(target, TRAIT_DEAF))
		ear_problems += "głuchy"
	else
		if(ears.damage)
			ear_problems += "[ears.damage > ears.maxHealth ? "trwałe" : "tymczasowe"] uszkodzenie słuchu"
		if(ears.deaf)
			ear_problems += "[ears.damage > ears.maxHealth ? "trwale" : "tymczasowo"] głuchy"
	senses += list(list("name" = "Uszy", "text" = length(ear_problems) ? jointext(ear_problems, ", ") : "zdrowe", "healthy" = !length(ear_problems)))
	var/list/eye_problems = list()
	var/obj/item/organ/eyes/eyes = target.getorganslot(ORGAN_SLOT_EYES)
	if(!istype(eyes))
		eye_problems += "brak oczu"
	else
		if(HAS_TRAIT(target, TRAIT_BLIND))
			eye_problems += "niewidomy"
		if(HAS_TRAIT(target, TRAIT_NEARSIGHT))
			eye_problems += "krótkowzroczny"
		if(eyes.damage > 30)
			eye_problems += "poważne uszkodzenie"
		else if(eyes.damage > 20)
			eye_problems += "znaczne uszkodzenie"
		else if(eyes.damage)
			eye_problems += "drobne uszkodzenie"
	senses += list(list("name" = "Oczy", "text" = length(eye_problems) ? jointext(eye_problems, ", ") : "zdrowe", "healthy" = !length(eye_problems)))
	return senses

/// Czy gatunek ma zmienione narządy albo hulka, jak „(mutant)” w trybie tekstowym
/mob/living/carbon/human/proc/health_analyzer_is_mutant()
	var/datum/species/S = dna.species
	if(dna.check_mutation(HULK))
		return TRUE
	return S.mutantlungs != initial(S.mutantlungs) || S.mutant_brain != initial(S.mutant_brain) 		|| S.mutant_heart != initial(S.mutant_heart) || S.mutanteyes != initial(S.mutanteyes) 		|| S.mutantears != initial(S.mutantears) || S.mutanthands != initial(S.mutanthands) 		|| S.mutanttongue != initial(S.mutanttongue) || S.mutanttail != initial(S.mutanttail) 		|| S.mutantliver != initial(S.mutantliver) || S.mutantstomach != initial(S.mutantstomach)

/// The window keeps updating only next to the patient and closes when they are far away (AuriStation#15)
/datum/ui_state/hands_state/health_analyzer
	var/obj/item/healthanalyzer/source

/datum/ui_state/hands_state/health_analyzer/New(obj/item/healthanalyzer/source)
	. = ..()
	src.source = source

/datum/ui_state/hands_state/health_analyzer/can_use_topic(src_object, mob/user)
	. = ..()
	if(. <= UI_CLOSE)
		return UI_CLOSE
	var/mob/living/target = source.ui_target?.resolve()
	if(isnull(target) || get_dist(user, target) > 3)
		return UI_CLOSE
	if(!user.Adjacent(target))
		. = min(., UI_DISABLED)
