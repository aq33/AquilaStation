//Antag modules for MODsuits

///Armor Booster - Grants your suit more armor and speed in exchange for EVA protection.
/obj/item/mod/module/armor_booster
	name = "moduł wzmocnienia pancerza MOD"
	desc = "Dodany później zestaw wysuwanych płyt pancernych, dzięki którym skafander działa właściwie jak pancerz wspomagany \
		i daje użytkownikowi niesamowitą ochronę przed konwencjonalną bronią palną i zwykłymi atakami w zwarciu. \
		Dodatkowe poszycie nie może się jednak rozłożyć razem z częściami skafandra odpowiedzialnymi za szczelność, \
		więc po rozłożeniu ten dodatkowy pancerz całkowicie uniemożliwia działania poza statkiem."
	icon_state = "armor_booster"
	module_type = MODULE_TOGGLE
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/armor_booster, /obj/item/mod/module/welding)
	overlay_state_inactive = "module_armorbooster_off"
	overlay_state_active = "module_armorbooster_on"
	use_mod_colors = TRUE
	mask_worn_overlay = TRUE
	/// Whether or not this module removes pressure protection.
	var/remove_pressure_protection = TRUE
	/// Slowdown added to the control unit while this module is disabled
	var/space_slowdown = 0.5
	/// Armor values added to the suit parts.
	var/list/armor_mod = list("melee" = 25, "bullet" = 30, "laser" = 15, "energy" = 15)
	/// List of parts of the suit that are spaceproofed, for giving them back the pressure protection.
	var/list/spaceproofed = list()

/obj/item/mod/module/armor_booster/no_speedbost
	space_slowdown = 0

/obj/item/mod/module/armor_booster/on_part_activation()
	RegisterSignal(mod, COMSIG_MOD_UPDATE_SPEED, PROC_REF(on_update_speed))
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		head_cover.flash_protect = 2
	mod.update_speed()

/obj/item/mod/module/armor_booster/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	UnregisterSignal(mod, COMSIG_MOD_UPDATE_SPEED)
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		head_cover.flash_protect = initial(head_cover.flash_protect)
	mod.update_speed()

/obj/item/mod/module/armor_booster/on_activation()
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(mod.wearer, "pancerz wzmocniony, brak ochrony EVA")
	/*
	var/datum/mod_part/head_cover = mod.get_part_datum_from_slot(ITEM_SLOT_HEAD) || mod.get_part_datum_from_slot(ITEM_SLOT_MASK) || mod.get_part_datum_from_slot(ITEM_SLOT_EYES)
	if(head_cover)
		RegisterSignal(mod, COMSIG_MOD_PART_SEALED, PROC_REF(seal_helmet))
		seal_helmet(mod, head_cover)
	*/
	var/datum/armor/added_armor = getArmor(arglist(armor_mod))
	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		part.armor = part.armor.attachArmor(added_armor)
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(clothing_part.clothing_flags & STOPSPRESSUREDAMAGE)
			clothing_part.clothing_flags &= ~STOPSPRESSUREDAMAGE
			spaceproofed[clothing_part] = TRUE
	mod.update_speed()

/obj/item/mod/module/armor_booster/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(!deleting)
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		balloon_alert(mod.wearer, "pancerz chowa się, gotowość do EVA")
	/*
	var/datum/mod_part/head_cover = mod.get_part_datum_from_slot(ITEM_SLOT_HEAD) || mod.get_part_datum_from_slot(ITEM_SLOT_MASK) || mod.get_part_datum_from_slot(ITEM_SLOT_EYES)
	if(head_cover)
		UnregisterSignal(mod, COMSIG_MOD_PART_SEALED)
	*/
	var/datum/armor/removed_armor = getArmor(arglist(armor_mod))
	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		part.armor = part.armor.detachArmor(removed_armor)
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(spaceproofed[clothing_part])
			clothing_part.clothing_flags |= STOPSPRESSUREDAMAGE
	mod.update_speed()
	spaceproofed = list()

/obj/item/mod/module/armor_booster/proc/on_update_speed(datum/source, list/module_slowdowns, prevent_slowdown)
	SIGNAL_HANDLER
	if (!active)
		module_slowdowns += space_slowdown

