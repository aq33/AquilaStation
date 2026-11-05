//Cardboard cutouts! They're man-shaped and can be colored with a crayon to look like a human in a certain outfit, although it's limited, discolored, and obvious to more than a cursory glance.
/obj/item/cardboard_cutout
	name = "tekturowa makieta"
	desc = "Tekturowa makieta o niewyraźnie ludzkich kształtach. Jest zupełnie pusta."
	icon = 'icons/obj/cardboard_cutout.dmi'
	icon_state = "cutout_basic"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE
	// Possible restyles for the cutout;
	// add an entry in change_appearance() if you add to here
	var/list/possible_appearances = list("Majtek", "Klaun", "Mim",
		"Zdrajca", "Operator nuklearny", "Kultysta", "Kultysta Ratvara",
		"Rewolucjonista", "Czarodziej", "Shadowling", "Ksenomorf", "Pokojówka ksenomorf", "Rojowiec",
		"Popielny wędrowiec", "Oficer szwadronu śmierci", "Ian", "Demon rzezi",
		"Demon śmiechu", "Prywatny ochroniarz")
	var/pushed_over = FALSE //If the cutout is pushed over and has to be righted
	var/deceptive = FALSE //If the cutout actually appears as what it portray and not a discolored version

	var/lastattacker = null

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/cardboard_cutout/attack_hand(mob/living/user)
	if(!user.combat_mode || pushed_over)
		return ..()
	user.visible_message("<span class='warning'>[user] przewraca [src]!</span>", "<span class='danger'>Przewracasz [src]!</span>")
	playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
	push_over()

/obj/item/cardboard_cutout/proc/push_over()
	name = initial(name)
	desc = "[initial(desc)] Jest przewrócona."
	icon = initial(icon)
	icon_state = "cutout_pushed_over"
	remove_atom_colour(FIXED_COLOUR_PRIORITY)
	alpha = initial(alpha)
	pushed_over = TRUE

/obj/item/cardboard_cutout/attack_self(mob/living/user)
	if(!pushed_over)
		return
	to_chat(user, "<span class='notice'>Stawiasz [src].</span>")
	desc = initial(desc)
	icon = initial(icon)
	icon_state = initial(icon_state) //This resets a cutout to its blank state - this is intentional to allow for resetting
	pushed_over = FALSE

/obj/item/cardboard_cutout/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/crayon))
		change_appearance(I, user)
		return
	// Why yes, this does closely resemble mob and object attack code.
	if(I.item_flags & NOBLUDGEON)
		return
	if(!I.force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)
	else if(I.hitsound)
		playsound(loc, I.hitsound, get_clamped_volume(), 1, -1)

	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)

	if(I.force)
		user.visible_message("<span class='danger'>[user] uderza [src] za pomocą [I]!</span>", \
			"<span class='danger'>Uderzasz [src] za pomocą [I]!</span>")
		if(prob(I.force))
			push_over()

/obj/item/cardboard_cutout/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	if(istype(P, /obj/item/projectile/bullet/reusable))
		P.on_hit(src, 0, piercing_hit)
	visible_message("<span class='danger'>[P] trafia [src]!</span>")
	playsound(src, 'sound/weapons/slice.ogg', 50, 1)
	if(prob(P.damage))
		push_over()
	return BULLET_ACT_HIT

