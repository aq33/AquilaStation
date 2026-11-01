//Ninja modules for MODsuits

///Cloaking - Lowers the user's visibility, can be interrupted by being touched or attacked.
/obj/item/mod/module/stealth
	name = "prototypowy moduł maskujący MOD"
	desc = "Gruntowna przeróbka skafandra; to rodzaj technologii maskowania wizualnego, która za pomocą ezoterycznej technologii \
		zagina światło wokół użytkownika, a materiały mimetyczne dopasowują powierzchnię skafandra do \
		otoczenia na podstawie danych z czujników. Z jakiegoś powodu ta technologia jest rzadko spotykana."
	icon_state = "cloak"
	module_type = MODULE_TOGGLE
	complexity = 4
	active_power_cost = DEFAULT_CHARGE_DRAIN * 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/stealth)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// Whether or not the cloak turns off on bumping.
	var/bumpoff = TRUE
	/// The alpha applied when the cloak is on.
	var/stealth_alpha = 50

/obj/item/mod/module/stealth/on_activation()
	if(bumpoff)
		RegisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP, PROC_REF(unstealth))
	RegisterSignal(mod.wearer, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	RegisterSignal(mod.wearer, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignal(mod.wearer, list(COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED), PROC_REF(unstealth))
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)
	drain_power(use_power_cost)

/obj/item/mod/module/stealth/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)

/obj/item/mod/module/stealth/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	to_chat(mod.wearer, span_warning("[src] rozładowuje się przy kontakcie!"))
	do_sparks(2, TRUE, src)
	drain_power(use_power_cost)
	deactivate()

/obj/item/mod/module/stealth/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/mod/module/stealth/proc/on_bullet_act(datum/source, obj/item/projectile/projectile)
	SIGNAL_HANDLER

	if(projectile.nodamage)
		return
	unstealth(source)

//Advanced Cloaking - Doesn't turf off on bump, less power drain, more stealthy.
/obj/item/mod/module/stealth/ninja
	name = "zaawansowany moduł maskujący MOD"
	desc = "Najnowsze osiągnięcie technologii maskowania; ten moduł to zdecydowane ulepszenie poprzednich wersji. \
		Pole dostrojono tak, by reagowało jeszcze szybciej, i jest na tyle stabilne, że \
		działa dalej nawet wtedy, gdy użytkownik na kogoś wpadnie. \
		Pobór energii drastycznie zmniejszono, co czyni go idealnym do zajęć takich jak \
		długie stanie przy wieżyczkach strażniczych."
	icon_state = "cloak_ninja"
	bumpoff = FALSE
	stealth_alpha = 20
	active_power_cost = DEFAULT_CHARGE_DRAIN
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 3 SECONDS

/obj/item/mod/module/stealth/ninja/on_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, REF(src))

/obj/item/mod/module/stealth/ninja/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	REMOVE_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, REF(src))

///Camera Vision - Prevents flashes, blocks tracking.
/obj/item/mod/module/welding/camera_vision
	name = "moduł zakłócania kamer MOD"
	desc = "Moduł montowany w hełmie skafandra. Ta specjalistyczna technologia służy do podstępów: \
		zastępuje zwykły wizjer wyświetlaczem z nanotechnologii, który potrafi wyświetlać specjalne obrazy \
		o dokładnie takiej częstotliwości, by zagłuszyć wszystkie znane formy śledzenia przez kamery i rozpoznawania twarzy, \
		a do tego automatycznie przyciemnia nadchodzące błyski, chroniąc oczy użytkownika. Stań się niewidzialny."
	icon_state = "welding_camera"
	removable = FALSE
	complexity = 0
	overlay_state_inactive = null
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/welding/camera_vision/on_part_activation()
	. = ..()
	RegisterSignal(mod.wearer, COMSIG_LIVING_CAN_TRACK, PROC_REF(can_track))

/obj/item/mod/module/welding/camera_vision/on_part_deactivation(deleting = FALSE)
	. = ..()
	UnregisterSignal(mod.wearer, COMSIG_LIVING_CAN_TRACK)

/obj/item/mod/module/welding/camera_vision/proc/can_track(datum/source, mob/user)
	SIGNAL_HANDLER

	return COMPONENT_CANT_TRACK

//Ninja Star Dispenser - Dispenses ninja stars.
/obj/item/mod/module/dispenser/ninja
	name = "moduł dozownika gwiazdek ninja MOD"
	desc = "Ta technologia Klanu Pająka wykorzystuje znane zasady równoważności energii i materii, \
		przemieniając nanity obecne już w skafandrze noszącego w monomolekularne shurikeny. \
		Nie mają one co prawda morderczej ostrości zwykłych gwiazdek do rzucania, \
		ale razią prądem uciekające cele i noszą symbol Klanu Pająka."
	dispense_type = /obj/item/throwing_star/stamina/ninja
	cooldown_time = 0.5 SECONDS

