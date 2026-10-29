/obj/item/clothing/head/culthood
	name = "pradawny kaptur kultysty"
	icon_state = "culthood"
	desc = "Podarty, zakurzony kaptur. Wnętrze pokrywają dziwne litery."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEEARS
	flags_cover = HEADCOVERSEYES
	armor = list("melee" = 30, "bullet" = 30, "laser" = 20,"energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10, "stamina" = 40)
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT

/obj/item/clothing/suit/cultrobes
	name = "pradawne szaty kultysty"
	desc = "Obszarpane, zakurzone szaty. Wnętrze pokrywają dziwne litery."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list("melee" = 30, "bullet" = 30, "laser" = 20,"energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10, "stamina" = 40, "bleed" = 20)
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT


/obj/item/clothing/head/culthood/alt
	name = "kaptur kultysty"
	desc = "Opancerzony kaptur noszony przez wyznawców Nar'Sie."
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/head/culthood/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/head/culthood/alt/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/suit/cultrobes/alt
	name = "szaty kultysty"
	desc = "Opancerzone szaty noszone przez wyznawców Nar'Sie."
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"

/obj/item/clothing/suit/cultrobes/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/suit/cultrobes/alt/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)


/obj/item/clothing/head/magus
	name = "hełm maga"
	icon_state = "magus"
	item_state = "magus"
	desc = "Hełm noszony przez wyznawców Nar'Sie."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT
	armor = list("melee" = 50, "bullet" = 30, "laser" = 50,"energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10, "stamina" = 50)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/suit/magusred
	name = "szaty maga"
	desc = "Opancerzone szaty noszone przez wyznawców Nar'Sie."
	icon_state = "magusred"
	item_state = "magusred"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list("melee" = 50, "bullet" = 30, "laser" = 50,"energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10, "stamina" = 50, "bleed" = 20)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/head/helmet/space/hardsuit/cult
	name = "\improper utwardzony hełm Nar'Sie"
	desc = "Ciężko opancerzony hełm noszony przez wojowników kultu Nar'Sie. Wzmacnia go twarda próżnia."
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list("melee" = 70, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 75, "stamina" = 50)
	light_system = NO_LIGHT_SUPPORT
	actions_types = list()
	high_pressure_multiplier = 0.5

/obj/item/clothing/suit/space/hardsuit/cult
	name = "\improper utwardzona zbroja Nar'Sie"
	icon_state = "cult_armor"
	item_state = "cult_armor"
	desc = "Ciężko opancerzony kombinezon noszony przez wojowników kultu Nar'Sie."
	w_class = WEIGHT_CLASS_BULKY
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade, /obj/item/tank/internals/)
	armor = list("melee" = 70, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 75, "stamina" = 50)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/cult

/obj/item/sharpener/cult
	name = "pradawna osełka"
	desc = "Kamień wzmocniony mroczną magią. Ostra broń użyta na nim staje się silniejsza."
	icon = 'icons/obj/cult.dmi'
	icon_state = "cult_sharpener"
	used = 0
	increment = 5
	max = 40
	prefix = "po mrocznym naostrzeniu"

/obj/item/sharpener/cult/update_icon()
	icon_state = "cult_sharpener[used ? "_used" : ""]"

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "wzmocniona zbroja kultysty"
	desc = "Wzmocniona zbroja, która tworzy wokół noszącego potężną tarczę."
	icon_state = "cult_armor"
	item_state = "cult_armor"
	w_class = WEIGHT_CLASS_BULKY
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40,"energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 50, "acid" = 60, "stamina" = 40, "bleed" = 20)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/cult_shield

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/Initialize()
	. = ..()
	// note that these charges don't regenerate
	AddComponent(/datum/component/shielded, recharge_start_delay = 0, shield_icon_file = 'icons/effects/cult_effects.dmi', shield_icon = "shield-cult", run_hit_callback = CALLBACK(src, PROC_REF(shield_damaged)))

/// A proc for callback when the shield breaks, since cult robes are stupid and have different effects
/obj/item/clothing/suit/hooded/cultrobes/cult_shield/proc/shield_damaged(mob/living/wearer, attack_text, new_current_charges)
	wearer.visible_message("<span class='danger'>Szaty [wearer] neutralizują [attack_text] w deszczu krwistoczerwonych iskier!</span>")
	new /obj/effect/temp_visual/cult/sparks(get_turf(wearer))
	if(new_current_charges == 0)
		wearer.visible_message("<span class='danger'>Runiczna tarcza wokół [wearer] nagle znika!</span>")

/obj/item/clothing/head/hooded/cult_hoodie/cult_shield
	name = "empowered cultist helmet"
	desc = "Empowered helmet which creates a powerful shield around the user."
	icon_state = "cult_hoodalt"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40,"energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 50, "acid" = 60, "stamina" = 40, "bleed" = 20)
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"Nie radziłabym tego.\"</span>")
		to_chat(user, "<span class='warning'>Ogarniają cię przytłaczające mdłości!</span>")
		user.dropItemToGround(src, TRUE)
		user.Dizzy(30)
		user.Paralyze(100)

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "szaty biczownika"
	desc = "Przesiąknięte krwią szaty nasycone mroczną magią. Pozwalają poruszać się z nieludzką szybkością, ale noszący otrzymuje większe obrażenia."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list("melee" = -45, "bullet" = -45, "laser" = -45,"energy" = -45, "bomb" = -45, "bio" = -45, "rad" = -45, "fire" = 0, "acid" = 0, "stamina" = 40, "bleed" = 20)
	slowdown = -0.6
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/berserkerhood

/obj/item/clothing/head/hooded/cult_hoodie/berserkerhood
	name = "kaptur biczownika"
	desc = "Przesiąknięty krwią kaptur nasycony mroczną magią."
	icon_state = "culthood"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 20)