/obj/item/cardboard_cutout/proc/change_appearance(obj/item/toy/crayon/crayon, mob/living/user)
	if(!crayon || !user)
		return
	if(pushed_over)
		to_chat(user, "<span class='warning'>Najpierw postaw [src]!</span>")
		return
	if(crayon.check_empty(user))
		return
	if(crayon.is_capped)
		to_chat(user, "<span class='warning'>Najpierw zdejmij zatyczkę!</span>")
		return
	var/new_appearance = input(user, "Wybierz nowy wygląd dla [src].", "Oszustwo XXVI wieku") as null|anything in sortList(possible_appearances)
	if(!new_appearance || !crayon || !user.canUseTopic(src, BE_CLOSE))
		return
	if(!do_after(user, 10, FALSE, src, TRUE))
		return
	user.visible_message("<span class='notice'>[user] zmienia wygląd [src].</span>", "<span class='notice'>Voilà! Zmieniasz wygląd [src].</span>")
	crayon.use_charges(1)
	crayon.check_empty(user)
	alpha = 255
	icon = initial(icon)
	if(!deceptive)
		add_atom_colour("#FFD7A7", FIXED_COLOUR_PRIORITY)
	switch(new_appearance)
		if("Majtek") //Nsv13 - Crayon eaters
			name = "[human_full_name_random(MALE)]" // AQ edit
			desc = "Tekturowa makieta majtka."
			icon_state = "cutout_greytide"
		if("Klaun")
			name = pick(GLOB.clown_names)
			desc = "Tekturowa makieta klauna. Masz wrażenie, że powinna stać w kącie."
			icon_state = "cutout_clown"
		if("Mim")
			name = pick(GLOB.mime_names)
			desc = "...(Tekturowa makieta mima.)"
			icon_state = "cutout_mime"
		if("Zdrajca")
			name = "[pick("Unknown", "Kapitan")]"
			desc = "Tekturowa makieta zdrajcy."
			icon_state = "cutout_traitor"
		if("Operator nuklearny")
			name = "[pick("Unknown", "ŁĄCZNOŚĆ", "Telekomunikacja", "SI", "cichy operator", "SKRYTOŚĆ", "skradaczek", "MEDYK", "Medyk")]"
			desc = "Tekturowa makieta operatora nuklearnego."
			icon_state = "cutout_fluke"
		if("Kultysta")
			name = "Unknown"
			desc = "Tekturowa makieta kultysty."
			icon_state = "cutout_cultist"
		if("Kultysta Ratvara")
			name = "[human_full_name_random(MALE)]" // AQ EDIT
			desc = "Tekturowa makieta sługi Ratvara."
			icon_state = "cutout_servant"
		if("Rewolucjonista")
			name = "Unknown"
			desc = "Tekturowa makieta rewolucjonisty."
			icon_state = "cutout_viva"
		if("Czarodziej")
			name = "[pick(GLOB.wizard_first)], [pick(GLOB.wizard_second)]"
			desc = "Tekturowa makieta czarodzieja."
			icon_state = "cutout_wizard"
		if("Shadowling")
			name = "Unknown"
			desc = "Tekturowa makieta shadowlinga."
			icon_state = "cutout_shadowling"
		if("Ksenomorf")
			name = "łowca obcych ([rand(1, 999)])"
			desc = "Tekturowa makieta ksenomorfa."
			icon_state = "cutout_fukken_xeno"
			if(prob(25))
				alpha = 75 //Spooky sneaking!
		if("Pokojówka ksenomorf")
			name = "zmysłowa pokojówka ksenomorf ([rand(1, 999)])"
			desc = "Tekturowa makieta pokojówki ksenomorfa."
			icon_state = "cutout_lusty"
		if("Rojowiec")
			name = "Rojowiec ([rand(1, 999)])"
			desc = "Tekturowa makieta rojowca."
			icon_state = "cutout_swarmer"
		if("Popielny wędrowiec")
			name = random_lizard_name(pick(MALE, FEMALE))
			desc = "Tekturowa makieta popielnego wędrowca."
			icon_state = "cutout_free_antag"
		if("Oficer szwadronu śmierci")
			name = pick(GLOB.commando_names)
			desc = "Tekturowa makieta komandosa śmierci."
			icon_state = "cutout_deathsquad"
		if("Ian")
			name = "Ian"
			desc = "Tekturowa makieta ukochanego corgi Starszego Oficera."
			icon_state = "cutout_ian"
		if("Demon rzezi")
			name = "demon rzezi"
			desc = "Tekturowa makieta demona rzezi."
			icon = 'icons/mob/mob.dmi'
			icon_state = "daemon"
		if("Demon śmiechu")
			name = "demon śmiechu"
			desc = "Tekturowa makieta demona śmiechu."
			icon = 'icons/mob/mob.dmi'
			icon_state = "bowmon"
		if("Prywatny ochroniarz")
			name = "Prywatny ochroniarz"
			desc = "Tekturowa makieta prywatnego ochroniarza."
			icon_state = "cutout_ntsec"
	return 1

/obj/item/cardboard_cutout/setDir(newdir)
	dir = SOUTH

/obj/item/cardboard_cutout/adaptive //Purchased by Syndicate agents, these cutouts are indistinguishable from normal cutouts but aren't discolored when their appearance is changed
	deceptive = TRUE

//	--- CHESS PIECES ---

// WHITE

/obj/item/cardboard_cutout/adaptive/chess
	desc = "Duża tekturowa makieta przypominająca figurę szachową."

/obj/item/cardboard_cutout/adaptive/chess/king
	name = "Biały Król"
	icon_state = "cutout_ian";

/obj/item/cardboard_cutout/adaptive/chess/queen
	name = "Biały Hetman"
	icon_state = "cutout_clown";

/obj/item/cardboard_cutout/adaptive/chess/rook
	name = "Biała Wieża"
	icon_state = "cutout_deathsquad";

/obj/item/cardboard_cutout/adaptive/chess/knight
	name = "Biały Skoczek"
	icon_state = "cutout_lusty";

/obj/item/cardboard_cutout/adaptive/chess/bishop
	name = "Biały Goniec"
	icon_state = "cutout_ntsec";

/obj/item/cardboard_cutout/adaptive/chess/pawn
	name = "Biały Pionek"
	icon_state = "cutout_greytide";

// BLACK

/obj/item/cardboard_cutout/adaptive/chess/black
	color = "#9999BB";

/obj/item/cardboard_cutout/adaptive/chess/black/king
	name = "Czarny Król"
	icon_state = "cutout_wizard";

/obj/item/cardboard_cutout/adaptive/chess/black/queen
	name = "Czarny Hetman"
	icon_state = "cutout_traitor";

/obj/item/cardboard_cutout/adaptive/chess/black/rook
	name = "Czarna Wieża"
	icon_state = "cutout_cultist";

/obj/item/cardboard_cutout/adaptive/chess/black/knight
	name = "Czarny Skoczek"
	icon_state = "cutout_fukken_xeno";

/obj/item/cardboard_cutout/adaptive/chess/black/bishop
	name = "Czarny Goniec"
	icon_state = "cutout_fluke";

/obj/item/cardboard_cutout/adaptive/chess/black/pawn
	name = "Czarny Pionek"
	icon_state = "cutout_shadowling";
