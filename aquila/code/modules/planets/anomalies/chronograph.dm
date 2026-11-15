// AQUILA - chronograf: port z Shiptesta (code/game/objects/effects/anomalies/anomalies_chronograph.dm i efektu
// code/datums/status_effects/buffs/accelerando.dm, licencja AGPLv3; sprite z Shiptesta, CC BY-SA 3.0).
// Ludzie w zasięgu wypadają z czasu: im bliżej, tym dłużej trwa przyspieszenie (szybszy ruch). Długie
// przyspieszenie leczy, potem siwieją włosy, a na koniec zostają mdłości i dezorientacja.
// Różnice względem Shiptesta:
// - rdzeń grawitacyjny jak w Shiptest (chronograf nie ma własnego);
// - puls co pulse_delay (Shiptest nie startował odliczania i działał przy każdym procesie) i 2 iskry na człowieka
//   zamiast 6;
// - przyspieszenie bez rozmycia ruchu, nakładki ekranu, szybszego do_after (nie mamy physiology.do_after_speed),
//   starzenia i leczenia ran (u nas nie ma ran tg) oraz wariantu śmiertelnego (używanego tylko w Shiptest gdzie
//   indziej).

/obj/effect/anomaly/chronograph
	name = "chronograf"
	desc = "Czas bije naprzód coraz szybciej. Accelerando życia trwa bez końca, a tutaj napędza rzeczywistość."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "chronograph"
	light_range = 6
	light_color = LIGHT_COLOR_LIGHT_CYAN
	aSignal = /obj/item/assembly/signaler/anomaly/grav
	var/effectrange = 6
	var/pulse_delay = 1 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/effect/anomaly/chronograph/anomalyEffect(delta_time)
	..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	for(var/mob/living/old in orange(effectrange, src))
		// Bliżej znaczy mocniej; na samej krawędzi zasięgu nic
		var/effect_power = effectrange - get_dist(old, src)
		if(effect_power <= 0)
			continue
		apply_accelerando(old, effect_power SECONDS, effect_power * 30 SECONDS)
		if(prob(10))
			to_chat(old, "<span class='warning'>[pick("Czas zaczyna przeciekać ci przez palce.", "Świat wydaje się trochę wolniejszy.", "Nikt już nie będzie tak szybki jak ty.", "Twoje chwile stały się czymś więcej.", "Sekundy zamieniają się w godziny.", "Każda chwila jest wiecznością.")]</span>")
		do_sparks(2, TRUE, old)

/// Wydłuża przyspieszenie o amount, najwyżej do max_duration pozostałego czasu (jak adjust_timed_status_effect w tg)
/obj/effect/anomaly/chronograph/proc/apply_accelerando(mob/living/target, amount, max_duration)
	var/datum/status_effect/accelerando/effect = target.has_status_effect(/datum/status_effect/accelerando)
	if(effect)
		var/remaining = max(effect.duration - world.time, 0)
		effect.duration = world.time + min(remaining + amount, max_duration)
		return
	target.apply_status_effect(/datum/status_effect/accelerando, min(amount, max_duration))

/obj/effect/anomaly/chronograph/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/chronograph

/// Przyspieszenie z chronografu: szybszy ruch, przy długim leczenie i siwienie, na koniec mdłości
/datum/status_effect/accelerando
	id = "accelerando"
	alert_type = null
	tick_interval = 5
	duration = 10 SECONDS
	/// Jak silne było (do skutków po końcu)
	var/intensity = 0

/datum/status_effect/accelerando/on_creation(mob/living/new_owner, new_duration)
	if(new_duration)
		duration = new_duration
	return ..()

/datum/status_effect/accelerando/on_apply()
	owner.add_movespeed_modifier_type(/datum/movespeed_modifier/accelerando)
	owner.visible_message("<span class='notice'>[owner] porusza się poza lokalną przestrzenią i czasem!</span>", "<span class='warning'>Natura rzeczywistości staje się oczywista, gdy wypadasz z rytmu czasu!</span>")
	return TRUE

/datum/status_effect/accelerando/tick(seconds_between_ticks)
	// Moc to pozostały czas w dziesiątkach sekund (najwyżej 18 przy 3 minutach)
	var/power = (duration - world.time) / (10 SECONDS)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/beached = owner
	if(power > 8)
		if(DT_PROB(10, seconds_between_ticks))
			to_chat(beached, "<span class='warning'>Twoje ciało zrasta się i leczy rany z wczoraj!</span>")
		intensity = max(intensity, 2)
		beached.adjustBruteLoss(-2)
		beached.adjustFireLoss(-2)
		beached.adjustOxyLoss(-1)
		beached.adjustToxLoss(-1)
	if(power > 17)
		set_hair(beached, "fff")
		intensity = 4
	else if(power > 12)
		set_hair(beached, "bbb")
		intensity = max(intensity, 3)

/datum/status_effect/accelerando/proc/set_hair(mob/living/carbon/human/beached, new_color)
	if(beached.hair_color == new_color && beached.facial_hair_color == new_color)
		return
	beached.hair_color = new_color
	beached.facial_hair_color = new_color
	beached.update_hair()

/datum/status_effect/accelerando/on_remove()
	owner.remove_movespeed_modifier_type(/datum/movespeed_modifier/accelerando)
	owner.visible_message("<span class='notice'>[owner] wraca do lokalnego czasu!</span>", "<span class='warning'>Szarpnięcie: twoje ciało nagle wraca do lokalnego czasu!</span>")
	if(intensity >= 2)
		owner.adjust_disgust(75)
		owner.confused += 20
	if(intensity >= 4)
		owner.adjust_disgust(150)
		owner.confused += 20
		owner.Paralyze(1 SECONDS)

/datum/movespeed_modifier/accelerando
	multiplicative_slowdown = -0.55
