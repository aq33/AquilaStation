#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar
# AQ EDIT START - listy plików z gita (śledzone i nowe, bez ignorowanych) zamiast rozwijania **:
# w Git Bash na Windows każde rozwinięcie code/**/*.dm trwa ponad minutę (tools/local_ci). Bez gita zostaje globstar.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	repo_files() {
		local pattern
		for pattern in "$@"; do
			# quotePath=false: bez tego ścieżki z polskimi literami przychodzą jako "\303\263..." i [ -f ] je odrzuca
			git -c core.quotePath=false ls-files -co --exclude-standard -- ":(glob)$pattern"
		done | sort -u | while IFS= read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done
	}
else
	repo_files() {
		local pattern f
		for pattern in "$@"; do
			for f in $pattern; do [ -f "$f" ] && printf '%s\n' "$f"; done
		done
	}
fi
# mapy Aquili (aquila/_maps) przechodzą przez te same lintery
mapfile -t MAPS < <(repo_files '_maps/**/*.dmm' 'aquila/_maps/**/*.dmm')
mapfile -t CODE_DM < <(repo_files 'code/**/*.dm')
mapfile -t ALL_DM < <(repo_files 'code/**/*.dm' 'nsv13/**/*.dm' 'aquila/**/*.dm')
mapfile -t MAPS_DM < <(repo_files '_maps/**/*.dm')
# AQ EDIT END

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

st=0

echo -e "${BLUE}Checking for map issues...${NC}"

if grep -El '^\".+\" = \(.+\)' "${MAPS[@]}";    then
    echo
    echo -e "${RED}ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!${NC}"
    st=1
fi;
if grep -P '^\ttag = \"icon' "${MAPS[@]}";    then
    echo
    echo -e "${RED}ERROR: Tag vars from icon state generation detected in maps, please remove them.${NC}"
    st=1
fi;
if grep -P 'step_[xy]' "${MAPS[@]}";    then
    echo
    echo -e "${RED}ERROR: step_x/step_y variables detected in maps, please remove them.${NC}"
    st=1
fi;
if grep -m 1 'pixel_[xy] = 0' "${MAPS[@]}";    then
    echo
    echo -e "${RED}ERROR: pixel_x/pixel_y = 0 variables detected in maps, please review to ensure they are not dirty varedits.${NC}"
    st=1
fi;
if grep -P '\td[1-2] =' "${MAPS[@]}";    then
    echo
    echo -e "${RED}ERROR: d1/d2 cable variables detected in maps, please remove them.${NC}"
    st=1
fi;
# AQ EDIT START - Smartwires: cables join by colour, so var-edits and two cables of one colour on a tile break powernets
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/cable[/\w]*?\{' "${MAPS[@]}";	then
	echo
	echo -e "${RED}ERROR: Var-edited cables detected in maps, use the colour subtypes instead (tools/smartwires/convert.py converts old maps).${NC}"
	st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/cable(?<type>[/\w]*),\n[^)]*?/obj/structure/cable\g{type},\n[^)]*?/area/.+\)' "${MAPS[@]}";	then
	echo
	echo -e "${RED}ERROR: Found multiple cables of the same colour on the same tile, please remove them.${NC}"
	st=1
fi;
# AQ EDIT END
echo -e "${BLUE}Checking for stacked cables...${NC}"
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/area/.+?\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found multiple lattices on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/barricade(?<type>[/\w]*),\n[^)]*?/obj/structure/barricade\g{type},\n[^)]*?/area/.+\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found multiple identical barricades on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/table(?<type>[/\w]*),\n[^)]*?/obj/structure/table\g{type},\n[^)]*?/area/.+\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found multiple identical tables on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/chair(?<type>[/\w]*),\n[^)]*?/obj/structure/chair\g{type},\n[^)]*?/area/.+\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found multiple identical chairs on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/area/.+\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found multiple airlocks on the same tile, please remove them.${NC}"
    st=1
