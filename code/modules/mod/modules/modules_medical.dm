//Medical modules for MODsuits

#define HEALTH_SCAN "Health"
//#define WOUND_SCAN "Wound"
#define CHEM_SCAN "Chemical"

///Health Analyzer - Gives the user a ranged health analyzer and their health status in the panel.
/obj/item/mod/module/health_analyzer
	name = "moduł analizatora zdrowia MOD"
	desc = "Moduł montowany w rękawicy skafandra. To zaawansowany zestaw do skanowania biologicznego, \
		który daje użytkownikowi szczegółowe informacje o funkcjach życiowych i obrażeniach innych nawet z odległości, \
		jednym ruchem nadgarstka. Dane są wygodnie podane, ale co z nimi zrobisz, zależy od ciebie."
	icon_state = "health"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/health_analyzer)
	cooldown_time = 0.5 SECONDS
	tgui_id = "health_analyzer"
	required_slots = list(ITEM_SLOT_GLOVES)
	/// Scanning mode, changes how we scan something.
	var/mode = HEALTH_SCAN
	/// List of all scanning modes.
	var/static/list/modes = list(HEALTH_SCAN, /*WOUND_SCAN,*/ CHEM_SCAN)

/obj/item/mod/module/health_analyzer/add_ui_data()
	. = ..()
	.["health"] = mod.wearer?.health || 0
	.["health_max"] = mod.wearer?.getMaxHealth() || 0
	.["loss_brute"] = mod.wearer?.getBruteLoss() || 0
	.["loss_fire"] = mod.wearer?.getFireLoss() || 0
	.["loss_tox"] = mod.wearer?.getToxLoss() || 0
	.["loss_oxy"] = mod.wearer?.getOxyLoss() || 0

	return .

/obj/item/mod/module/health_analyzer/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!isliving(target))
		return
	switch(mode)
		if(HEALTH_SCAN)
			healthscan(mod.wearer, target)
		//if(WOUND_SCAN)
		//	woundscan(mod.wearer, target)
		if(CHEM_SCAN)
			chemscan(mod.wearer, target)
	drain_power(use_power_cost)

/obj/item/mod/module/health_analyzer/get_configuration()
	. = ..()
	.["mode"] = add_ui_configuration("Tryb skanowania", "list", mode, modes)

	return .

/obj/item/mod/module/health_analyzer/configure_edit(key, value)
	switch(key)
		if("mode")
			mode = value

#undef HEALTH_SCAN
//#undef WOUND_SCAN
#undef CHEM_SCAN

///Quick Carry - Lets the user carry bodies quicker.
/obj/item/mod/module/quick_carry
	name = "moduł szybkiego noszenia MOD"
	desc = "Zestaw zaawansowanych serw, które przekierowują moc z ramion skafandra, by pomóc nosić rannych \
		albo po prostu dla zabawy. Nanotrasen zablokował jednak możliwość wspomagania walki wręcz."
	icon_state = "carry"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/quick_carry, /obj/item/mod/module/constructor)
	required_slots = list(ITEM_SLOT_GLOVES)
	var/quick_carry_trait = TRAIT_QUICK_CARRY

/obj/item/mod/module/quick_carry/on_part_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, TRAIT_FASTMED, REF(src))
	ADD_TRAIT(mod.wearer, quick_carry_trait, REF(src))

/obj/item/mod/module/quick_carry/on_part_deactivation(deleting = FALSE)
	. = ..()
	REMOVE_TRAIT(mod.wearer, TRAIT_FASTMED, REF(src))
	REMOVE_TRAIT(mod.wearer, quick_carry_trait, REF(src))

/obj/item/mod/module/quick_carry/advanced
	name = "zaawansowany moduł szybkiego noszenia MOD"
	removable = FALSE
	complexity = 0
	quick_carry_trait = TRAIT_QUICKER_CARRY

