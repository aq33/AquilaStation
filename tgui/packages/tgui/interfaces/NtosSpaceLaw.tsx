// AQUILA - program PDA „Prawo kosmiczne”: kodeks z wyszukiwarką, kalkulatorem wyroku i podpowiedzią kary
import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import {
  calculateSentence,
  type Facilities,
  formatSentence,
  type Punishment,
  suggestPunishment,
} from './common/Sentence';

type Crime = {
  name: string;
  tooltip: string;
  colour: string;
  icon: string;
  sentence: number;
};

type Category = {
  name: string;
  crimes: Crime[];
};

type Data = {
  categories: Category[];
  facilities: Facilities;
  max_fine: number;
};

export const NtosSpaceLaw = (props) => {
  const { data } = useBackend<Data>();
  const categories = data.categories || [];
  const [query, setQuery] = useState('');
  const [charges, setCharges] = useState<string[]>([]);
  const [attempted, setAttempted] = useState(false);
  const [elevated, setElevated] = useState(false);
  const [resisted, setResisted] = useState(false);

  const allCrimes = categories.flatMap((category) => category.crimes);
  const sentenceOf = (name: string) =>
    allCrimes.find((crime) => crime.name === name)?.sentence || 0;
  const baseTime = charges.reduce((sum, name) => sum + sentenceOf(name), 0);
  const total = calculateSentence(baseTime, { attempted, elevated, resisted });
  const punishments = suggestPunishment({
    charges: charges.map(sentenceOf),
    total,
    elevated,
    resisted,
    facilities: data.facilities || {
      genpop: false,
      gulag: false,
      exile: false,
    },
    maxFine: data.max_fine || 0,
  });

  const toggleCharge = (name: string) =>
    setCharges(
      charges.includes(name)
        ? charges.filter((charge) => charge !== name)
        : [...charges, name],
    );

  const needle = query.trim().toLowerCase();
  const matches = (crime: Crime) =>
    !needle ||
    crime.name.toLowerCase().includes(needle) ||
    (crime.tooltip || '').toLowerCase().includes(needle);
  const anyMatch = allCrimes.some(matches);

  return (
    <NtosWindow width={520} height={640}>
      <NtosWindow.Content scrollable>
        <Section
          title="Kalkulator wyroku"
          buttons={
            charges.length > 0 && (
              <Button icon="times" onClick={() => setCharges([])}>
                Wyczyść
              </Button>
            )
          }
        >
          {charges.length === 0 ? (
            <Box color="label">
              Kliknij artykuł poniżej, żeby dodać zarzut. Czasy się sumują,
              zbrodnia od razu daje dożywocie.
            </Box>
          ) : (
            <>
              <Box mb={1}>
                {charges.map((name) => (
                  <Button
                    key={name}
                    compact
                    icon="times"
                    onClick={() => toggleCharge(name)}
                  >
                    {name}
                  </Button>
                ))}
              </Box>
              <Box>
                <Button.Checkbox
                  checked={attempted}
                  tooltip="-5 min; dożywocie spada do 15 min"
                  onClick={() => setAttempted(!attempted)}
                >
                  Usiłowanie
                </Button.Checkbox>
                <Button.Checkbox
                  checked={elevated}
                  tooltip="+5 min; od 15 min w górę dożywocie"
                  onClick={() => setElevated(!elevated)}
                >
                  Recydywa
                </Button.Checkbox>
                <Button.Checkbox
                  checked={resisted}
                  tooltip="+20% na końcu"
                  onClick={() => setResisted(!resisted)}
                >
                  Opór przy zatrzymaniu
                </Button.Checkbox>
              </Box>
              <Box mt={1} fontSize={1.2}>
                Wyrok: <b>{formatSentence(total)}</b>
              </Box>
              <Box mt={1} bold>
                Sugerowana kara
              </Box>
              {punishments.map((punishment) => (
                <PunishmentRow key={punishment.kind} punishment={punishment} />
              ))}
            </>
          )}
        </Section>
        <Section>
          <Input
            fluid
            autoFocus
            placeholder="Szukaj artykułu…"
            value={query}
            onChange={(value) => setQuery(value)}
          />
        </Section>
        {!anyMatch && <NoticeBox>Nie ma takiego artykułu.</NoticeBox>}
        {categories.map((category) => {
          const crimes = category.crimes.filter(matches);
          if (crimes.length === 0) {
            return null;
          }
          return (
            <Section key={category.name} title={category.name}>
              {crimes.map((crime) => (
                <CrimeRow
                  key={crime.name}
                  crime={crime}
                  charged={charges.includes(crime.name)}
                  onToggle={() => toggleCharge(crime.name)}
                />
              ))}
            </Section>
          );
        })}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

type CrimeRowProps = {
  crime: Crime;
  charged: boolean;
  onToggle: () => void;
};

const CrimeRow = (props: CrimeRowProps) => {
  const { crime, charged, onToggle } = props;
  return (
    <Stack mb={1} align="center">
      <Stack.Item width="1.5em" textAlign="center">
        <Icon name={crime.icon || 'gavel'} color={crime.colour} />
      </Stack.Item>
      <Stack.Item grow>
        <Box bold color={crime.colour}>
          {crime.name}
          <Box inline color="label" ml={1} style={{ fontWeight: 'normal' }}>
            {formatSentence(crime.sentence)}
          </Box>
        </Box>
        <Box color="label">{crime.tooltip}</Box>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon={charged ? 'check' : 'plus'}
          selected={charged}
          tooltip={charged ? 'Usuń zarzut' : 'Dodaj zarzut'}
          onClick={onToggle}
        />
      </Stack.Item>
    </Stack>
  );
};

type PunishmentRowProps = {
  punishment: Punishment;
};

/** Jedna forma kary z podpowiedzi (suggestPunishment w common/Sentence.ts) */
const PunishmentRow = (props: PunishmentRowProps) => {
  const { punishment } = props;
  switch (punishment.kind) {
    case 'fine':
      return (
        <Box>
          <Icon name="receipt" mr={1} />
          Mandat: <b>{punishment.amount} kr</b> (albo areszt na{' '}
          {formatSentence(punishment.time)})
        </Box>
      );
    case 'brig':
      return (
        <Box>
          <Icon name="clock" mr={1} />
          Areszt w celi z zegarem: <b>{formatSentence(punishment.time)}</b>
        </Box>
      );
    case 'genpop':
      return (
        <Box>
          <Icon name="id-card" mr={1} />
          GenPop: identyfikator więźnia na{' '}
          <b>{formatSentence(punishment.time)}</b>
        </Box>
      );
    case 'gulag':
      return (
        <Box>
          <Icon name="hammer" mr={1} />
          Gułag: <b>{punishment.points} pkt</b> do wykopania
        </Box>
      );
    case 'permanent_cell':
      return (
        <Box>
          <Icon name="lock" mr={1} />
          Stała cela. Dożywocie zatwierdza Komendant albo Kapitan.
        </Box>
      );
    case 'gulag_permanent':
      return (
        <Box>
          <Icon name="hammer" mr={1} />
          Gułag bez zwolnienia (w konsoli gułagu „Dożywocie”)
        </Box>
      );
    case 'exile':
      return (
        <Box>
          <Icon name="vr-cardboard" mr={1} />
          Cyfrowe wygnanie: implant wygnania i netpod, więzień na zawsze zostaje
          w Pętli
        </Box>
      );
    default:
      return null;
  }
};