/obj/item/mod/module/armor_booster/generate_worn_overlay(mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	overlay_state_active = "[initial(overlay_state_active)]-[mod.skin]"
	return ..()

/*
/obj/item/mod/module/armor_booster/proc/seal_helmet(datum/source, datum/mod_part/part)
	var/datum/mod_part/head_cover = mod.get_part_datum_from_slot(ITEM_SLOT_HEAD) || mod.get_part_datum_from_slot(ITEM_SLOT_MASK) || mod.get_part_datum_from_slot(ITEM_SLOT_EYES)
	if(part != head_cover)
		return
	if(part.sealed)
		ADD_TRAIT(mod.wearer, TRAIT_HEAD_INJURY_BLOCKED, REF(src))
	else
		REMOVE_TRAIT(mod.wearer, TRAIT_HEAD_INJURY_BLOCKED, REF(src))
*/

/obj/item/mod/module/armor_booster/on_install()
	RegisterSignal(mod, COMSIG_MOD_GET_VISOR_OVERLAY, PROC_REF(on_visor_overlay))

/obj/item/mod/module/armor_booster/on_uninstall(deleting)
	UnregisterSignal(mod, COMSIG_MOD_GET_VISOR_OVERLAY)

/obj/item/mod/module/armor_booster/proc/on_visor_overlay(datum/source,  mutable_appearance/standing, list/overrides)
	SIGNAL_HANDLER
	if (active)
		overrides += mutable_appearance(overlay_icon_file, "module_armorbooster_visor-[mod.skin]", layer = standing.layer + 0.1)

///Energy Shield - Gives you a rechargeable energy shield that nullifies attacks.
/obj/item/mod/module/energy_shield
	name = "moduł tarczy energetycznej MOD"
	desc = "Osobiste ochronne pole siłowe, spotykane zwykle w zastosowaniach wojskowych. \
		Ta zaawansowana tarcza deflektorowa to w zasadzie pomniejszona wersja tarcz ze statków kosmicznych, \
		co łatwo poznać po poborze energii. Potrafi zablokować niemal każdy nadchodzący atak, \
		ale przy niewielkiej liczbie osobnych ładunków użytkownik wciąż pozostaje śmiertelny."
	icon_state = "energy_shield"
	complexity = 3
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_power_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/energy_shield)
	required_slots = list(ITEM_SLOT_BACK)
	/// Max charges of the shield.
	var/max_charges = 3
	/// The time it takes for the first charge to recover.
	var/recharge_start_delay = 20 SECONDS
	/// How much time it takes for charges to recover after they started recharging.
	var/charge_increment_delay = 1 SECONDS
	/// How much charge is recovered per recovery.
	var/charge_recovery = 1
	/// Whether or not this shield can lose multiple charges.
	var/lose_multiple_charges = FALSE
	/// The item path to recharge this shielkd.
	var/recharge_path
	/// The icon file of the shield.
	var/shield_icon_file = 'icons/effects/effects.dmi'
	/// The icon_state of the shield.
	var/shield_icon = "shield-red"
	/// Charges the shield should start with.
	var/charges

/obj/item/mod/module/energy_shield/Initialize(mapload)
	. = ..()
	charges = max_charges

/obj/item/mod/module/energy_shield/on_part_activation()
	var/datum/component/shielded/shield = mod.AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, shield_icon_file = shield_icon_file, shield_icon = shield_icon)
	shield.current_charges = clamp(charges, 0, max_charges)
	shield.recharge_path = recharge_path
	if(shield.current_charges < max_charges && recharge_start_delay)
		START_PROCESSING(SSdcs, shield)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS,  PROC_REF(shield_reaction))

/obj/item/mod/module/energy_shield/on_part_deactivation(deleting = FALSE)
	var/datum/component/shielded/shield = mod.GetComponent(/datum/component/shielded)
	charges = shield?.current_charges
	qdel(shield)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/mod/module/energy_shield/proc/shield_reaction(mob/living/carbon/human/owner, atom/movable/hitby, damage = 0, attack_text = "atak", attack_type = MELEE_ATTACK, armour_penetration = 0)
	SIGNAL_HANDLER

	if(SEND_SIGNAL(mod, COMSIG_ITEM_HIT_REACT, owner, hitby, attack_text, 0, damage, attack_type) & COMPONENT_HIT_REACTION_BLOCK)
		drain_power(use_power_cost)
		return SHIELD_BLOCK
	return NONE