fi;
# NSV13 - only look for windowlocks, we need double firelocks for fastmos
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/door/firedoor/window[/\w]*?,\n[^)]*?/obj/machinery/door/firedoor/window[/\w]*?,\n[^)]*?/area/.+\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found multiple firelocks on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/closet(?<type>[/\w]*),\n[^)]*?/obj/structure/closet\g{type},\n[^)]*?/area/.+\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found multiple identical closets on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/grille(?<type>[/\w]*),\n[^)]*?/obj/structure/grille\g{type},\n[^)]*?/area/.+\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found multiple identical grilles on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/girder(?<type>[/\w]*),\n[^)]*?/obj/structure/girder\g{type},\n[^)]*?/area/.+\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found multiple identical girders on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/stairs(?<type>[/\w]*),\n[^)]*?/obj/structure/stairs\g{type},\n[^)]*?/area/.+\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found multiple identical stairs on the same tile, please remove them.${NC}"
	st=1
fi;
if grep '^/area/.+[\{]' "${MAPS[@]}";    then
    echo
    echo -e "${RED}ERROR: Variable editted /area path use detected in a map, please replace with a proper area path.${NC}"
    st=1
fi;
if grep -P '\W\/turf\s*[,\){]' "${MAPS[@]}"; then
    echo
    echo -e "${RED}ERROR: Base /turf path use detected in maps, please replace a with proper turf path.${NC}"
    st=1
fi;
if grep -n -P '^/*var/' "${CODE_DM[@]}" /dev/null; then
    echo
    echo -e "${RED}ERROR: Unmanaged global var use detected in code, please use the helpers.${NC}"
    st=1
fi;
if grep -n -i 'centcomm' "${CODE_DM[@]}" /dev/null; then
    echo
    echo -e "${RED}ERROR: Misspelling(s) of CentCom detected in code, please remove the extra M(s).${NC}"
    st=1
fi;
if grep -n -i 'centcomm' "${MAPS_DM[@]}" /dev/null; then
    echo
    echo -e "${RED}ERROR: Misspelling(s) of CentCom detected in maps, please remove the extra M(s).${NC}"
    st=1
fi;
if grep -n -P 'set name\s*=\s*"[\S\s]*![\S\s]*"' "${CODE_DM[@]}" /dev/null; then
    echo
    echo -e "${RED}ERROR: Verb with name containing an exclamation point found. These verbs are not compatible with TGUI chat's statpanel or chat box.${NC}"
    st=1
fi;
if grep -n -P '(?i)(href|action)\s*=[\s='"'"'"\\\\]*\?' "${ALL_DM[@]}" /dev/null; then
    echo
    echo -e "${RED}ERROR: BYOND 516 requires internal href links to begin with \"byond://\".${NC}"
    st=1
fi;
if grep -n -P '^\s*var/([\w/]*/)?caller\b' "${ALL_DM[@]}" /dev/null; then
    echo
    echo -e "${RED}ERROR: 'caller' is a BYOND 516 built-in: a var with that name reads as the calling proc inside procs. Rename it.${NC}"
    st=1
fi;
if grep -n -P '^\s*TEST_FOCUS\(' "${ALL_DM[@]}" /dev/null; then
    echo
    echo -e "${RED}ERROR: TEST_FOCUS left in code: CI would run only the focused unit tests. Remove it before pushing.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/turf/[/\w]*?,\n[^)]*?/turf/[/\w]*?,\n[^)]*?/area/.+?\)' "${MAPS[@]}"; then
	echo
    echo -e "${RED}ERROR: Multiple turfs detected on the same tile! Please choose only one turf!${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/area/.+?,\n[^)]*?/area/.+?\)' "${MAPS[@]}"; then
	echo
    echo -e "${RED}ERROR: Multiple areas detected on the same tile! Please choose only one area!${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/turf/closed/wall[/\w]*?,\n[^)]*?/area/.+?\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found a lattice stacked with a wall, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found a lattice stacked within a wall, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/window[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found a window stacked within a wall, please remove it.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found an airlock stacked within a wall, please remove it.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/stairs[/\w]*?,\n[^)]*?/turf/open/genturf[/\w]*?,\n[^)]*?/area/.+?\)' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found a staircase on top of a gen_turf. Please replace the gen_turf with a proper turf.${NC}"
    st=1
