// Integracja nowego kultu krwi z resztą kodu (obszar „integracja”).
// Rzeczy po starym kulcie Bee, które są potrzebne poza folderem bloodcult,
// oraz przeniesione z draftu Monke zmiany plików core (kapelan, duchy, plecak, Zaćmienie).

// ---------------------------------------------------------------------------
// Bazowa akcja kultu. Wcześniej w code/modules/antagonists/cult/cult_comms.dm (usunięty),
// dalej potrzebna dla /datum/action/innate/cult/create_rune (rune_spawn_action.dm) i akcji z nowego kodu.
/datum/action/innate/cult
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS

/datum/action/innate/cult/IsAvailable()
	if(!IS_CULTIST(owner))
		return FALSE
	return ..()

// ---------------------------------------------------------------------------
// SSticker.mode.cult - lista umysłów kultystów, z której korzysta stary kod (mindshield, mob_helpers, mind).
// Stary antag Bee sam ją uzupełniał, nowy tego nie robi.
/datum/antagonist/cult/on_gain()
	. = ..()
	if(owner && SSticker.mode)
		SSticker.mode.cult |= owner

/datum/antagonist/cult/on_removal()
	if(owner && SSticker.mode)
		SSticker.mode.cult -= owner
	return ..()

// ---------------------------------------------------------------------------
// Plecak kultu wzmacnia moc kultysty (draft: code/game/objects/items/storage/backpack.dm)
/obj/item/storage/backpack/cultpack/get_cult_power()
	return 30

// ---------------------------------------------------------------------------
// Plamy krwi: kolor bazowy (dla bazgrołów krwią) i licznik zakrwawionych podłóg kultu
// (draft: code/game/objects/effects/decals/cleanable/humans.dm)
/obj/effect/decal/cleanable/blood
	var/base_color

/obj/effect/decal/cleanable/blood/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	base_color = color
	var/datum/team/cult/cult_team = locate_team(/datum/team/cult)
	cult_team?.add_bloody_floor(get_turf(src))

/obj/effect/decal/cleanable/blood/Destroy()
	var/datum/team/cult/cult_team = locate_team(/datum/team/cult)
	cult_team?.remove_bloody_floor(get_turf(src))
	return ..()

// ---------------------------------------------------------------------------
// Duchy w czasie Zaćmienia (draft: code/modules/mob/dead/observer/observer.dm)
/mob/dead/observer
	var/appearance_backup

/mob/dead/observer/Initialize(mapload)
	. = ..()
	if(GLOB.eclipse?.eclipse_start_time && !GLOB.eclipse.eclipse_finished)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, narsie_act))

/mob/dead/observer/update_icon(new_form)
	// W czasie Zaćmienia duch nie zmienia formy (zostaje duchem Nar'Sie)
	if(new_form && GLOB.eclipse?.eclipse_start_time && !GLOB.eclipse.eclipse_finished)
		new_form = null
	return ..(new_form)

/mob/dead/observer/narsie_act()
	var/prompt = tgui_alert(src, "Czy chcesz zostać duchem kultu?", "[name]", list("Tak", "Nie"), timeout = 20 SECONDS)
	if(prompt != "Tak")
		return
	if(invisibility != 0)
		var/datum/action/cooldown/blood_doodle/doodle = new
		doodle.Grant(src)
		appearance_backup = appearance
		icon = 'aquila/icons/bloodcult/mob.dmi'
		icon_state = "ghost-narsie"
		invisibility = 0
		alpha = 0
		animate(src, alpha = 127, time = 0.5 SECONDS)
		flick("rune_seer", src)

// ---------------------------------------------------------------------------
// Zaćmienie na paralaksie (draft: code/_onclick/hud/parallax.dm). Wołane z hooka w create_parallax.
/atom/movable/screen/parallax_layer/rifts
	icon = 'aquila/icons/bloodcult/riftbox.dmi'
	icon_state = "rift"
	layer = 2
	speed = 0.5

/atom/movable/screen/parallax_layer/rifts/Initialize(mapload, view)
	. = ..()
	add_atom_colour("#FF330030", ADMIN_COLOUR_PRIORITY) // COLOR_CARP_RIFT_RED z tg

