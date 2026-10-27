// Podgląd chorób dla duchów i adminów (Monkestation2.0: observer.dm toggle_disease_view, ADMIN_VERB disease_view/diseases_panel).
// U nas nie ma makr GAME_VERB_DESC/ADMIN_VERB, więc to zwykłe czasowniki.

/mob/dead/observer
	/// Czy duch widzi wektory zakażeń (chmury, zakażone przedmioty i osoby).
	var/disease_view = FALSE

/mob/dead/observer/verb/toggle_disease_view()
	set name = "Toggle Disease View"
	set desc = "Pokazuje lub ukrywa wektory zakażeń (uśpione, krew, kontakt, powietrze)."
	set category = "Ghost"

	if(disease_view)
		RemoveElement(/datum/element/virus_viewer)
		to_chat(src, "<span class='notice'>Podgląd chorób wyłączony.</span>")
	else
		AddElement(/datum/element/virus_viewer)
		to_chat(src, "<span class='notice'>Podgląd chorób włączony.</span>")

	disease_view = !disease_view

/client/proc/disease_view()
	set name = "Disease View"
	set desc = "Pokazuje wizualizację chorób."
	set category = "Debug"

	if(!check_rights(R_ADMIN))
		return
	if(isobserver(mob))
		var/mob/dead/observer/observer = mob
		observer.toggle_disease_view() // Na duchu cecha nie działa, więc idzie przez czasownik ducha.
		return
	if(HAS_TRAIT_FROM(mob, TRAIT_VIRUS_SCANNER, ADMIN_TRAIT))
		REMOVE_TRAIT(mob, TRAIT_VIRUS_SCANNER, ADMIN_TRAIT)
		to_chat(src, "<span class='notice'>Adminowski podgląd chorób wyłączony.</span>")
	else
		ADD_TRAIT(mob, TRAIT_VIRUS_SCANNER, ADMIN_TRAIT)
		to_chat(src, "<span class='notice'>Adminowski podgląd chorób włączony.</span>")

/client/proc/diseases_panel()
	set name = "Disease Panel"
	set desc = "Lista patogenów w rundzie i ich logi."
	set category = "Logs"

	if(!check_rights(R_ADMIN))
		return
	holder.diseases_panel()
