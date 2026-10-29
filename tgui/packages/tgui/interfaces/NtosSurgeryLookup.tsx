// AQUILA - program PDA „Operacje”: spis operacji z narzędziami i wymaganiami (nowy szkielet chirurgii z tg)
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { extractRequirementMap } from './OperatingComputer/helpers';
import type { CatalogOperation } from './OperatingComputer/types';

type Data = {
  surgeries: CatalogOperation[];
};

export const NtosSurgeryLookup = (props) => {
  const { data } = useBackend<Data>();
  const surgeries = data.surgeries || [];
  const [query, setQuery] = useState('');
  const [hideMechanic, setHideMechanic] = useState(false);

  const needle = query.trim().toLowerCase();
  const filtered = surgeries
    .filter((surgery) => !hideMechanic || !surgery.mechanic)
    .filter(
      (surgery) =>
        !needle ||
        surgery.name.toLowerCase().includes(needle) ||
        (surgery.desc || '').toLowerCase().includes(needle) ||
        surgery.tools.some((tool) => tool.name.toLowerCase().includes(needle)),
    )
    .sort((a, b) => a.name.localeCompare(b.name));

  return (
    <NtosWindow width={520} height={640}>
      <NtosWindow.Content scrollable>
        <Section>
          <Input
            fluid
            autoFocus
            placeholder="Szukaj operacji albo narzędzia…"
            value={query}
            onChange={(value) => setQuery(value)}
          />
          <Box mt={1}>
            <Button.Checkbox
              checked={hideMechanic}
              onClick={() => setHideMechanic(!hideMechanic)}
            >
              Ukryj operacje robotycznych części ciała
            </Button.Checkbox>
          </Box>
        </Section>
        <Section title={`Operacje (${filtered.length})`}>
          <Box color="label" mb={1}>
            Operacje nie mają już kroków: każda jest jedną czynnością, a co da
            się zrobić, zależy od narzędzia w ręce i stanu kończyny (nacięta
            skóra, zaciśnięte naczynia, przepiłowana kość…). Zacznij od
            położenia serwet albo prześcieradła na pacjencie. Procent przy
            narzędziu to jego sprawność; gdy operacja trwa ponad dwa i pół raza
            dłużej niż zwykle, pojawia się szansa porażki.
          </Box>
          {filtered.length === 0 && (
            <NoticeBox>Nie ma takiej operacji.</NoticeBox>
          )}
          {filtered.map((surgery) => (
            <SurgeryEntry key={surgery.id} surgery={surgery} />
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const SurgeryEntry = (props: { surgery: CatalogOperation }) => {
  const { surgery } = props;
  const tools = [...surgery.tools].sort((a, b) => b.speed - a.speed);
  const notes: string[] = [];
  if (surgery.locked) {
    notes.push('wymaga dysku z operacją albo zbadania technologii');
  }
  if (surgery.looping) {
    notes.push('powtarza się sama, dopóki da się ją robić');
  }
  return (
    <Collapsible title={surgery.name}>
      <Box ml={1} mb={1}>
        {!!surgery.desc && <Box mb={1}>{surgery.desc}</Box>}
        <Box color="label">Czas: {surgery.time} s</Box>
        {notes.length > 0 && (
          <Box color="average" mt={0.5}>
            {notes.join(' · ')}
          </Box>
        )}
        <Box mt={1}>
          {tools.map((tool, toolIndex) => (
            <Box
              inline
              key={tool.name}
              color={toolIndex === 0 ? 'good' : 'label'}
              bold={toolIndex === 0}
              mr={1}
            >
              {tool.name}
              {tool.speed < 100 && ` (${tool.speed}%)`}
              {toolIndex < tools.length - 1 && ','}
            </Box>
          ))}
        </Box>
        {Object.entries(extractRequirementMap(surgery)).map(
          ([title, requirements]) =>
            requirements.length > 0 && (
              <Box key={title} mt={1}>
                <Box italic color="label">
                  {title}
                </Box>
                <Stack vertical>
                  {requirements.map((requirement) => (
                    <Stack.Item key={requirement}>
                      - {capitalizeFirst(requirement)}
                    </Stack.Item>
                  ))}
                </Stack>
              </Box>
            ),
        )}
      </Box>
    </Collapsible>
  );
};
