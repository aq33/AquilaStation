/obj/item/reagent_containers/hypospray
	name = "hypospray"
	desc = "Hypospray firmy DeForest Medical Corporation to sterylny autoinjektor z igłą powietrzną do szybkiego podawania leków pacjentom. Ma też dyszę, którą można zmieniać dawkę."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = list(1,5,15)
	resistance_flags = ACID_PROOF
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	var/ignore_flags = 0
	var/infinite = FALSE


/obj/item/reagent_containers/hypospray/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/reagent_containers/hypospray/attack(mob/living/M, mob/user)
	inject(M, user)

///Handles all injection checks, injection and logging.
/obj/item/reagent_containers/hypospray/proc/inject(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] jest pusty!</span>")
		return FALSE
	if(!iscarbon(M))
		return FALSE

	//Always log attemped injects for admins
	var/list/injected = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		injected += R.name
	var/contained = english_list(injected)
	log_combat(user, M, "attempted to inject", src, "([contained])")

	if(reagents.total_volume && (ignore_flags || M.can_inject(user, 1))) // Ignore flag should be checked first or there will be an error message.
		to_chat(M, "<span class='warning'>Czujesz maleńkie ukłucie!</span>")
		to_chat(user, "<span class='notice'>Wstrzykujesz [M] zawartość [src].</span>")
		playsound(loc, pick('sound/items/hypospray.ogg','sound/items/hypospray2.ogg'), 50, TRUE)

		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.reaction(M, INJECT, fraction)
		if(M.reagents)
			var/trans = 0
			if(!infinite)
				trans = reagents.trans_to(M, amount_per_transfer_from_this, transfered_by = user)
			else
				trans = reagents.copy_to(M, amount_per_transfer_from_this)

			to_chat(user, "<span class='notice'>Wstrzyknięto [trans] j. W [src] pozostało [reagents.total_volume] j.</span>")
			log_combat(user, M, "injected", src, "([contained])")
		return TRUE
	return FALSE

/obj/item/reagent_containers/hypospray/CMO/verb/empty()
	set name = "Empty Hypospray"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
		return
	if (alert(usr, "Na pewno chcesz to opróżnić?", "Opróżnij butelkę:", "Tak", "Nie") != "Tak")
		return
	if(isturf(usr.loc) && src.loc == usr)
		to_chat(usr, "<span class='notice'>Opróżniasz [src] na podłogę.</span>")
		reagents.reaction(usr.loc)
		src.reagents.clear_reagents()

/obj/item/reagent_containers/hypospray/CMO
	list_reagents = list(/datum/reagent/medicine/omnizine = 30)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/reagent_containers/hypospray/combat
	name = "bojowy iniektor stymulantów"
	desc = "Zmodyfikowany autoinjektor z igłą powietrzną, którego agenci wsparcia używają do szybkiego leczenia ran w walce."
	amount_per_transfer_from_this = 10
	item_state = "combat_hypo"
	icon_state = "combat_hypo"
	volume = 90
	possible_transfer_amounts = list(10,15,30,45)
	ignore_flags = 1 // So they can heal their comrades.
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30, /datum/reagent/medicine/omnizine = 30, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/stabilizing_nanites = 15)

/obj/item/reagent_containers/hypospray/combat/nanites
	name = "eksperymentalny bojowy iniektor stymulantów"
	desc = "Zmodyfikowany autoinjektor z igłą powietrzną do użytku w walce. Fabrycznie napełniony eksperymentalnymi nanitami medycznymi i stymulantem, które szybko leczą i dodają sił w boju."
	item_state = "nanite_hypo"
	icon_state = "nanite_hypo"
	volume = 100
	possible_transfer_amounts = list(5,10,15,30,50)
	list_reagents = list(/datum/reagent/medicine/adminordrazine/quantum_heal = 80, /datum/reagent/medicine/synaptizine = 20)

