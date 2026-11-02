	//Baseline hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "hełm hardsuitu"
	desc = "Specjalny hełm do pracy w niebezpiecznym środowisku o niskim ciśnieniu. Ma osłonę przed promieniowaniem."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	max_integrity = 300
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 50, "acid" = 75, "stamina" = 20, "bleed" = 70)
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 1
	light_on = FALSE
	var/basestate = "hardsuit"
	var/on = FALSE
	var/obj/item/clothing/suit/space/hardsuit/suit
	var/hardsuit_type = "engineering" //Determines used sprites: hardsuit[on]-[type]
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT //NSV13 - added HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | THICKMATERIAL | SHOWEROKAY | SNUG_FIT //NSV13 - kept SHOWEROKAY
	var/current_tick_amount = 0
	var/radiation_count = 0
	var/grace = RAD_GEIGER_GRACE_PERIOD
	var/datum/looping_sound/geiger/soundloop

/obj/item/clothing/head/helmet/space/hardsuit/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE, TRUE)
	soundloop.volume = 5
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	if(!QDELETED(suit))
		qdel(suit)
	suit = null
	QDEL_NULL(soundloop)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/attack_self(mob/user)
	on = !on
	icon_state = "[basestate][on]-[hardsuit_type]"
	user.update_inv_head()	//so our mob-overlays update

	set_light_on(on)

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/hardsuit/dropped(mob/user)
	..()
	if(suit)
		suit.RemoveHelmet()

		soundloop?.stop(user) //NSV13 fixes hololog runtime

/obj/item/clothing/head/helmet/space/hardsuit/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_HEAD)
		return 1

/obj/item/clothing/head/helmet/space/hardsuit/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_HEAD)
		if(suit)
			suit.RemoveHelmet()
			soundloop.stop(user)
		else
			qdel(src)
	else
		soundloop.start(user)

/obj/item/clothing/head/helmet/space/hardsuit/proc/display_visor_message(var/msg)
	var/mob/wearer = loc
	if(msg && ishuman(wearer))
		wearer.show_message("[icon2html(src, wearer)]<b><span class='robot'>[msg]</span></b>", MSG_VISUAL)

/obj/item/clothing/head/helmet/space/hardsuit/rad_act(amount)
	. = ..()
	if(amount <= RAD_BACKGROUND_RADIATION)
		return
	current_tick_amount += amount

/obj/item/clothing/head/helmet/space/hardsuit/process(delta_time)
	radiation_count = LPFILTER(radiation_count, current_tick_amount, delta_time, RAD_GEIGER_RC)

	if(current_tick_amount)
		grace = RAD_GEIGER_GRACE_PERIOD
	else
		grace -= delta_time
		if(grace <= 0)
			radiation_count = 0

	current_tick_amount = 0

	soundloop.last_radiation = radiation_count

/obj/item/clothing/head/helmet/space/hardsuit/emp_act(severity)
	. = ..()
	display_visor_message("Wykryto [severity > 1 ? "słaby" : "silny"] impuls elektromagnetyczny!")


/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "Specjalny skafander chroniący w niebezpiecznym środowisku o niskim ciśnieniu. Ma osłonę przed promieniowaniem."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	max_integrity = 300
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 50, "acid" = 75, "stamina" = 20, "bleed" = 70)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser)
	siemens_coefficient = 0
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	actions_types = list(/datum/action/item_action/toggle_helmet)
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	var/obj/item/tank/jetpack/suit/jetpack = null
	pocket_storage_component_path = null
	var/hardsuit_type

/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)
	. = ..()

/obj/item/clothing/suit/space/hardsuit/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, "<span class='warning'>[src] ma już zamontowany plecak odrzutowy.</span>")
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, "<span class='warning'>Nie możesz zamontować ulepszenia w [src], gdy go nosisz.</span>")
			return

		if(user.transferItemToLoc(I, src))
			jetpack = I
			to_chat(user, "<span class='notice'>Montujesz plecak odrzutowy w [src].</span>")
			return
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!jetpack)
			to_chat(user, "<span class='warning'>[src] nie ma zamontowanego plecaka odrzutowego.</span>")
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING))
			to_chat(user, "<span class='warning'>Nie możesz zdjąć plecaka odrzutowego z [src], gdy go nosisz.</span>")
			return

		jetpack.turn_off(user)
		jetpack.forceMove(drop_location())
		jetpack = null
		to_chat(user, "<span class='notice'>Zdejmujesz plecak odrzutowy z [src].</span>")
		return
	//NSV13 - added helmet cams
	else if(I.tool_behaviour == TOOL_WIRECUTTER || istype(I, /obj/item/wallframe/camera))
		helmet.attackby(I, user, params)
	//end NSV13
	return ..()


/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	..()
	if(jetpack)
		if(slot == ITEM_SLOT_OCLOTHING)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	if(jetpack)
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)

/obj/item/clothing/suit/space/hardsuit/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_OCLOTHING) //we only give the mob the ability to toggle the helmet if he's wearing the hardsuit.
		return 1

	//Engineering
