// Płynniejsza paralaksa z BeeStation/BeeStation-Hornet#14864 (tg#66567) na naszym update_parallax():
// warstwy dociągają przesunięcie przez tyle czasu, ile trwa ślizg obiektu, który przesuwa widok klienta.
// Bez refaktoru paralaksy Bee: FTL dalej stoi na parallax_layer/update_status() z nsv13.

/// Czy animować przesunięcie warstw paralaksy (na niskich ustawieniach nie, żeby nie grzać słabych komputerów)
/client/var/do_parallax_animations = TRUE

/**
 * Czas ślizgu (w ds) obiektu, który niesie oko klienta (client.eye): najdalszy kontener oka (mob, mech, szafka).
 * Zwraca 0, gdy ten obiekt nie ślizga się (kamera overmapy z animate_movement = NO_STEPS) albo ślizg jest zerowy.
 */
/proc/get_parallax_glide_rate(atom/eye)
	var/atom/movable/mover = eye
	if(!istype(mover))
		return 0
	while(ismovable(mover.loc))
		mover = mover.loc
	if(mover.animate_movement == NO_STEPS || mover.glide_size <= 0)
		return 0
	return round(world.icon_size / mover.glide_size * world.tick_lag, world.tick_lag)
