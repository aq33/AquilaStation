/obj/item/deployablemine
	name = "mina do rozłożenia"
	desc = "Nieuzbrojona mina lądowa. Podłóż ją, by ją uzbroić."
	icon_state = "uglymine"
	var/mine_type = /obj/effect/mine
	var/arming_time = 30

/obj/item/deployablemine/stun
	desc = "Nieuzbrojona mina ogłuszająca. Podłóż ją, by ją uzbroić."
	mine_type = /obj/effect/mine/stun

/obj/item/deployablemine/smartstun
	name = "inteligentna mina do rozłożenia"
	desc = "Nieuzbrojona inteligentna mina ogłuszająca. Podłóż ją, by ją uzbroić."
	mine_type = /obj/effect/mine/stun/smart

/obj/item/deployablemine/rapid
	name = "szybka inteligentna mina do rozłożenia"
	desc = "Nieuzbrojona inteligentna mina ogłuszająca, którą można bardzo szybko podłożyć."
	mine_type = /obj/effect/mine/stun/smart/adv
	arming_time = 10
	w_class = WEIGHT_CLASS_SMALL

/obj/item/deployablemine/heavy
	name = "inteligentna mina „Młot” do rozłożenia"
	desc = "Nieuzbrojona inteligentna ciężka mina ogłuszająca, którą trudno rozbroić."
	mine_type = /obj/effect/mine/stun/smart/heavy
	arming_time = 50

/obj/item/deployablemine/explosive
	mine_type = /obj/effect/mine/explosive

/obj/item/deployablemine/honk
	name = "honkblaster 1000 do rozłożenia"
	desc = "Zaawansowana żartobliwa mina lądowa dla klaunów, honk! Po uruchomieniu wali w głowę wyjątkowo głośnym HONK. Podłóż ją, by ją uzbroić, albo zmień jej dźwięk syntezatorem dźwięku."
	mine_type = /obj/effect/mine/sound

/obj/item/deployablemine/traitor
	name = "wybuchowa gumowa kaczka"
	desc = "Ładunek wybuchowy z zapalnikiem naciskowym przebrany za gumową kaczkę. Podłóż go, by uzbroić."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	mine_type = /obj/effect/mine/explosive/traitor
	w_class = WEIGHT_CLASS_SMALL

/obj/item/deployablemine/traitor/bigboom
	name = "silna wybuchowa gumowa kaczka"
	desc = "Ładunek wybuchowy z zapalnikiem naciskowym przebrany za gumową kaczkę. Podłóż go, by uzbroić. Ta wersja ma silny ładunek X4, który daje większy wybuch."
	mine_type = /obj/effect/mine/explosive/traitor/bigboom

/obj/item/deployablemine/gas
	name = "mina tlenowa"
	desc = "Nieuzbrojona mina, która po uruchomieniu uwalnia tlen do powietrza. Trochę bez sensu, co?"
	mine_type = /obj/effect/mine/gas

/obj/item/deployablemine/plasma
	name = "mina zapalająca"
	desc = "Nieuzbrojona mina, która po uruchomieniu uwalnia plazmę do powietrza, a potem ją zapala."
	mine_type = /obj/effect/mine/gas/plasma

/obj/item/deployablemine/sleepy
	name = "mina usypiająca"
	desc = "Nieuzbrojona mina, która po uruchomieniu uwalnia N2O do powietrza. Dobranoc!"
	mine_type = /obj/effect/mine/gas/n2o

/obj/item/deployablemine/afterattack(atom/plantspot, mob/user, proximity)
	if(!proximity)
		return

	if(!istype(plantspot,/turf/open)) // you can't plant a mine inside a wall or on a mob
		return

	if(isspaceturf(plantspot))
		to_chat(user, "<span class='warning'>Nie możesz podłożyć miny w kosmosie!</span>")
		return

	if((istype(plantspot,/turf/open/lava)) || (istype(plantspot,/turf/open/chasm)))
		to_chat(user, "<span class='warning'>Nie możesz tu podłożyć miny!</span>")
		return

	to_chat(user, "<span class='notice'>Zaczynasz uzbrajać [src]...</span>")
	if(do_after(user, arming_time, target = src))
		new mine_type(plantspot)
		to_chat(user, "<span class='notice'>Podkładasz i uzbrajasz [src].</span>")
		log_combat(user, src, "planted and armed")
		qdel(src)

/obj/effect/mine
	name = "atrapa miny"
	desc = "Lepiej trzymaj się od tego z daleka."
	density = FALSE
	anchored = TRUE
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "uglymine"
	var/triggered = FALSE
	var/smartmine = 0
	var/disarm_time = 200
	var/disarm_product = /obj/item/deployablemine // ie what drops when the mine is disarmed
	///if this has a value, the explosion of the mine will be delayed slightly for dramatic effect while the sound plays
	var/dramatic_sound

/obj/effect/mine/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/mine/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/multitool))
		to_chat(user, "<span class='notice'>Zaczynasz rozbrajać [src]...</span>")
		if(do_after(user, disarm_time, target = src))
			to_chat(user, "<span class='notice'>Rozbrajasz [src].</span>")
			new disarm_product(src.loc)
			qdel(src)