/obj/item/clothing/head/helmet/space/hardsuit/engine
	name = "inżynieryjny hełm hardsuitu"
	desc = "Specjalny hełm do pracy w niebezpiecznym środowisku o niskim ciśnieniu. Ma osłonę przed promieniowaniem."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //NSV13
	worn_icon = 'nsv13/icons/mob/head.dmi' //NSV13
	icon_state = "hardsuit0-engineering-legacy" //NSV13
	item_state = "eng_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 12, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75, "stamina" = 20, "bleed" = 70)
	hardsuit_type = "engineering-legacy" //NSV13
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/engine
	name = "inżynieryjny hardsuit"
	desc = "Specjalny skafander chroniący w niebezpiecznym środowisku o niskim ciśnieniu. Ma osłonę przed promieniowaniem."
	icon = 'nsv13/icons/obj/clothing/suits.dmi' //NSV13
	worn_icon = 'nsv13/icons/mob/suit.dmi' //NSV13
	icon_state = "hardsuit-engineering-legacy" //NSV13
	supports_variations = DIGITIGRADE_VARIATION //NSV13 - legacy sprite has digisprite.
	item_state = "eng_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75, "stamina" = 20, "bleed" = 70)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine
	resistance_flags = FIRE_PROOF

	//Atmospherics
/obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	name = "hełm hardsuitu atmosferyki"
	desc = "Specjalny hełm do pracy w niebezpiecznym środowisku o niskim ciśnieniu. Ma osłonę termiczną."
	icon_state = "hardsuit0-atmospherics-legacy" //NSV13
	item_state = "atmo_helm"
	hardsuit_type = "atmospherics-legacy" //NSV13
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 100, "acid" = 75, "stamina" = 20, "bleed" = 70)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/atmos
	name = "hardsuit atmosferyki"
	desc = "Specjalny skafander chroniący w niebezpiecznym środowisku o niskim ciśnieniu. Ma osłonę termiczną."
	icon_state = "hardsuit-atmospherics-legacy" //NSV13
	supports_variations = DIGITIGRADE_VARIATION //NSV13 - legacy sprite has digisprite.
	item_state = "atmo_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 100, "acid" = 75, "stamina" = 20, "bleed" = 70)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/atmos


	//Chief Engineer's hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	name = "zaawansowany hełm hardsuitu"
	desc = "Zaawansowany hełm do pracy w niebezpiecznym środowisku o niskim ciśnieniu. Lśni od wypolerowania."
	icon_state = "hardsuit0-white-legacy" //NSV13
	item_state = "ce_helm"
	hardsuit_type = "white-legacy" //NSV13
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 90, "stamina" = 30, "bleed" = 70)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/elite
	icon_state = "hardsuit-white-legacy" //NSV13
	supports_variations = DIGITIGRADE_VARIATION //NSV13 - legacy sprite has digisprite.
	name = "zaawansowany hardsuit"
	desc = "Zaawansowany skafander chroniący w niebezpiecznym środowisku o niskim ciśnieniu. Lśni od wypolerowania."
	item_state = "ce_hardsuit"
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 90, "stamina" = 30, "bleed" = 70)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	jetpack = /obj/item/tank/jetpack/suit

	//Mining hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "górniczy hełm hardsuitu"
	desc = "Specjalny hełm do pracy w niebezpiecznym środowisku o niskim ciśnieniu. Ma wzmocnione płyty na spotkania z dziką fauną i podwójne reflektory."
	icon_state = "hardsuit0-mining"
	item_state = "mining_helm"
	hardsuit_type = "mining"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	heat_protection = HEAD
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75, "stamina" = 40, "bleed" = 70)
	light_range = 7
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator)
	high_pressure_multiplier = 0.6

/obj/item/clothing/head/helmet/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/suit/space/hardsuit/mining
	icon_state = "hardsuit-mining"
	name = "górniczy hardsuit"
	desc = "Specjalny skafander chroniący w niebezpiecznym środowisku o niskim ciśnieniu. Ma wzmocnione płyty na spotkania z dziką fauną."
	item_state = "mining_hardsuit"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	supports_variations = DIGITIGRADE_VARIATION
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75, "stamina" = 40, "bleed" = 70)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/mining
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	high_pressure_multiplier = 0.6

/obj/item/clothing/suit/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

	//Exploration hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/exploration
	name = "hełm hardsuitu odkrywcy"
	desc = "Zaawansowany hardsuit odporny na próżnię, zaprojektowany do ochrony przed zagrożeniami poza statkiem."
	icon_state = "hardsuit0-exploration"
	item_state = "death_commando_mask"
	hardsuit_type = "exploration"
	heat_protection = HEAD
	armor = list("melee" = 35, "bullet" = 15, "laser" = 20, "energy" = 10, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75, "stamina" = 20, "bleed" = 70)
	light_range = 6
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator)

/obj/item/clothing/suit/space/hardsuit/exploration
	icon_state = "hardsuit-exploration"
	name = "hardsuit odkrywcy"
	desc = "Zaawansowany hardsuit odporny na próżnię, zaprojektowany do ochrony przed zagrożeniami poza statkiem. Choć wygląda uderzająco podobnie do górniczego hardsuitu, \
		przedstawiciele Nanotrasen podkreślają, że jest pod każdym względem wyjątkowy, a projektu w żaden sposób nie skopiowano."
	item_state = "exploration_hardsuit"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 20, "energy" = 10, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75, "stamina" = 20, "bleed" = 70)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/exploration
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

	//Cybersun Hardsuit
	//A kind of side-grade to the explorer suit, sacrificing burn protection for brute. If you can kill the guy inside it, anyways.

