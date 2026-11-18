// AQUILA - NIFSoft: program działający na NIF-ie, i dysk, z którego się go wgrywa.
// Port z Monkestation (nifsofts.dm), bez punktów nagród i zapisu między rundami.

#define DEFAULT_NIFSOFT_COOLDOWN 5 SECONDS

/// Bazowy NIFSoft
/datum/nifsoft
	/// Nazwa programu
	var/name = "Ogólny NIFSoft"
	/// Nazwa widoczna w oknie NIF (EMP chwilowo ją miesza)
	var/program_name
	/// Opis programu w oknie NIF i w katalogu
	var/program_desc = "Ten program coś robi!"
	/// NIF, na którym działa program
	var/datum/weakref/parent_nif
	/// Nosiciel NIF-u
	var/mob/living/carbon/human/linked_mob
	/// Cena w kredytach w katalogu
	var/purchase_price = 300
	/// Zakładka katalogu
	var/buying_category = NIFSOFT_CATEGORY_GENERAL
	/// Ikona Font Awesome przy nazwie
	var/ui_icon = "floppy-disk"
	/// Motyw okna programu, jeśli ma własne
	var/ui_theme = "default"

	/// Czy program można zainstalować tylko raz
	var/single_install = TRUE
	/// Programy, z którymi ten się wyklucza
	var/list/mutually_exclusive_programs = list()

	/// Czy program ma tryb włączony/wyłączony
	var/active_mode = FALSE
	/// Czy program jest włączony
	var/active = FALSE
	/// Zużycie energii na cykl, gdy program jest włączony
	var/active_cost = 0
	/// Koszt energii jednego uruchomienia
	var/activation_cost = 0
	/// Czy program ma czas odnowienia
	var/cooldown = FALSE
	/// Czy program właśnie się odnawia
	var/on_cooldown = FALSE
	/// Czas odnowienia
	var/cooldown_duration = DEFAULT_NIFSOFT_COOLDOWN
	/// Modele NIF, na które program się instaluje
	var/list/compatible_nifs = list(/obj/item/organ/cyberimp/brain/nif)

/datum/nifsoft/New(obj/item/organ/cyberimp/brain/nif/recepient_nif)
	. = ..()
	compatible_nifs += /obj/item/organ/cyberimp/brain/nif/debug
	program_name = name

	if(!istype(recepient_nif) || !recepient_nif.install_nifsoft(src))
		qdel(src)
		return

	update_theme()

/datum/nifsoft/Destroy()
	if(active)
		INVOKE_ASYNC(src, PROC_REF(activate))

	linked_mob = null

	var/obj/item/organ/cyberimp/brain/nif/installed_nif = parent_nif?.resolve()
	if(installed_nif)
		installed_nif.loaded_nifsofts -= src

	return ..()

/// Włącza albo wyłącza program (dla programów bez trybu: uruchamia go raz)
/datum/nifsoft/proc/activate()
	var/obj/item/organ/cyberimp/brain/nif/installed_nif = parent_nif?.resolve()

	if(!installed_nif)
		if(active) // NIF właśnie jest niszczony: wyłącz sam program, bez rozliczania energii
			active = FALSE
			return TRUE
		stack_trace("NIFSoft [src] activated on a null parent!")
		return FALSE

	if(installed_nif.broken)
		installed_nif.balloon_alert(installed_nif.linked_mob, "NIF jest zepsuty")
		return FALSE

	if(cooldown && on_cooldown)
		installed_nif.balloon_alert(installed_nif.linked_mob, "[name] się odnawia")
		return FALSE

	if(active)
		active = FALSE
		installed_nif.balloon_alert(installed_nif.linked_mob, "[name] wyłączony")
		installed_nif.power_usage -= active_cost
		installed_nif.update_static_data_for_all_viewers()
		return TRUE

	if(!installed_nif.change_power_level(activation_cost))
		return FALSE

	if(active_mode)
		installed_nif.balloon_alert(installed_nif.linked_mob, "[name] włączony")
		installed_nif.power_usage += active_cost
		active = TRUE
		installed_nif.update_static_data_for_all_viewers()

	if(cooldown)
		addtimer(CALLBACK(src, PROC_REF(remove_cooldown)), cooldown_duration)
		on_cooldown = TRUE

	return TRUE

