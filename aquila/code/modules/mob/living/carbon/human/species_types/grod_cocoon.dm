// Kokon Groda (BeeStation/BeeStation-Hornet#7202): korona w ciele innej rasy przerabia je chorobą na Groda,
// a na koniec gospodarz zasypia w kokonie. Koronę da się też posadzić w tacy hydroponicznej i wyhodować z niej nowe ciało.

// Choroba przemiany

/datum/disease/transformation/grod
	name = "Przemiana w Groda"
	agent = "Mikroby korony"
	desc = "Korona Groda przerabia ciało gospodarza na ciało Groda. Nikt nie wie, po co to robi."
	cure_text = "Sól kuchenna"
	danger = DISEASE_MINOR
	visibility_flags = NONE
	stage_prob = 35
	cures = list(/datum/reagent/consumable/sodiumchloride)
	cure_chance = 10
	viable_mobtypes = list(/mob/living/carbon/human)
	infectable_biotypes = list(MOB_ORGANIC, MOB_INORGANIC, MOB_UNDEAD)
	stage1 = list("Twoje stawy miękną.")
	stage2 = list("Twoja skóra mięknie.")
	stage3 = list("Czujesz się ociężale.")
	stage4 = list("Chce ci się spać.")
	stage5 = list("Musisz się przespać...")
	new_form = /mob/living/carbon/human/species/grod

/// Zamiast nowego moba jak w zwykłej przemianie: to samo ciało zmienia rasę, zachowuje koronę i zasypia w kokonie
/datum/disease/transformation/grod/do_disease_transformation(mob/living/affected_mob)
	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H) || H.stat == DEAD || H.notransform || istype(H.loc, /obj/structure/grod_cocoon))
		return
	if(length(stage5))
		to_chat(H, "<span class='userdanger'>[pick(stage5)]</span>")
	grod_cocoon_transform(H)
	cure(FALSE)

/// Przemienia człowieka w Groda w kokonie. Korona (albo inny mózg) zostaje w ciele.
/proc/grod_cocoon_transform(mob/living/carbon/human/H)
	var/obj/item/organ/brain/brain = H.getorganslot(ORGAN_SLOT_BRAIN)
	var/crown_color = istype(brain, /obj/item/organ/brain/grod) ? brain.color : null
	brain?.Remove(H, TRUE, TRUE)
	H.drop_all_held_items()
	H.set_species(/datum/species/grod)
	if(brain)
		var/obj/item/organ/brain/stray = H.getorganslot(ORGAN_SLOT_BRAIN) // set_species daje nowy mózg rasy
		if(stray)
			stray.Remove(H, TRUE, TRUE)
			qdel(stray)
		brain.Insert(H, TRUE, TRUE)
	if(crown_color)
		H.dna.features["mcolor"] = copytext(crown_color, 2)
		H.update_body()
	var/obj/structure/grod_cocoon/cocoon = new(get_turf(H))
	cocoon.color = "#[H.dna.features["mcolor"] || "3fae3f"]"
	H.visible_message("<span class='warning'>[H] zwija się w miękki kokon!</span>")
	H.forceMove(cocoon)
	return cocoon

// Kokon

/obj/structure/grod_cocoon
	name = "kokon Groda"
	desc = "Tajemnicze zjawisko, rzadko obserwowane. W środku coś się rusza."
	icon = GROD_ICON_EXTRAS
	icon_state = "cocoon"
	density = TRUE
	anchored = TRUE
	max_integrity = 50
	/// Korona posadzona w tacy (przedmiot albo pająk-korona z graczem): po wzroście dostaje nowe ciało
	var/atom/movable/seed
	/// Timer wzrostu nowego ciała
	var/grow_timer

/obj/structure/grod_cocoon/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(seed)
		Shake(2, 2, 1 SECONDS)
		to_chat(user, "<span class='notice'>W kokonie wciąż rośnie nowe ciało. Lepiej poczekać.</span>")
		return TRUE
	if(prob(GROD_COCOON_RIP_CHANCE))
		visible_message("<span class='warning'>[user] rozrywa [src]!</span>", "<span class='warning'>Rozrywasz [src]!</span>")
		qdel(src)
	else
		Shake(5, 5, 2 SECONDS)
		visible_message("<span class='warning'>[user] potrząsa [src].</span>", "<span class='warning'>Potrząsasz [src].</span>")
	return TRUE

