// AQUILA - urządzenia do NIF-ów: przecinak NIFSoftów, regenerator NIF i adapter okularów do soczewek.
// Port z Monkestation (misc_devices.dm), bez opisów fabularnych special_desc (nie mamy tego mechanizmu).

/// Przecinak NIF: wymazuje wybrany NIFSoft z NIF-u innej osoby (dla ochrony i antagonistów)
/obj/item/nifsoft_remover
	name = "przecinak NIF Lopland „Wrangler”"
	desc = "Małe urządzenie, którym można usunąć wybrany NIFSoft z NIF-u innej osoby. Użyj go na niej."
	icon = 'aquila/icons/monke/nif/nif_devices.dmi'
	icon_state = "nifsoft_remover"
	w_class = WEIGHT_CLASS_SMALL
	/// Czy usunięty program trafia na dysk
	var/create_disk = FALSE

/obj/item/nifsoft_remover/attack(mob/living/carbon/human/target_mob, mob/living/user, params)
	if(!ishuman(target_mob))
		return ..()
	var/obj/item/organ/cyberimp/brain/nif/target_nif = target_mob.getorganslot(ORGAN_SLOT_BRAIN_NIF)

	if(!istype(target_nif) || !length(target_nif.loaded_nifsofts))
		balloon_alert(user, "brak NIFSoftów!")
		return

	var/datum/nifsoft/nifsoft_to_remove = tgui_input_list(user, "Wybierz NIFSoft do usunięcia.", name, target_nif.loaded_nifsofts)
	if(!nifsoft_to_remove || QDELETED(nifsoft_to_remove))
		return FALSE

	user.visible_message(span_warning("[user] przykłada [name] do głowy [target_mob]."), span_notice("Zaczynasz usuwać NIFSoft."))
	if(!do_after(user, 5 SECONDS, target = target_mob))
		balloon_alert(user, "usuwanie przerwane!")
		return FALSE

	var/removed_name = nifsoft_to_remove.name
	var/removed_type = nifsoft_to_remove.type
	if(!target_nif.remove_nifsoft(nifsoft_to_remove))
		balloon_alert(user, "usuwanie nieudane!")
		return FALSE

	to_chat(user, span_notice("Usuwasz program [removed_name]."))
	user.log_message("removed [removed_name] from [key_name(target_mob)]", LOG_GAME)

	if(create_disk)
		var/obj/item/disk/nifsoft_uploader/new_disk = new(user.drop_location())
		new_disk.loaded_nifsoft = removed_type
		new_disk.name = "dysk z danymi NIFSoft: [removed_name]"
		user.put_in_hands(new_disk)

	return TRUE

/obj/item/nifsoft_remover/syndie
	name = "przecinak NIF Cybersun „Skalpel”"
	desc = "Przerobiony przecinak NIF, który usuwa wybrany NIFSoft i zapisuje jego czystą kopię na dysku."
	icon_state = "nifsoft_remover_syndie"
	create_disk = TRUE

/// Regenerator NIF: przywraca wytrzymałość bez operacji
/obj/item/nif_repair_kit
	name = "regenerator NIF Cerulean"
	desc = "Zestaw naprawczy, którym można przywrócić wytrzymałość NIF-u bez operacji. Użyj go na nosicielu."
	icon = 'aquila/icons/monke/nif/nif_devices.dmi'
	icon_state = "repair_paste"
	w_class = WEIGHT_CLASS_SMALL
	/// Ile wytrzymałości przywraca jedno użycie
	var/repair_amount = 20
	/// Ile zostało użyć
	var/uses = 5

/obj/item/nif_repair_kit/examine(mob/user)
	. = ..()
	. += span_notice("Pozostało użyć: [uses].")

/obj/item/nif_repair_kit/attack(mob/living/carbon/human/mob_to_repair, mob/living/user, params)
	if(!ishuman(mob_to_repair))
		return ..()

	var/obj/item/organ/cyberimp/brain/nif/installed_nif = mob_to_repair.getorganslot(ORGAN_SLOT_BRAIN_NIF)
	if(!istype(installed_nif))
		balloon_alert(user, "brak NIF-u")
		return FALSE

	if(!do_after(user, 5 SECONDS, target = mob_to_repair))
		balloon_alert(user, "naprawa przerwana")
		return FALSE

	if(QDELETED(installed_nif) || !installed_nif.adjust_durability(repair_amount))
		balloon_alert(user, "NIF jest w pełni sprawny")
		return FALSE

	to_chat(user, span_notice("Naprawiasz NIF."))
	if(mob_to_repair != user)
		to_chat(mob_to_repair, span_notice("[user] naprawia twój NIF."))

	uses--
	if(uses <= 0)
		qdel(src)
	return TRUE

/// Adapter, po którym wybrane okulary obsługują soczewki NIFSoft
/obj/item/nif_hud_adapter
	name = "adapter soczewki jasnowidza"
	desc = "Zestaw, który przerabia wybrane okulary tak, żeby wyświetlały HUD-y z NIF-u. Użyj go na okularach."
	icon = 'aquila/icons/monke/nif/nif_kits.dmi'
	icon_state = "partskit"
	w_class = WEIGHT_CLASS_SMALL

	/// Czy adapter zostaje po użyciu
	var/multiple_uses = FALSE
	/// Okulary, które da się przerobić
	var/static/list/glasses_whitelist = list(
		/obj/item/clothing/glasses/monocle,
		/obj/item/clothing/glasses/regular,
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/clothing/glasses/sunglasses/advanced/gar,
		/obj/item/clothing/glasses/heat,
		/obj/item/clothing/glasses/cold,
		/obj/item/clothing/glasses/orange,
		/obj/item/clothing/glasses/red,
	)

/obj/item/nif_hud_adapter/examine(mob/user)
	. = ..()
	var/list/compatible_glasses_names = list()
	for(var/obj/item/glasses_type as anything in glasses_whitelist)
		var/glasses_name = initial(glasses_type.name)
		if(glasses_name)
			compatible_glasses_names += glasses_name

	if(length(compatible_glasses_names))
		. += span_notice("Pasuje do: [english_list(compatible_glasses_names)].")

/obj/item/nif_hud_adapter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !istype(target, /obj/item/clothing/glasses))
		return

	if(!is_type_in_list(target, glasses_whitelist))
		balloon_alert(user, "nie pasuje!")
		return

	if(HAS_TRAIT(target, TRAIT_NIFSOFT_HUD_GRANTER))
		balloon_alert(user, "już przerobione!")
		return

	var/obj/item/clothing/glasses/upgraded = target
	user.visible_message(span_notice("[user] przerabia [upgraded.name] adapterem."), span_notice("Przerabiasz [upgraded.name], teraz obsługują soczewki NIFSoft."))
	upgraded.name = "[upgraded.name] z HUD-em NIF"
	upgraded.AddElement(/datum/element/nifsoft_hud)
	playsound(upgraded.loc, 'sound/weapons/circsawhit.ogg', 50, vary = TRUE)

	if(!multiple_uses)
		qdel(src)