/obj/effect/mine/proc/mineEffect(mob/victim)
	to_chat(victim, "<span class='danger'>*klik*</span>")

/obj/effect/mine/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(!isturf(loc) || AM.throwing || (AM.movement_type & (FLYING | FLOATING)) || !AM.has_gravity() || triggered)
		return
	if(ismob(AM))
		checksmartmine(AM)
	else
		triggered = TRUE	//ensures multiple explosions aren't queued if/while the mine is delayed
		INVOKE_ASYNC(src, PROC_REF(triggermine), AM)

/obj/effect/mine/proc/checksmartmine(mob/living/target)
	if(target)
		if(smartmine && target.has_mindshield_hud_icon())
			return
		else if(dramatic_sound)
			triggered = TRUE
			playsound(loc, dramatic_sound, 100, 1)
			target.Paralyze(30, TRUE, TRUE) //"Trip" the mine if you will. Ignores stun immunity.
			addtimer(CALLBACK(src, PROC_REF(triggermine), target), 10)
			return
		else
			triggered = 1
			triggermine(target)
					

/obj/effect/mine/proc/triggermine(mob/living/victim)
	visible_message("<span class='danger'>[victim] uruchamia [icon2html(src, viewers(src))] [src]!</span>")
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	mineEffect(victim)
	SEND_SIGNAL(src, COMSIG_MINE_TRIGGERED, victim)
	qdel(src)

/obj/effect/mine/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	triggermine()

/obj/effect/mine/explosive
	name = "mina wybuchowa"
	var/range_devastation = 0
	var/range_heavy = 1
	var/range_light = 2
	var/range_flash = 3
	disarm_product = /obj/item/deployablemine/explosive

/obj/effect/mine/explosive/traitor
	name = "gumowa kaczuszka"
	desc = "Gumowa kaczuszko, jesteś super, z tobą kąpiel to frajdy suuuuper. Gumowa kaczuszko, kocham cię baaaardzooo~"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	dramatic_sound = 'sound/items/bikehorn.ogg'
	range_heavy = 2
	range_light = 3
	range_flash = 4
	disarm_time = 400
	disarm_product = /obj/item/deployablemine/traitor

/obj/effect/mine/explosive/traitor/bigboom
	range_devastation = 2
	range_heavy = 4
	range_light = 8
	range_flash = 6
	disarm_product = /obj/item/deployablemine/traitor/bigboom

/obj/effect/mine/explosive/mineEffect(mob/victim)
	explosion(loc, range_devastation, range_heavy, range_light, range_flash)

/obj/effect/mine/stun
	name = "mina ogłuszająca"
	var/stun_time = 150
	var/damage = 0
	disarm_product = /obj/item/deployablemine/stun

/obj/effect/mine/stun/smart
	name = "inteligentna mina ogłuszająca"
	desc = "Zaawansowana mina z systemem rozpoznawania swój-obcy, która ignoruje osoby z implantem ochrony umysłu."
	smartmine = 1
	disarm_time = 250
	disarm_product = /obj/item/deployablemine/smartstun

/obj/effect/mine/stun/smart/adv
	name = "szybka inteligentna mina"
	disarm_time = 120
	disarm_product = /obj/item/deployablemine/rapid

/obj/effect/mine/stun/smart/heavy
	name = "inteligentna mina „Młot”"
	disarm_time = 350
	stun_time = 230
	damage = 40
	disarm_product = /obj/item/deployablemine/heavy



/obj/effect/mine/stun/mineEffect(mob/living/victim)
	if(isliving(victim))
		victim.adjustStaminaLoss(stun_time)
		victim.adjustBruteLoss(damage)

/obj/effect/mine/shrapnel
	name = "mina odłamkowa"
	var/shrapnel_type = /obj/item/projectile/bullet/shrapnel
	var/shrapnel_magnitude = 3

/obj/effect/mine/shrapnel/mineEffect(mob/victim)
	AddComponent(/datum/component/pellet_cloud, projectile_type=shrapnel_type, magnitude=shrapnel_magnitude)

/obj/effect/mine/shrapnel/sting
	name = "mina żądłowa"
	shrapnel_type = /obj/item/projectile/bullet/pellet/stingball

/obj/effect/mine/kickmine
	name = "mina wykopująca"

/obj/effect/mine/kickmine/mineEffect(mob/victim)
	if(isliving(victim) && victim.client)
		to_chat(victim, "<span class='userdanger'>Zostajesz wyrzucony BEZ POWODU!</span>")
		qdel(victim.client)


/obj/effect/mine/gas
	name = "mina tlenowa"
	var/gas_amount = 360
	var/gas_type = "o2"
	disarm_product = /obj/item/deployablemine/gas

/obj/effect/mine/gas/mineEffect(mob/victim)
	atmos_spawn_air("[gas_type]=[gas_amount]")


/obj/effect/mine/gas/plasma
	name = "mina zapalająca"
	gas_type = "plasma"
	disarm_product = /obj/item/deployablemine/plasma


