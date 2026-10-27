import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

type Data = {
  disease_threshold: string;
  locked: BooleanLike;
  nanite_cloud: number;
  reverse: BooleanLike;
  scan_mode: string;
  target_hygiene: number;
  target_nutrition: number;
  target_species: string;
};

// Wartości idą do DM bez zmian, tłumaczone są tylko etykiety.
const DISEASE_THEASHOLD_LIST = [
  { value: 'Positive', name: 'Korzystna' },
  { value: 'Harmless', name: 'Nieszkodliwa' },
  { value: 'Minor', name: 'Łagodna' },
  { value: 'Medium', name: 'Średnia' },
  { value: 'Harmful', name: 'Szkodliwa' },
  { value: 'Dangerous', name: 'Niebezpieczna' },
  { value: 'BIOHAZARD', name: 'ZAGROŻENIE BIOLOGICZNE' },
];

const TARGET_SPECIES_LIST = [
  { name: 'Człowiek', value: 'human' },
  { name: 'Jaszczuroczłek', value: 'lizard' },
  { name: 'Muchoczłek', value: 'fly' },
  { name: 'Felinid', value: 'felinid' },
  { name: 'Plazmoid', value: 'plasma' },
  { name: 'Ćmoczłek', value: 'moth' },
  { name: 'Galaretoczłek', value: 'jelly' },
  { name: 'Roślinoczłek', value: 'pod' },
  { name: 'Golem', value: 'golem' },
  { name: 'Zombie', value: 'zombie' },
];

// AQUILA: tryb higieny (gałąź higiena)
const TARGET_HYGIENE_LIST = [
  { name: 'czysta', label: 'Czysta', key: 'Clean', value: 250 },
  { name: 'brudna', label: 'Brudna', key: 'Dirty', value: 75 },
];

const TARGET_NUTRITION_LIST = [
  { name: 'Głodująca', key: 'Starving', value: 150 },
  { name: 'Otyła', key: 'Obese', value: 600 },
];

export const ScannerGate = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={400} height={300}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox
          onLockedStatusChange={() => act('toggle_lock')}
        />
        {!data.locked && <ScannerGateControl />}
      </Window.Content>
    </Window>
  );
};

const SCANNER_GATE_ROUTES = {
  Off: {
    title: 'Tryb skanera: wyłączony',
    component: () => ScannerGateOff,
  },
  Wanted: {
    title: 'Tryb skanera: poszukiwani',
    component: () => ScannerGateWanted,
  },
  Guns: {
    title: 'Tryb skanera: broń',
    component: () => ScannerGateGuns,
  },
  Mindshield: {
    title: 'Tryb skanera: implant lojalności',
    component: () => ScannerGateMindshield,
  },
  Disease: {
    title: 'Tryb skanera: choroby',
    component: () => ScannerGateDisease,
  },
  Species: {
    title: 'Tryb skanera: rasa',
    component: () => ScannerGateSpecies,
  },
  Nutrition: {
    title: 'Tryb skanera: odżywienie',
    component: () => ScannerGateNutrition,
  },
  Hygiene: {
    title: 'Tryb skanera: higiena',
    component: () => ScannerGateHygiene,
  },
  Contraband: {
    title: 'Tryb skanera: kontrabanda',
    component: () => ScannerGateContraband,
  },
  Nanites: {
    title: 'Tryb skanera: nanity',
    component: () => ScannerGateNanites,
  },
};

const ScannerGateControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { scan_mode } = data;
  const route = SCANNER_GATE_ROUTES[scan_mode] || SCANNER_GATE_ROUTES.Off;
  const Component = route.component();
  return (
    <Section
      title={route.title}
      buttons={
        scan_mode !== 'Off' && (
          <Button
            icon="arrow-left"
            onClick={() => act('set_mode', { new_mode: 'Off' })}
          >
            Wróć
          </Button>
        )
      }
    >
      <Component />
    </Section>
  );
};

const SCAN_MODES = [
  { mode: 'Wanted', name: 'Poszukiwani' },
  { mode: 'Guns', name: 'Broń' },
  { mode: 'Contraband', name: 'Kontrabanda' },
  { mode: 'Mindshield', name: 'Implant lojalności' },
  { mode: 'Disease', name: 'Choroby' },
  { mode: 'Species', name: 'Rasa' },
  { mode: 'Nutrition', name: 'Odżywienie' },
  { mode: 'Hygiene', name: 'Higiena' },
  { mode: 'Nanites', name: 'Nanity' },
];

const ScannerGateOff = (props) => {
  const { act } = useBackend<Data>();
  return (
    <>
      <Box mb={2}>Wybierz tryb skanowania.</Box>
      <Box>
        {SCAN_MODES.map((entry) => (
          <Button
            key={entry.mode}
            onClick={() => act('set_mode', { new_mode: entry.mode })}
          >
            {entry.name}
          </Button>
        ))}
      </Box>
    </>
  );
};

