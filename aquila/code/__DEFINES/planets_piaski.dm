// AQUILA - atmosfery planet skalistych, białych piasków, pustynnych i mglistych (aquila/code/modules/planets/).
// Stałe mieszanki jak przy planecie wulkanicznej (Shiptest losuje je z /datum/atmosphere w podanych granicach;
// tu jedna wartość ze środka zakresu, bez gazów, których nie mamy: CO, SO2, Ar, O3).

/// Planeta skalista: dwutlenek węgla z azotem, ok. 90 kPa, 263 K, nie do oddychania
#define PLANET_ROCK_ATMOS "co2=86;n2=17;TEMP=263"
/// Białe piaski: rzadka i zimna, ok. 40 kPa, 248 K
#define PLANET_SAND_ATMOS "o2=16;n2=21;co2=11;TEMP=248"
/// Pustynia: oddychalna i gorąca, 313 K
#define PLANET_DESERT_ATMOS "o2=20;n2=80;TEMP=313.15"
/// Planeta mglista: oddychalna i chłodna, ok. 92 kPa, 273 K
#define PLANET_SHROUDED_ATMOS "o2=24;n2=74;co2=3;TEMP=273"