///Injector - Gives the suit an extendable large-capacity piercing syringe.
/obj/item/mod/module/injector
	name = "moduł iniektora MOD"
	desc = "Moduł montowany w nadgarstku skafandra; działa jak strzykawka o dużej pojemności \
		z końcówką na tyle cienką, że trafia w awaryjne porty iniekcyjne każdego pancerza \
		i bez trudu go przebija. Twojego też."
	icon_state = "injector"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/reagent_containers/syringe/mod
	incompatible_modules = list(/obj/item/mod/module/injector)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/reagent_containers/syringe/mod
	name = "strzykawka iniektora MOD"
	desc = "Strzykawka o dużej pojemności z końcówką na tyle cienką, że trafia w \
		awaryjne porty iniekcyjne każdego pancerza i bez trudu go przebija. Twojego też."
	icon_state = "mod_0"
	base_icon_state = "mod"
	amount_per_transfer_from_this = 30
	possible_transfer_amounts = list(5, 10, 15, 20, 30)
	volume = 30
	//inject_flags = INJECT_CHECK_PENETRATE_THICK

///Organ Thrower - Lets you shoot organs, immediately replacing them if the target has the organ manipulation surgery.
/obj/item/mod/module/organ_thrower
	name = "moduł miotacza organów MOD"
	desc = "Urządzenie odzyskane z rozbitego statku Interdyne Pharmaceuticals; \
		ten moduł wydobyto na światło dzienne, na dobre czy na złe. \
		To montowane na ramieniu urządzenie korzysta z technologii podobnej do współczesnych wymieniaczy części \
		i potrafi przechowywać organy i wstawiać je do otwartych pacjentów. \
		DeForest Medical Corporation zaleca, by nie informować pacjentów, że go użyto."
	icon_state = "organ_thrower"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/organ_thrower, /obj/item/mod/module/microwave_beam)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// How many organs the module can hold.
	var/max_organs = 5
	/// A list of all our organs.
	var/organ_list = list()

/obj/item/mod/module/organ_thrower/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/wearer_human = mod.wearer
	if(istype(target, /obj/item/organ))
		if(!wearer_human.Adjacent(target))
			return
		var/atom/movable/organ = target
		if(length(organ_list) >= max_organs)
			balloon_alert(mod.wearer, "za dużo organów!")
			return
		organ_list += organ
		organ.forceMove(src)
		balloon_alert(mod.wearer, "podniesiono: [organ]")
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		drain_power(use_power_cost)
		return
	if(!length(organ_list))
		return
	var/atom/movable/fired_organ = pop(organ_list)
	var/obj/item/projectile/organ/projectile = new /obj/item/projectile/organ(mod.wearer.loc, fired_organ)
	projectile.preparePixelProjectile(target, mod.wearer)
	projectile.firer = mod.wearer
	playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
	INVOKE_ASYNC(projectile, TYPE_PROC_REF(/obj/item/projectile, fire))
	drain_power(use_power_cost)

/obj/item/projectile/organ
	name = "organ"
	damage = 0
	nodamage = TRUE
	hitsound = 'sound/effects/attackblob.ogg'
	hitsound_wall = 'sound/effects/attackblob.ogg'
	/// A reference to the organ we "are".
	var/obj/item/organ/organ

/obj/item/projectile/organ/Initialize(mapload, obj/item/stored_organ)
	. = ..()
	if(!stored_organ)
		return INITIALIZE_HINT_QDEL
	appearance = stored_organ.appearance
	stored_organ.forceMove(src)
	organ = stored_organ

/obj/item/projectile/organ/Destroy()
	organ = null
	return ..()

