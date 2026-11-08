// AQUILA - Alt+klik otwiera okno kafelka (RPG Loot, tgstation/tgstation#82533). Hook: /atom/AltClick() i
// /atom/AltClickNoInteract() w code/_onclick/click.dm.

/atom
	/// FALSE: typ ma własną akcję Alt+klik i nie otwiera okna kafelka (alt_click_actions.dm)
	var/alt_click_loot = TRUE

/// Czy Alt+klik na ten atom otwiera okno kafelka (FALSE, gdy atom ma własną akcję)
/atom/proc/opens_loot_panel()
	return alt_click_loot

// Alt+klik na przedmiot z wyborem wyglądu otwiera wybór (/obj/AltClick)
/obj/opens_loot_panel()
	if(unique_reskin && !current_skin)
		return FALSE
	return ..()

/// Otwiera okno zawartości kafelka. ignore_blockers dla duchów i innych, które nie dotykają świata.
/mob/proc/open_loot_panel(atom/target, turf/tile, ignore_blockers = FALSE)
	if(!client || !tile)
		return FALSE
	if(movement_type & VENTCRAWLING)
		return FALSE
	if(!ignore_blockers && !target.opens_loot_panel())
		return FALSE
	var/datum/lootpanel/panel = client.get_loot_panel()
	panel.open(tile)
	return TRUE
