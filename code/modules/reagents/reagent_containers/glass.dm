
/obj/item/reagent_containers/glass
	name = "szkło"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	obj_flags = UNIQUE_RENAME
	reagent_flags = OPENCONTAINER | DUNKABLE
	spillable = TRUE
	resistance_flags = ACID_PROOF


/obj/item/reagent_containers/glass/attack(mob/M, mob/user, obj/target)
	if(!canconsume(M, user))
		return

	if(!spillable)
		return

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] jest pusty!</span>")
		return

	if(istype(M))
		if(user.combat_mode)
			var/R
			M.visible_message("<span class='danger'>[user] chlusta zawartością [src] na [M]!</span>", \
							"<span class='userdanger'>[user] chlusta na ciebie zawartością [src]!</span>")
			if(reagents)
				for(var/datum/reagent/A in reagents.reagent_list)
					R += "[A] ([num2text(A.volume)]),"

			if(isturf(target) && reagents.reagent_list.len && thrownby)
				log_combat(thrownby, target, "splashed (thrown) [english_list(reagents.reagent_list)]")
				message_admins("[ADMIN_LOOKUPFLW(thrownby)] chlusta (rzutem) [english_list(reagents.reagent_list)] na [target] w [ADMIN_VERBOSEJMP(target)].")
			reagents.reaction(M, TOUCH)
			log_combat(user, M, "splashed", R)
			reagents.clear_reagents()
		else
			if(M != user)
				M.visible_message("<span class='danger'>[user] próbuje nakarmić [M] czymś z [src].</span>", \
						"<span class='userdanger'>[user] próbuje nakarmić cię czymś z [src].</span>")
				if(!do_mob(user, M))
					return
				if(!reagents || !reagents.total_volume)
					return // The drink might be empty after the delay, such as by spam-feeding
				M.visible_message("<span class='danger'>[user] karmi [M] czymś z [src].</span>", \
						"<span class='userdanger'>[user] karmi cię czymś z [src].</span>")
				log_combat(user, M, "fed", reagents.log_list())
			else
				to_chat(user, "<span class='notice'>Wypijasz łyk z [src].</span>")
			var/fraction = min(5/reagents.total_volume, 1)
			reagents.reaction(M, INGEST, fraction)
			addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, trans_to), M, 5), 5)
			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)

/obj/item/reagent_containers/glass/afterattack(obj/target, mob/user, proximity)
	. = ..()
	if((!proximity) || !check_allowed_items(target,target_self=1))
		return

	if(!spillable)
		return

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] jest pusty!</span>")
			return

		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] jest pełny.</span>")
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>Przelewasz [trans] j. roztworu do [target].</span>")
		playsound(src, "aquila/sound/items/pour.ogg", 15, TRUE) // AQUILA EDIT

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] jest pusty i nie można go uzupełnić!</span>")
			return

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] jest pełny.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>Napełniasz [src] [trans] j. zawartości [target].</span>")

	else if(reagents.total_volume)
		if(user.combat_mode)
			user.visible_message("<span class='danger'>[user] chlusta zawartością [src] na [target]!</span>", \
								"<span class='notice'>Chlustasz zawartością [src] na [target].</span>")
			reagents.reaction(target, TOUCH)
			reagents.clear_reagents()

/obj/item/reagent_containers/glass/attackby(obj/item/I, mob/user, params)
	var/hotness = I.is_hot()
	if(hotness && reagents)
		reagents.expose_temperature(hotness)
		to_chat(user, "<span class='notice'>Podgrzewasz [name] za pomocą [I]!</span>")

	if(istype(I, /obj/item/food/egg)) //breaking eggs
		var/obj/item/food/egg/E = I
		if(reagents)
			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[src] jest pełny.</span>")
			else
				to_chat(user, "<span class='notice'>Rozbijasz [E] w [src].</span>")
				E.reagents.trans_to(src, E.reagents.total_volume, transfered_by = user)
				qdel(E)
			return
	..()


/obj/item/reagent_containers/glass/beaker
	name = "zlewka"
	desc = "Zlewka. Mieści do 50 j."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	custom_materials = list(/datum/material/glass=500)
	fill_icon_thresholds = list(1, 20, 40, 60, 80, 100) //AQUILA EDIT - Paradise fill states

/obj/item/reagent_containers/glass/beaker/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/reagent_containers/glass/beaker/get_part_rating()
	return reagents.maximum_volume

/obj/item/reagent_containers/glass/beaker/jar
	name = "słoik na miód"
	desc = "Słoik na miód. Mieści do 50 j. słodkiej rozkoszy."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vapour"