/obj/item/projectile/organ/on_hit(atom/target)
	. = ..()
	if(!ishuman(target))
		organ.forceMove(drop_location())
		organ = null
		return
	var/mob/living/carbon/human/organ_receiver = target
	var/succeed = FALSE
	if(organ_receiver.surgeries.len)
		for(var/datum/surgery/procedure as anything in organ_receiver.surgeries)
			if(procedure.location != organ.zone)
				continue
			if(!istype(procedure, /datum/surgery/organ_manipulation))
				continue
			var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
			if(!istype(surgery_step, /datum/surgery_step/manipulate_organs))
				continue
			succeed = TRUE
			break
	if(succeed)
		var/obj/item/organ/organ_evacced = organ_receiver.getorganslot(organ.slot)
		if(organ_evacced && !(organ_evacced.organ_flags & ORGAN_UNREMOVABLE))
			organ_evacced.Remove(target)
			organ_evacced.forceMove(get_turf(target))
		organ.Insert(target)
	else
		organ.forceMove(drop_location())
	organ = null

/*
///Patrient Transport - Generates hardlight bags you can put people in.
/obj/item/mod/module/criminalcapture/patienttransport
	name = "moduł transportu pacjenta MOD"
	desc = "Moduł wbudowany w przedramię skafandra. Niezliczone fale wysyłanych do \
		Indecipheries i innych niebezpiecznych miejsc zespołów górniczych, w większości zaginionych, wiele nauczyły DeForest Medical Company. \
		Zwykłe worki na zwłoki trudno przechowywać, trudno rozłożyć i jeszcze trudniej utrzymać w całości w ciężkich warunkach. \
		Oto worek transportowy z twardego światła. Przywoływany samym gestem, nieważki i odporny na \
		każdy ekstremalny scenariusz, jaki przyjdzie noszącemu do głowy, ten worek jest idealnie zaprojektowany do \
		transportu każdego ciała w każdym środowisku i o każdej porze."
	icon_state = "patient_transport"
	bodybag_type = /obj/structure/closet/body_bag/environmental/hardlight
	capture_time = 1.5 SECONDS
	packup_time = 0.5 SECONDS
*/

///Defibrillator - Gives the suit an extendable pair of shock paddles.
/obj/item/mod/module/defibrillator
	name = "moduł defibrylatora MOD"
	desc = "Moduł wbudowany w rękawice skafandra; medycy nazywają go zwykle „Leczniczymi Dłońmi”. \
		Użytkownik kładzie dłonie nad pacjentem. Komputery pokładowe skafandra obliczają potrzebne napięcie, \
		a zmodyfikowany komputer celowniczy wyznacza najlepszą pozycję do ucisku. \
		Na skórę pacjenta działa siła dwudziestu pięciu funtów. Wyładowania płyną z rękawic skafandra \
		i defibrylują serce, a noszący wraca na Medyczny jako bohater. Nawet nie myśl o używaniu go jako broni; \
		przepisy produkcyjne i blokady oprogramowania wyraźnie tego zabraniają."
	icon_state = "defibrillator"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 25
	device = /obj/item/shockpaddles/mod
	incompatible_modules = list(/obj/item/mod/module/defibrillator)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/defibrillator/Initialize(mapload)
	. = ..()
	RegisterSignal(device, COMSIG_DEFIBRILLATOR_SUCCESS, PROC_REF(on_defib_success))

/obj/item/mod/module/defibrillator/proc/on_defib_success(obj/item/shockpaddles/source)
	SIGNAL_HANDLER

	drain_power(use_power_cost)

/obj/item/shockpaddles/mod
	name = "łopatki defibrylatora MOD"
	req_defib = FALSE

// Our paddles only recharge after a successful shock, so that is where the suit pays for it
/obj/item/shockpaddles/mod/recharge(time)
	SEND_SIGNAL(src, COMSIG_DEFIBRILLATOR_SUCCESS)
	return ..()