/// Hook z create_parallax: szczeliny + czerwone zabarwienie warstw, żeby nowi klienci widzieli to samo niebo co reszta.
/proc/bloodcult_eclipse_parallax(client/C)
	if(!C)
		return
	bloodcult_add_rifts(C)
	bloodcult_color_parallax(C)

/// Sama warstwa szczelin, bez barwienia. Szczeliny są też w fazie Nar'Sie (bloodcult_eclipse_active).
/proc/bloodcult_add_rifts(client/C)
	if(!C || !bloodcult_eclipse_active())
		return
	if(locate(/atom/movable/screen/parallax_layer/rifts) in C.parallax_layers_cached)
		return
	// Za pierwszą warstwą, żeby nie wypadła przez limit parallax_layers_max
	C.parallax_layers_cached.Insert(2, new /atom/movable/screen/parallax_layer/rifts(null, C.view))

// ---------------------------------------------------------------------------
// Rytuał dekonwersji Biblią (draft: code/modules/library/bibles.dm)
// Biblia na kimś z wodą święconą we krwi, poza trybem walki, rozpoczyna dekonwersję kultysty.
/obj/item/storage/book/bible/attack(mob/living/M, mob/living/carbon/human/user, heal_mode = TRUE)
	. = ..()
	if(!istype(M) || !istype(user))
		return
	if(IS_CULTIST(user) || user.combat_mode || !M.reagents?.has_reagent(/datum/reagent/water/holywater))
		return
	playsound(src, "punch", 25, 1, -1)
	if(M.stat == DEAD)
		to_chat(user, span_warning("Nie da się nawrócić zmarłego!"))
		return TRUE
	if(M.health < 20)
		to_chat(user, span_warning("[M] jest zbyt słaby, by znieść rytuał dekonwersji. Najpierw go trochę podlecz."))
		return TRUE
	var/datum/antagonist/cult/cultist
	if(IS_CULTIST(M))
		cultist = M.mind.has_antag_datum(/datum/antagonist/cult)
		if(cultist.deconversion)
			to_chat(user, span_warning("Dekonwersja już trwa!"))
			return TRUE
		to_chat(M, span_userdanger("Ktoś próbuje cię odwrócić od kultu!"))
		cultist.deconversion = 1 // wartość zastępcza, za 5 sekund zastąpi ją /datum/deconversion_ritual
	if(do_after(user, 5 SECONDS, target = M))
		to_chat(user, span_warning("W imię [deity_name], Nar'Sie, opuść to ciało i duszę!"))
		if(cultist)
			user.visible_message(span_warning("[M] zaczyna promieniować światłem."))
			new /datum/deconversion_ritual(user, M, src)
		else
			user.visible_message(span_warning("...ale nic niezwykłego się nie dzieje."))
	else if(cultist)
		cultist.deconversion = null // przerwane, można spróbować ponownie
	return TRUE

/datum/deconversion_ritual
	var/datum/antagonist/cult/cultist = null
	var/cult_chaplain = FALSE
	var/last_cultist = FALSE
	var/success = DECONVERSION_ACCEPT

/datum/deconversion_ritual/New(mob/living/deconverter, mob/living/deconvertee, obj/item/storage/book/bible/bible)
	..()
	cultist = IS_CULTIST(deconvertee) // przed wczesnym qdel, żeby Destroy() zdjął zastępcze deconversion = 1
	if(!bible || !bible.deity_name || !deconverter || !deconvertee || !cultist)
		qdel(src)
		return
	deconvertee.overlays += image('aquila/icons/bloodcult/effects.dmi', src, "deconversion")
	playsound(deconvertee, 'aquila/sound/bloodcult/deconversion_start.ogg', 50, 0, -4)
	cultist.deconversion = src

	deconvertee.adjust_dizzy(30)
	deconvertee.adjust_stutter(10)
	deconvertee.adjust_jitter(30)
	deconvertee.Paralyze(10 SECONDS)

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	var/living_cultists = 0
	for(var/datum/mind/mind in cult?.members)
		if(mind.current && mind.current.stat != DEAD) // zgibowani (current == null) się nie liczą
			living_cultists++
	if(living_cultists <= 1)
		last_cultist = TRUE

	INVOKE_ASYNC(src, PROC_REF(ask_deconvertee), deconvertee, bible)
	INVOKE_ASYNC(src, PROC_REF(run_ritual), deconverter, deconvertee, bible)

