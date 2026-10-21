import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { scale, toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  disk_size: number;
  disk_used: number;
  downloadcompletion: number;
  downloading: BooleanLike;
  downloadname: string;
  downloadsize: number;
  error: string;
  emagged: BooleanLike;
  // AQUILA: podpowiedź „Włóż ID” przy programach wymagających dostępu
  id_inserted: BooleanLike;
  categories: string[];
  programs: ProgramData[];
};

type ProgramData = {
  icon: string;
  filename: string;
  filedesc: string;
  fileinfo: string;
  category: string;
  installed: BooleanLike;
  compatible: BooleanLike;
  size: number;
  access: BooleanLike;
  verifiedsource: BooleanLike;
};

// AQUILA: zakładka ze wszystkimi programami naraz
const ALL_CATEGORY = 'All';

// Kategorie przychodzą z DM po angielsku i służą do filtrowania, więc tłumaczymy tylko etykiety.
const CATEGORY_NAMES: Record<string, string> = {
  [ALL_CATEGORY]: 'Wszystkie',
  Crew: 'Załoga',
  Engineering: 'Inżynieria',
  Robotics: 'Robotyka',
  Supply: 'Zaopatrzenie',
  Security: 'Ochrona',
  Science: 'Nauka',
  Medical: 'Medycyna',
  Command: 'Dowództwo',
  Other: 'Inne',
};

export const NtosNetDownloader = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    disk_size,
    disk_used,
    downloadcompletion,
    downloading,
    downloadname,
    downloadsize,
    error,
    emagged,
    categories = [],
    programs = [],
  } = data;
  const all_categories = [ALL_CATEGORY, ...categories];
  const downloadpercentage = toFixed(
    scale(downloadcompletion, 0, downloadsize) * 100,
  );
  const [selectedCategory, setSelectedCategory] = useState(all_categories[0]);
  const [searchItem, setSearchItem] = useState('');
  const search = createSearch<ProgramData>(
    searchItem,
    (program) => program.filedesc,
  );
  let items =
    searchItem.length > 0
      ? // Z zapytaniem szukamy we wszystkim.
        filter(programs, search)
      : selectedCategory === ALL_CATEGORY
        ? programs
        : // Bez zapytania pokazujemy programy z wybranej kategorii.
          filter(programs, (program) => program.category === selectedCategory);
  // Sortowanie po zgodności i nazwie
  items = sortBy(items, [
    (program: ProgramData) => !program.compatible,
    (program: ProgramData) => program.filedesc,
  ]);
  if (!emagged) {
    // Bez emaga widać tylko programy ze zweryfikowanych źródeł
    items = filter(items, (program) => program.verifiedsource === 1);
  }
  const disk_free_space = downloading
    ? disk_size - Number(toFixed(disk_used + downloadcompletion))
    : disk_size - disk_used;

  return (
    <NtosWindow width={600} height={600}>
      <NtosWindow.Content scrollable>
        {!!error && (
          <NoticeBox>
            <Box mb={1}>{error}</Box>
            <Button onClick={() => act('PRG_reseterror')}>Resetuj</Button>
          </NoticeBox>
        )}
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Dysk twardy"
              buttons={
                (!!downloading && (
                  <Button
                    icon="spinner"
                    iconSpin
                    tooltipPosition="left"
                    tooltip={`Pobieranie: ${downloadname}.prg (${downloadpercentage}%)`}
                  />
                )) ||
                (!!downloadname && (
                  <Button
                    color="good"
                    icon="download"
                    tooltipPosition="left"
                    tooltip={`Pobrano ${downloadname}.prg`}
                  />
                ))
              }
            >
              <ProgressBar
                value={downloading ? disk_used + downloadcompletion : disk_used}
                minValue={0}
                maxValue={disk_size}
              >
                <Box textAlign="left">
                  {`Wolne: ${disk_free_space} GQ z ${disk_size} GQ`}
                </Box>
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section>
          <Input
            autoFocus
            height="23px"
            placeholder="Szukaj programu po nazwie..."
            fluid
            value={searchItem}
            onChange={setSearchItem}
          />
        </Section>
        <Stack>
          <Stack.Item minWidth="105px" shrink={0} basis={0}>
            <Tabs vertical>
              {all_categories.map((category) => (
                <Tabs.Tab
                  key={category}
                  selected={category === selectedCategory}
                  onClick={() => setSelectedCategory(category)}
                >
                  {CATEGORY_NAMES[category] || category}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow={1} basis={0}>
            {items?.map((program) => (
              <Program key={program.filename} program={program} />
            ))}
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const Program = (props: { program: ProgramData }) => {
  const { program } = props;
  const { act, data } = useBackend<Data>();
  const {
    disk_size,
    disk_used,
    downloading,
    downloadname,
    downloadcompletion,
    emagged,
    id_inserted,
  } = data;
  const disk_free = disk_size - disk_used;
  return (
    <Section>
      <Stack align="baseline">
        <Stack.Item grow bold>
          <Icon name={program.icon} mr={1} />
          {program.filedesc}
        </Stack.Item>
        <Stack.Item
          shrink={0}
          width="48px"
          textAlign="right"
          color="label"
          nowrap
        >
          {program.size} GQ
        </Stack.Item>
        <Stack.Item shrink={0} width="134px" textAlign="right">
          {(downloading && program.filename === downloadname && (
            <ProgressBar
              width="101px"
              height="23px"
              color="good"
              minValue={0}
              maxValue={program.size}
              value={downloadcompletion}
            />
          )) ||
            (!program.installed &&
              program.compatible &&
              program.access &&
              program.size < disk_free && (
                <Button
                  bold
                  icon="download"
                  disabled={!!downloading}
                  tooltipPosition="left"
                  tooltip={
                    downloading ? 'Czekam na zakończenie pobierania...' : ''
                  }
                  onClick={() =>
                    act('PRG_downloadfile', {
                      filename: program.filename,
                    })
                  }
                >
                  Pobierz
                </Button>
              )) || (
              <Button
                bold
                icon={program.installed ? 'check' : 'times'}
                color={
                  program.installed
                    ? 'good'
                    : !program.compatible
                      ? 'bad'
                      : 'grey'
                }
              >
                {program.installed
                  ? 'Zainstalowany'
                  : !program.compatible
                    ? 'Niezgodny'
                    : !program.access
                      ? id_inserted
                        ? 'Brak dostępu'
                        : 'Włóż ID'
                      : 'Brak miejsca'}
              </Button>
            )}
        </Stack.Item>
      </Stack>
      <Box mt={1} italic color="label">
        {program.fileinfo}
      </Box>
      {!program.verifiedsource && !emagged && (
        <NoticeBox mt={1} mb={0} danger fontSize="12px">
          Niezweryfikowane źródło. Nanotrasen odradza pobieranie i używanie
          oprogramowania z nieoficjalnych serwerów.
        </NoticeBox>
      )}
    </Section>
  );
};