fi;
if grep -Pzo '/obj/machinery/conveyor/inverted[/\w]*?\{\n[^}]*?dir = [1248];[^}]*?\},?\n' "${MAPS[@]}";	then
	echo
    echo -e "${RED}ERROR: Found an inverted conveyor belt with a cardinal dir. Please replace it with a normal conveyor belt.${NC}"
    st=1
fi;
if ls _maps/*.json | grep -P "[A-Z]"; then
    echo
    echo -e "${RED}ERROR: Uppercase in a map .JSON file detected, these must be all lowercase.${NC}"
    st=1
fi;
for json in _maps/*.json
do
    # AQ EDIT - tr: jq na Windows kończy linie CRLF, a \r w nazwie pliku daje fałszywe „invalid file reference”
    filepath="_maps/$(jq -r '.map_path' $json | tr -d '\r')"
    filenames=$(jq -r '.map_file' $json | tr -d '\r')
    if [[ "$filenames" =~ ^\[ ]] # If it starts with brackets it's a list
    then
        echo "$filenames" | jq -c '.[]' | tr -d '\r' | while read filename
        do
            #Remove quotes
            filename="${filename%\"}"
            filename="${filename#\"}"

            if [ ! -f "$filepath/$filename" ]
            then
                echo -e "${RED}WARNING: Found potential invalid file reference to $filepath/$filename in _maps/$json${NC}"
                st=1
            fi
        done
    else # It's not a list, it's just one file name
        if [ ! -f "$filepath/$filenames" ]
        then
            echo -e "${RED}WARNING: Found potential invalid file reference to $filepath/$filenames in _maps/$json${NC}"
            st=1
        fi
    fi
done

# Check for old .proc/ syntax (use the proc reference helpers)
if grep -n -P --exclude='__byond_version_compat.dm' '\.proc/' "${CODE_DM[@]}" /dev/null; then
    echo
    echo -e "${RED}ERROR: Outdated proc reference use detected in code, please use proc reference helpers.${NC}"
    st=1
fi;

echo -e "${BLUE}Checking for missing newlines...${NC}"
nl='
'
nl=$'\n'
# AQ EDIT START - pliki z gita i jeden grep/gawk na wszystkie zamiast trzech procesów na plik
# (na Windows ~55 tys. procesów, prawie godzina) i bez ignorowanych plików (cache, node_modules)
text_files() {
	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		repo_files '**' | tr '\n' '\0' | xargs -0 -r grep -Il . --
	else
		find . -type f -not \( -path "./.git/*" -prune \) -exec grep -Iq . {} \; -print
	fi
}
if command -v gawk >/dev/null 2>&1; then
	while IFS= read -r f; do
		echo -e "${RED}ERROR: file $f is missing a trailing newline${NC}"
		st=1
	done < <(text_files | tr '\n' '\0' | xargs -0 -r gawk 'ENDFILE { if (FNR > 0 && RT == "") print FILENAME }')
else
while read f; do
    t=$(tail -c2 "$f"; printf x); r1="${nl}$"; r2="${nl}${r1}"
    if [[ ! ${t%x} =~ $r1 ]]; then
        echo -e "${RED}ERROR: file $f is missing a trailing newline${NC}"
        st=1
    fi;
done < <(text_files)
fi
# AQ EDIT END

if [ $st = 0 ]; then
    echo
    echo -e "${GREEN}No errors found using grep!${NC}"
fi;

if [ $st = 1 ]; then
    echo
    echo -e "${RED}Errors found, please fix them and try again.${NC}"
fi;

exit $st