/obj/item/mod/module/energy_shield/wizard
	name = "moduł tarczy bojowego maga MOD"
	desc = "Rzucający to zaklęcie zyskuje wokół siebie widoczną barierę, kierując tajemną moc przez \
		specjalne runy wygrawerowane na powierzchni skafandra, by wytworzyć ścianę mocy. \
		Ta tarcza doskonale niweluje ataki od wielkokalibrowych karabinów po magiczne pociski, \
		choć mogą ją wyczerpać także bardziej przyziemne ataki. Nie ochroni rzucającego przed społecznym ośmieszeniem."
	icon_state = "battlemage_shield"
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0 //magic
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0 //magic too
	max_charges = 15
	recharge_start_delay = 0 SECONDS
	charge_recovery = 8
	shield_icon_file = 'icons/obj/magic.dmi'
	shield_icon = "mageshield"
	recharge_path = /obj/item/wizard_armour_charge
	required_slots = list()

///Magic Nullifier - Protects you from magic.
/obj/item/mod/module/anti_magic
	name = "moduł niwelatora magii MOD"
	desc = "Zestaw obsydianowych prętów zamontowanych w kluczowych punktach skafandra, \
		wprawianych w drgania o niskiej częstotliwości, by rezonowały. \
		Tworzy to wokół użytkownika krótkozasięgowe, ale silne pole niwelujące magię, \
		wspomagane całkowitą wymianą zwykłego chłodziwa skafandra na wodę święconą. \
		Zaklęcia będą się odbijać od tego pola, ale nie pomoże ono innym uwierzyć ci w to wszystko."
	icon_state = "magic_nullifier"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/anti_magic)
	required_slots = list(ITEM_SLOT_BACK)

/obj/item/mod/module/anti_magic/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_ANTIMAGIC, REF(src))
	ADD_TRAIT(mod.wearer, TRAIT_HOLY, REF(src))

/obj/item/mod/module/anti_magic/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_ANTIMAGIC, REF(src))
	REMOVE_TRAIT(mod.wearer, TRAIT_HOLY, REF(src))

/obj/item/mod/module/anti_magic/wizard
	name = "moduł neutralizatora magii MOD"
	desc = "Rzucający to zaklęcie zyskuje wokół siebie niewidzialną barierę, kierując tajemną moc przez \
		specjalne runy wygrawerowane na powierzchni skafandra, by wytworzyć pole antymagiczne. \
		Pole zneutralizuje każdą magię, która zetknie się z użytkownikiem. \
		Nie ochroni rzucającego przed społecznym ośmieszeniem."
	icon_state = "magic_neutralizer"
	required_slots = list()

/obj/item/mod/module/anti_magic/wizard/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_ANTIMAGIC_NO_SELFBLOCK, REF(src))

/obj/item/mod/module/anti_magic/wizard/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_ANTIMAGIC_NO_SELFBLOCK, REF(src))

///Insignia - Gives you a skin specific stripe.
/obj/item/mod/module/insignia
	name = "moduł insygniów MOD"
	desc = "Mimo systemów IFF, łączności radiowej i nowoczesnych metod dedukcji z użyciem \
		własnych oczu kolorowe malowania wciąż są popularnym sposobem, by różne frakcje w galaktyce pokazywały, kim \
		są. Ten system używa zestawu małych ruchomych rozpylaczy farby, by nakładać i usuwać różne \
		wzory kolorystyczne na skafandrze."
	icon_state = "insignia"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/insignia)
	overlay_state_inactive = "module_insignia"
	mask_worn_overlay = TRUE