/obj/item/clothing/head/helmet/space/hardsuit/cybersun
	name = "hełm hardsuitu Cybersun"
	desc = "Bulwiasty czerwony hełm do szabrowania w niebezpiecznym środowisku o niskim ciśnieniu. Ma podwójne reflektory i widok 360 stopni."
	icon_state = "hardsuit0-cybersun"
	item_state = "death_commando_mask"
	hardsuit_type = "cybersun"
	armor = list("melee" = 30, "bullet" = 35, "laser" = 15, "energy" = 15, "bomb" = 60, "bio" = 100, "rad" = 55, "fire" = 30, "acid" = 60, "stamina" = 15, "bleed" = 70)
	strip_delay = 600

/obj/item/clothing/suit/space/hardsuit/cybersun
	icon_state = "cybersun"
	name = "hardsuit Cybersun"
	desc = "Masywny skafander ochronny, który chroni inżynierów, naukowców i innych pracowników Cybersun przed niebezpieczeństwami, gdy porzucają bezpieczeństwo \
		stabilniejszej posady na rzecz zagrożeń głębokiego kosmosu kontrolowanego przez Nanotrasen. Zaprojektowano go tak, by dało się w nim pracować mimo zagrożeń we wrakach, \
		więc ochronę przed laserami poświęcono na rzecz skuteczniejszych płyt przeciw obrażeniom obuchowym i osłony przed promieniowaniem."
	armor = list("melee" = 30, "bullet" = 35, "laser" = 15, "energy" = 15, "bomb" = 60, "bio" = 100, "rad" = 55, "fire" = 30, "acid" = 60, "stamina" = 15, "bleed" = 70)
	hardsuit_type = "cybersun"
	item_state = "death_commando_mask"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/cybersun
	jetpack = /obj/item/tank/jetpack/suit

	//Syndicate hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "krwistoczerwony hełm hardsuitu"
	desc = "Zaawansowany dwutrybowy hełm do operacji specjalnych. Jest w trybie EVA. Własność Maruderów Gorlex."
	alt_desc = "Zaawansowany dwutrybowy hełm do operacji specjalnych. Jest w trybie bojowym. Własność Maruderów Gorlex."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	hardsuit_type = "syndi"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 40, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90, "stamina" = 60, "bleed" = 70)
	on = TRUE
	var/obj/item/clothing/suit/space/hardsuit/syndi/linkedsuit = null
	actions_types = list(/datum/action/item_action/toggle_helmet_mode,\
		/datum/action/item_action/toggle_beacon_hud)
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEEARS|HIDESNOUT
	visor_flags = STOPSPRESSUREDAMAGE

/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_icon()
	icon_state = "hardsuit[on]-[hardsuit_type]"

/obj/item/clothing/head/helmet/space/hardsuit/syndi/Initialize(mapload)
	. = ..()
	//Link
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/syndi))
		linkedsuit = loc
		//NOTE FOR COPY AND PASTING: BEACON MUST BE MADE FIRST
		//Add the monitor (Default to null - No tracking)
		var/datum/component/tracking_beacon/component_beacon = linkedsuit.AddComponent(/datum/component/tracking_beacon, "synd", null, null, TRUE, "#8f4a4b")
		//Add the monitor (Default to null - No tracking)
		component_beacon.attached_monitor = AddComponent(/datum/component/team_monitor, "synd", null, component_beacon)
	else
		AddComponent(/datum/component/team_monitor, "synd", null)

/obj/item/clothing/head/helmet/space/hardsuit/syndi/ui_action_click(mob/user, datum/action)
	switch(action.type)
		if(/datum/action/item_action/toggle_helmet_mode)
			attack_self(user)
		if(/datum/action/item_action/toggle_beacon_hud)
			toggle_hud(user)

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/toggle_hud(mob/user)
	var/datum/component/team_monitor/monitor = GetComponent(/datum/component/team_monitor)
	if(!monitor)
		to_chat(user, "<span class='notice'>Kombinezon nie jest wyposażony w nadajnik lokalizacyjny.</span>")
		return
	monitor.toggle_hud(!monitor.hud_visible, user)
	if(monitor.hud_visible)
		to_chat(user, "<span class='notice'>Przełączasz wyświetlacz HUD swojego kombinezonu.</span>")
	else
		to_chat(user, "<span class='warning'>Wyłączasz wyświetlacz HUD swojego kombinezonu.</span>")

/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self(mob/user) //Toggle Helmet
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>Nie możesz przełączyć hełmu, będąc w [user.loc]!</span>" )
		return
	on = !on
	if(on || force)
		to_chat(user, "<span class='notice'>Przełączasz hardsuit w tryb EVA, poświęcając szybkość dla ochrony w kosmosie.</span>")
		activate_space_mode()
	else
		to_chat(user, "<span class='notice'>Przełączasz hardsuit w tryb bojowy i możesz teraz biec z pełną prędkością.</span>")
		activate_combat_mode()
	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	toggle_hardsuit_mode(user)
	user.update_inv_head()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/toggle_hardsuit_mode(mob/user) //Helmet Toggles Suit Mode
	if(linkedsuit)
		linkedsuit.icon_state = "hardsuit[on]-[hardsuit_type]"
		linkedsuit.update_icon()
		if(on)
			linkedsuit.activate_space_mode()
		else
			linkedsuit.activate_combat_mode()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/activate_space_mode()
	name = initial(name)
	desc = initial(desc)
	set_light_on(TRUE)
	clothing_flags |= visor_flags
	flags_cover |= HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv |= visor_flags_inv
	cold_protection |= HEAD
	on = TRUE

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/activate_combat_mode()
	name = "[initial(name)] (tryb bojowy)"
	desc = alt_desc
	set_light_on(FALSE)
	clothing_flags &= ~visor_flags
	flags_cover &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
	flags_inv &= ~visor_flags_inv
	cold_protection &= ~HEAD
	on = FALSE

