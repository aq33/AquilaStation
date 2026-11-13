// Examine w układzie tgstation: pierwsza linia (To jest...) w zakładce na górnej krawędzi ramki, reszta w ramce.
// U ludzi w zakładce jest też portret postaci: płaski sprite z tym, co ma na sobie, liczony raz do zmiany wyglądu.
// Hook: run_examinate() w code/modules/mob/mob.dm.

/// HTML wyniku examine dla tego moba
/mob/proc/aq_examine_html(atom/examined, list/result)
	if(!islist(result))
		result = list(result)
	if(!length(result))
		return ""
	result = aq_order_examine_sections(result)
	var/title = result[1]
	var/portrait = examined.aq_examine_portrait(src)
	if(portrait)
		title = "[portrait] [title]"
	if(length(result) < 2)
		return "<span class='infoplain'>[boxed_message(title)]</span>"
	return "<span class='infoplain'>[fieldset_block(title, aq_join_examine_lines(result.Copy(2)), "boxed_message")]</span>"

/// Łączy linie examine nową linią (czat ma white-space: pre-wrap), ale nie obok kresek separator_hr, które same są blokiem
/proc/aq_join_examine_lines(list/lines)
	var/static/regex/trailing_newlines = regex("\n+$")
	var/list/out = list()
	var/previous_block = TRUE
	for(var/line in lines)
		if(isnull(line))
			continue
		line = trailing_newlines.Replace("[line]", "")
		var/is_block = findtext(line, "<div class='separator'>") == 1
		if(length(out) && !previous_block && !is_block)
			out += "\n"
		out += line
		previous_block = is_block
	return jointext(out, "")

/**
 * Układa examine człowieka w sekcje jak w tg: ubranie, pod kreską stan (także linie dopisane przez nadpisania examine()
 * po ..(), np. blizny i zapach), pod kreską dane z HUD-ów, na końcu link „Przyjrzyj się uważniej”.
 * Wynik bez znaczników AQ_EXAMINE_* zwraca bez zmian.
 */
/proc/aq_order_examine_sections(list/result)
	var/status_at = result.Find(AQ_EXAMINE_STATUS_MARK)
	var/hud_at = result.Find(AQ_EXAMINE_HUD_MARK)
	var/hud_end = result.Find(AQ_EXAMINE_HUD_END)
	if(!status_at || !hud_at || !hud_end || !(status_at < hud_at && hud_at < hud_end))
		return result
	var/list/ordered = result.Copy(1, status_at)
	var/list/status = list()
	for(var/line in result.Copy(status_at + 1, hud_at) + result.Copy(hud_end + 1))
		if(line)
			status += line
	var/list/hud = list()
	var/list/links = list()
	for(var/line in result.Copy(hud_at + 1, hud_end))
		if(!line)
			continue
		if(findtext(line, "lookup_info=open_examine_panel"))
			links += line
		else
			hud += line
	if(length(status))
		ordered += separator_hr("Stan")
		ordered += status
	if(length(hud))
		ordered += separator_hr("Analiza medyczna i ochrony")
		ordered += hud
	ordered += links
	return ordered

/// Portret do zakładki examine (tag img) albo null
/atom/proc/aq_examine_portrait(mob/user)
	return null

/// Najrzadziej co tyle portret jest liczony od nowa (getFlatIcon i zapis pliku są drogie, a nakładki zmieniają się często: pisanie, obrażenia)
#define AQ_PORTRAIT_REFRESH_COOLDOWN (10 SECONDS)

/mob/living
	/// Podpis wyglądu, dla którego policzono portret do examine
	var/aq_portrait_signature
	/// Nazwa assetu z portretem
	var/aq_portrait_asset
	COOLDOWN_DECLARE(aq_portrait_cooldown)

/mob/living/carbon/human/aq_examine_portrait(mob/user)
	return aq_build_portrait(user)

// Morf przebrany za człowieka też dostaje portret (swój obecny wygląd), inaczej brak portretu go zdradza
/mob/living/simple_animal/hostile/morph/aq_examine_portrait(mob/user)
	if(morphed && ishuman(form))
		return aq_build_portrait(user)
	return ..()

/// Portret moba (tag img) z pamięci podręcznej; liczony od nowa po zmianie wyglądu, najwyżej raz na AQ_PORTRAIT_REFRESH_COOLDOWN
/mob/living/proc/aq_build_portrait(mob/user)
	if(!user?.client)
		return null
	if(SSlag_switch.measures[DISABLE_USR_ICON2HTML] && !HAS_TRAIT(user, TRAIT_BYPASS_MEASURES))
		return null
	if(!aq_portrait_asset || (COOLDOWN_FINISHED(src, aq_portrait_cooldown) && !aq_portrait_stale_while_moving()))
		var/signature = aq_appearance_signature()
		if(signature != aq_portrait_signature || !aq_portrait_asset)
			var/icon/flat = getFlatIcon(src, SOUTH, no_anim = TRUE)
			if(!flat)
				return null
			var/list/name_and_ref = generate_and_hash_rsc_file(flat)
			aq_portrait_asset = "[name_and_ref[3]].png"
			SSassets.transport.register_asset(aq_portrait_asset, name_and_ref[1], name_and_ref[2])
			aq_portrait_signature = signature
			COOLDOWN_START(src, aq_portrait_cooldown, AQ_PORTRAIT_REFRESH_COOLDOWN)
	SSassets.transport.send_assets(user.client, aq_portrait_asset)
	return "<img class='examine_portrait' src='[SSassets.transport.get_asset_url(aq_portrait_asset)]'>"

/// W ruchu animacja chodu przenosi trzymane przedmioty i części ciała do vis_contents, których getFlatIcon nie widzi:
/// wtedy zostaje poprzedni portret
/mob/living/proc/aq_portrait_stale_while_moving()
	var/datum/component/walk_animation/walk = GetComponent(/datum/component/walk_animation)
	return walk?.active

#undef AQ_PORTRAIT_REFRESH_COOLDOWN

/// Podpis tego, co widać na sprite'cie (bez kierunku), żeby nie liczyć portretu od nowa przy każdym obrocie
/mob/living/proc/aq_appearance_signature()
	var/list/parts = list("[icon]", icon_state, "[color]", "[alpha]")
	for(var/overlay in overlays)
		parts += "\ref[overlay]"
	for(var/underlay in underlays)
		parts += "\ref[underlay]"
	return jointext(parts, "|")

// Okno „Przyjrzyj się uważniej” (nsv13/code/modules/mob/living/carbon/examine_tgui.dm): obiekt podglądu trafia na mapę
// dopiero, gdy okno jest widoczne. Zarejestrowany wcześniej, zanim powstanie kontrolka mapy, był malutką postacią
// w rogu domyślnego widoku 15x15 (to samo co w podglądzie preferencji).
/datum/examine_panel/proc/aq_show_examine_screen(mob/user, datum/tgui_window/window)
	if(window && !window.visible)
		RegisterSignal(window, COMSIG_TGUI_WINDOW_VISIBLE, PROC_REF(aq_on_examine_window_visible), override = TRUE)
		return
	user.client?.register_map_obj(examine_panel_screen)

/datum/examine_panel/proc/aq_on_examine_window_visible(datum/tgui_window/window, client/viewer)
	SIGNAL_HANDLER
	UnregisterSignal(window, COMSIG_TGUI_WINDOW_VISIBLE)
	if(viewer && examine_panel_screen)
		viewer.register_map_obj(examine_panel_screen)
