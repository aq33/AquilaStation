/// Nagrania ogłoszeń eventów głosem domyślnego announcera (polski dubbing), klucz ANNOUNCER_EVENT(nazwa).
/// Teksty i generator: tools/tts/event_announcements.tsv, tools/tts/make_event_announcements.py
GLOBAL_LIST_INIT(aquila_event_announcement_sounds, list(
	"radiation_storm_end" = 'aquila/sound/ai/events/radiation_storm_end.ogg',
	"bluespace_translocation" = 'aquila/sound/ai/events/bluespace_translocation.ogg',
	"anomaly_energy" = 'aquila/sound/ai/events/anomaly_energy.ogg',
	"anomaly_bluespace" = 'aquila/sound/ai/events/anomaly_bluespace.ogg',
	"anomaly_delimber" = 'aquila/sound/ai/events/anomaly_delimber.ogg',
	"anomaly_flux" = 'aquila/sound/ai/events/anomaly_flux.ogg',
	"anomaly_grav" = 'aquila/sound/ai/events/anomaly_grav.ogg',
	"anomaly_hallucination" = 'aquila/sound/ai/events/anomaly_hallucination.ogg',
	"anomaly_pyro" = 'aquila/sound/ai/events/anomaly_pyro.ogg',
	"anomaly_vortex" = 'aquila/sound/ai/events/anomaly_vortex.ogg',
	"asteroid_impact" = 'aquila/sound/ai/events/asteroid_impact.ogg',
	"beer_clog" = 'aquila/sound/ai/events/beer_clog.ogg',
	"brand_intelligence" = 'aquila/sound/ai/events/brand_intelligence.ogg',
	"bureaucratic_error" = 'aquila/sound/ai/events/bureaucratic_error.ogg',
	"carp_migration" = 'aquila/sound/ai/events/carp_migration.ogg',
	"communications_blackout" = 'aquila/sound/ai/events/communications_blackout.ogg',
	"dolphin_migration" = 'aquila/sound/ai/events/dolphin_migration.ogg',
	"electrical_storm" = 'aquila/sound/ai/events/electrical_storm.ogg',
	"unknown_vessel" = 'aquila/sound/ai/events/unknown_vessel.ogg',
	"high_priority_bounty" = 'aquila/sound/ai/events/high_priority_bounty.ogg',
	"immovable_rod" = 'aquila/sound/ai/events/immovable_rod.ogg',
	"major_dust" = 'aquila/sound/ai/events/major_dust.ogg',
	"meateor_wave" = 'aquila/sound/ai/events/meateor_wave.ogg',
	"pirates_armed_vessel" = 'aquila/sound/ai/events/pirates_armed_vessel.ogg',
	"pirates_data_theft" = 'aquila/sound/ai/events/pirates_data_theft.ogg',
	"plasma_decon" = 'aquila/sound/ai/events/plasma_decon.ogg',
	"portal_storm" = 'aquila/sound/ai/events/portal_storm.ogg',
	"prison_break" = 'aquila/sound/ai/events/prison_break.ogg',
	"processor_overload" = 'aquila/sound/ai/events/processor_overload.ogg',
	"sentience" = 'aquila/sound/ai/events/sentience.ogg',
	"shuttle_loan_syndicate" = 'aquila/sound/ai/events/shuttle_loan_syndicate.ogg',
	"shuttle_loan_russian" = 'aquila/sound/ai/events/shuttle_loan_russian.ogg',
	"shuttle_loan_spider" = 'aquila/sound/ai/events/shuttle_loan_spider.ogg',
	"shuttle_loan_supply" = 'aquila/sound/ai/events/shuttle_loan_supply.ogg',
	"shuttle_loan_virus" = 'aquila/sound/ai/events/shuttle_loan_virus.ogg',
	"shuttle_loan_pizza" = 'aquila/sound/ai/events/shuttle_loan_pizza.ogg',
	"shuttle_loan_bees" = 'aquila/sound/ai/events/shuttle_loan_bees.ogg',
	"shuttle_loan_bomb" = 'aquila/sound/ai/events/shuttle_loan_bomb.ogg',
	"space_dragon" = 'aquila/sound/ai/events/space_dragon.ogg',
	"supermatter_surge" = 'aquila/sound/ai/events/supermatter_surge.ogg',
	"magicarp" = 'aquila/sound/ai/events/magicarp.ogg',
	"radioactive_sludge" = 'aquila/sound/ai/events/radioactive_sludge.ogg',
	"shitstorm_end" = 'aquila/sound/ai/events/shitstorm_end.ogg',
	"crystal_portals" = 'aquila/sound/ai/events/crystal_portals.ogg',
	"crystal_destabilized" = 'aquila/sound/ai/events/crystal_destabilized.ogg',
	"crystal_wave" = 'aquila/sound/ai/events/crystal_wave.ogg',
	"crystal_surge" = 'aquila/sound/ai/events/crystal_surge.ogg',
	"crystal_critical" = 'aquila/sound/ai/events/crystal_critical.ogg',
	"crystal_failed" = 'aquila/sound/ai/events/crystal_failed.ogg',
	"crystal_restored" = 'aquila/sound/ai/events/crystal_restored.ogg',
	"crystal_sacrifice" = 'aquila/sound/ai/events/crystal_sacrifice.ogg',
	"department_strike" = 'aquila/sound/ai/events/department_strike.ogg',
	"market_crash" = 'aquila/sound/ai/events/market_crash.ogg',
	"market_stable" = 'aquila/sound/ai/events/market_stable.ogg',
	"portal_storm_kurwinox" = 'aquila/sound/ai/events/portal_storm_kurwinox.ogg',
	"prisoner_transfer" = 'aquila/sound/ai/events/prisoner_transfer.ogg',
	"stray_cargo" = 'aquila/sound/ai/events/stray_cargo.ogg',
	"wallrot" = 'aquila/sound/ai/events/wallrot.ogg',
	"liquid_backpressure" = 'aquila/sound/ai/events/liquid_backpressure.ogg',
	"liquid_anomaly" = 'aquila/sound/ai/events/liquid_anomaly.ogg',
	"gremlins" = 'aquila/sound/ai/events/gremlins.ogg',
	"aurora_start" = 'aquila/sound/ai/events/aurora_start.ogg',
	"aurora_end" = 'aquila/sound/ai/events/aurora_end.ogg',
	"ship_partition" = 'aquila/sound/ai/events/ship_partition.ogg',
	"wizard_teleports" = 'aquila/sound/ai/events/wizard_teleports.ogg',
	"ancient_god" = 'aquila/sound/ai/events/ancient_god.ogg',
	"carp_rift" = 'aquila/sound/ai/events/carp_rift.ogg',
	"alien_artifact" = 'aquila/sound/ai/events/alien_artifact.ogg',
	"magnetic_field" = 'aquila/sound/ai/events/magnetic_field.ogg',
	"shitstorm" = 'aquila/sound/ai/events/shitstorm.ogg',
	"bingle_wave" = 'aquila/sound/ai/events/bingle_wave.ogg',
	"easter_bunnies" = 'aquila/sound/ai/events/easter_bunnies.ogg',
	"power_capacitors" = 'aquila/sound/ai/events/power_capacitors.ogg'
))