/obj/item/clothing/suit/space/hardsuit/syndi
	name = "krwistoczerwony hardsuit"
	desc = "Zaawansowany dwutrybowy hardsuit do operacji specjalnych. Jest w trybie EVA. Własność Maruderów Gorlex."
	alt_desc = "Zaawansowany dwutrybowy hardsuit do operacji specjalnych. Jest w trybie bojowym. Własność Maruderów Gorlex."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	w_class = WEIGHT_CLASS_NORMAL
	supports_variations = DIGITIGRADE_VARIATION
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 40, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90, "stamina" = 60, "bleed" = 70)
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	jetpack = /obj/item/tank/jetpack/suit
	item_flags = ILLEGAL	//Syndicate only and difficult to obtain outside of uplink anyway. Nukie hardsuits on the ship are illegal.
	var/cm_slowdown = 0 //NSV13
	actions_types = list(
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/toggle_beacon,
		/datum/action/item_action/toggle_beacon_frequency
	)

/obj/item/clothing/suit/space/hardsuit/syndi/ComponentInitialize() //NSV13
    . = ..()
    artifact_immunity()

/obj/item/clothing/suit/space/hardsuit/syndi/proc/artifact_immunity() //NSV13
    AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)

/obj/item/clothing/suit/space/hardsuit/syndi/ui_action_click(mob/user, datum/actiontype)
	switch(actiontype.type)
		if(/datum/action/item_action/toggle_helmet)
			ToggleHelmet()
		if(/datum/action/item_action/toggle_beacon)
			toggle_beacon(user)
		if(/datum/action/item_action/toggle_beacon_frequency)
			set_beacon_freq(user)

/obj/item/clothing/suit/space/hardsuit/syndi/proc/toggle_beacon(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, "<span class='notice'>Kombinezon nie jest wyposażony w nadajnik lokalizacyjny.</span>")
		return
	beacon.toggle_visibility(!beacon.visible)
	if(beacon.visible)
		to_chat(user, "<span class='notice'>Włączasz nadajnik lokalizacyjny w [src]. Każdy na tej samej częstotliwości może teraz śledzić twoje położenie.</span>")
	else
		to_chat(user, "<span class='warning'>Wyłączasz nadajnik lokalizacyjny w [src].</span>")

/obj/item/clothing/suit/space/hardsuit/syndi/proc/set_beacon_freq(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, "<span class='notice'>Kombinezon nie jest wyposażony w nadajnik lokalizacyjny.</span>")
		return
	beacon.change_frequency(user)

/obj/item/clothing/suit/space/hardsuit/syndi/RemoveHelmet()
	. = ..()
	//Update helmet to non combat mode
	var/obj/item/clothing/head/helmet/space/hardsuit/syndi/syndieHelmet = helmet
	if(!syndieHelmet)
		return
	syndieHelmet.activate_combat_mode()
	syndieHelmet.update_icon()
	for(var/X in syndieHelmet.actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
	//Update the icon_state first
	icon_state = "hardsuit[syndieHelmet.on]-[syndieHelmet.hardsuit_type]"
	update_icon()
	//Actually apply the non-combat mode to suit and update the suit overlay
	activate_combat_mode()

/obj/item/clothing/suit/space/hardsuit/syndi/proc/activate_space_mode()
	name = initial(name)
	desc = initial(desc)
	slowdown = 1
	clothing_flags |= STOPSPRESSUREDAMAGE
	cold_protection |= CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	if(ishuman(loc))
		var/mob/living/carbon/H = loc
		H.update_equipment_speed_mods()
		H.update_inv_wear_suit()
		H.update_inv_w_uniform()

/obj/item/clothing/suit/space/hardsuit/syndi/proc/activate_combat_mode()
	name = "[initial(name)] (tryb bojowy)"
	desc = alt_desc
	slowdown = cm_slowdown //NSV13
	clothing_flags &= ~STOPSPRESSUREDAMAGE
	cold_protection &= ~(CHEST | GROIN | LEGS | FEET | ARMS | HANDS)
	if(ishuman(loc))
		var/mob/living/carbon/H = loc
		H.update_equipment_speed_mods()
		H.update_inv_wear_suit()
		H.update_inv_w_uniform()

//Elite Syndie suit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	name = "elitarny hełm hardsuitu Syndykatu"
	desc = "Elitarna wersja hełmu Syndykatu z lepszym pancerzem i ognioodpornością. Jest w trybie EVA. Własność Maruderów Gorlex."
	alt_desc = "Elitarna wersja hełmu Syndykatu z lepszym pancerzem i ognioodpornością. Jest w trybie bojowym. Własność Maruderów Gorlex."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 60, "bomb" = 55, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100, "stamina" = 80, "bleed" = 70)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