/obj/item/mod/module/insignia/generate_worn_overlay(mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	. = ..()
	for(var/mutable_appearance/appearance as anything in .)
		appearance.color = color

/obj/item/mod/module/insignia/commander
	color = "#4980a5"

/obj/item/mod/module/insignia/security
	color = "#b30d1e"

/obj/item/mod/module/insignia/engineer
	color = "#e9c80e"

/obj/item/mod/module/insignia/medic
	color = "#ebebf5"

/obj/item/mod/module/insignia/janitor
	color = "#7925c7"

/obj/item/mod/module/insignia/clown
	color = "#ff1fc7"

/obj/item/mod/module/insignia/chaplain
	color = "#f0a00c"

/obj/item/mod/module/noslip
	name = "moduł antypoślizgowy MOD"
	desc = "To zmodyfikowany wariant zwykłych butów magnetycznych z kryształami piezoelektrycznymi w podeszwach. \
		Dwie płytki na spodzie butów automatycznie wysuwają się i magnesują przy każdym kroku; \
		przyciąganie jest za słabe, by przyczepić się do kadłuba, ale wystarczająco silne, by \
		uchronić cię przed skutkami tego, że nie przeczytałeś znaku o mokrej podłodze. Honk Co. wielokrotnie \
		protestowało przeciwko legalności tych modułów."
	icon_state = "noslip"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/noslip)
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/noslip/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_NOSLIPWATER, REF(src))

/obj/item/mod/module/noslip/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSLIPWATER, REF(src))

///Flamethrower - Launches fire across the area.
/obj/item/mod/module/flamethrower
	name = "moduł miotacza ognia MOD"
	desc = "Miotacz ognia robiony na zamówienie, do wypalania sobie drogi. Płoń jasno."
	icon_state = "flamethrower"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/flamethrower)
	cooldown_time = 2.5 SECONDS
	overlay_state_inactive = "module_flamethrower"
	overlay_state_active = "module_flamethrower_on"
	required_slots = list(ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING)

/obj/item/mod/module/flamethrower/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/item/projectile/flame = new /obj/item/projectile/bullet/incendiary/backblast/flamethrower(mod.wearer.loc)
	flame.preparePixelProjectile(target, mod.wearer)
	flame.firer = mod.wearer
	playsound(src, 'sound/items/modsuit/flamethrower.ogg', 75, TRUE)
	INVOKE_ASYNC(flame, TYPE_PROC_REF(/obj/item/projectile, fire))
	drain_power(use_power_cost)

/obj/item/projectile/bullet/incendiary/backblast/flamethrower
	range = 6

///Power kick - Lets the user launch themselves at someone to kick them.
/obj/item/mod/module/power_kick
	name = "moduł potężnego kopnięcia MOD"
	desc = "Ten moduł używa wysokowydajnego myomeru, by wytworzyć niesamowitą ilość energii, przenoszoną na siłę kopnięcia."
	icon_state = "power_kick"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/power_kick)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_FEET)
	/// Damage on kick.
	var/damage = 20
	/// The wound bonus of the kick.
	var/wounding_power = 35
	/// How long we knockdown for on the kick.
	var/knockdown_time = 2 SECONDS

/obj/item/mod/module/power_kick/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	mod.wearer.visible_message(span_warning("[mod.wearer] zaczyna ładować kopnięcie!"), \
		blind_message = span_hear("Słyszysz dźwięk ładowania."))
	playsound(src, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	balloon_alert(mod.wearer, "zaczynasz ładowanie...")
	animate(mod.wearer, 0.3 SECONDS, pixel_z = 16, flags = ANIMATION_RELATIVE|SINE_EASING|EASE_OUT)
	addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/atom, SpinAnimation), 3, 2), 0.3 SECONDS)
	if(!do_after(mod.wearer, 1 SECONDS, target = mod))
		animate(mod.wearer, 0.2 SECONDS, pixel_z = -16, flags = ANIMATION_RELATIVE|SINE_EASING|EASE_IN)
		return
	animate(mod.wearer)
	drain_power(use_power_cost)
	playsound(src, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	var/angle = get_angle(mod.wearer, target) + 180
	mod.wearer.transform = mod.wearer.transform.Turn(angle)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	mod.wearer.throw_at(target, range = 7, speed = 2, thrower = mod.wearer, spin = FALSE, callback = CALLBACK(src, PROC_REF(on_throw_end), mod.wearer, -angle))

/obj/item/mod/module/power_kick/proc/on_throw_end(mob/user, angle)
	if(!user)
		return
	user.transform = user.transform.Turn(angle)
	animate(user, 0.2 SECONDS, pixel_z = -16, flags = ANIMATION_RELATIVE|SINE_EASING|EASE_IN)

/obj/item/mod/module/power_kick/proc/on_throw_impact(mob/living/source, atom/target, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!mod?.wearer)
		return
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_damage(damage, BRUTE, mod.wearer.zone_selected)
		living_target.Knockdown(knockdown_time)
	else if(isobj(target))
		var/obj/target_object = target
		target_object.take_damage(damage, BRUTE, "melee")
	else
		return
	mod.wearer.do_attack_animation(target, ATTACK_EFFECT_SMASH)

///Chameleon - lets the suit disguise as any item that would fit on that slot.
/obj/item/mod/module/chameleon
	name = "moduł kameleona MOD"
	desc = "Moduł używający technologii kameleona, by upodobnić jednostkę sterującą MOD do innego plecaka. Działa tylko przy wyłączonym skafandrze."
	icon_state = "chameleon"
	module_type = MODULE_USABLE
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/chameleon)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	/// A list of all the items the suit can disguise as.
	var/list/possible_disguises = list()
	/// The path of the item we're disguised as.
	var/obj/item/current_disguise

