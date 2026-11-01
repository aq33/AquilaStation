//Engineering modules for MODsuits

///Welding Protection - Makes the helmet protect from flashes and welding.
/obj/item/mod/module/welding
	name = "moduł ochrony przy spawaniu MOD"
	desc = "Moduł montowany w wizjerze skafandra; wyświetla przed oczami użytkownika \
		spolaryzowaną holograficzną nakładkę. Ma certyfikat odporności na \
		skrajności takie jak spawanie punktowe i łukowe, zaćmienia słońca i ręczne latarki."
	icon_state = "welding"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/welding, /obj/item/mod/module/armor_booster)
	overlay_state_inactive = "module_welding"
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/welding/on_part_activation()
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		//this is a screen that displays an image, so flash sensitives can use this to protect against flashes.
		head_cover.flash_protect = 2

/obj/item/mod/module/welding/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		head_cover.flash_protect = initial(head_cover.flash_protect)

///T-Ray Scan - Scans the terrain for undertile objects.
/obj/item/mod/module/t_ray
	name = "moduł skanera T-ray MOD"
	desc = "Moduł montowany w wizjerze skafandra; pozwala użytkownikowi wysłać impuls promieniowania terahercowego \
		i w zasadzie echolokować to, co pod podłogą, głównie kable i rury. \
		Podstawa w pracy atmosferyka i w walce z przemytem."
	icon_state = "tray"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/t_ray)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)
	/// T-ray scan range.
	var/range = 4

/obj/item/mod/module/t_ray/on_active_process(delta_time)
	t_ray_scan(mod.wearer, 0.8 SECONDS, range)

///Magnetic Stability - Gives the user a slowdown but makes them negate gravity and be immune to slips.
/obj/item/mod/module/magboot
	name = "moduł stabilizacji magnetycznej MOD"
	desc = "To potężne elektromagnesy zamontowane w butach skafandra, które dają użytkownikowi zarówno \
		świetną przyczepność w każdych warunkach w pomieszczeniach, jak i możliwość jazdy na gapę na zewnątrz kadłuba. \
		Te podstawowe modele nie mają jednak skomputeryzowanych układów, które same by je włączały i wyłączały, \
		więc wielu użytkowników skarży się na pewną lepkość kroków."
	icon_state = "magnet"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/magboot)
	required_slots = list(ITEM_SLOT_FEET)
	/// Slowdown added onto the suit.
	var/slowdown_active = 0.5

/obj/item/mod/module/magboot/on_install()
	RegisterSignal(mod, COMSIG_MOD_UPDATE_SPEED, PROC_REF(on_update_speed))

/obj/item/mod/module/magboot/on_uninstall(deleting)
	UnregisterSignal(mod, COMSIG_MOD_UPDATE_SPEED)

/obj/item/mod/module/magboot/on_activation()
	ADD_TRAIT(mod.wearer, TRAIT_NEGATES_GRAVITY, REF(src))
	ADD_TRAIT(mod.wearer, TRAIT_NOSLIPWATER, REF(src))
	mod.update_speed()

/obj/item/mod/module/magboot/on_deactivation(display_message = TRUE, deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_NEGATES_GRAVITY, REF(src))
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSLIPWATER, REF(src))
	mod.update_speed()

/obj/item/mod/module/magboot/proc/on_update_speed(datum/source, list/module_slowdowns, prevent_slowdown)
	SIGNAL_HANDLER
	if (!prevent_slowdown && active)
		module_slowdowns += slowdown_active

/obj/item/mod/module/magboot/advanced
	name = "zaawansowany moduł stabilizacji magnetycznej MOD"
	removable = FALSE
	complexity = 0
	slowdown_active = 0