/obj/item/clothing/suit/space/hardsuit/syndi/elite
	name = "elitarny hardsuit Syndykatu"
	desc = "Elitarna wersja hardsuitu Syndykatu z lepszym pancerzem i ognioodpornością. Jest w trybie podróżnym."
	alt_desc = "Elitarna wersja hardsuitu Syndykatu z lepszym pancerzem i ognioodpornością. Jest w trybie bojowym."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 60, "bomb" = 55, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100, "stamina" = 80, "bleed" = 70)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

//The Owl Hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/owl
	name = "sowi hełm hardsuitu"
	desc = "Zaawansowany dwutrybowy hełm na każdą okazję do walki z przestępczością. Jest w trybie podróżnym."
	alt_desc = "Zaawansowany dwutrybowy hełm na każdą okazję do walki z przestępczością. Jest w trybie bojowym."
	icon_state = "hardsuit1-owl"
	item_state = "s_helmet"
	hardsuit_type = "owl"
	visor_flags_inv = 0
	visor_flags = 0
	on = FALSE

/obj/item/clothing/suit/space/hardsuit/syndi/owl
	name = "sowi hardsuit"
	desc = "Zaawansowany dwutrybowy hardsuit na każdą okazję do walki z przestępczością. Jest w trybie podróżnym."
	alt_desc = "Zaawansowany dwutrybowy hardsuit na każdą okazję do walki z przestępczością. Jest w trybie bojowym."
	icon_state = "hardsuit1-owl"
	item_state = "s_suit"
	hardsuit_type = "owl"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/owl


	//Wizard hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/wizard
	name = "wysadzany klejnotami hełm hardsuitu"
	desc = "Dziwaczny hełm wysadzany klejnotami, z którego bije magiczna energia."
	icon_state = "hardsuit0-wiz"
	item_state = "wiz_helm"
	hardsuit_type = "wiz"
	resistance_flags = FIRE_PROOF | ACID_PROOF //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 50, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 70, "bleed" = 70)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/wizard
	icon_state = "hardsuit-wiz"
	name = "wysadzany klejnotami hardsuit"
	desc = "Dziwaczny skafander wysadzany klejnotami, z którego bije magiczna energia."
	item_state = "wiz_hardsuit"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 50, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 70, "bleed" = 70)
	allowed = list(/obj/item/teleportation_scroll, /obj/item/tank/internals)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/wizard
	jetpack = /obj/item/tank/jetpack/suit
	slowdown = 0.3

/obj/item/clothing/suit/space/hardsuit/wizard/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)
	AddComponent(/datum/component/anti_magic, TRUE, FALSE, INFINITY, FALSE)


	//Medical hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/medical
	name = "medyczny hełm hardsuitu"
	desc = "Specjalny hełm do pracy w niebezpiecznym środowisku o niskim ciśnieniu. Wykonany z lekkich materiałów dla większej wygody, ale nie chroni oczu przed intensywnym światłem."
	icon_state = "hardsuit0-medical"
	item_state = "medical_helm"
	hardsuit_type = "medical"
	flash_protect = 0
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 75, "stamina" = 20, "bleed" = 70)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SHOWEROKAY | SNUG_FIT | SCAN_REAGENTS //NSV13 - kept SHOWEROKAY

/obj/item/clothing/suit/space/hardsuit/medical
	icon_state = "hardsuit-medical"
	name = "medyczny hardsuit"
	desc = "Specjalny skafander chroniący w niebezpiecznym środowisku o niskim ciśnieniu. Wykonany z lekkich materiałów, więc łatwiej się w nim ruszać."
	item_state = "medical_hardsuit"
	supports_variations = DIGITIGRADE_VARIATION
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/firstaid, /obj/item/healthanalyzer, /obj/item/stack/medical)
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 75, "stamina" = 20, "bleed" = 70)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical
	slowdown = 0.5

/obj/item/clothing/head/helmet/space/hardsuit/medical/cmo
	name = "hełm hardsuitu Ordynatora"
	desc = "Specjalny hełm do pracy w niebezpiecznym środowisku o niskim ciśnieniu. Wykonany z lekkich materiałów dla większej wygody i chroni oczy przed intensywnym światłem."
	flash_protect = 2

/obj/item/clothing/suit/space/hardsuit/medical/cmo
	name = "hardsuit Ordynatora"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical/cmo
/* aquila edit start
	//Research Director hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/rd
	name = "prototypowy hełm hardsuitu"
	desc = "Prototypowy hełm do badań w niebezpiecznym środowisku o niskim ciśnieniu. Po wizjerze przewijają się dane naukowe."
	icon_state = "hardsuit0-rd"
	hardsuit_type = "rd"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 100, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 80, "stamina" = 30, "bleed" = 70)
	var/obj/machinery/doppler_array/integrated/bomb_radar
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SHOWEROKAY | SNUG_FIT | SCAN_REAGENTS //NSV13 - kept SHOWEROKAY
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/head/helmet/space/hardsuit/rd/Initialize(mapload)
	. = ..()
	bomb_radar = new /obj/machinery/doppler_array/integrated(src)

/obj/item/clothing/head/helmet/space/hardsuit/rd/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		DHUD.add_hud_to(user)

/obj/item/clothing/head/helmet/space/hardsuit/rd/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		DHUD.remove_hud_from(user)

/obj/item/clothing/suit/space/hardsuit/research_director
	icon_state = "hardsuit-rd"
	name = "prototypowy hardsuit"
	desc = "Prototypowy skafander chroniący w niebezpiecznym środowisku o niskim ciśnieniu. Ma rozbudowane opancerzenie do pracy z materiałami wybuchowymi i niebezpiecznymi materiałami badawczymi."
	item_state = "hardsuit-rd"
	supports_variations = DIGITIGRADE_VARIATION
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT //Same as an emergency firesuit. Not ideal for extended exposure.
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/gun/energy/wormhole_projector,
	/obj/item/hand_tele, /obj/item/aicard)
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 100, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 80, "stamina" = 30, "bleed" = 70)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/rd

/obj/item/clothing/suit/space/hardsuit/research_director/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)
*/ //aquila edit end
	//Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security
	name = "policyjny hełm hardsuitu"
	desc = "Specjalny hełm do pracy w niebezpiecznym środowisku o niskim ciśnieniu. Ma dodatkową warstwę pancerza."
	icon_state = "hardsuit0-sec"
	item_state = "sec_helm"
	hardsuit_type = "sec"
	armor = list("melee" = 35, "bullet" = 45, "laser" = 15,"energy" = 40, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75, "stamina" = 50, "bleed" = 70) //NSV13


