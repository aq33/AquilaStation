// Miękkie światło i poświata świecących rzeczy, bliżej wyglądu SS14.
// Oba efekty liczy tylko karta graficzna klienta (filtry na plane masterach), serwer nic nie dokłada.
// Gracz wyłącza je w preferencjach: „Miękkie światło”, „Poświata” i „Promienie świateł”.
//
// Miękkie światło: rozmycie płaszczyzny światła, zanim emisyjne wytną w niej dziury.
// Narożnikowe światło tg daje romby wokół lamp i kafelkowe krawędzie przy ścianach, rozmycie je wygładza.
//
// Poświata: kopia płaszczyzn podłogi i gry, przycięta do emisyjnych (ekrany, lampy, pociski),
// rozmyta i dodana na wierzch oświetlonej sceny. Ma więc kolor świecącej rzeczy, a mob przed ekranem
// zasłania ją tak samo jak samo świecenie (emissive_blocker).
//
// Promienie: ten sam łańcuch filtrów poświaty z radial_blur przed bloomem, jak „glare” w Paradise.
// Smugi rozchodzą się od środka ekranu, więc lampy przy krawędzi widoku mają dłuższe promienie.
// Działają tylko z poświatą: bez bloomu wycięcie kształtu zabiera prawie całe smugi.
// Osobnej płaszczyzny nie ma: między światłem a HUD-em nie została żadna wolna liczba całkowita plane.

/datum/preferences
	/// Rozmycie płaszczyzny światła
	var/soft_lighting = TRUE
	/// AQ_GLOW_*: siła poświaty emisyjnych
	var/glow_level = AQ_GLOW_MEDIUM
	/// Promienie od świecących rzeczy
	var/light_glare = FALSE

/// Ustawienia poświaty: list(rozmiar bloomu, rozrost przed rozmyciem, alfa bloomu)
/proc/aq_glow_settings(level)
	switch(level)
		if(AQ_GLOW_LOW)
			return list(1.5, 0, 130)
		if(AQ_GLOW_MEDIUM)
			return list(2, 0.5, 180)
		if(AQ_GLOW_HIGH)
			return list(3, 1, 230)
	return null

/// Kopie płaszczyzn do poświaty. Wspólne dla wszystkich klientów, jak maski animacji chodu.
GLOBAL_LIST_EMPTY(aq_glow_sources)

/proc/get_aq_glow_sources()
	var/list/sources = GLOB.aq_glow_sources
	var/atom/movable/screen/aq_glow_source/floor_source = length(sources) == 2 ? sources[1] : null
	var/atom/movable/screen/aq_glow_source/game_source = length(sources) == 2 ? sources[2] : null
	if(QDELETED(floor_source) || QDELETED(game_source))
		GLOB.aq_glow_sources = list(new /atom/movable/screen/aq_glow_source/floor, new /atom/movable/screen/aq_glow_source/game)
	return GLOB.aq_glow_sources

/// Kopia płaszczyzny (render_source) narysowana na płaszczyźnie poświaty.
/// screen_loc "1,1" jak przekaźniki płaszczyzn w tg: bufor plane mastera zaczyna się w lewym dolnym rogu widoku,
/// a z "CENTER" kopia na 516 jest przesunięta o pół widoku w pionie (sprawdzone na zrzutach).
/atom/movable/screen/aq_glow_source
	name = ""
	screen_loc = "1,1"
	plane = AQ_EMISSIVE_GLOW_PLANE
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/aq_glow_source/floor
	render_source = FLOOR_PLANE_RENDER_TARGET
	layer = 1

/atom/movable/screen/aq_glow_source/game
	render_source = GAME_PLANE_RENDER_TARGET
	layer = 2

/atom/movable/screen/plane_master/aq_emissive_glow
	name = "emissive glow plane master"
	plane = AQ_EMISSIVE_GLOW_PLANE
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/aq_emissive_glow/backdrop(mob/mymob)
	clear_filters()
	var/client/C = mymob?.client
	if(!C)
		return
	var/list/settings = aq_glow_settings(C.prefs?.glow_level)
	if(!settings)
		// Bez kopii płaszczyzn plane master jest pusty i nic nie kosztuje
		C.screen -= get_aq_glow_sources()
		return
	C.screen |= get_aq_glow_sources()
	add_filter("aq_glow_mask", 1, alpha_mask_filter(render_source = EMISSIVE_RENDER_TARGET))
	if(C.prefs.light_glare)
		add_filter("aq_glow_glare", 1.5, radial_blur_filter(AQ_GLARE_SIZE))
	add_filter("aq_glow_bloom", 2, list("type" = "bloom", "threshold" = "#000000", "size" = settings[1], "offset" = settings[2], "alpha" = settings[3]))
	// Sam świecący kształt już jest jasny (wycięty z ciemności), więc zostaje tylko aureola wokół niego.
	// Bez tego ekrany i lampy prześwietlają się do bieli.
	add_filter("aq_glow_cut", 3, alpha_mask_filter(render_source = EMISSIVE_RENDER_TARGET, flags = MASK_INVERSE))

// Kopie płaszczyzn czytają z render_target. Nazwę dostają tylko plane mastery HUD-u (backdrop),
// nie te z okien kamer, żeby poświata nie pokazywała obrazu z innej mapy.
/atom/movable/screen/plane_master/floor/backdrop(mob/mymob)
	. = ..()
	render_target = FLOOR_PLANE_RENDER_TARGET

/atom/movable/screen/plane_master/game_world/backdrop(mob/mymob)
	. = ..()
	render_target = GAME_PLANE_RENDER_TARGET

/atom/movable/screen/plane_master/lighting/backdrop(mob/mymob)
	. = ..()
	remove_filter("aq_soft_lighting")
	if(mymob?.client?.prefs?.soft_lighting)
		// Priorytet 0: przed maską emisyjnych (1), żeby ekrany i lampy zostały ostre
		add_filter("aq_soft_lighting", 0, gauss_blur_filter(AQ_SOFT_LIGHTING_BLUR))

/// Odświeża efekty światła po zmianie preferencji
/client/proc/aq_update_lighting_planes()
	var/datum/hud/hud = mob?.hud_used
	if(!hud)
		return
	for(var/plane_key in list("[LIGHTING_PLANE]", "[AQ_EMISSIVE_GLOW_PLANE]"))
		var/atom/movable/screen/plane_master/plane_master = hud.plane_masters[plane_key]
		plane_master?.backdrop(mob)