///Thread Ripper - Temporarily rips apart clothing to make it not cover the body.
/obj/item/mod/module/thread_ripper
	name = "moduł rozpruwacza nici MOD"
	desc = "Moduł robiony na zamówienie, zintegrowany z nadgarstkiem skafandra. Rozpruwacz nici powstał z \
		technologii z początku 2562 roku, po próbie znanego badacza Nanotrasenu, by \
		rozwinąć technologię błyskawicznego krawiectwa z Autodrobów. Zamiast tworzyć \
		każdy wzór tkaniny pod słońcem, rozpruwacz nici potrafi je błyskawicznie rozbierać. \
		Wszystko, od splotu kevlaru przez skórę po duratkaninę, można szybko rozpruć według życzenia noszącego \
		i zszyć z powrotem; medycy często korzystają z tego, by łatwo dostać się do ciała przy \
		operacjach, defibrylacji czy wstrzykiwaniu leków, a pacjenci nie muszą się martwić, że ich \
		markowe ubrania zostaną zniszczone."
	icon_state = "thread_ripper"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/thread_ripper)
	cooldown_time = 1.5 SECONDS
	overlay_state_inactive = "module_threadripper"
	required_slots = list(ITEM_SLOT_GLOVES)
	/// An associated list of ripped clothing and the body part covering slots they covered before
	var/list/ripped_clothing = list()

/obj/item/mod/module/thread_ripper/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target) || !iscarbon(target) || target == mod.wearer)
		balloon_alert(mod.wearer, "nieprawidłowy cel!")
		return
	var/mob/living/carbon/carbon_target = target
	if(length(ripped_clothing))
		balloon_alert(mod.wearer, "już zdarte!")
		return
	balloon_alert(mod.wearer, "zdzieranie ubrania...")
	playsound(src, 'sound/items/zip.ogg', 25, TRUE, frequency = -1)
	if(!do_after(mod.wearer, 1.5 SECONDS, target = carbon_target))
		balloon_alert(mod.wearer, "przerwano!")
		return
	var/target_zones = body_zone2cover_flags(mod.wearer.zone_selected)
	for(var/obj/item/clothing as anything in carbon_target.get_equipped_items())
		if(!clothing)
			continue
		var/shared_flags = target_zones & clothing.body_parts_covered
		if(shared_flags)
			ripped_clothing[clothing] = shared_flags
			clothing.body_parts_covered &= ~shared_flags

/obj/item/mod/module/thread_ripper/on_process(delta_time)
	. = ..()
	if(!.)
		return
	if(!length(ripped_clothing))
		return
	var/zipped = FALSE
	for(var/obj/item/clothing as anything in ripped_clothing)
		if(QDELETED(clothing))
			ripped_clothing -= clothing
			continue
		var/mob/living/carbon/clothing_wearer = clothing.loc
		if(istype(clothing_wearer) && mod.wearer.Adjacent(clothing_wearer) && !clothing_wearer.is_holding(clothing))
			continue
		zipped = TRUE
		clothing.body_parts_covered |= ripped_clothing[clothing]
		ripped_clothing -= clothing
	if(zipped)
		playsound(src, 'sound/items/zip.ogg', 25, TRUE)
		balloon_alert(mod.wearer, "ubranie naprawione")

/obj/item/mod/module/thread_ripper/on_part_deactivation(deleting = FALSE)
	if(!length(ripped_clothing))
		return
	for(var/obj/item/clothing as anything in ripped_clothing)
		if(QDELETED(clothing))
			ripped_clothing -= clothing
			continue
		clothing.body_parts_covered |= ripped_clothing[clothing]
	ripped_clothing = list()
	if(!deleting)
		playsound(src, 'sound/items/zip.ogg', 25, TRUE)

///Surgical Processor - Lets you do advanced surgeries portably.
/obj/item/mod/module/surgical_processor
	name = "moduł procesora chirurgicznego MOD"
	desc = "Moduł z pokładowym komputerem chirurgicznym, który można połączyć z innymi komputerami, by pobierać i \
		przeprowadzać zaawansowane operacje w biegu."
	icon_state = "surgical_processor"
	module_type = MODULE_ACTIVE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN
	device = /obj/item/surgical_processor/mod
	incompatible_modules = list(/obj/item/mod/module/surgical_processor)
	cooldown_time = 0.5 SECONDS

/obj/item/surgical_processor/mod
	name = "procesor chirurgiczny MOD"