/obj/item/clothing/suit/hooded/cultrobes/berserker/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"Nie radziłabym tego.\"</span>")
		to_chat(user, "<span class='warning'>Ogarniają cię przytłaczające mdłości!</span>")
		user.dropItemToGround(src, TRUE)
		user.Dizzy(30)
		user.Paralyze(100)

/obj/item/clothing/glasses/hud/health/night/cultblind
	desc = "Niech Nar'Sie prowadzi cię przez ciemność i chroni przed światłem."
	name = "opaska fanatyka"
	icon_state = "blindfold"
	item_state = "blindfold"
	flash_protect = 1
	vision_correction = 1

/obj/item/clothing/glasses/hud/health/night/cultblind/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"Chcesz oślepnąć, tak?\"</span>")
		user.dropItemToGround(src, TRUE)
		user.Dizzy(30)
		user.Paralyze(100)
		user.blind_eyes(30)

/obj/item/reagent_containers/glass/beaker/unholywater
	name = "flaszka nieświętej wody"
	desc = "Toksyczna dla niewiernych, ożywcza dla wiernych – z tej flaszki można się napić albo nią rzucić."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	color = "#333333"
	list_reagents = list(/datum/reagent/fuel/unholywater = 50)

/obj/item/shuttle_curse
	name = "przeklęta kula"
	desc = "Zaglądasz w tę zadymioną kulę i dostrzegasz straszny los, który czeka prom ewakuacyjny."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shuttlecurse"
	var/static/curselimit = 0

/obj/item/shuttle_curse/attack_self(mob/living/user)
	if(!iscultist(user))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(100)
		to_chat(user, "<span class='warning'>Potężna siła odpycha cię od [src]!</span>")
		return
	if(curselimit > 1)
		to_chat(user, "<span class='notice'>Wyczerpaliśmy możliwość przeklinania promu.</span>")
		return
	if(locate(/obj/eldritch/narsie) in GLOB.poi_list)
		to_chat(user, "<span class='warning'>Nar'Sie jest już na tym planie, nie da się opóźnić końca wszystkiego.</span>")
		return

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 1800
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		var/security_num = seclevel2num(get_security_level())
		var/set_coefficient = 1
		switch(security_num)
			if(SEC_LEVEL_GREEN)
				set_coefficient = 2
			if(SEC_LEVEL_BLUE)
				set_coefficient = 1
			else
				set_coefficient = 0.5
		var/surplus = timer - (SSshuttle.emergencyCallTime * set_coefficient)
		SSshuttle.emergency.setTimer(timer)
		if(surplus > 0)
			SSshuttle.block_recall(surplus)
		to_chat(user, "<span class='danger'>Rozbijasz kulę! Mroczna esencja wiruje w powietrzu, po czym znika.</span>")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 50, 1)
		qdel(src)
		sleep(20)
		var/static/list/curses
		if(!curses)
			curses = list("Technik od paliwa właśnie poderżnął sobie gardło, błagając o śmierć.",
			"Oprogramowanie nawigacyjne promu zastąpiono plikiem zawierającym tylko dwa słowa: ONO NADCHODZI.",
			"Woźnego promu znaleziono, gdy mył okna własną krwią.",
			"Inżynierka promu zaczęła krzyczeć 'ŚMIERĆ TO NIE KONIEC' i wyrywała kable, aż łuk elektryczny spalił jej ciało.",
			"Inspektorka promu zaczęła się szaleńczo śmiać przez radio, po czym rzuciła się w turbinę silnika.",
			"Dyspozytora promu znaleziono martwego z krwawymi symbolami wyciętymi na ciele.",
			"Transponder promu zamiast przydzielonego sygnału identyfikacyjnego nadaje zakodowaną wiadomość 'LĘKAJCIE SIĘ STAREJ KRWI'.")
		var/message = pick_n_take(curses)
		message += " Prom zostanie opóźniony o trzy minuty."
		priority_announce("[message]", "Awaria systemu", 'sound/misc/notice1.ogg')
		curselimit++