/obj/item/throwing_star/stamina/ninja
	name = "gwiazdka ninja do rzucania"
	throwforce = 10

///Hacker - This module hooks onto your empty-handed grab intent clicks and causes ninja actions.
/obj/item/mod/module/hacker
	name = "moduł hakera MOD"
	desc = "Zbudowany w jednym celu, do walki elektronicznej, ten moduł montuje się w dłoniach. \
		Dzięki komunikacji bliskiego zasięgu i precyzyjnej elektrostymulacji przewodów w maszynach \
		to marzenie każdego hakera służy zwykle do przechodzenia przez drzwi jak zjawa. \
		Potrafi też nieprecyzyjnie elektrostymulować przeciwników zabójcy-sabotażysty przy atakach rozbrajających."
	icon_state = "hacker"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/hacker)
	required_slots = list(ITEM_SLOT_GLOVES)
	/// Minimum amount of power we can drain in a single drain action
	var/mindrain = 200
	/// Maximum amount of power we can drain in a single drain action
	var/maxdrain = 400
	/// Whether or not the communication console hack was used to summon another antagonist.
	var/communication_console_hack_success = FALSE
	/// How many times the module has been used to force open doors.
	var/door_hack_counter = 0

/obj/item/mod/module/hacker/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_HUMAN_EARLY_UNARMED_ATTACK,  PROC_REF(hack))

/obj/item/mod/module/hacker/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)

// We have no right click attacks, so the hacker works on empty-handed clicks with the grab intent
/obj/item/mod/module/hacker/proc/hack(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	// right click like on Bee, grab intent for the old intent mode
	if(!(LAZYACCESS(modifiers, RIGHT_CLICK) || source.a_intent == INTENT_GRAB) || !proximity)
		return NONE
	target.add_fingerprint(mod.wearer)
	return target.ninjadrain_act(mod.wearer, src)

/obj/item/mod/module/hacker/proc/charge_message(atom/drained_atom, drain_amount)
	if(drain_amount)
		to_chat(mod.wearer, span_notice("Pozyskano <B>[drain_amount]</B> jedn. energii z: [drained_atom]."))
	else
		to_chat(mod.wearer, span_warning("[drained_atom] nie ma już energii, musisz znaleźć inne źródło!"))

///Weapon Recall - Teleports your katana to you, prevents gun use.
/obj/item/mod/module/weapon_recall
	name = "moduł przywoływania broni MOD"
	desc = "Podstawa życia członka klanu jako mistrza miecza i moduł symbolizujący jego wieczną więź z bronią. \
		Łączy się z mikronapędem bluespace w rękojeści energetycznej katany i potrafi przywołać ją do \
		wprawnych dłoni użytkownika, gdziekolwiek jest. Ci, którzy zawiążą taką więź z bronią, są jednak przeklęci, \
		by stopić swoje istnienie z walką w jednym celu: Pokonać Przeciwnika. \
		Ich dłoń jest dłonią, która tnie, ich ciało ciałem, które tnie, ich umysł umysłem, który tnie. \
		Broń dystansowa jest zakazana."
	icon_state = "recall"
	removable = FALSE
	module_type = MODULE_USABLE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/weapon_recall)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES, ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// The item linked to the module that will get recalled.
	var/obj/item/linked_weapon
	/// The accepted typepath we can link to.
	var/accepted_type = /obj/item/energy_katana

/obj/item/mod/module/weapon_recall/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_NOGUNS, REF(src))

/obj/item/mod/module/weapon_recall/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_NOGUNS, REF(src))

/obj/item/mod/module/weapon_recall/on_use()
	if(!linked_weapon)
		var/obj/item/weapon_to_link = mod.wearer.is_holding_item_of_type(accepted_type)
		if(!weapon_to_link)
			balloon_alert(mod.wearer, "brak połączonej broni!")
			return
		set_weapon(weapon_to_link)
		balloon_alert(mod.wearer, "połączono: [linked_weapon.name]")
		return
	if(linked_weapon in mod.wearer.GetAllContents())
		balloon_alert(mod.wearer, "już jest na tobie!")
		return
	var/distance = get_dist(mod.wearer, linked_weapon)
	var/in_view = (linked_weapon in view(mod.wearer)) && !(linked_weapon in get_turf(mod.wearer))
	if(!in_view && !drain_power(use_power_cost * distance))
		balloon_alert(mod.wearer, "za mało energii!")
		return
	linked_weapon.forceMove(linked_weapon.drop_location())
	if(in_view)
		do_sparks(5, FALSE, linked_weapon)
		mod.wearer.visible_message(span_danger("[linked_weapon] leci w stronę: [mod.wearer]!"),span_warning("Wyciągasz rękę, a [linked_weapon] leci w twoją stronę!"))
		linked_weapon.throw_at(mod.wearer, distance+1, linked_weapon.throw_speed, mod.wearer)
	else
		recall_weapon()