/datum/deconversion_ritual/proc/ask_deconvertee(mob/living/deconvertee, obj/item/storage/book/bible/bible)
	var/accept_text = !cult_chaplain ? "Porzuć kult" : "Nic już nie rozumiem, no dobra?"
	var/refuse_text = !cult_chaplain ? "Opieraj się!" : "To oczywista sztuczka! Opieraj się!"
	var/answer = tgui_alert(deconvertee, "Moc [bible.deity_name] zmusza cię do porzucenia służby Kultowi Nar'Sie.", "Masz 10 sekund na decyzję", list(accept_text, refuse_text), timeout = 10 SECONDS)
	if(QDELETED(src))
		return
	if(answer == refuse_text)
		success = DECONVERSION_REFUSE
		to_chat(deconvertee, span_warning("Odpychasz od siebie słodkie obietnice przebaczenia."))
		return
	success = DECONVERSION_ACCEPT
	if(!last_cultist) // nie grozimy, jeśli nie zostanie nikt, kto by te groźby spełnił
		to_chat(deconvertee, span_cult("[cult_chaplain ? "TAK ŁATWO DAŁEŚ SIĘ OSZUKAĆ? NIECH I TAK BĘDZIE." : "ZAPŁACISZ ZA TO."]"))

/datum/deconversion_ritual/proc/run_ritual(mob/living/deconverter, mob/living/deconvertee, obj/item/storage/book/bible/bible)
	new /obj/effect/bible_spin(get_turf(deconvertee), deconverter, bible)
	sleep(10 SECONDS)
	if(QDELETED(src))
		return
	if(!deconvertee || !IS_CULTIST(deconvertee))
		qdel(src)
		return
	deconvertee.take_overall_damage(10) // to zawsze boli
	var/turf/T = get_turf(deconvertee)
	anim(target = deconvertee, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "cult_jaunt_land", plane = GAME_PLANE_UPPER)

	switch(success)
		if(DECONVERSION_ACCEPT)
			var/mob/living/simple_animal/shade/redshade_A = new(T)
			var/mob/living/simple_animal/shade/redshade_B = new(T)
			var/list/adjacent_turfs = list()
			for(var/turf/U in orange(1, T))
				adjacent_turfs += U
			playsound(deconvertee, 'aquila/sound/bloodcult/deconversion_complete.ogg', 50, 0, -4)
			deconvertee.visible_message(span_notice("Oczy [deconvertee] stają się jasne. Dzięki błogosławieństwu [bible.deity_name] wyrzeka się Nar'Sie."), span_notice("[bible.deity_name] ci wybacza. Nie dzielisz już celów kultu."))
			deconvertee.visible_message(span_userdanger("Z okultystycznej energii, która go opuściła, powstaje para cieni i rzuca się na niego."))
			cultist.owner.current.add_particles(PS_CULT_HALO)
			cultist.owner.current.adjust_particles(PVAR_COLOR, "#00000066", PS_CULT_HALO)
			cultist.owner.current.adjust_particles(PVAR_ICON_STATE, "cult_halo[cultist.get_devotion_rank()]", PS_CULT_HALO)
			cultist.owner.remove_antag_datum(/datum/antagonist/cult)
			var/list/speak = list("...oddasz krew, którą ci daliśmy, [deconvertee]...", "...nie odwraca się plecami do naszego daru...", "...skoro nie oddasz serca Nar'Sie, nie jest ci już potrzebne...")
			redshade_A.say(pick(speak))
			redshade_B.say(pick(speak))
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(bloodcult_deconversion_shades), deconvertee, redshade_A, redshade_B, adjacent_turfs), 1)
		if(DECONVERSION_REFUSE)
			playsound(deconvertee, 'aquila/sound/bloodcult/deconversion_failed.ogg', 50, 0, -4)
			to_chat(deconvertee, span_notice("Udaje ci się odeprzeć egzorcyzm."))
			deconvertee.visible_message(span_userdanger("Rytuał został odparty!"), span_warning("Zebrana energia odbija się na twoim ciele..."))
	deconvertee.overlays -= image('aquila/icons/bloodcult/effects.dmi', src, "deconversion")
	qdel(src)