/obj/item/cult_shift
	name = "przesuwacz zasłony"
	desc = "Ta relikwia natychmiast teleportuje ciebie i wszystko, co ciągniesz, na umiarkowaną odległość do przodu."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shifter"
	var/uses = 4

/obj/item/cult_shift/examine(mob/user)
	. = ..()
	if(uses)
		. += "<span class='cult'>Pozostałe użycia: [uses].</span>"
	else
		. += "<span class='cult'>Wydaje się wyczerpany.</span>"

/obj/item/cult_shift/proc/handle_teleport_grab(turf/T, mob/user)
	var/mob/living/carbon/C = user
	if(C.pulling)
		var/atom/movable/pulled = C.pulling
		do_teleport(pulled, T, channel = TELEPORT_CHANNEL_CULT)
		. = pulled

/obj/item/cult_shift/attack_self(mob/user)
	if(!uses || !iscarbon(user))
		to_chat(user, "<span class='warning'>[src] jest matowy i nieruchomy w twoich dłoniach.</span>")
		return
	if(!iscultist(user))
		user.dropItemToGround(src, TRUE)
		step(src, pick(GLOB.alldirs))
		to_chat(user, "<span class='warning'>[src] wymyka ci się z rąk - twoja więź z tym wymiarem jest zbyt silna!</span>")
		return

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/turf/destination = get_teleport_loc(mobloc,C,9,1,0,3,1,0,1)

	if(destination)
		uses--
		if(uses <= 0)
			icon_state ="shifter_drained"
		playsound(mobloc, "sparks", 50, 1)
		new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, C.dir)

		var/atom/movable/pulled = handle_teleport_grab(destination, C)
		if(do_teleport(C, destination, channel = TELEPORT_CHANNEL_CULT))
			if(pulled)
				C.start_pulling(pulled) //forcemove resets pulls, so we need to re-pull
			new /obj/effect/temp_visual/dir_setting/cult/phase(destination, C.dir)
			playsound(destination, 'sound/effects/phasein.ogg', 25, 1)
			playsound(destination, "sparks", 50, 1)

	else
		to_chat(C, "<span class='danger'>Tutaj nie da się rozedrzeć zasłony!</span>")

/obj/item/flashlight/flare/culttorch
	name = "pochodnia pustki"
	desc = "Weterani kultu natychmiast przesyłają nią przedmioty potrzebującym współbraciom."
	w_class = WEIGHT_CLASS_SMALL
	light_range = 1
	icon_state = "torch"
	item_state = "torch"
	color = "#ff0000"
	on_damage = 15
	slot_flags = null
	on = TRUE
	var/charges = 5