/obj/item/reagent_containers/glass/beaker/large
	name = "duża zlewka"
	desc = "Duża zlewka. Mieści do 100 j."
	icon_state = "beakerlarge"
	materials = list(/datum/material/glass=2500)
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100)

/obj/item/reagent_containers/glass/beaker/plastic
	name = "bardzo duża zlewka"
	desc = "Bardzo duża zlewka. Mieści do 120 j."
	icon_state = "beakerwhite"
	materials = list(/datum/material/glass=2500, /datum/material/plastic=3000)
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,60,120)
	fill_icon_thresholds = list(1, 10, 20, 40, 60, 80, 100) //AQUILA EDIT - own fill states, large beaker ones are Paradise now

/obj/item/reagent_containers/glass/beaker/meta
	name = "zlewka z metamateriału"
	desc = "Duża zlewka. Mieści do 180 j."
	icon_state = "beakergold"
	fill_icon_thresholds = list(1, 10, 25, 50, 60, 80, 100) //AQUILA EDIT
	materials = list(/datum/material/glass=2500, /datum/material/plastic=3000, /datum/material/gold=1000, /datum/material/titanium=1000)
	volume = 180
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,60,120,180)

/obj/item/reagent_containers/glass/beaker/noreact
	name = "zlewka kriostatyczna"
	desc = "Zlewka kriostatyczna, w której chemikalia można przechowywać bez \
		reakcji. Mieści do 50 j."
	icon_state = "beakernoreact"
	materials = list(/datum/material/iron=3000)
	reagent_flags = OPENCONTAINER | NO_REACT
	volume = 50
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/glass/beaker/bluespace
	name = "zlewka bluespace"
	desc = "Zlewka bluespace, zasilana eksperymentalną technologią bluespace \
		oraz Pierwiastkiem Kubańskim połączonym ze Związkiem Pete. Mieści do \
		300 j."
	icon_state = "beakerbluespace"
	materials = list(/datum/material/glass = 5000, /datum/material/plasma = 3000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100,300)

/obj/item/reagent_containers/glass/beaker/cryoxadone
	list_reagents = list(/datum/reagent/medicine/cryoxadone = 30)

/obj/item/reagent_containers/glass/beaker/sulphuric
	list_reagents = list(/datum/reagent/toxin/acid = 50)

/obj/item/reagent_containers/glass/beaker/slime
	list_reagents = list(/datum/reagent/toxin/slimejelly = 50)

/obj/item/reagent_containers/glass/beaker/large/styptic
	name = "zbiornik rezerwowy: proszek hemostatyczny"
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 50)

/obj/item/reagent_containers/glass/beaker/large/silver_sulfadiazine
	name = "zbiornik rezerwowy: sulfadiazyna srebra"
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 50)

/obj/item/reagent_containers/glass/beaker/large/charcoal
	name = "zbiornik rezerwowy: węgiel aktywowany"
	list_reagents = list(/datum/reagent/medicine/charcoal = 50)

/obj/item/reagent_containers/glass/beaker/large/epinephrine
	name = "zbiornik rezerwowy: epinefryna"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 50)

/obj/item/reagent_containers/glass/beaker/synthflesh
	list_reagents = list(/datum/reagent/medicine/synthflesh = 50)

/obj/item/reagent_containers/glass/bucket
	name = "wiadro"
	desc = "To wiadro."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	materials = list(/datum/material/iron=200)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(5,10,15,20,25,30,50,70)
	volume = 70
	flags_inv = HIDEHAIR
	slot_flags = ITEM_SLOT_HEAD
	resistance_flags = NONE
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 75, "acid" = 50, "stamina" = 0, "bleed" = 0) //Weak melee protection, because you can wear it on your head
	slot_equipment_priority = list( \
		ITEM_SLOT_BACK, ITEM_SLOT_ID,\
		ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING,\
		ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_NECK,\
		ITEM_SLOT_FEET, ITEM_SLOT_GLOVES,\
		ITEM_SLOT_EARS, ITEM_SLOT_EYES,\
		ITEM_SLOT_BELT, ITEM_SLOT_SUITSTORE,\
		ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET,\
		ITEM_SLOT_DEX_STORAGE
	)

/obj/item/reagent_containers/glass/bucket/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/mop))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='warning'>W [src] skończyła się woda!</span>")
		else
			reagents.trans_to(O, 5, transfered_by = user)
			to_chat(user, "<span class='notice'>Moczysz [O] w [src].</span>")
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
	else if(isprox(O))
		to_chat(user, "<span class='notice'>Dodajesz [O] do [src].</span>")
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/cleanbot)
	else
		..()