/// Grod w kokonie może się z niego wygryźć od środka
/obj/structure/grod_cocoon/container_resist(mob/living/user)
	to_chat(user, "<span class='notice'>Zaczynasz przegryzać się przez ścianki kokonu.</span>")
	Shake(2, 2, 1 SECONDS)
	if(!do_after(user, GROD_COCOON_RESIST_TIME, target = src) || user.loc != src)
		return
	visible_message("<span class='warning'>[user] przegryza się przez [src]!</span>")
	qdel(src)

/obj/structure/grod_cocoon/Destroy()
	deltimer(grow_timer)
	seed = null
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM as anything in contents)
		AM.forceMove(T)
		if(isliving(AM))
			visible_message("<span class='warning'>Z [src] wyłania się [AM]!</span>")
	return ..()

/// Posadzona korona: po GROD_COCOON_GROW_TIME z kokonu wychodzi nowy Grod
/obj/structure/grod_cocoon/proc/start_growth(atom/movable/new_seed)
	seed = new_seed
	seed.forceMove(src)
	name = "strąk Groda"
	desc = "Roślina wyrastająca z posadzonej korony. W środku rośnie nowe ciało Groda."
	color = null
	set_growth_stage(1)
	addtimer(CALLBACK(src, PROC_REF(set_growth_stage), 2), GROD_COCOON_GROW_TIME / 3)
	addtimer(CALLBACK(src, PROC_REF(set_growth_stage), 3), GROD_COCOON_GROW_TIME * 2 / 3)
	grow_timer = addtimer(CALLBACK(src, PROC_REF(finish_growth)), GROD_COCOON_GROW_TIME, TIMER_STOPPABLE)

/// Etapy wzrostu strąka w tacy (growth1-3 z Dysku twórczyni)
/obj/structure/grod_cocoon/proc/set_growth_stage(stage)
	if(QDELETED(src) || !seed)
		return
	icon_state = "growth[stage]"

/obj/structure/grod_cocoon/proc/finish_growth()
	grow_timer = null
	var/obj/item/organ/brain/grod/crown
	var/datum/mind/mind
	var/new_name
	if(istype(seed, /mob/living/simple_animal/hostile/grod_crown))
		var/mob/living/simple_animal/hostile/grod_crown/spider = seed
		crown = spider.crown
		spider.crown = null
		mind = spider.mind
		new_name = spider.real_name
	else if(istype(seed, /obj/item/organ/brain/grod))
		crown = seed
		new_name = crown.brainmob?.real_name
	if(!crown)
		qdel(src)
		return
	var/atom/movable/old_seed = seed
	seed = null
	var/mob/living/carbon/human/body = new(src)
	body.set_species(/datum/species/grod)
	var/obj/item/organ/brain/stray = body.getorganslot(ORGAN_SLOT_BRAIN)
	if(stray)
		stray.Remove(body, TRUE, TRUE)
		qdel(stray)
	if(crown.color)
		body.dna.features["mcolor"] = copytext(crown.color, 2)
	if(new_name)
		body.fully_replace_character_name(null, new_name)
	crown.Insert(body, TRUE) // mózg z graczem (brainmob) sam przenosi go do ciała
	if(mind)
		mind.transfer_to(body)
	if(old_seed != crown)
		qdel(old_seed)
	body.update_body()
	to_chat(body, "<span class='notice'><b>Jasny błysk!</b><br><i>Czujesz się jak nowa istota.</i></span>")
	body.flash_act()
	log_game("[key_name(body)] wyrósł jako nowy Grod z kokonu w [AREACOORD(src)].")
	qdel(src)

// Sadzenie korony w tacy hydroponicznej

/// Czy w tej tacy można posadzić koronę: potrzebne podłoże, żadnej rośliny i żadnego kokonu
/obj/item/plant_tray/proc/grod_can_plant(mob/user)
	if(!tray_component?.substrate)
		to_chat(user, "<span class='warning'>W [src] nie ma podłoża.</span>")
		return FALSE
	if(locate(/obj/structure/grod_cocoon) in get_turf(src))
		to_chat(user, "<span class='warning'>Tu już rośnie kokon.</span>")
		return FALSE
	for(var/atom/movable/AM as anything in contents)
		if(AM.GetComponent(/datum/component/plant))
			to_chat(user, "<span class='warning'>W [src] coś już rośnie.</span>")
			return FALSE
	return TRUE

