// Korona Groda (port BeeStation/BeeStation-Hornet#7202): mózg, który może opuścić ciało jako pająk-korona
// i przejąć ciało bez mózgu. Śmierć pająka jest ostateczna: zostaje martwa korona (mózg), którą da się już tylko włożyć chirurgicznie.

/obj/item/organ/brain/grod
	name = "korona Groda"
	desc = "Krucha, rozumna istota, która żyje w głowie Groda. Bez niej ciało Groda jest pustą skorupą."
	icon = GROD_ICON_CROWN_SPIDER
	icon_state = "crown_spider_dead"

/obj/item/organ/brain/grod/Insert(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		color = "#[H.dna?.features["mcolor"] || "3fae3f"]"
		H.update_body()

/obj/item/organ/brain/grod/transfer_identity(mob/living/L)
	. = ..()
	name = "korona Groda ([L.real_name])"

/obj/item/organ/brain/grod/Remove(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	. = ..()
	if(ishuman(C))
		C.update_body() // korona znika z głowy

// Akcja: opuść ciało

/datum/action/innate/grod_crownspider
	name = "Odłącz koronę"
	desc = "Opuść obecne ciało jako pająk-korona. Rób to tylko w ostateczności: pająk jest kruchy, a jego śmierć jest ostateczna."
	icon_icon = GROD_ICON_ACTIONS
	button_icon_state = "crownspider"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/grod_crownspider/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !isgrod(H))
		return
	if(!istype(H.getorganslot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/grod))
		to_chat(H, "<span class='warning'>Nie masz korony!</span>")
		return
	if(H.incapacitated() || H.IsStun() || H.IsSleeping() || H.IsParalyzed() || H.restrained())
		to_chat(H, "<span class='warning'>Nie możesz teraz opuścić ciała.</span>")
		return
	if(alert(H, "Na pewno chcesz opuścić to ciało? Korona będzie krucha i wolna, a jej śmierć jest ostateczna.", "Odłącz koronę", "Tak", "Nie") != "Tak")
		return
	if(QDELETED(H) || H.incapacitated() || !istype(H.getorganslot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/grod))
		return
	grod_leave_body(H)

/// Korona wychodzi z ciała jako pająk, a gracz razem z nią. Ciało zostaje bez mózgu.
/proc/grod_leave_body(mob/living/carbon/human/H)
	var/obj/item/organ/brain/grod/crown = H.getorganslot(ORGAN_SLOT_BRAIN)
	var/datum/mind/mind = H.mind
	var/turf/T = get_turf(H)
	crown.Remove(H, TRUE, TRUE)
	var/mob/living/simple_animal/hostile/grod_crown/spider = new(T)
	spider.name = "korona ([H.real_name])"
	spider.real_name = H.real_name
	spider.color = "#[H.dna?.features["mcolor"] || "3fae3f"]"
	crown.forceMove(spider)
	spider.crown = crown
	spider.health = max(1, round(spider.maxHealth * (1 - crown.damage / crown.maxHealth)))
	H.visible_message("<span class='warning'>Z głowy [H] wypełza korona na cienkich nóżkach!</span>")
	if(mind)
		mind.transfer_to(spider)
		to_chat(spider, "<span class='warning'>Twoja świadomość wraca do korony i opuszczasz ciało!</span>")
	H.death()
	return spider

// Pająk-korona

/mob/living/simple_animal/hostile/grod_crown
	name = "korona Groda"
	desc = "Wygląda jak korona Groda... na cienkich nóżkach."
	icon = GROD_ICON_CROWN_SPIDER
	icon_state = "crown_spider"
	icon_living = "crown_spider"
	icon_dead = "crown_spider_dead"
	gender = NEUTER
	health = GROD_CROWNSPIDER_HEALTH
	maxHealth = GROD_CROWNSPIDER_HEALTH
	melee_damage = 0
	attacktext = "szczypie"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("piszczy")
	pass_flags = PASSMOB | PASSTABLE
	mob_size = MOB_SIZE_TINY
	speed = 3
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_lh = GROD_ICON_CROWN_SPIDER
	held_rh = GROD_ICON_CROWN_SPIDER
	head_icon = 'aquila/icons/mob/species/grod/crown_spider_worn.dmi'
	held_state = "crown_spider"
	initial_language_holder = /datum/language_holder/grod_crown
	AIStatus = AI_OFF
	/// Mózg Groda, który niesie ten pająk
	var/obj/item/organ/brain/grod/crown

/mob/living/simple_animal/hostile/grod_crown/Destroy()
	QDEL_NULL(crown)
	return ..()

/mob/living/simple_animal/hostile/grod_crown/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(ishuman(A) && try_infest(A))
		return
	return ..()

/mob/living/simple_animal/hostile/grod_crown/MouseDrop(atom/over)
	. = ..()
	if(ishuman(over) && Adjacent(over))
		try_infest(over)

/// Wejście w ciało bez mózgu. Ciało innej rasy przemienia się w Groda.
/mob/living/simple_animal/hostile/grod_crown/proc/try_infest(mob/living/carbon/human/target)
	if(!crown || stat != CONSCIOUS)
		return FALSE
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		to_chat(src, "<span class='userdanger'>Obca obecność odpycha nas od tego ciała. Poszukajmy innego.</span>")
		return TRUE
	if(!target.get_bodypart(BODY_ZONE_HEAD))
		to_chat(src, "<span class='warning'>To ciało nie ma głowy.</span>")
		return TRUE
	visible_message("<span class='danger'>[src] zaczyna wgryzać się w głowę [target]!</span>", "<span class='notice'>Zaczynasz wgryzać się w głowę [target].</span>")
	if(!do_after(src, 5 SECONDS, target = target) || QDELETED(crown) || target.getorganslot(ORGAN_SLOT_BRAIN))
		return TRUE
	infest(target)
	return TRUE

/mob/living/simple_animal/hostile/grod_crown/proc/infest(mob/living/carbon/human/target)
	var/obj/item/organ/brain/grod/brain = crown
	crown = null
	// Przejęcie ciała boli koronę: co najmniej GROD_CROWN_INFEST_DAMAGE, więcej przy poranionym pająku, ale nie do śmierci mózgu
	var/damage = max(GROD_CROWN_INFEST_DAMAGE, (maxHealth - health) * 4)
	damage = min(damage, max(0, brain.maxHealth - 1 - brain.damage))
	if(!isgrod(target))
		target.set_species(/datum/species/grod)
		var/obj/item/organ/brain/stray = target.getorganslot(ORGAN_SLOT_BRAIN) // set_species daje nowy mózg rasy
		if(stray)
			stray.Remove(target, TRUE, TRUE)
			qdel(stray)
	brain.Insert(target, TRUE)
	brain.applyOrganDamage(damage)
	if(isgrod(target) && color)
		target.dna.features["mcolor"] = copytext(color, 2)
		target.update_body()
	target.visible_message("<span class='danger'>[src] wgryza się w głowę [target] i zapuszcza w niej korzenie!</span>")
	if(mind)
		mind.transfer_to(target)
	if(target.stat == DEAD)
		target.revive(full_heal = FALSE)
	qdel(src)

/mob/living/simple_animal/hostile/grod_crown/death(gibbed)
	if(crown)
		crown.forceMove(drop_location())
		crown.applyOrganDamage(crown.maxHealth) // śmierć w tej postaci jest ostateczna
		crown = null
	. = ..()
	if(!QDELETED(src))
		qdel(src)

// Język Poh'lan: szczęk i pomruki, dla innych niezrozumiałe

/datum/language/pohlan
	name = "Poh'lan"
	desc = "Język Grodów, złożony ze szczęku żuwaczek i pomruków. Dla obcych zupełnie niezrozumiały."
	speech_verb = "pomrukuje"
	ask_verb = "pomrukuje pytająco"
	exclaim_verb = "oznajmia"
	key = "c"
	icon = 'aquila/icons/mob/species/grod/language.dmi'
	icon_state = "pohlan"
	sentence_chance = 8
	space_chance = 10
	syllables = list(
		"ży", "zy", "zi", "rzy", "szy", "ów", "rze", "że", "ść", "rzsz", "sz", "aż", "cz",
		"czy", "cze", "ci", "cin", "dze", "dzi", "drzy", "żdż", "dzy", "bź", "ić", "ąż", "ęż",
	)

/datum/language_holder/grod
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM), /datum/language/pohlan = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM), /datum/language/pohlan = list(LANGUAGE_ATOM))

/// Sama korona rozumie wspólny, ale mówi tylko w Poh'lan
/datum/language_holder/grod_crown
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM), /datum/language/pohlan = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/pohlan = list(LANGUAGE_ATOM))