/obj/item/reagent_containers/hypospray/combat/nanites/update_icon()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/reagent_containers/hypospray/combat/heresypurge
	name = "przebijający iniektor wody święconej"
	desc = "Zmodyfikowany autoinjektor z igłą powietrzną do użytku w walce. Fabrycznie napełniony 5 dawkami mieszanki wody święconej i środka uspokajającego. Nie stosować na sojusznikach."
	item_state = "holy_hypo"
	icon_state = "holy_hypo"
	volume = 250
	possible_transfer_amounts = list(25,50,100)
	list_reagents = list(/datum/reagent/water/holywater = 150, /datum/reagent/peaceborg/tire = 50, /datum/reagent/peaceborg/confuse = 50)
	amount_per_transfer_from_this = 50

//MediPens

/obj/item/reagent_containers/hypospray/medipen
	name = "medipen z epinefryną"
	desc = "Szybki i bezpieczny sposób na ustabilizowanie pacjenta w stanie krytycznym, także dla personelu bez zaawansowanej wiedzy medycznej. Zawiera silny konserwant, który podany zwłokom opóźnia rozkład."
	icon_state = "medipen"
	item_state = "medipen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount_per_transfer_from_this = 13
	volume = 13
	possible_transfer_amounts = list()
	ignore_flags = 1 //so you can medipen through hardsuits
	reagent_flags = DRAWABLE
	flags_1 = null
	list_reagents = list(/datum/reagent/medicine/epinephrine = 10, /datum/reagent/toxin/formaldehyde = 3)
	custom_price = 40