/obj/item/reagent_containers/glass/bucket/equipped(mob/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		if(reagents.total_volume)
			to_chat(user, "<span class='userdanger'>Zawartość [src] wylewa się na ciebie!</span>")
			reagents.reaction(user, TOUCH)
			reagents.clear_reagents()
		reagents.flags = NONE

/obj/item/reagent_containers/glass/bucket/dropped(mob/user)
	..()
	if(reagents)
		reagents.flags = initial(reagent_flags)

/obj/item/reagent_containers/glass/bucket/equip_to_best_slot(var/mob/M)
	if(reagents.total_volume) //If there is water in a bucket, don't quick equip it to the head
		var/index = slot_equipment_priority.Find(ITEM_SLOT_HEAD)
		slot_equipment_priority.Remove(ITEM_SLOT_HEAD)
		. = ..()
		slot_equipment_priority.Insert(index, ITEM_SLOT_HEAD)
		return
	return ..()

/obj/item/reagent_containers/glass/waterbottle
	name = "butelka wody"
	desc = "Butelka wody napełniona w starej rozlewni na Ziemi."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "smallbottle"
	item_state = "bottle"
	list_reagents = list(/datum/reagent/water = 49.5, /datum/reagent/fluorine = 0.5)//see desc, don't think about it too hard
	materials = list(/datum/material/glass=0)
	volume = 50
	amount_per_transfer_from_this = 10
	fill_icon_thresholds = list(0, 10, 25, 50, 75, 80, 90)

	// The 2 bottles have separate cap overlay icons because if the bottle falls over while bottle flipping the cap stays fucked on the moved overlay
	var/cap_icon_state = "bottle_cap_small"
	var/cap_on = TRUE
	var/cap_lost = FALSE
	var/mutable_appearance/cap_overlay
	var/flip_chance = 10

/obj/item/reagent_containers/glass/waterbottle/Initialize(mapload)
	. = ..()
	cap_overlay = mutable_appearance(icon, cap_icon_state)
	if(cap_on)
		spillable = FALSE
		add_overlay(cap_overlay, TRUE)

/obj/item/reagent_containers/glass/waterbottle/examine(mob/user)
	. = ..()
	if(cap_lost)
		. += "<span class='notice'>Wygląda na to, że brakuje nakrętki.</span>"
	else if(cap_on)
		. += "<span class='notice'>Nakrętka jest mocno zakręcona, by nic się nie rozlało. Alt-kliknij, by ją zdjąć.</span>"
	else
		. += "<span class='notice'>Nakrętka została zdjęta. Alt-kliknij, by ją założyć.</span>"

/obj/item/reagent_containers/glass/waterbottle/AltClick(mob/user)
	if(cap_lost)
		to_chat(user, "<span class='warning'>Wygląda na to, że brakuje nakrętki! Gdzie się podziała?</span>")
		return

	var/fumbled = HAS_TRAIT(user, TRAIT_CLUMSY) && prob(5)
	if(cap_on || fumbled)
		cap_on = FALSE
		spillable = TRUE
		cut_overlay(cap_overlay, TRUE)
		animate(src, transform = null, time = 2, loop = 0)
		if(fumbled)
			to_chat(user, "<span class='warning'>Majstrujesz przy nakrętce [src]! Nakrętka spada na ziemię i po prostu znika. Gdzie ona się, do diabła, podziała?</span>")
			cap_lost = TRUE
		else
			to_chat(user, "<span class='notice'>Zdejmujesz nakrętkę z [src].</span>")
	else
		cap_on = TRUE
		spillable = FALSE
		add_overlay(cap_overlay, TRUE)
		to_chat(user, "<span class='notice'>Zakładasz nakrętkę na [src].</span>")
	update_icon()

/obj/item/reagent_containers/glass/waterbottle/is_refillable()
	if(cap_on)
		return FALSE
	. = ..()

/obj/item/reagent_containers/glass/waterbottle/is_drainable()
	if(cap_on)
		return FALSE
	. = ..()

/obj/item/reagent_containers/glass/waterbottle/attack(mob/M, mob/user, obj/target)
	if(cap_on && reagents.total_volume && istype(M))
		to_chat(user, "<span class='warning'>Zanim to zrobisz, musisz zdjąć nakrętkę!</span>")
		return
	. = ..()

/obj/item/reagent_containers/glass/waterbottle/afterattack(obj/target, mob/user, proximity)
	if(cap_on && (target.is_refillable() || target.is_drainable() || (reagents.total_volume && user.combat_mode)))
		to_chat(user, "<span class='warning'>Zanim to zrobisz, musisz zdjąć nakrętkę!</span>")
		return

	else if(istype(target, /obj/item/reagent_containers/glass/waterbottle))
		var/obj/item/reagent_containers/glass/waterbottle/WB = target
		if(WB.cap_on)
			to_chat(user, "<span class='warning'>[WB] ma mocno zakręconą nakrętkę!</span>")
	. = ..()

// heehoo bottle flipping
/obj/item/reagent_containers/glass/waterbottle/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(cap_on && reagents.total_volume)
		if(prob(flip_chance)) // landed upright
			src.visible_message("<span class='notice'>[src] ląduje pionowo!</span>")
			SEND_SIGNAL(throwingdatum.thrower, COMSIG_ADD_MOOD_EVENT, "bottle_flip", /datum/mood_event/bottle_flip)
		else // landed on it's side
			animate(src, transform = matrix(prob(50)? 90 : -90, MATRIX_ROTATE), time = 3, loop = 0)

/obj/item/reagent_containers/glass/waterbottle/pickup(mob/user)
	..()
	animate(src, transform = null, time = 1, loop = 0)

/obj/item/reagent_containers/glass/waterbottle/empty
	list_reagents = list()
	cap_on = FALSE

/obj/item/reagent_containers/glass/waterbottle/large
	desc = "Świeża, duża butelka wody ze sklepu."
	icon_state = "largebottle"
	materials = list(/datum/material/glass=0)
	list_reagents = list(/datum/reagent/water = 100)
	volume = 100
	amount_per_transfer_from_this = 20
	cap_icon_state = "bottle_cap"

/obj/item/reagent_containers/glass/waterbottle/large/empty
	list_reagents = list()
	cap_on = FALSE

/obj/item/pestle
	name = "tłuczek"
	desc = "Starożytne, proste narzędzie, którym razem z moździerzem miażdży się przedmioty albo wyciska z nich sok."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pestle"
	force = 7

/obj/item/reagent_containers/glass/mortar
	name = "moździerz"
	desc = "Specjalnie wyprofilowana misa o starożytnym kształcie. Włożone do niej przedmioty można zmiażdżyć tłuczkiem albo wycisnąć z nich sok, ale w przeciwieństwie do nowoczesnych metod jest to powolne i męczące. Alt + klik wyjmuje przedmiot."
	icon_state = "mortar"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50, 100)
	volume = 100
	reagent_flags = OPENCONTAINER
	spillable = TRUE
	var/obj/item/grinded