/proc/bloodcult_deconversion_shades(mob/living/deconvertee, mob/living/simple_animal/shade/redshade_A, mob/living/simple_animal/shade/redshade_B, list/adjacent_turfs)
	for(var/mob/living/simple_animal/shade/redshade as anything in list(redshade_A, redshade_B))
		if(QDELETED(redshade))
			continue
		if(length(adjacent_turfs))
			redshade.forceMove(pick(adjacent_turfs))
		if(!QDELETED(deconvertee))
			deconvertee.attack_animal(redshade)
		animate(redshade, alpha = 0, time = 2.5 SECONDS)
		QDEL_IN(redshade, 3 SECONDS)
	if(!QDELETED(deconvertee))
		deconvertee.blood_volume -= 100 // auć

/datum/deconversion_ritual/Destroy()
	if(cultist)
		cultist.deconversion = null
	cultist = null
	return ..()

// Wirująca Biblia (Belmont)
/obj/effect/bible_spin
	var/mob/living/owner
	var/obj/item/storage/book/bible/source
	var/image/bible_image
	var/current_spin = 0
	var/lifetime = 10 SECONDS
	var/lifetime_max = 10 SECONDS
	var/distance = 0
	var/distance_min = 8
	var/distance_amplitude = 24
	var/spin_speed = 30

/obj/effect/bible_spin/New(turf/loc, _owner, _source)
	..()
	if(!_owner || !_source)
		qdel(src)
		return
	playsound(src, 'aquila/sound/bloodcult/bible_throw.ogg', 70, 0)
	owner = _owner
	source = _source
	source.forceMove(src)
	current_spin = dir2angle(owner.dir)
	bible_image = image(source.icon, source, source.icon_state)
	bible_image.plane = ABOVE_LIGHTING_PLANE
	overlays += bible_image
	INVOKE_ASYNC(src, PROC_REF(process_spin))

/obj/effect/bible_spin/proc/process_spin()
	set waitfor = FALSE

	while(owner && !QDELETED(owner) && source && !QDELETED(source) && (source.loc == src) && lifetime > 0)
		update_spin()
		var/obj/effect/afterimage/A = new(loc, null, 15)
		animate(A)
		A.appearance = appearance
		A.pixel_x = pixel_x
		A.pixel_y = pixel_y
		animate(A, alpha = 0, time = 10)
		A.layer--
		A.add_particles(PS_BIBLE_PAGE)
		A.adjust_particles(PVAR_VELOCITY, list(pixel_x/2, pixel_y/2), PS_BIBLE_PAGE)
		A.adjust_particles(PVAR_SPAWNING, 2, PS_BIBLE_PAGE)
		if((lifetime % 10) == 0)
			playsound(src, 'aquila/sound/bloodcult/bible_spin.ogg', 50, 0)
			for(var/mob/living/L in range(1, src))
				if(L == owner)
					continue
				source.throw_impact(L)
		lifetime--
		addtimer(CALLBACK(A, TYPE_PROC_REF(/atom, adjust_particles), PVAR_SPAWNING, 0, PS_BIBLE_PAGE), 1) // jedna strona na powidok
		sleep(1)

	if(source && !QDELETED(source))
		source.forceMove(loc)
		if(owner)
			owner.put_in_hands(source)
	qdel(src)

/obj/effect/bible_spin/proc/update_spin()
	current_spin += spin_speed
	distance = distance_min + distance_amplitude*sin(180*(lifetime/lifetime_max))
	animate(src, pixel_x = distance*cos(current_spin), pixel_y = distance*sin(current_spin), time = 1)

// ---------------------------------------------------------------------------
// Krzyż bojowy kapelana - wracający bumerang (draft: code/modules/jobs/job_types/chaplain/chaplain_nullrod.dm)
/obj/item/projectile/boomerang
	name = "boomerang"
	icon = 'aquila/icons/bloodcult/boomerang.dmi'
	icon_state = "boomerang-spin"
	damage = 20
	damage_type = BRUTE
	speed = 0.66
	var/obj/item/nullrod/cross_boomerang/boomerang
	var/list/hit_atoms = list()

/obj/item/projectile/boomerang/Bump(atom/A)
	if(!(A in hit_atoms))
		hit_atoms += A
		if(boomerang)
			boomerang.throw_impact(A)
			if(boomerang.loc != src) // ktoś złapał bumerang
				boomerang.originator = null
				boomerang = null
				qdel(src)
				return
			else if(iscarbon(A))
				boomerang.apply_status_effects(A)
				forceMove(A.loc)
				A.Bumped(boomerang)
				qdel(src)
				return
			A.Bumped(boomerang)
	return ..()

