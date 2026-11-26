// AQUILA - Ceny gazów w eksporcie cargo (kredyty za mol w kanistrze).
// /datum/export/large/gas_canister/get_cost() czyta GLOB.gas_data.prices (hook AQ EDIT w code/modules/cargo/exports/large_objects.dm),
// więc nowy gaz ustawia cenę w swoim datumie. Tu są stawki, które eksport miał wpisane na sztywno, żeby nic nie zmieniło ceny.
// Ceny z datumów w core (tryt 7, pluoksium 6, nitryl 3, hipernoblium 50, BZ 3, stymulum 25) nikt wcześniej nie czytał.

/datum/gas/bz
	price = 4

/datum/gas/stimulum
	price = 100

/datum/gas/hypernoblium
	price = 1000

/datum/gas/tritium
	price = 5

/datum/gas/pluoxium
	price = 5

/datum/gas/nitryl
	price = 0

/datum/gas/constricted_plasma
	price = 2

/datum/gas/nucleium
	price = 50