/obj/effect/mine/gas/n2o
	name = "mina usypiająca"
	gas_type = "n2o"
	disarm_product = /obj/item/deployablemine/sleepy

/obj/effect/mine/sound
	name = "honkblaster 1000"
	var/sound = 'sound/items/bikehorn.ogg'
	var/volume = 100
	disarm_time = 1200 // very long disarm time to expand the annoying factor
	disarm_product = /obj/item/deployablemine/honk

/obj/effect/mine/sound/mineEffect(mob/victim)
	playsound(loc, sound, volume, 1)

/obj/effect/mine/sound/attackby(obj/item/soundsynth/J, mob/user, params)
	if(istype(J, /obj/item/soundsynth))
		to_chat(user, "<span class='notice'>Zmieniasz ustawienia dźwięku [src].</span>")
		sound = J.selected_sound


/obj/effect/mine/sound/bwoink
	name = "mina bwoink"
	sound = 'sound/effects/adminhelp.ogg'

/obj/effect/mine/pickup
	name = "znajdźka"
	desc = "podnieś mnie"
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"
	density = FALSE
	var/duration = 0

/obj/effect/mine/pickup/Initialize(mapload)
	. = ..()
	animate(src, pixel_y = 4, time = 20, loop = -1)

/obj/effect/mine/pickup/triggermine(mob/victim)
	if(triggered)
		return
	triggered = 1
	invisibility = INVISIBILITY_ABSTRACT
	mineEffect(victim)
	qdel(src)


/obj/effect/mine/pickup/bloodbath
	name = "Czerwona kula"
	desc = "Czujesz złość już na sam jej widok."
	duration = 1200 //2min
	color = "#FF0000"
	var/mob/living/doomslayer
	var/obj/item/chainsaw/doomslayer/chainsaw

/obj/effect/mine/pickup/bloodbath/mineEffect(mob/living/carbon/victim)
	if(!victim.client || !istype(victim))
		return
	to_chat(victim, "<span class='reallybig redtext'>ROZRYWAJ I ROZDZIERAJ</span>")

	spawn(0)
		new /datum/hallucination/delusion(victim, TRUE, "demon",duration,0)

	chainsaw = new(victim.loc)
	victim.log_message("entered a blood frenzy", LOG_ATTACK)

	ADD_TRAIT(chainsaw, TRAIT_NODROP, CHAINSAW_FRENZY_TRAIT)
	victim.drop_all_held_items()
	victim.put_in_hands(chainsaw, forced = TRUE)
	chainsaw.attack_self(victim)
	victim.reagents.add_reagent(/datum/reagent/medicine/adminordrazine,25)
	to_chat(victim, "<span class='warning'>ZABIJ, ZABIJ, ZABIJ! NIE MASZ JUŻ SOJUSZNIKÓW, ZABIJ ICH WSZYSTKICH!</span>")

	var/datum/client_colour/colour = victim.add_client_colour(/datum/client_colour/bloodlust)
	QDEL_IN(colour, 11)
	doomslayer = victim
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(end_blood_frenzy))
	QDEL_IN(WEAKREF(src), duration)

/obj/effect/mine/pickup/bloodbath/proc/end_blood_frenzy()
	SIGNAL_HANDLER

	if(doomslayer)
		to_chat(doomslayer, "<span class='notice'>Twoja żądza krwi wsiąka z powrotem w bagno podświadomości, a ty odzyskujesz panowanie nad sobą.</span>")
		doomslayer.log_message("exited a blood frenzy", LOG_ATTACK)
	if(chainsaw)
		qdel(chainsaw)

/obj/effect/mine/pickup/healing
	name = "Niebieska kula"
	desc = "Czujesz się lepiej już na sam jej widok."
	color = "#0000FF"

/obj/effect/mine/pickup/healing/mineEffect(mob/living/carbon/victim)
	if(!victim.client || !istype(victim))
		return
	to_chat(victim, "<span class='notice'>Czujesz się świetnie!</span>")
	victim.revive(full_heal = 1, admin_revive = 1)

/obj/effect/mine/pickup/speed
	name = "Żółta kula"
	desc = "Czujesz się szybszy już na sam jej widok."
	color = "#FFFF00"
	duration = 300

/obj/effect/mine/pickup/speed/mineEffect(mob/living/carbon/victim)
	if(!victim.client || !istype(victim))
		return
	to_chat(victim, "<span class='notice'>Czujesz się szybki!</span>")
	victim.add_movespeed_modifier(MOVESPEED_ID_YELLOW_ORB, update=TRUE, priority=100, multiplicative_slowdown=-2, blacklisted_movetypes=(FLYING|FLOATING))
	addtimer(CALLBACK(src, PROC_REF(finish_effect), victim), duration)

/obj/effect/mine/pickup/speed/proc/finish_effect(mob/living/carbon/victim)
	victim.remove_movespeed_modifier(MOVESPEED_ID_YELLOW_ORB)
	to_chat(victim, "<span class='notice'>Zwalniasz.</span>")