/obj/item/reagent_containers/hypospray/medipen/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna się dławić [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return OXYLOSS//ironic. he could save others from oxyloss, but not himself.

/obj/item/reagent_containers/hypospray/medipen/inject(mob/living/M, mob/user)
	. = ..()
	if(.)
		reagents.maximum_volume = 0 //Makes them useless afterwards
		reagents.flags = NONE
		update_icon()

/obj/item/reagent_containers/hypospray/medipen/attack_self(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		inject(user, user)

/obj/item/reagent_containers/hypospray/medipen/update_icon()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/reagent_containers/hypospray/medipen/examine()
	. = ..()
	if(reagents && reagents.reagent_list.len)
		. += "<span class='notice'>Jest obecnie załadowany.</span>"
	else
		. += "<span class='notice'>Jest zużyty.</span>"

/obj/item/reagent_containers/hypospray/medipen/stimpack //goliath kiting
	name = "medipen stymulujący"
	desc = "Szybki sposób na pobudzenie wydzielania adrenaliny, dzięki któremu swobodniej poruszasz się w krępującym pancerzu."
	icon_state = "stimpen"
	item_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list(/datum/reagent/medicine/ephedrine = 10, /datum/reagent/consumable/coffee = 10)

/obj/item/reagent_containers/hypospray/medipen/stimpack/traitor
	desc = "Zmodyfikowany autoinjektor z amfetaminą do użytku w walce. Ma łagodne działanie lecznicze."
	list_reagents = list(/datum/reagent/medicine/amphetamine = 10, /datum/reagent/medicine/omnizine = 10)

/obj/item/reagent_containers/hypospray/medipen/pumpup
	name = "medipen pompujący"
	desc = "Zawiera bardzo dużą dawkę niezwykle silnego stymulantu, który na około pięć minut znacznie zwiększa odporność na spowolnienia i przyspiesza wychodzenie z nich. Nie stosować w ciąży."
	icon_state = "syndipen"
	item_state = "tbpen"
	volume = 50
	amount_per_transfer_from_this = 50
	list_reagents = list(/datum/reagent/medicine/pumpup = 50)

/obj/item/reagent_containers/hypospray/medipen/stimulants
	name = "medipen ze stymulantem"
	desc = "Zawiera bardzo dużą dawkę niezwykle silnego stymulantu, który na około pięć minut znacznie zwiększa szybkość ruchu i bardzo mocno skraca ogłuszenia. Nie stosować w ciąży."
	icon_state = "syndipen"
	item_state = "tbpen"
	volume = 50
	amount_per_transfer_from_this = 50
	list_reagents = list(/datum/reagent/medicine/amphetamine = 50)

/obj/item/reagent_containers/hypospray/medipen/morphine
	name = "medipen z morfiną"
	desc = "Szybki sposób, by wyrwać się z opresji! Choć poczujesz się dość senny."
	icon_state = "morphen"
	item_state = "morphen"
	list_reagents = list(/datum/reagent/medicine/morphine = 10)

/obj/item/reagent_containers/hypospray/medipen/dexalin
	name = "medipen z deksaliną"
	icon_state = "dexpen"
	item_state = "dexpen"
	desc = "Autoinjektor z deksaliną, który szybko leczy obrażenia od niedotlenienia."
	list_reagents = list(/datum/reagent/medicine/dexalin = 10)

/obj/item/reagent_containers/hypospray/medipen/tuberculosiscure
	name = "autoinjektor BVAK"
	desc = "Autoinjektor z zestawem odtrutek na biowirusy. Ma dwie dawki: dla ciebie i dla kogoś innego. Wstrzyknij po zakażeniu."
	icon_state = "tbpen"
	item_state = "tbpen"
	volume = 60
	amount_per_transfer_from_this = 30
	list_reagents = list(/datum/reagent/medicine/atropine = 10, /datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/salbutamol = 20, /datum/reagent/medicine/spaceacillin = 20)

/obj/item/reagent_containers/hypospray/medipen/tuberculosiscure/update_icon()
	if(reagents.total_volume > 30)
		icon_state = initial(icon_state)
	else if (reagents.total_volume > 0)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/reagent_containers/hypospray/medipen/survival
	name = "medipen przetrwania"
	desc = "Medipen do przetrwania w najsurowszych warunkach: leczy i chroni przed zagrożeniami środowiskowymi. OSTRZEŻENIE: nie wstrzykuj kilku penów jeden po drugim."
	icon_state = "survpen"
	item_state = "survpen"
	volume = 57
	amount_per_transfer_from_this = 57
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/tricordrazine = 15, /datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/lavaland_extract = 2, /datum/reagent/medicine/omnizine = 5)

/obj/item/reagent_containers/hypospray/medipen/species_mutator
	name = "medipen mutujący gatunek"
	desc = "Wyrusz w szaloną podróż po rasowej nieczułości, \
		dosłownie przywłaszczając sobie inne rasy."
	volume = 1
	amount_per_transfer_from_this = 1
	list_reagents = list("unstablemutationtoxin" = 1)

/obj/item/reagent_containers/hypospray/medipen/atropine
	name = "autoinjektor z atropiną"
	desc = "Szybki sposób na uratowanie kogoś w stanie krytycznym!"
	icon_state = "atropen"
	item_state = "atropen"
	list_reagents = list(/datum/reagent/medicine/atropine = 10)

/obj/item/reagent_containers/hypospray/medipen/snail
	name = "zastrzyk dla ślimaków"
	desc = "Uniwersalny lek dla ślimaków! Nie stosować na nie-ślimakach!"
	list_reagents = list(/datum/reagent/snail = 10)
	icon_state = "snail"
	item_state = "snail"

/obj/item/reagent_containers/hypospray/medipen/magillitis
	name = "eksperymentalny autoinjektor"
	desc = "Iniektor igłowy na niestandardowej ramie z małym jednorazowym zbiornikiem z eksperymentalną surowicą. W przeciwieństwie do popularniejszej ramy medipena nie przebija pancerzy ani skafandrów, a substancji w środku nie da się wydobyć."
	icon_state = "gorillapen"
	item_state = "gorillapen"
	volume = 5
	ignore_flags = 0
	reagent_flags = NONE
	list_reagents = list(/datum/reagent/magillitis = 5)