///Emergency Tether - Shoots a grappling hook projectile in 0g that throws the user towards it.
/obj/item/mod/module/tether
	name = "moduł awaryjnej liny MOD"
	desc = "Hak z liną robiony na zamówienie, napędzany wyciągarką zdolną przyciągnąć użytkownika. \
		Niektóre starsze modele chwytaków do ładunków mają udźwig kilku ton, \
		ale te działają tylko w zerowej grawitacji, co dla niektórych inżynierów jest błogosławieństwem."
	icon_state = "tether"
	module_type = MODULE_ACTIVE
	module_type = MODULE_ACTIVE
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/tether)
	cooldown_time = 1.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/tether/used()
	if(mod.wearer.has_gravity(get_turf(src)))
		balloon_alert(mod.wearer, "za duża grawitacja!")
		playsound(src, 'sound/weapons/gun_dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/tether/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/item/projectile/tether = new /obj/item/projectile/tether(mod.wearer.loc)
	tether.preparePixelProjectile(target, mod.wearer)
	tether.firer = mod.wearer
	playsound(src, 'sound/weapons/batonextend.ogg', 25, TRUE)
	INVOKE_ASYNC(tether, TYPE_PROC_REF(/obj/item/projectile, fire))
	drain_power(use_power_cost)

/obj/item/projectile/tether
	name = "lina"
	icon_state = "tether_projectile"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	damage = 0
	nodamage = TRUE
	range = 10
	hitsound = 'sound/weapons/batonextend.ogg'
	hitsound_wall = 'sound/weapons/batonextend.ogg'
	suppressed = TRUE
	/// Reference to the beam following the projectile.
	var/line

/obj/item/projectile/tether/fire(setAngle)
	if(firer)
		line = firer.Beam(src, "line", 'icons/obj/clothing/modsuit/mod_modules.dmi', time = 10 SECONDS)
	..()

/obj/item/projectile/tether/on_hit(atom/target)
	. = ..()
	if(firer)
		firer.throw_at(target, 10, 1, firer, FALSE, FALSE, null, MOVE_FORCE_NORMAL, TRUE)

/obj/item/projectile/tether/Destroy()
	QDEL_NULL(line)
	return ..()

///Radiation Protection - Protects the user from radiation.
/obj/item/mod/module/rad_protection
	name = "moduł ochrony przed promieniowaniem MOD"
	desc = "Moduł wykorzystujący polimery i odblaskowe osłony, by chronić użytkownika przed promieniowaniem jonizującym; \
		to częste zagrożenie w kosmosie, zwłaszcza obok kryształu supermaterii."
	icon_state = "radshield"
	complexity = 2
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/rad_protection)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// Rad armor each part had before we maxed it out
	var/list/old_rad_armor = list()

// Our radiation still uses rad armor instead of a protection trait, so we max out the rad armor of every part
/obj/item/mod/module/rad_protection/on_part_activation()
	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		old_rad_armor[part] = part.armor.rad
		part.armor = part.armor.setRating(rad = 100)

/obj/item/mod/module/rad_protection/on_part_deactivation(deleting = FALSE)
	for(var/obj/item/part as anything in old_rad_armor)
		if(QDELETED(part))
			continue
		part.armor = part.armor.setRating(rad = old_rad_armor[part])
	old_rad_armor.Cut()

/obj/item/mod/module/rad_protection/on_uninstall(deleting = FALSE)
	old_rad_armor.Cut()

///Constructor - Lets you build quicker and create RCD holograms.
/obj/item/mod/module/constructor
	name = "moduł konstruktora MOD"
	desc = "Ten moduł zajmuje całe przedramię noszącego, przez co wyraźnie gryzie się z \
		zaawansowanymi serwami ramion do noszenia członków załogi. Działa za to jako \
		niezwykle zaawansowany skaner hologramów budowlanych, a do tego zawiera \
		najnowsze schematy inżynieryjne i wbudowaną pamięć, które pomagają użytkownikowi stawiać ściany."
	icon_state = "constructor"
	module_type = MODULE_USABLE
	complexity = 2
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/constructor, /obj/item/mod/module/quick_carry)
	cooldown_time = 11 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/constructor/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_QUICK_BUILD, REF(src))

/obj/item/mod/module/constructor/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICK_BUILD, REF(src))

/obj/item/mod/module/constructor/on_use()
	rcd_scan(src, fade_time = 10 SECONDS)
	drain_power(use_power_cost)

///Mister - Sprays water over an area.
/obj/item/mod/module/mister
	name = "moduł zraszacza wody MOD"
	desc = "Moduł ze zraszaczem, który potrafi spryskiwać okolicę."
	icon_state = "mister"
	module_type = MODULE_ACTIVE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/reagent_containers/spray/mister
	incompatible_modules = list(/obj/item/mod/module/mister)
	cooldown_time = 0.5 SECONDS
	/// Volume of our reagent holder.
	var/volume = 500

/obj/item/mod/module/mister/Initialize(mapload)
	create_reagents(volume, OPENCONTAINER)
	return ..()

///Resin Mister - Sprays resin over an area.
/obj/item/mod/module/mister/atmos
	name = "moduł zraszacza żywicy MOD"
	desc = "Atmosferyczny zraszacz żywicy, który pozwala szybko naprawić okolicę."
	device = /obj/item/extinguisher/mini/nozzle/mod
	volume = 250

/obj/item/mod/module/mister/atmos/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/water, volume)

/obj/item/extinguisher/mini/nozzle/mod
	name = "atmosferyczny zraszacz MOD"
	desc = "Atmosferyczny zraszacz żywicy z trzema trybami, zamontowany jako moduł."