/obj/item/mod/module/chameleon/on_install()
	var/list/all_disguises = sort_list(subtypesof(get_path_by_slot(mod.slot_flags)), GLOBAL_PROC_REF(cmp_typepaths_asc))
	for(var/clothing_path in all_disguises)
		var/obj/item/clothing = clothing_path
		if(!initial(clothing.icon_state))
			continue
		var/chameleon_item_name = "[initial(clothing.name)] ([initial(clothing.icon_state)])"
		possible_disguises[chameleon_item_name] = clothing_path

/obj/item/mod/module/chameleon/on_uninstall(deleting = FALSE)
	if(current_disguise)
		return_look()
	possible_disguises = null

/obj/item/mod/module/chameleon/used()
	if(mod.active || mod.activating)
		balloon_alert(mod.wearer, "jednostka aktywna!")
		return FALSE
	return ..()

/obj/item/mod/module/chameleon/on_use()
	if(current_disguise)
		return_look()
		return
	var/picked_name = tgui_input_list(mod.wearer, "Wybierz wygląd, który chcesz przyjąć", "Ustawienia kameleona", possible_disguises)
	if(!possible_disguises[picked_name] || mod.active || mod.activating)
		return
	current_disguise = possible_disguises[picked_name]
	update_look()

/obj/item/mod/module/chameleon/proc/update_look()
	mod.name = initial(current_disguise.name)
	mod.desc = initial(current_disguise.desc)
	mod.icon_state = initial(current_disguise.icon_state)
	mod.icon = initial(current_disguise.icon)
	mod.worn_icon = initial(current_disguise.worn_icon)
	mod.alternate_worn_layer = initial(current_disguise.alternate_worn_layer)
	mod.lefthand_file = initial(current_disguise.lefthand_file)
	mod.righthand_file = initial(current_disguise.righthand_file)
	mod.worn_icon_state = initial(current_disguise.worn_icon_state)
	mod.item_state = initial(current_disguise.item_state)
	mod.wearer.update_clothing(mod.slot_flags)
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(return_look))

/obj/item/mod/module/chameleon/proc/return_look()
	mod.name = "[initial(mod.name)] (model [mod.theme.name])"
	mod.desc = "[initial(mod.desc)] [mod.theme.desc]"
	mod.update_icon_state()
	var/list/mod_skin = mod.theme.variants[mod.skin]
	mod.icon = mod_skin[MOD_ICON_OVERRIDE] || 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	mod.worn_icon = mod_skin[MOD_WORN_ICON_OVERRIDE] || 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	mod.lefthand_file = initial(mod.lefthand_file)
	mod.righthand_file = initial(mod.righthand_file)
	mod.worn_icon_state = null
	mod.item_state = null
	mod.wearer.update_clothing(mod.slot_flags)
	current_disguise = null
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)

///Plate Compression - Compresses the suit to normal size
/obj/item/mod/module/plate_compression
	name = "moduł kompresji płyt MOD"
	desc = "Moduł, który utrzymuje skafander bardzo ciasno dopasowany, zmniejszając jego rozmiary. \
		Ze względu na nacisk na wszystkie części zwykłe moduły schowka się nie mieszczą."
	icon_state = "plate_compression"
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/plate_compression, /obj/item/mod/module/storage)
	/// The size we set the suit to.
	var/new_size = WEIGHT_CLASS_NORMAL
	/// The suit's size before the module is installed.
	var/old_size