/obj/item/plant_tray/proc/grod_plant(atom/movable/new_seed, mob/user)
	var/obj/structure/grod_cocoon/cocoon = new(get_turf(src))
	cocoon.pixel_x = pixel_x + plant_offset[1]
	cocoon.pixel_y = pixel_y + plant_offset[2]
	cocoon.start_growth(new_seed)
	visible_message("<span class='notice'>Wokół korony w [src] zaczyna rosnąć kokon.</span>")
	log_game("[key_name(user)] posadził koronę Groda w [src] w [AREACOORD(src)].")
	return cocoon

/obj/item/plant_tray/attackby(obj/item/attacking_item, mob/living/user, params)
	if(user.combat_mode)
		return ..()
	if(istype(attacking_item, /obj/item/organ/brain/grod))
		var/obj/item/organ/brain/grod/crown = attacking_item
		if(crown.organ_flags & ORGAN_FAILING)
			to_chat(user, "<span class='warning'>Ta korona jest martwa, nic z niej nie wyrośnie.</span>")
			return TRUE
		if(!crown.brainmob)
			to_chat(user, "<span class='warning'>Ta korona jest pusta, nic z niej nie wyrośnie.</span>")
			return TRUE
		if(grod_can_plant(user) && user.temporarilyRemoveItemFromInventory(crown))
			grod_plant(crown, user)
		return TRUE
	if(istype(attacking_item, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/holder = attacking_item
		var/mob/living/simple_animal/hostile/grod_crown/spider = holder.held_mob
		if(istype(spider))
			if(grod_can_plant(user))
				holder.grod_unwrap()
				grod_plant(spider, user)
			return TRUE
	return ..()

/// Pająk-korona sam wchodzi do tacy z podłożem
/mob/living/simple_animal/hostile/grod_crown/proc/try_plant(obj/item/plant_tray/tray)
	if(!crown || stat != CONSCIOUS || !tray.grod_can_plant(src))
		return
	visible_message("<span class='notice'>[src] zaczyna zakopywać się w [tray].</span>", "<span class='notice'>Zaczynasz zakopywać się w [tray].</span>")
	if(!do_after(src, 5 SECONDS, target = tray) || !crown || !tray.grod_can_plant(src))
		return
	tray.grod_plant(src, src)
	to_chat(src, "<span class='notice'>Zapuszczasz korzenie. Za jakiś czas wyrośnie z ciebie nowe ciało.</span>")

/// Wyjmuje pająka-koronę z rąk bez komunikatu o wyrwaniu się i usuwa uchwyt
/obj/item/clothing/head/mob_holder/proc/grod_unwrap()
	var/mob/living/L = held_mob
	held_mob = null
	L.forceMove(get_turf(src))
	L.reset_perspective()
	qdel(src)

/// Pająka trzymanego w rękach da się włożyć do głowy ciała bez mózgu
/obj/item/clothing/head/mob_holder/attack(mob/living/M, mob/living/user, params)
	var/mob/living/simple_animal/hostile/grod_crown/spider = held_mob
	if(!istype(spider) || !ishuman(M) || user.combat_mode)
		return ..()
	var/mob/living/carbon/human/target = M
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		to_chat(user, "<span class='warning'>W [target] już jest mózg!</span>")
		return
	if(!target.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, "<span class='warning'>To ciało nie ma głowy.</span>")
		return
	to_chat(user, "<span class='notice'>Zaczynasz wkładać [spider] do głowy [target]...</span>")
	if(!do_after(user, 5 SECONDS, target = target) || held_mob != spider || target.getorganslot(ORGAN_SLOT_BRAIN))
		return
	grod_unwrap()
	spider.infest(target)

// Toksyna korony

/datum/reagent/crowntoxin
	name = "Toksyna korony"
	description = "Zaawansowana toksyna przemieniająca, wytwarzana przez korony Grodów."
	color = "#ddff00"
	taste_description = "królewskości"
	metabolization_rate = 5

/datum/reagent/crowntoxin/on_mob_metabolize(mob/living/L)
	. = ..()
	if(ishuman(L) && !isgrod(L))
		L.ForceContractDisease(new /datum/disease/transformation/grod(), FALSE, TRUE)

/obj/item/reagent_containers/glass/bottle/grod
	name = "butelka toksyny korony"
	desc = "Mała butelka. Zawiera toksynę korony Grodów."
	list_reagents = list(/datum/reagent/crowntoxin = 30)