/obj/item/projectile/boomerang/Destroy()
	if(boomerang)
		return_to_sender()
	return ..()

/obj/item/projectile/boomerang/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!boomerang)
		qdel(src)

/obj/item/projectile/boomerang/proc/return_to_sender()
	if(!boomerang)
		qdel(src)
		return
	var/turf/T = get_turf(src)
	if(!boomerang.return_check())
		boomerang.forceMove(T)
		boomerang.thrown = FALSE
		boomerang.dropped()
		boomerang = null
		return

	var/atom/return_target
	if(firer)
		if(isturf(firer.loc) && (firer.z == z) && (get_dist(firer, src) <= 26))
			return_target = firer

	if(!return_target)
		return_target = starting

	var/obj/effect/tracker/boomerang/Tr = new(T)
	Tr.target = return_target
	Tr.appearance = appearance
	Tr.refresh = speed
	Tr.luminosity = luminosity
	Tr.boomerang = boomerang
	Tr.hit_atoms = hit_atoms.Copy()
	boomerang.forceMove(Tr)
	boomerang = null

/obj/effect/tracker/boomerang
	name = "boomerang"
	icon = 'aquila/icons/bloodcult/boomerang.dmi'
	icon_state = "boomerang-spin"
	mouse_opacity = MOUSE_OPACITY_ICON
	density = TRUE
	pass_flags = PASSTABLE
	var/obj/item/nullrod/cross_boomerang/boomerang
	var/list/hit_atoms = list()

/obj/effect/tracker/boomerang/Destroy()
	var/turf/T = get_turf(src)
	if(T && boomerang)
		boomerang.forceMove(T)
		boomerang.thrown = FALSE
		boomerang.dropped()
		boomerang.originator = null
		boomerang = null
	return ..()

/obj/effect/tracker/boomerang/on_step()
	if(boomerang && !QDELETED(boomerang))
		boomerang.on_step(src)
	else
		qdel(src)

/obj/effect/tracker/boomerang/Bumped(atom/movable/AM)
	make_contact(AM)

/obj/effect/tracker/boomerang/proc/make_contact(atom/Obstacle)
	if(!boomerang)
		qdel(src)
		return FALSE
	if(Obstacle in hit_atoms)
		return FALSE
	hit_atoms += Obstacle
	if(Obstacle == boomerang.originator)
		if(on_expire(FALSE))
			qdel(src)
			return TRUE
	boomerang.throw_impact(Obstacle)
	if(boomerang.loc != src) // ktoś złapał bumerang
		boomerang.originator = null
		boomerang = null
		qdel(src)
		return TRUE
	else if(iscarbon(Obstacle))
		boomerang.apply_status_effects(Obstacle)
		return FALSE
	Obstacle.Bumped(boomerang)
	if(!ismob(Obstacle))
		on_expire(TRUE)
		qdel(src)
		return TRUE
	return FALSE

/obj/effect/tracker/boomerang/on_expire(bumped_atom = FALSE)
	if(boomerang && boomerang.originator && Adjacent(boomerang.originator))
		if(boomerang.on_return())
			if(boomerang)
				boomerang.originator = null
			boomerang = null
			return TRUE
	return FALSE

/obj/item/nullrod/cross_boomerang
	name = "battle cross"
	desc = "Święty srebrny krzyż, który rozprasza zło i razi nieczyste stworzenia."
	throwforce = 20
	icon = 'aquila/icons/bloodcult/boomerang.dmi'
	icon_state = "cross_modern"
	item_state = "nullrod"
	var/thrown = FALSE
	var/flickering = 0
	var/classic = FALSE
	var/mob/living/carbon/originator
	COOLDOWN_DECLARE(last_sound_loop)
	var/sound_throw = 'aquila/sound/bloodcult/boomerang_cross_start.ogg'
	var/sound_loop = 'aquila/sound/bloodcult/boomerang_cross_loop.ogg'

/obj/item/nullrod/cross_boomerang/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/nullrod/cross_boomerang/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]-moody")

