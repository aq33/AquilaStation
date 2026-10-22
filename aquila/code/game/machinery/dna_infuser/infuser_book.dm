// AQUILA - port z tgstation (code/game/machinery/dna_infuser/infuser_book.dm)
// U nas zamiast okna TGUI InfuserBook zwykła książka HTML budowana z GLOB.infuser_entries.

/obj/item/book/manual/infuser
	name = "Księga infuzji DNA"
	desc = "Cała książka o tym, jak nie zmienić się w muchomutanta."
	icon_state = "bookCloning"
	author = "Dział Genetyki"
	title = "Księga infuzji DNA"
	w_class = WEIGHT_CLASS_TINY
	window_size = "600x700"

/obj/item/book/manual/infuser/on_read(mob/user)
	if(!dat)
		dat = build_infuser_book()
	return ..()

/obj/item/book/manual/infuser/proc/build_infuser_book()
	var/list/text = list()
	text += "<h2>Księga infuzji DNA</h2>"
	text += "<p>Instrukcja: zdobądź martwe stworzenie (albo próbkę - martwą mysz, mięso gondoli, plon z hydroponiki). \
		Włóż je do gniazda infusera lub przeciągnij na maszynę. Pacjent wchodzi do komory, ktoś inny uruchamia maszynę. \
		Każda infuzja zamienia JEDEN organ na zmutowany odpowiednik.</p>"
	text += "<p>Maszyna na początku przyjmuje tylko wpisy tieru [DNA_MUTANT_TIER_ONE]. Gdy pacjent osiągnie pełny bonus \
		zestawu z najwyższego dostępnego tieru, maszyna odblokowuje kolejny (maksymalnie tier [DNA_INFUSER_MAX_TIER]). \
		Zbyt złożone albo nieznane DNA kończy się... muchą.</p><hr>"
	for(var/tier in DNA_MUTANT_TIER_ZERO to DNA_INFUSER_MAX_TIER)
		text += "<h3>Tier [tier]</h3>"
		for(var/entry_type in GLOB.infuser_entries)
			var/datum/infuser_entry/entry = GLOB.infuser_entries[entry_type]
			if(entry.tier != tier)
				continue
			text += "<b>[entry.name]</b> <i>(źródło: [entry.infuse_mob_name])</i><br>"
			text += "[entry.desc]<br>"
			if(entry.threshold_desc != DNA_INFUSION_NO_THRESHOLD)
				text += "<b>Po przekroczeniu progu:</b> [entry.threshold_desc]<br>"
			if(length(entry.qualities))
				text += "<ul>"
				for(var/quality in entry.qualities)
					text += "<li>[quality]</li>"
				text += "</ul>"
			else
				text += "<br>"
	return jointext(text, "")