/// Oddaje koszt uruchomienia
/datum/nifsoft/proc/refund_activation_cost()
	var/obj/item/organ/cyberimp/brain/nif/installed_nif = parent_nif?.resolve()
	if(!installed_nif)
		return
	installed_nif.change_power_level(-activation_cost)

/// Kończy odnawianie
/datum/nifsoft/proc/remove_cooldown()
	on_cooldown = FALSE

/// Przywraca nazwę po EMP
/datum/nifsoft/proc/restore_name()
	program_name = initial(name)

/// Reakcja programu na EMP: wyłącza się i na minutę miesza nazwę
/datum/nifsoft/proc/on_emp(emp_severity)
	if(active)
		activate()

	var/static/list/random_characters = list("#","!","%","^","*","$","@","^","A","b","c","D","F","W","H","Y","z","U","O","o")
	var/scrambled_name = "!"

	for(var/i in 1 to length(program_name))
		scrambled_name += pick(random_characters)

	program_name = scrambled_name
	addtimer(CALLBACK(src, PROC_REF(restore_name)), 60 SECONDS)

/datum/nifsoft/ui_state(mob/user)
	return GLOB.conscious_state

/// Dopasowuje motyw programu do NIF-u
/datum/nifsoft/proc/update_theme()
	var/obj/item/organ/cyberimp/brain/nif/target_nif = parent_nif?.resolve()
	if(!target_nif)
		return FALSE

	ui_theme = target_nif.current_theme
	return TRUE

/// Dysk wgrywający NIFSoft do NIF-u
/obj/item/disk/nifsoft_uploader
	name = "dysk z danymi NIFSoft"
	desc = "Dysk z danymi, z którego można wgrać zapisany na nim NIFSoft do NIF-u. Użyj go w ręce na sobie albo na innej osobie."
	icon = 'aquila/icons/monke/nif/nif_disks.dmi'
	icon_state = "base_disk"
	/// Zapisany program
	var/datum/nifsoft/loaded_nifsoft = /datum/nifsoft
	/// Czy dysk zostaje po instalacji
	var/reusable = FALSE

/obj/item/disk/nifsoft_uploader/Initialize(mapload)
	. = ..()
	name = "dysk z danymi NIFSoft: [initial(loaded_nifsoft.name)]"

/obj/item/disk/nifsoft_uploader/examine(mob/user)
	. = ..()
	var/nifsoft_desc = initial(loaded_nifsoft.program_desc)
	if(nifsoft_desc)
		. += span_notice("Opis programu: [nifsoft_desc]")

/// Próbuje zainstalować program z dysku w NIF-ie celu
/obj/item/disk/nifsoft_uploader/proc/attempt_software_install(mob/living/carbon/human/target, mob/user)
	if(!ishuman(target))
		return FALSE
	var/obj/item/organ/cyberimp/brain/nif/installed_nif = target.getorganslot(ORGAN_SLOT_BRAIN_NIF)
	if(!istype(installed_nif))
		balloon_alert(user || target, "brak NIF-u")
		return FALSE

	var/datum/nifsoft/installed_nifsoft = new loaded_nifsoft(installed_nif)
	if(QDELETED(installed_nifsoft) || !installed_nifsoft.parent_nif)
		balloon_alert(user || target, "instalacja nieudana")
		return FALSE

	if(!reusable)
		qdel(src)
	return TRUE

/obj/item/disk/nifsoft_uploader/attack_self(mob/user)
	attempt_software_install(user, user)

/obj/item/disk/nifsoft_uploader/attack(mob/living/target_mob, mob/living/user, params)
	if(target_mob != user && !do_after(user, 5 SECONDS, target = target_mob))
		balloon_alert(user, "instalacja przerwana")
		return FALSE

	attempt_software_install(target_mob, user)

#undef DEFAULT_NIFSOFT_COOLDOWN