/obj/item/clothing/suit/space/hardsuit/security
	icon_state = "hardsuit-sec"
	name = "policyjny hardsuit"
	desc = "Specjalny skafander chroniący w niebezpiecznym środowisku o niskim ciśnieniu. Ma dodatkową warstwę pancerza."
	item_state = "sec_hardsuit"
	supports_variations = DIGITIGRADE_VARIATION
	armor = list("melee" = 35, "bullet" = 45, "laser" = 15, "energy" = 40, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75, "stamina" = 50, "bleed" = 70) //NSV13
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security

/obj/item/clothing/suit/space/hardsuit/security/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

	//Head of Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security/hos
	name = "hełm hardsuitu Komendanta"
	desc = "Specjalny, masywny hełm do pracy w niebezpiecznym środowisku o niskim ciśnieniu. Ma dodatkową warstwę pancerza."
	icon_state = "hardsuit0-hos"
	hardsuit_type = "hos"
	armor = list("melee" = 45, "bullet" = 60, "laser" = 15, "energy" = 40, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 95, "acid" = 95, "stamina" = 60, "bleed" = 70) //NSV13


/obj/item/clothing/suit/space/hardsuit/security/head_of_security
	icon_state = "hardsuit-hos"
	name = "hardsuit Komendanta"
	supports_variations = DIGITIGRADE_VARIATION
	desc = "Specjalny, masywny skafander chroniący w niebezpiecznym środowisku o niskim ciśnieniu. Ma dodatkową warstwę pancerza."
	armor = list("melee" = 45, "bullet" = 60, "laser" = 15, "energy" = 40, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 95, "acid" = 95, "stamina" = 60, "bleed" = 70) //NSV13
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	jetpack = /obj/item/tank/jetpack/suit

	//SWAT MKII
/obj/item/clothing/head/helmet/space/hardsuit/swat
	name = "\improper hełm SWAT MK.II"
	icon_state = "swat2helm"
	item_state = "swat2helm"
	desc = "Taktyczny hełm SWAT MK.II."
	armor = list("melee" = 40, "bullet" = 50, "laser" = 20, "energy" = 60, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 60, "bleed" = 70) //NSV13
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/swat/attack_self()

/obj/item/clothing/suit/space/hardsuit/swat
	name = "\improper skafander SWAT MK.II"
	desc = "Skafander SWAT MK.II z opływowymi stawami i pancerzem z najlepszych materiałów, izolowany od intensywnego ciepła. Najbardziej zaawansowany dostępny pancerz taktyczny."
	icon_state = "swat2"
	item_state = "swat2"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 20, "energy" = 60, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 60, "bleed" = 70) //NSV13
	resistance_flags = FIRE_PROOF | ACID_PROOF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT //this needed to be added a long fucking time ago
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat

/obj/item/clothing/suit/space/hardsuit/swat/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

	//Captain
/obj/item/clothing/head/helmet/space/hardsuit/swat/captain
	name = "hełm hardsuitu kapitana"
	icon_state = "capspace"
	item_state = "capspacehelmet"
	desc = "Taktyczny hełm SWAT MK.II, który może się pochwalić lepszą ochroną i okropnym gustem."

/obj/item/clothing/suit/space/hardsuit/swat/captain
	name = "skafander SWAT kapitana"
	desc = "Skafander SWAT MK.II z opływowymi stawami i pancerzem z najlepszych materiałów, izolowany od intensywnego ciepła. Najbardziej zaawansowany dostępny pancerz taktyczny. Zwykle zarezerwowany dla najcięższej korporacyjnej ochrony, ten ma królewskie wykończenie w barwach Nanotrasen. Lepiej, żeby asystenci go nie dorwali."
	icon_state = "caparmor"
	item_state = "capspacesuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat/captain

	//Clown
/obj/item/clothing/head/helmet/space/hardsuit/clown
	name = "hełm hardsuitu kosmohonk"
	desc = "Specjalny hełm do pracy w niebezpiecznym środowisku o niskim poziomie humoru. Ma osłonę przed promieniowaniem."
	icon_state = "hardsuit0-clown"
	item_state = "hardsuit0-clown"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 60, "acid" = 30, "stamina" = 20, "bleed" = 70)
	hardsuit_type = "clown"