/obj/item/mod/module/plate_compression/on_install()
	old_size = mod.w_class
	mod.w_class = new_size

/obj/item/mod/module/plate_compression/on_uninstall(deleting = FALSE)
	mod.w_class = old_size
	old_size = null
	if(!mod.loc)
		return
	var/datum/component/storage/holding_storage = mod.loc.GetComponent(/datum/component/storage)
	if(!holding_storage || holding_storage.max_w_class >= mod.w_class)
		return
	mod.forceMove(drop_location())

/obj/item/mod/module/demoralizer
	name = "moduł demoralizatora psi-echo MOD"
	desc = "Pewna wyjątkowo makabryczna członkini zespołu badawczego Roseus Galactic zadała współpracownikom pytanie: \
	„Pragnę mocy, by okaleczać psychikę wrogów, gdy ich mordę. Kto mnie powstrzyma przed wdrożeniem tego w naszym następnym projekcie?” \
	I tak niechętnie wynaleziono Demoralizator Psi-Echo. Przyszłość wojny psychologicznej, już dziś!"
	icon_state = "brain_hurties"
	complexity = 0
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	removable = FALSE
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	var/datum/proximity_monitor/advanced/demoraliser/demoralizer

/obj/item/mod/module/demoralizer/on_part_activation()
	var/datum/demoralise_moods/module/mood_category = new()
	demoralizer = new(mod.wearer, 7, TRUE, mood_category)

/obj/item/mod/module/demoralizer/on_part_deactivation(deleting = FALSE)
	QDEL_NULL(demoralizer)

/obj/item/mod/module/infiltrator
	name = "moduł podstawowych programów infiltracyjnych MOD"
	desc = "Główne systemy maskujące skafandra. Dzięki sygnałom elektromagnetycznym \
		nikt w pobliżu nie może dokładnie przyjrzeć się noszącemu ani wyraźnie go usłyszeć. \
		Zawiera też układy amortyzujące, które pomagają chronić użytkownika przed ciosami w głowę."
	icon_state = "infiltrator"
	complexity = 0
	removable = FALSE
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0
	incompatible_modules = list(/obj/item/mod/module/infiltrator, /obj/item/mod/module/armor_booster, /obj/item/mod/module/welding)
	required_slots = list(ITEM_SLOT_FEET, ITEM_SLOT_HEAD, ITEM_SLOT_OCLOTHING)

/obj/item/mod/module/infiltrator/on_install()
	mod.item_flags |= EXAMINE_SKIP

/obj/item/mod/module/infiltrator/on_uninstall(deleting = FALSE)
	mod.item_flags &= ~EXAMINE_SKIP

/obj/item/mod/module/infiltrator/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, MOD_TRAIT)
	ADD_TRAIT(mod.wearer, TRAIT_UNKNOWN, MOD_TRAIT)
	RegisterSignal(mod.wearer, COMSIG_TRY_MODIFY_SPEECH, PROC_REF(on_speech_modification))
	//var/obj/item/organ/tongue/user_tongue = mod.wearer.get_organ_slot(ORGAN_SLOT_TONGUE)
	//user_tongue.temp_say_mod = "states"
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(head_cover))
		head_cover.flash_protect = 2

/obj/item/mod/module/infiltrator/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, MOD_TRAIT)
	REMOVE_TRAIT(mod.wearer, TRAIT_UNKNOWN, MOD_TRAIT)
	UnregisterSignal(mod.wearer, COMSIG_TRY_MODIFY_SPEECH)
	//var/obj/item/organ/tongue/user_tongue = mod.wearer.get_organ_slot(ORGAN_SLOT_TONGUE)
	//user_tongue.temp_say_mod = initial(user_tongue.temp_say_mod)
	if(deleting)
		return
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(head_cover))
		head_cover.flash_protect = initial(head_cover.flash_protect)

/obj/item/mod/module/infiltrator/proc/on_speech_modification(datum/source)
	SIGNAL_HANDLER
	if(!mod.active)
		return
	//Prevent speech modifications if the suit is active
	return PREVENT_MODIFY_SPEECH