/obj/item/flashlight/flare/culttorch/afterattack(atom/movable/A, mob/user, proximity)
	if(!proximity)
		return
	if(!iscultist(user))
		to_chat(user, "To chyba nic pożytecznego nie robi.")
		return

	if(istype(A, /obj/item))

		var/list/cultists = list()
		for(var/datum/mind/M in SSticker.mode.cult)
			if(M.current && M.current.stat != DEAD)
				cultists |= M.current
		var/mob/living/cultist_to_receive = input(user, "Kogo chcesz wezwać do [src]?", "Wyznawcy Geometry") as null|anything in (cultists - user)
		if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
			return
		if(!cultist_to_receive)
			to_chat(user, "<span class='cult italic'>Potrzebujesz celu podróży!</span>")
			log_game("Void torch failed - no target")
			return
		if(cultist_to_receive.stat == DEAD)
			to_chat(user, "<span class='cult italic'>[cultist_to_receive] nie żyje!</span>")
			log_game("Void torch failed  - target died")
			return
		if(!iscultist(cultist_to_receive))
			to_chat(user, "<span class='cult italic'>[cultist_to_receive] nie jest wyznawcą Geometry!</span>")
			log_game("Void torch failed - target was deconverted")
			return
		if(A in user.GetAllContents())
			to_chat(user, "<span class='cult italic'>[A] musi leżeć na powierzchni, żeby go teleportować!</span>")
			return
		to_chat(user, "<span class='cult italic'>Podpalasz [A] za pomocą [src], obracając go w popiół, ale w płomieniach pochodni widzisz, że [A] dotarł do [cultist_to_receive]!")
		cultist_to_receive.put_in_hands(A)
		charges--
		to_chat(user, "[src] ma teraz ładunków: [charges].")
		if(charges == 0)
			qdel(src)

	else
		..()
		to_chat(user, "<span class='warning'>[src] może przenosić tylko przedmioty!</span>")


/obj/item/gun/ballistic/rifle/boltaction/enchanted/arcane_barrage/blood
	name = "grad krwawych pocisków"
	desc = "Krew za krew."
	color = "#ff0000"
	guns_left = 24
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'
	weapon_weight = WEAPON_LIGHT

/obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/blood

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/item/projectile/magic/arcane_barrage/blood
	firing_effect_type = /obj/effect/temp_visual/cult/sparks

/obj/item/projectile/magic/arcane_barrage/blood
	name = "krwawy pocisk"
	icon_state = "mini_leaper"
	nondirectional_sprite = TRUE
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter

/obj/item/projectile/magic/arcane_barrage/blood/Bump(atom/target)
	var/turf/T = get_turf(target)
	playsound(T, 'sound/effects/splat.ogg', 50, TRUE)
	if(iscultist(target))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stat != DEAD)
				H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 4)
		if(isshade(target) || isconstruct(target))
			var/mob/living/simple_animal/M = target
			if(M.health+5 < M.maxHealth)
				M.adjustHealth(-5)
		new /obj/effect/temp_visual/cult/sparks(T)
		qdel(src)
	else
		..()

/obj/item/blood_beam
	name = "\improper magiczna aura"
	desc = "Złowieszcza aura, która zakrzywia wokół siebie bieg rzeczywistości."
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charging = FALSE
	var/firing = FALSE
	var/angle

/obj/item/blood_beam/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/blood_beam/afterattack(atom/A, mob/living/user, flag, params)
	. = ..()
	if(firing || charging)
		return
	var/C = user.client
	if(ishuman(user) && C)
		angle = get_angle(get_turf(src), get_turf(A))
	else
		qdel(src)
		return
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge), user)
	if(do_after(user, 90, target = user))
		firing = TRUE
		INVOKE_ASYNC(src, PROC_REF(pewpew), user, params)
		var/obj/structure/emergency_shield/invoker/N = new(user.loc)
		if(do_after(user, 90, target = user))
			user.Paralyze(40)
			to_chat(user, "<span class='cult italic'>Wyczerpujesz moc tego zaklęcia!</span>")
		firing = FALSE
		if(N)
			qdel(N)
		qdel(src)
	charging = FALSE

/obj/item/blood_beam/proc/charge(mob/user)
	var/obj/O
	playsound(src, 'sound/magic/lightning_chargeup.ogg', 100, 1)
	for(var/i in 1 to 12)
		if(!charging)
			break
		if(i > 1)
			sleep(15)
		if(i < 4)
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune1/inner(user.loc, 30, "#ff0000")
		else
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune5(user.loc, 30, "#ff0000")
			new /obj/effect/temp_visual/dir_setting/cult/phase/out(user.loc, user.dir)
	if(O)
		qdel(O)

