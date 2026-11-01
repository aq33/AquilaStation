// AQUILA - wspólna część objawów przeniesionych z wirusologii disease2 Monkestation
// (monkestation/code/modules/virology/disease/symtoms/). Objawy siedzą w plikach obok, podzielone jak u Monke:
// helpful.dm, minor.dm (flavor + annoying), hinderance.dm, harmful.dm (harmful + deadly).
//
// Czym różni się nasza wersja od oryginału:
// - Monke ma „badness” 0-5 i mnożnik siły; u nas objaw ma statystyki choroby (ukrycie, odporność, szybkość stadiów,
//   transmisja), poziom 1-9 i progi, które odblokowują mocniejsze działanie. Mnożnik przeszedł na progi.
// - U Monke choroba ma 4 stadia i jeden objaw na stadium; u nas 5 stadiów i do 6 objawów naraz, więc stadium Monke N
//   to u nas zwykle N+1.
// - Losowa szansa na tick przeszła na nasze symptom_delay_min/max.

/datum/symptom
	/// AQUILA - TRUE dla objawów przeniesionych z wirusologii disease2 Monkestation
	var/from_disease2 = FALSE