/obj/item/nullrod/cross_boomerang/throw_at(atom/target, range, speed, mob/thrower, spin = 1, diagonals_first = 0, datum/callback/callback, force, quickstart = TRUE)
	if(!thrower)
		return ..()
	thrown = TRUE
	playsound(loc, sound_throw, 70, 0)
	originator = thrower

	SET_PLANE_EXPLICIT(src, ABOVE_LIGHTING_PLANE, thrower)

	var/turf/starting = get_turf(src)
	target = get_turf(target)
	var/obj/item/projectile/boomerang/rang = new(starting)
	rang.boomerang = src
	rang.firer = thrower
	rang.def_zone = ran_zone(thrower.zone_selected)
	rang.preparePixelProjectile(target, thrower)
	rang.icon_state = "[icon_state]-spin"
	rang.overlays += overlays
	rang.plane = plane
	rang.stun = 1 SECONDS

	forceMove(rang)
	rang.fire()

/obj/item/nullrod/cross_boomerang/proc/on_step(obj/O)
	if(COOLDOWN_FINISHED(src, last_sound_loop))
		COOLDOWN_START(src, last_sound_loop, 1 SECONDS)
		playsound(loc, sound_loop, 35, 0)
	dir = turn(dir, 45)
	var/obj/effect/afterimage/A = new(O.loc, O, fadout = 5, initial_alpha = 100, pla = ABOVE_LIGHTING_PLANE)
	A.layer = O.layer - 1
	A.color = "#1E45FF"
	if(istype(O, /obj/effect/tracker)) // cząsteczki tylko w drodze powrotnej
		A.add_particles(PS_CROSS_DUST)
		A.add_particles(PS_CROSS_ORB)

	flickering = (flickering + 1) % 4
	if(flickering > 1)
		O.color = "#53A6FF"
	else
		O.color = null

/// Warunki powrotu bumerangu
/obj/item/nullrod/cross_boomerang/proc/return_check()
	return TRUE

/obj/item/nullrod/cross_boomerang/proc/apply_status_effects(mob/living/carbon/C, minimal_effect = 0)
	C.Stun(max(minimal_effect, 1 SECONDS))

/obj/item/nullrod/cross_boomerang/proc/on_return()
	return (istype(originator) && originator.put_in_hands(src))

/obj/item/nullrod/cross_boomerang/pickup(mob/user)
	. = ..()
	thrown = FALSE

/obj/item/nullrod/cross_boomerang/dropped(mob/user, silent = FALSE)
	. = ..()
	SET_PLANE_EXPLICIT(src, initial(plane), user)

/obj/item/nullrod/cross_boomerang/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(istype(hit_atom, /obj/machinery/computer/arcade))
		playsound(hit_atom, 'aquila/sound/bloodcult/boomerang_cross_transform.ogg', 30, 0)
		classic = !classic
		icon_state = "[classic ? "cross_classic" : "cross_modern"]"
		if(istype(loc, /obj))
			var/obj/O = loc
			O.icon_state = "[icon_state]-spin"
		update_icon()
	return ..()

// ---------------------------------------------------------------------------
// Typy kultu pomijane w teście create_and_destroy (draft: code/modules/unit_tests/unit_test.dm).
// Przez text2path, żeby brakujący typ nie psuł kompilacji.
/proc/bloodcult_create_and_destroy_ignores()
	. = list()
	for(var/path_text in list(
		"/obj/item/tome",
		"/obj/item/weapon/blood_tesseract",
		"/obj/item/restraints/handcuffs/cult",
		"/mob/living/simple_animal/astral_projection",
		"/mob/living/simple_animal/hostile/hex",
		"/obj/item/melee/blood_dagger",
		"/obj/item/melee/soulblade",
		"/obj/effect/tracker/boomerang",
		"/obj/effect/new_rune",
		"/obj/item/projectile/soulbullet",
		"/obj/item/projectile/blooddagger",
		"/obj/item/projectile/bloodslash",
		))
		var/path = text2path(path_text)
		if(path)
			. += path
	for(var/path_text in list(
		"/obj/effect/afterimage",
		"/obj/effect/bloodcult_jaunt",
		"/obj/effect/cult_ritual",
		"/obj/effect/cult_shortcut",
		"/obj/effect/rooting_trap",
		"/obj/effect/stun_indicator",
		"/obj/item/projectile/boomerang",
		"/obj/structure/cult",
		"/obj/abstract/mind_ui_element",
		))
		var/path = text2path(path_text)
		if(path)
			. += typesof(path)