const ScannerGateWanted = (props) => {
  const { data } = useBackend<Data>();
  const { reverse } = data;
  return (
    <>
      <Box mb={2}>
        Alarm, jeśli skanowana osoba {reverse ? 'nie jest' : 'jest'} poszukiwana
        nakazem aresztowania.
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateGuns = (props) => {
  const { data } = useBackend<Data>();
  const { reverse } = data;
  return (
    <>
      <Box mb={2}>
        Alarm, jeśli skanowana osoba{' '}
        {reverse ? 'nie ma przy sobie broni' : 'ma przy sobie broń'}.
      </Box>
      <ScannerGateMode />
    </>
  );
};

// AQUILA: tryb kontrabandy (N-spect z tg)
const ScannerGateContraband = (props) => {
  const { data } = useBackend<Data>();
  const { reverse } = data;
  return (
    <>
      <Box mb={2}>
        Alarm, jeśli skanowana osoba{' '}
        {reverse ? 'nie ma przy sobie kontrabandy' : 'ma przy sobie kontrabandę'}
        .
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateMindshield = (props) => {
  const { data } = useBackend<Data>();
  const { reverse } = data;
  return (
    <>
      <Box mb={2}>
        Alarm, jeśli skanowana osoba {reverse ? 'nie ma' : 'ma'} implant
        {reverse ? 'u' : ''} lojalności.
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateDisease = (props) => {
  const { act, data } = useBackend<Data>();
  const { reverse, disease_threshold } = data;
  const threshold = DISEASE_THEASHOLD_LIST.find(
    (entry) => entry.value === disease_threshold,
  );
  return (
    <>
      <Box mb={2}>
        Alarm, jeśli skanowana osoba {reverse ? 'nie ma' : 'ma'} choroby co
        najmniej na poziomie: {threshold?.name ?? disease_threshold}.
      </Box>
      <Box mb={2}>
        {DISEASE_THEASHOLD_LIST.map((entry) => (
          <Button.Checkbox
            key={entry.value}
            checked={entry.value === disease_threshold}
            onClick={() =>
              act('set_disease_threshold', {
                new_threshold: entry.value,
              })
            }
          >
            {entry.name}
          </Button.Checkbox>
        ))}
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateSpecies = (props) => {
  const { act, data } = useBackend<Data>();
  const { reverse, target_species } = data;
  const species = TARGET_SPECIES_LIST.find((species) => {
    return species.value === target_species;
  });
  return (
    <>
      <Box mb={2}>
        Alarm, jeśli rasa skanowanej osoby {reverse ? 'to nie' : 'to'}:{' '}
        {species?.name}.
        {target_species === 'zombie' &&
          ' Wykrywa wszystkie rodzaje zombie, także uśpione.'}
      </Box>
      <Box mb={2}>
        {TARGET_SPECIES_LIST.map((species) => (
          <Button.Checkbox
            key={species.value}
            checked={species.value === target_species}
            onClick={() =>
              act('set_target_species', {
                new_species: species.value,
              })
            }
          >
            {species.name}
          </Button.Checkbox>
        ))}
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateNutrition = (props) => {
  const { act, data } = useBackend<Data>();
  const { reverse, target_nutrition } = data;
  const nutrition = TARGET_NUTRITION_LIST.find((nutrition) => {
    return nutrition.value === target_nutrition;
  });
  return (
    <>
      <Box mb={2}>
        Alarm, jeśli skanowana osoba {reverse ? 'nie jest' : 'jest'}:{' '}
        {nutrition?.name.toLowerCase()}.
      </Box>
      <Box mb={2}>
        {TARGET_NUTRITION_LIST.map((nutrition) => (
          <Button.Checkbox
            key={nutrition.key}
            checked={nutrition.value === target_nutrition}
            onClick={() =>
              act('set_target_nutrition', {
                new_nutrition: nutrition.key,
              })
            }
          >
            {nutrition.name}
          </Button.Checkbox>
        ))}
      </Box>
      <ScannerGateMode />
    </>
  );
};

// AQUILA: tryb higieny (gałąź higiena)
const ScannerGateHygiene = (props) => {
  const { act, data } = useBackend<Data>();
  const { reverse, target_hygiene } = data;
  const hygiene = TARGET_HYGIENE_LIST.find((hygiene) => {
    return hygiene.value === target_hygiene;
  });
  return (
    <>
      <Box mb={2}>
        Alarm, jeśli skanowana osoba {reverse ? 'nie jest' : 'jest'}{' '}
        {hygiene?.name}.
      </Box>
      <Box mb={2}>
        {TARGET_HYGIENE_LIST.map((hygiene) => (
          <Button.Checkbox
            key={hygiene.key}
            checked={hygiene.value === target_hygiene}
            onClick={() =>
              act('set_target_hygiene', {
                new_hygiene: hygiene.key,
              })
            }
          >
            {hygiene.label}
          </Button.Checkbox>
        ))}
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateNanites = (props) => {
  const { act, data } = useBackend<Data>();
  const { reverse, nanite_cloud } = data;
  return (
    <>
      <Box mb={2}>
        Alarm, jeśli skanowana osoba {reverse ? 'nie ma' : 'ma'} nanit
        {reverse ? 'ów' : 'y'} z chmury {nanite_cloud}.
      </Box>
      <Box mb={2}>
        <LabeledList>
          <LabeledList.Item label="ID chmury">
            <NumberInput
              step={1}
              value={nanite_cloud}
              width="65px"
              minValue={1}
              maxValue={100}
              stepPixelSize={2}
              onChange={(value) =>
                act('set_nanite_cloud', {
                  new_cloud: value,
                })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Box>
      <ScannerGateMode />
    </>
  );
};

const ScannerGateMode = (props) => {
  const { act, data } = useBackend<Data>();
  const { reverse } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="Działanie">
        <Button
          icon={reverse ? 'random' : 'long-arrow-alt-right'}
          onClick={() => act('toggle_reverse')}
          color={reverse ? 'bad' : 'good'}
        >
          {reverse ? 'Odwrócone' : 'Domyślne'}
        </Button>
      </LabeledList.Item>
    </LabeledList>
  );
};