/obj/item/reagent_containers/glass/mortar/AltClick(mob/user)
	if(grinded)
		grinded.forceMove(drop_location())
		grinded = null
		to_chat(user, "Wyjmujesz przedmiot ze środka.")

/obj/item/reagent_containers/glass/mortar/attackby(obj/item/I, mob/living/carbon/human/user)
	..()
	if(istype(I,/obj/item/pestle))
		if(grinded)
			if(user.getStaminaLoss() > 50)
				to_chat(user, "<span class='danger'>Jesteś zbyt zmęczony, by pracować!</span>")
				return
			to_chat(user, "Zaczynasz ucierać...")
			if((do_after(user, 25, target = src)) && grinded)
				user.adjustStaminaLoss(40)
				if(grinded.juice_typepath) //prioritize juicing
					grinded.juice(reagents, user) //NSV13 - newfood juicing converts the item's own reagents, so it goes before the plain transfer
					to_chat(user, "Wyciskasz [grinded] na płyn.")
					QDEL_NULL(grinded)
					return
				if(grinded.reagents) //food and pills
					grinded.reagents.trans_to(src, grinded.reagents.total_volume, transfered_by = user)
				grinded.on_grind()
				reagents.add_reagent_list(grinded.grind_results)
				to_chat(user, "Ucierasz [grinded] na proszek.")
				QDEL_NULL(grinded)
				return
			return
		else
			to_chat(user, "<span class='danger'>Nie ma czego ucierać!</span>")
			return
	if(grinded)
		to_chat(user, "<span class='danger'>W środku już coś jest!</span>")
		return
	if(istype(I,/obj/item/reagent_containers))
		var/obj/item/reagent_containers/p = I
		if(p.prevent_grinding)
			to_chat(user, "<span class='danger'>Nie możesz tego utrzeć!</span>")
			return

	if(I.juice_typepath || I.grind_results)
		I.forceMove(src)
		grinded = I
		return
	to_chat(user, "<span class='danger'>Nie możesz tego utrzeć!</span>")

/obj/item/reagent_containers/glass/saline
	name = "kanister soli fizjologicznej"
	volume = 5000
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 5000)