/obj/item/clothing/suit/space/hardsuit/clown
	name = "hardsuit kosmohonk"
	desc = "Specjalny skafander chroniący w niebezpiecznym środowisku o niskim poziomie humoru. Ma osłonę przed promieniowaniem. Może go nosić tylko prawdziwy klaun."
	icon_state = "hardsuit-clown"
	item_state = "clown_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 60, "acid" = 30, "stamina" = 20, "bleed" = 70)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/clown

/obj/item/clothing/suit/space/hardsuit/clown/mob_can_equip(mob/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!..() || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if(H.mind.assigned_role == JOB_NAME_CLOWN)
		return TRUE
	else
		return FALSE

	//Old Prototype
/obj/item/clothing/head/helmet/space/hardsuit/ancient
	name = "prototypowy hełm hardsuitu RIG"
	desc = "Wczesny prototyp hełmu hardsuitu RIG, który szybko nasuwa się na głowę. Przez ograniczenia konstrukcji nie ma wbudowanych kamer, więc ogranicza widoczność."
	icon_state = "hardsuit0-ancient"
	item_state = "anc_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 5, "energy" = 10, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 75, "stamina" = 30, "bleed" = 70)
	hardsuit_type = "ancient"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ancient
	name = "prototypowy hardsuit RIG"
	desc = "Prototypowy zasilany hardsuit RIG. Świetnie chroni przed żywiołami kosmosu, a dzięki zasilanym siłownikom wygodnie się w nim porusza. Wciąż jest jednak bardzo masywny."
	icon_state = "hardsuit-ancient"
	item_state = "anc_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 5, "energy" = 10, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 75, "stamina" = 30, "bleed" = 70)
	slowdown = 3
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ancient
	resistance_flags = FIRE_PROOF
	move_sound = list('sound/effects/servostep.ogg')

/////////////SHIELDED//////////////////////////////////

/obj/item/clothing/suit/space/hardsuit/shielded
	name = "hardsuit z tarczą"
	desc = "Hardsuit z wbudowaną tarczą energetyczną. Szybko się ładuje, gdy nikt do ciebie nie strzela."
	icon_state = "hardsuit-hos"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	allowed = null
	supports_variations = DIGITIGRADE_VARIATION
	armor = list("melee" = 30, "bullet" = 15, "laser" = 30, "energy" = 40, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 60, "bleed" = 70)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	/// How many charges total the shielding has
	var/max_charges = 3
	/// How long after we've been shot before we can start recharging.
	var/recharge_delay = 20 SECONDS
	/// How quickly the shield recharges each charge once it starts charging
	var/recharge_rate = 1 SECONDS
	/// The icon for the shield
	var/shield_icon = "shield-old"

/obj/item/clothing/suit/space/hardsuit/shielded/Initialize(mapload)
	. = ..()
	if(!allowed)
		allowed = GLOB.advanced_hardsuit_allowed

/obj/item/clothing/suit/space/hardsuit/shielded/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_delay, charge_increment_delay = recharge_rate, shield_icon = shield_icon)

/obj/item/clothing/head/helmet/space/hardsuit/shielded
	resistance_flags = FIRE_PROOF | ACID_PROOF

///////////////Capture the Flag////////////////////

/obj/item/clothing/suit/space/hardsuit/shielded/ctf
	name = "biały hardsuit z tarczą"
	desc = "Standardowy hardsuit do gry w zdobywanie flagi."
	icon_state = "ert_medical"
	item_state = "ert_medical"
	hardsuit_type = "ert_medical"
	// Adding TRAIT_NODROP is done when the CTF spawner equips people
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	armor = list("melee" = 0, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 95, "acid" = 95, "stamina" = 0, "bleed" = 0)
	slowdown = 0
	max_charges = 5

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/red
	name = "czerwony hardsuit z tarczą"
	icon_state = "ert_security"
	item_state = "ert_security"
	hardsuit_type = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/red
	shield_icon = "shield-red"

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/blue
	name = "niebieski hardsuit z tarczą"
	desc = "Standardowy hardsuit do gry w zdobywanie flagi."
	icon_state = "ert_command"
	item_state = "ert_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/blue



/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	name = "hełm hardsuitu z tarczą"
	desc = "Standardowy hełm hardsuitu do gry w zdobywanie flagi."
	icon_state = "hardsuit0-ert_medical"
	item_state = "hardsuit0-ert_medical"
	hardsuit_type = "ert_medical"
	armor = list("melee" = 0, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 95, "acid" = 95, "stamina" = 0, "bleed" = 0)


/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/red
	icon_state = "hardsuit0-ert_security"
	item_state = "hardsuit0-ert_security"
	hardsuit_type = "ert_security"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/blue
	name = "hełm hardsuitu z tarczą"
	desc = "Standardowy hełm hardsuitu do gry w zdobywanie flagi."
	icon_state = "hardsuit0-ert_commander"
	item_state = "hardsuit0-ert_commander"
	hardsuit_type = "ert_commander"





//////Syndicate Version