/datum/centcom_announcer/default/New()
	. = ..()
	for(var/name in GLOB.aquila_event_announcement_sounds)
		event_sounds[ANNOUNCER_EVENT(name)] = GLOB.aquila_event_announcement_sounds[name]

/// Klucz ANNOUNCER_EVENT, którego bieżący announcer nie ma (intern, medbot), zamienia na jego zwykły alert
/proc/aquila_event_announcement_sound(sound)
	if(istext(sound) && findtext(sound, "announcer_event_") == 1 && !SSstation.announcer.event_sounds[sound])
		if(istype(SSstation.announcer, /datum/centcom_announcer/default))
			stack_trace("Brak nagrania ogłoszenia [sound] w GLOB.aquila_event_announcement_sounds (literówka w ANNOUNCER_EVENT albo brak wiersza w tools/tts/event_announcements.tsv)")
		return SSstation.announcer.get_rand_alert_sound()
	return sound

/// Okno raportu dowództwa: nagrania eventów nie trafiają na listę dźwięków admina
/datum/command_report_menu/ui_static_data(mob/user)
	. = ..()
	var/list/sounds = .["announcer_sounds"]
	for(var/sound_key in sounds.Copy())
		if(findtext(sound_key, "announcer_event_") == 1)
			sounds -= sound_key
