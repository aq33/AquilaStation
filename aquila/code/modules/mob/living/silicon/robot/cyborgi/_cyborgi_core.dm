// AQUILA - nowe moduły i ulepszenia cyborgów: wspólne rzeczy.
// Moduły i skiny: aquila/code/modules/mob/living/silicon/robot/cyborgi/modules.dm, ulepszenia: upgrades.dm,
// narzędzia: items.dm, projekty i badania: research.dm, zagubiony cyborg: lost.dm.
// Opis skąd co pochodzi: nagłówki plików i aquila/icons/mob/silicon/ATTRIBUTION_cyborgi.md.

/// Noktowizja cyborga (ulepszenia: noktowizja, noktowizyjne mezony). Bity 0-3 zajmuje core (code/__DEFINES/sight.dm)
#define BORG_AQ_NIGHTVISION (1<<4)
/// Źródło cech nadawanych przez moduł
#define AQ_BORG_MODULE_TRAIT "aq_borg_module"
/// Źródło cech nadawanych przez ulepszenia
#define AQ_BORG_UPGRADE_TRAIT "aq_borg_upgrade"
/// Najniższy ładunek, którego narzędzia cyborga nie ruszą, żeby nie wyłączyć jednostki
#define AQ_BORG_MIN_CHARGE 1000
/// Spowolnienie magnetycznych przyczep i przyspieszenie dopalaczy ratowniczych
#define MOVESPEED_ID_AQ_BORG_TRACTION "aq_borg_traction"
#define MOVESPEED_ID_AQ_RESCUE_BOOSTERS "aq_rescue_boosters"
/// Skiny nowych modułów (porty z Bay, Eris i Goona)
#define AQ_CYBORG_ICON_MODULES 'aquila/icons/mob/silicon/robots_aquila_modules.dmi'

/obj/item/robot_module
	/// AQUILA: plik z domyślnym wyglądem modułu (przy wyborze bez skina, np. moduł z ulepszenia albo admina)
	var/aq_base_icon_file
	/// AQUILA: kanał radia działu (alarm śmierci cyborga)
	var/aq_department_channel = RADIO_CHANNEL_SCIENCE

/obj/item/robot_module/medical
	aq_department_channel = RADIO_CHANNEL_MEDICAL

/obj/item/robot_module/engineering
	aq_department_channel = RADIO_CHANNEL_ENGINEERING

/obj/item/robot_module/security
	aq_department_channel = RADIO_CHANNEL_SECURITY

/obj/item/robot_module/peacekeeper
	aq_department_channel = RADIO_CHANNEL_SECURITY

/obj/item/robot_module/janitor
	aq_department_channel = RADIO_CHANNEL_SERVICE

/obj/item/robot_module/butler
	aq_department_channel = RADIO_CHANNEL_SERVICE

/obj/item/robot_module/clown
	aq_department_channel = RADIO_CHANNEL_SERVICE

/obj/item/robot_module/miner
	aq_department_channel = RADIO_CHANNEL_SUPPLY

/obj/item/robot_module/cargo
	aq_department_channel = RADIO_CHANNEL_SUPPLY

/// Moduły dodane przez Aquilę w kółku wyboru modułu (hook w /mob/living/silicon/robot/proc/pick_module)
/proc/aquila_add_cyborg_modules(list/module_list)
	module_list["Research"] = /obj/item/robot_module/research
	module_list["Chemistry"] = /obj/item/robot_module/medical/chemistry
	module_list["Surgeon"] = /obj/item/robot_module/medical/surgeon
	module_list["Rescue"] = /obj/item/robot_module/medical/rescue
	module_list["Construction"] = /obj/item/robot_module/engineering/construction
	module_list["Exploration"] = /obj/item/robot_module/exploration
	module_list["Detective"] = /obj/item/robot_module/detective
	module_list["Brobocop"] = /obj/item/robot_module/brobocop
	module_list["Hydroponics"] = /obj/item/robot_module/hydroponics
	module_list["Clerical"] = /obj/item/robot_module/cargo/clerical
	module_list["Logistics"] = /obj/item/robot_module/cargo/logistics
	module_list["Multirole"] = /obj/item/robot_module/standard/multirole