/obj/item/mod/module/weapon_recall/proc/set_weapon(obj/item/weapon)
	linked_weapon = weapon
	RegisterSignal(linked_weapon, COMSIG_MOVABLE_IMPACT, PROC_REF(catch_weapon))
	RegisterSignal(linked_weapon, COMSIG_PARENT_QDELETING, PROC_REF(deleted_weapon))

/obj/item/mod/module/weapon_recall/proc/recall_weapon(caught = FALSE)
	linked_weapon.forceMove(get_turf(src))
	var/alert = ""
	if(mod.wearer.put_in_hands(linked_weapon))
		alert = "[linked_weapon.name] teleportuje się do twojej ręki"
	else if(mod.wearer.equip_to_slot_if_possible(linked_weapon, ITEM_SLOT_BELT, disable_warning = TRUE))
		alert = "[linked_weapon.name] chowa się w twoim pasie"
	else
		alert = "[linked_weapon.name] teleportuje się pod ciebie"
	if(caught)
		if(mod.wearer.is_holding(linked_weapon))
			alert = "łapiesz: [linked_weapon.name]"
		else
			alert = "[linked_weapon.name] ląduje pod tobą"
	else
		do_sparks(5, FALSE, linked_weapon)
	if(alert)
		balloon_alert(mod.wearer, alert)