/obj/item/blood_beam/proc/pewpew(mob/user, params)
	var/turf/targets_from = get_turf(src)
	var/spread = 40
	var/second = FALSE
	var/set_angle = angle
	for(var/i in 1 to 12)
		if(second)
			set_angle = angle - spread
			spread -= 8
		else
			sleep(15)
			set_angle = angle + spread
		second = !second //Handles beam firing in pairs
		if(!firing)
			break
		playsound(src, 'sound/magic/exit_blood.ogg', 75, 1)
		new /obj/effect/temp_visual/dir_setting/cult/phase(user.loc, user.dir)
		var/turf/temp_target = get_turf_in_angle(set_angle, targets_from, 40)
		for(var/turf/T in getline(targets_from,temp_target))
			if (locate(/obj/effect/blessing, T))
				temp_target = T
				playsound(T, 'sound/machines/clockcult/ark_damage.ogg', 50, 1)
				new /obj/effect/temp_visual/at_shield(T, T)
				break
			T.narsie_act(TRUE, TRUE)
			for(var/mob/living/target in T.contents)
				if(iscultist(target))
					new /obj/effect/temp_visual/cult/sparks(T)
					if(ishuman(target))
						var/mob/living/carbon/human/H = target
						if(H.stat != DEAD)
							H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 7)
					if(isshade(target) || isconstruct(target))
						var/mob/living/simple_animal/M = target
						if(M.health+15 < M.maxHealth)
							M.adjustHealth(-15)
						else
							M.health = M.maxHealth
				else
					var/mob/living/L = target
					if(L.density)
						L.Paralyze(20)
						L.adjustBruteLoss(45)
						playsound(L, 'sound/hallucinations/wail.ogg', 50, 1)
						L.emote("scream")
		var/datum/beam/current_beam = new(user,temp_target,time=7,beam_icon_state="blood_beam",btype=/obj/effect/ebeam/blood)
		INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))


/obj/effect/ebeam/blood
	name = "promień krwi"

/obj/item/shield/mirror
	name = "lustrzana tarcza"
	desc = "Niesławna tarcza, którą sekty Nar'Sie mylą i dezorientują wrogów. Ma obciążone krawędzie, więc nadaje się do rzucania i z nadnaturalną celnością obezwładnia wielu przeciwników."
	icon_state = "mirror_shield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 5
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	max_integrity = 50
	w_class = WEIGHT_CLASS_BULKY
	block_flags = BLOCKING_PROJECTILE
	attack_verb = list("trąca", "dźga")
	hitsound = 'sound/weapons/smash.ogg'
	var/illusions = 4

/obj/item/shield/mirror/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "atak", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(iscultist(owner))
		. = ..()
		if(.)
			if(illusions > 0)
				illusions--
				if(prob(60))
					var/mob/living/simple_animal/hostile/illusion/M = new(owner.loc)
					M.faction = list("cult")
					M.Copy_Parent(owner, 70, 10, 5)
					M.move_to_delay = owner.movement_delay()
				else
					var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
					E.Copy_Parent(owner, 70, 10)
					E.GiveTarget(owner)
					E.Goto(owner, owner.movement_delay(), E.minimum_distance)
			return TRUE
	else
		if(prob(50))
			var/mob/living/simple_animal/hostile/illusion/H = new(owner.loc)
			H.Copy_Parent(owner, 100, 20, 5)
			H.faction = list("cult")
			H.GiveTarget(owner)
			H.move_to_delay = owner.movement_delay()
			to_chat(owner, "<span class='danger'><b>[src] cię zdradza!</b></span>")
		return FALSE

/obj/item/shield/mirror/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	var/datum/thrownthing/D = throwingdatum
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(iscultist(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(L.put_in_active_hand(src))
				L.visible_message("<span class='warning'>[L] łapie [src] w locie!</span>")
			else
				L.visible_message("<span class='warning'>[src] odbija się od [L], jakby odepchnięty niewidzialną siłą!</span>")
		else if(!..())
			if(!L.anti_magic_check())
				L.Paralyze(30) //NSV13 - revert cult to pre-nerf state
				if(D?.thrower)
					for(var/mob/living/Next in orange(2, T))
						if(!Next.density || iscultist(Next))
							continue
						throw_at(Next, 3, 1, D.thrower)
						return
					throw_at(D.thrower, 7, 1, null)
	else
		..()