/obj/item/clothing/suit/space/hardsuit/shielded/syndi
	name = "krwistoczerwony hardsuit"
	desc = "Zaawansowany hardsuit z wbudowaną tarczą energetyczną."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 40, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 60, "bleed" = 70)
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	slowdown = 0
	shield_icon = "shield-red"
	actions_types = list(
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/toggle_beacon,
		/datum/action/item_action/toggle_beacon_frequency
	)
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/ui_action_click(mob/user, datum/actiontype)
	switch(actiontype.type)
		if(/datum/action/item_action/toggle_helmet)
			ToggleHelmet()
		if(/datum/action/item_action/toggle_beacon)
			toggle_beacon(user)
		if(/datum/action/item_action/toggle_beacon_frequency)
			set_beacon_freq(user)

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/proc/toggle_beacon(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, "<span class='notice'>Kombinezon nie jest wyposażony w nadajnik lokalizacyjny.</span>")
		return
	beacon.toggle_visibility(!beacon.visible)
	if(beacon.visible)
		to_chat(user, "<span class='notice'>Włączasz nadajnik lokalizacyjny w [src]. Każdy na tej samej częstotliwości może teraz śledzić twoje położenie.</span>")
	else
		to_chat(user, "<span class='warning'>Wyłączasz nadajnik lokalizacyjny w [src].</span>")

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/proc/set_beacon_freq(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, "<span class='notice'>Kombinezon nie jest wyposażony w nadajnik lokalizacyjny.</span>")
		return
	beacon.change_frequency(user)

//Helmet - With built in HUD

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	name = "krwistoczerwony hełm hardsuitu"
	desc = "Zaawansowany hełm hardsuitu z wbudowaną tarczą energetyczną."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	hardsuit_type = "syndi"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 40, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 60, "bleed" = 70)
	actions_types = list(/datum/action/item_action/toggle_helmet_light,\
		/datum/action/item_action/toggle_beacon_hud)

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/shielded/syndi))
		var/obj/linkedsuit = loc
		//NOTE FOR COPY AND PASTING: BEACON MUST BE MADE FIRST
		//Add the monitor (Default to null - No tracking)
		var/datum/component/tracking_beacon/component_beacon = linkedsuit.AddComponent(/datum/component/tracking_beacon, "synd", null, null, TRUE, "#8f4a4b")
		//Add the monitor (Default to null - No tracking)
		component_beacon.attached_monitor = AddComponent(/datum/component/team_monitor, "synd", null, component_beacon)
	else
		AddComponent(/datum/component/team_monitor, "synd", null)

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi/ui_action_click(mob/user, datum/action)
	switch(action.type)
		if(/datum/action/item_action/toggle_helmet_mode)
			toggle_helmlight()
		if(/datum/action/item_action/toggle_beacon_hud)
			toggle_hud(user)

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi/proc/toggle_hud(mob/user)
	var/datum/component/team_monitor/monitor = GetComponent(/datum/component/team_monitor)
	if(!monitor)
		to_chat(user, "<span class='notice'>Kombinezon nie jest wyposażony w nadajnik lokalizacyjny.</span>")
		return
	monitor.toggle_hud(!monitor.hud_visible, user)
	if(monitor.hud_visible)
		to_chat(user, "<span class='notice'>Przełączasz wyświetlacz HUD swojego kombinezonu.</span>")
	else
		to_chat(user, "<span class='warning'>Wyłączasz wyświetlacz HUD swojego kombinezonu.</span>")

///SWAT version
/obj/item/clothing/suit/space/hardsuit/shielded/swat
	name = "skafander Komandosa Śmierci"
	desc = "Zaawansowany hardsuit, który komandosi chętnie zabierają na operacje specjalne."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	hardsuit_type = "syndi"
	max_charges = 4
	recharge_delay = 1.5 SECONDS
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" =60, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 100, "bleed" = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	jetpack = /obj/item/tank/jetpack/suit
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	dog_fashion = /datum/dog_fashion/back/deathsquad

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	name = "hełm Komandosa Śmierci"
	desc = "Taktyczny hełm z wbudowaną tarczą energetyczną."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	hardsuit_type = "syndi"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 60, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 100, "bleed" = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()

/obj/item/clothing/suit/space/hardsuit/shielded/swat/honk
	name = "skafander oddziału HONK"
	desc = "Przezabawny hardsuit, który żołnierze oddziału HONK chętnie zabierają na specjalne psikusy."
	icon_state = "hardsuit-clown"
	item_state = "clown_hardsuit"
	hardsuit_type = "clown"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/swat/honk

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat/honk
	name = "hełm oddziału HONK"
	desc = "Przezabawny hełm z wbudowaną osłoną przed propagandą mimów."
	icon_state = "hardsuit0-clown"
	item_state = "hardsuit0-clown"
	hardsuit_type = "clown"


// Doomguy ERT version
/obj/item/clothing/suit/space/hardsuit/shielded/doomguy
	name = "pancerz juggernauta"
	desc = "Jakimś cudem nadający się do kosmosu pancerz, który świetnie chroni przed niemal wszystkim. W dziwnie nostalgicznym zielonym kolorze. "
	icon_state = "doomguy"
	item_state = "doomguy"
	max_charges = 1
	recharge_delay = 100
	armor = list("melee" = 135, "bullet" = 135, "laser" = 135, "energy" = 135, "bomb" = 135, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 100, "bleed" = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/doomguy
	dog_fashion = /datum/dog_fashion/back/deathsquad

/obj/item/clothing/head/helmet/space/hardsuit/shielded/doomguy
	name = "hełm juggernauta"
	desc = "Zakurzony stary hełm, który jakimś cudem wytrzymuje nawet najsilniejsze ciosy."
	icon_state = "doomguy"
	item_state = "doomguy"
	armor = list("melee" = 135, "bullet" = 135, "laser" = 135, "energy" = 135, "bomb" = 135, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 100, "bleed" = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()