/obj/item/mod/module/weapon_recall/proc/catch_weapon(obj/item/source, atom/hit_atom, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	if(!mod)
		return
	if(hit_atom != mod.wearer)
		return
	INVOKE_ASYNC(src, PROC_REF(recall_weapon), TRUE)
	return COMPONENT_MOVABLE_IMPACT_NEVERMIND

/obj/item/mod/module/weapon_recall/proc/deleted_weapon(obj/item/source)
	SIGNAL_HANDLER

	linked_weapon = null

//Reinforced DNA Lock - Gibs if wrong DNA, emp-proof.
/obj/item/mod/module/dna_lock/reinforced
	name = "wzmocniony moduł blokady DNA MOD"
	desc = "Moduł, który współpracuje z różnymi blokadami i uszczelnieniami powiązanymi z systemami skafandra \
		i sprawia, że może go nosić tylko ktoś o dokładnie takim samym profilu DNA jak użytkownik. \
		Dzięki przylegającej osłonie tłumiącej jest całkowicie odporny na zakłócenia elektromagnetyczne; \
		do tego sumiennie chroni sekrety Klanu Pająka przed nieświadomymi obcymi."
	icon_state = "dnalock_ninja"
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5

/obj/item/mod/module/dna_lock/reinforced/on_mod_activation(datum/source, mob/user)
	. = ..()
	if(. != MOD_CANCEL_ACTIVATE || !isliving(user))
		return
	if(mod.ai_assistant == user)
		to_chat(mod.ai_assistant, span_danger("<B>kRYTyCZNY BŁĄd</B>: 381200-*#00CODE <B>BLUE</B>\niNGERENCJA SI wYKRyTA\nAKCJa ZIGNOrOWANA"))
		return
	var/mob/living/living_user = user
	to_chat(living_user, span_danger("<B>kRYTyCZNY BŁĄd</B>: 382200-*#00CODE <B>RED</B>\nNIEAUTORYZOWANE UŻYCIE WYKRyTE\nUrUCHAMIANIE PODPR0CEDURY 13...\nELIMINACJA U-U-UŻYTKOWNIKA..."))
	living_user.investigate_log("has been gibbed by using a MODsuit equipped with [src].", INVESTIGATE_DEATHS)
	living_user.gib()

/obj/item/mod/module/dna_lock/reinforced/on_emp(datum/source, severity)
	return

//EMP Pulse - In addition to normal shielding, can also launch an EMP itself.
/obj/item/mod/module/emp_shield/pulse
	name = "moduł impulsu EMP MOD"
	desc = "Ten moduł zwykle aktywuje się dramatycznym gestem: odwraca i rozszerza \
		osłonę EMP skafandra, wywołując własny impuls elektromagnetyczny. Nie zaszkodzi noszącemu, \
		ale wkurzy wszystkich wokół."
	icon_state = "emp_pulse"
	module_type = MODULE_USABLE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 10
	cooldown_time = 8 SECONDS

/obj/item/mod/module/emp_shield/pulse/on_use()
	playsound(src, 'sound/effects/empulse.ogg', 60, TRUE)
	empulse(src, heavy_range = 4, light_range = 6)
	drain_power(use_power_cost)

/// Ninja Status Readout - Like the normal status display (see the base type), but with a clock.
/obj/item/mod/module/status_readout/ninja
	name = "moduł odczytu stanu Klanu Pająka MOD"
	desc = "Niegdyś popularny moduł; ta technologia niestety wyszła z mody w bezpieczniejszych rejonach kosmosu \
		i, sądząc po dodatkowych oznaczeniach na obudowie tej jednostki, trafiła prosto w pajęcze objęcia Klanu Pająka. \
		Jak inne podobne jednostki ta podłącza się do kręgosłupa skafandra i potrafi zbierać i wyświetlać \
		wszystkie możliwe dane biometryczne noszącego: sen, odżywienie, kondycję, odciski palców, \
		a nawet przydatne informacje, jak ogólny stan zdrowia i samopoczucie. Ta ma zegar kalibrowany do \
		lokalnego czasu systemu i wyświetlacz numeru operacji. Głośnik monitora funkcji życiowych usunięto."
	display_time = TRUE
	death_sound = null
	death_sound_volume = null

///Energy Net - Ensnares enemies in a net that prevents movement.
/obj/item/mod/module/energy_net
	name = "moduł sieci energetycznej MOD"
	desc = "Miotacz sieci robiony na zamówienie. Zwykłe wersje tego urządzenia chwytającego \
		korzystają z włókien monomolekularnych albo tnącego drutu żyletkowego, a ten używa twardego światła, by rozłożyć \
		pole pułapki zdolne unieruchomić nawet najsilniejszych przeciwników."
	icon_state = "energy_net"
	removable = FALSE
	module_type = MODULE_ACTIVE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 6
	incompatible_modules = list(/obj/item/mod/module/energy_net)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// List of all energy nets this module made.
	var/list/energy_nets = list()

/obj/item/mod/module/energy_net/on_part_deactivation(deleting)
	for(var/obj/structure/energy_net/net as anything in energy_nets)
		net.obj_destruction("energy")

/obj/item/mod/module/energy_net/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(IS_SPACE_NINJA(mod.wearer) && isliving(target))
		mod.wearer.say("Chodź tutaj!", forced = type)
	var/obj/item/projectile/net = new /obj/item/projectile/energy_net(mod.wearer.loc, src)
	net.preparePixelProjectile(target, mod.wearer)
	net.firer = mod.wearer
	playsound(src, 'sound/weapons/punchmiss.ogg', 25, TRUE)
	INVOKE_ASYNC(net, TYPE_PROC_REF(/obj/item/projectile, fire))
	drain_power(use_power_cost)

/obj/item/mod/module/energy_net/proc/add_net(obj/structure/energy_net/net)
	energy_nets += net
	RegisterSignal(net, COMSIG_PARENT_QDELETING, PROC_REF(remove_net))

/obj/item/mod/module/energy_net/proc/remove_net(obj/structure/energy_net/net)
	SIGNAL_HANDLER
	energy_nets -= net

/obj/item/projectile/energy_net
	name = "sieć energetyczna"
	icon_state = "net_projectile"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	damage = 0
	range = 9
	hitsound = 'sound/items/fultext_deploy.ogg'
	hitsound_wall = 'sound/items/fultext_deploy.ogg'
	/// Reference to the beam following the projectile.
	var/line
	/// Reference to the energy net module.
	var/datum/weakref/net_module

/obj/item/projectile/energy_net/Initialize(mapload, net_module)
	. = ..()
	src.net_module = WEAKREF(net_module)

/obj/item/projectile/energy_net/fire(setAngle)
	if(firer)
		line = firer.Beam(src, "net_beam", 'icons/obj/clothing/modsuit/mod_modules.dmi')
	return ..()

/obj/item/projectile/energy_net/on_hit(mob/living/target, blocked = 0, pierce_hit)
	. = ..()
	if(!istype(target))
		return
	if(locate(/obj/structure/energy_net) in get_turf(target))
		return
	var/obj/structure/energy_net/net = new /obj/structure/energy_net(target.drop_location())
	var/obj/item/mod/module/energy_net/module = net_module?.resolve()
	if(module)
		module.add_net(net)
	firer?.visible_message(span_danger("[firer] łapie [target] w sieć energetyczną!"), span_notice("Łapiesz [target] w sieć energetyczną!"))
	if(target.buckled)
		target.buckled.unbuckle_mob(target, force = TRUE)
	net.buckle_mob(target, force = TRUE)

/obj/item/projectile/energy_net/Destroy()
	QDEL_NULL(line)
	return ..()

///Adrenaline Boost - Stops all stuns the ninja is affected with, increases his speed.
/obj/item/mod/module/adrenaline_boost
	name = "moduł zastrzyku adrenaliny MOD"
	desc = "Klan Pająka ma wiele sekretów. Dokładne specyfikacje skafandrów, \
		techniki, dzięki którym każde cięcie wyciska z wrogów łzy podziwu, \
		ale jedną z największych tajemnic jest związek chemiczny, którego zabójcy-sabotażyści używają w potrzebie. \
		Usuwa on u użytkownika wszelkie zmęczenie i unieruchomienie, a nawet \
		leczy całkowity paraliż. Wiadomo tylko, że płyn musi się „ugotować” w promieniowaniu, \
		więc ten moduł uzupełnia się radem."
	icon_state = "adrenaline_boost"
	removable = FALSE
	module_type = MODULE_USABLE
	allow_flags = MODULE_ALLOW_INCAPACITATED
	incompatible_modules = list(/obj/item/mod/module/adrenaline_boost)
	cooldown_time = 12 SECONDS
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// What reagent we need to refill?
	var/reagent_required = /datum/reagent/uranium/radium
	/// How much of a reagent we need to refill the boost.
	var/reagent_required_amount = 20

/obj/item/mod/module/adrenaline_boost/Initialize(mapload)
	. = ..()
	create_reagents(reagent_required_amount)
	reagents.add_reagent(reagent_required, reagent_required_amount)

/obj/item/mod/module/adrenaline_boost/used()
	if(!reagents.has_reagent(reagent_required, reagent_required_amount))
		balloon_alert(mod.wearer, "brak energii!")
		return FALSE
	return ..()

/obj/item/mod/module/adrenaline_boost/on_use()
	//if(IS_SPACE_NINJA(mod.wearer))
	//	mod.wearer.say(pick_list_replacements(NINJA_FILE, "lines"), forced = type)
	to_chat(mod.wearer, span_notice("Używasz zastrzyku adrenaliny."))
	mod.wearer.SetAllImmobility(0)
	mod.wearer.adjustStaminaLoss(-200)
	mod.wearer.stuttering = 0
	mod.wearer.reagents.add_reagent(/datum/reagent/medicine/amphetamine, 5)
	reagents.remove_reagent(reagent_required, reagents.total_volume * 0.75)
	addtimer(CALLBACK(src, PROC_REF(boost_aftereffects), mod.wearer), 7 SECONDS)

/obj/item/mod/module/adrenaline_boost/on_install()
	RegisterSignal(mod, COMSIG_PARENT_ATTACKBY,  PROC_REF(on_attackby))

/obj/item/mod/module/adrenaline_boost/on_uninstall(deleting)
	UnregisterSignal(mod, COMSIG_PARENT_ATTACKBY)

/obj/item/mod/module/adrenaline_boost/attackby(obj/item/attacking_item, mob/user, params)
	if(charge_boost(attacking_item, user))
		return TRUE
	return ..()

/obj/item/mod/module/adrenaline_boost/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user)
	SIGNAL_HANDLER

	if(charge_boost(attacking_item, user))
		return COMPONENT_NO_AFTERATTACK
	return NONE

/obj/item/mod/module/adrenaline_boost/proc/charge_boost(obj/item/attacking_item, mob/user)
	if(!attacking_item.is_open_container())
		return FALSE
	if(reagents.has_reagent(reagent_required, reagent_required_amount))
		balloon_alert(mod.wearer, "już naładowane!")
		return FALSE
	if(!attacking_item.reagents.trans_id_to(src, reagent_required, reagent_required_amount))
		return FALSE
	balloon_alert(mod.wearer, "ładunek uzupełniony [reagents.has_reagent(reagent_required, reagent_required_amount) ? "w pełni" : "częściowo"]")
	return TRUE

/obj/item/mod/module/adrenaline_boost/proc/boost_aftereffects(mob/affected_mob)
	if(!affected_mob)
		return
	reagents.trans_to(affected_mob, reagents.total_volume)
	to_chat(affected_mob, span_danger("Zaczynasz odczuwać skutki uboczne zastrzyku."))