/// Ikona modułu w kółku wyboru: moduły Aquili mają wygląd we własnym pliku
/proc/aquila_cyborg_module_radial_icon(module_type)
	var/obj/item/robot_module/module = module_type
	return initial(module.aq_base_icon_file) || 'icons/mob/robots.dmi'

/obj/item/robot_module/be_transformed_to(obj/item/robot_module/old_module, forced = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/silicon/robot/cyborg = loc
	if(!istype(cyborg))
		return
	// Bez wybranego skina cyborg zostaje w domyślnym pliku core (transform_to), a moduł Aquili ma wygląd u siebie
	if(aq_base_icon_file && cyborg.icon == 'icons/mob/robots.dmi')
		cyborg.icon = aq_base_icon_file
	aq_on_install(cyborg)

// Stary moduł znika w transform_to już po założeniu nowego, więc cechy mają źródło REF(modułu), a nie wspólne
/obj/item/robot_module/Destroy()
	if(robot)
		aq_on_remove(robot)
	return ..()

/// Moduł został założony na cyborga (cechy modułu, odporności)
/obj/item/robot_module/proc/aq_on_install(mob/living/silicon/robot/cyborg)
	return

/// Moduł schodzi z cyborga (zmiana albo reset modułu)
/obj/item/robot_module/proc/aq_on_remove(mob/living/silicon/robot/cyborg)
	return

/// Większe magazyny materiałów (zaawansowane moduły): mnożnik pojemności i odnawiania.
/// Woła się po każdym rebuild_modules(), ale powiększa tylko nowe magazyny (bez darmowego uzupełnienia przy montażu ulepszeń)
/obj/item/robot_module/proc/aq_scale_storages(multiplier)
	for(var/datum/robot_energy_storage/storage in storages)
		var/target = round(initial(storage.max_energy) * multiplier)
		if(storage.max_energy == target)
			continue
		storage.max_energy = target
		storage.recharge_rate = round(initial(storage.recharge_rate) * multiplier)
		storage.energy = target

/// Szuka narzędzia danego typu w module cyborga
/mob/living/silicon/robot/proc/aq_find_module_item(item_type)
	if(!module)
		return null
	return locate(item_type) in module.modules

/// Dodaje do modułu nowe narzędzie i zwraca je
/mob/living/silicon/robot/proc/aq_add_module_item(item_type)
	var/obj/item/new_item = new item_type(module)
	module.basic_modules += new_item
	module.add_module(new_item, FALSE, TRUE)
	return new_item

/// Usuwa z modułu wszystkie narzędzia danego typu (z podtypami) i zwraca, ile usunął
/mob/living/silicon/robot/proc/aq_remove_module_items(item_type)
	. = 0
	if(!module)
		return
	for(var/obj/item/module_item in module.modules.Copy())
		if(istype(module_item, item_type))
			module.remove_module(module_item, TRUE)
			.++

/// Czy cyborg ma dość energii na zużycie amount (zostawia AQ_BORG_MIN_CHARGE), i zużywa ją
/mob/living/silicon/robot/proc/aq_use_charge(amount)
	if(!cell || cell.charge < amount + AQ_BORG_MIN_CHARGE)
		return FALSE
	cell.use(amount)
	return TRUE

// Noktowizja jako dodatkowy bit sight_mode, po zwykłym wzroku cyborga
/mob/living/silicon/robot/update_sight()
	. = ..()
	if(!client || stat == DEAD)
		return
	if(sight_mode & BORG_AQ_NIGHTVISION)
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
		see_in_dark = max(see_in_dark, 8)
		sync_lighting_plane_alpha()
