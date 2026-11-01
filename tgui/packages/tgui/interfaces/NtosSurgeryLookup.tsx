// AQUILA - program PDA „Operacje”: spis operacji z narzędziami i wymaganiami (nowy szkielet chirurgii z tg), podzielony na części ciała
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { extractRequirementMap } from './OperatingComputer/helpers';
import type {
  CatalogOperation,
  CatalogSection,
} from './OperatingComputer/types';

type Data = {
  surgeries: CatalogOperation[];
  sections: CatalogSection[];
};

const MECHANIC_SECTION = 'mechanic';

const byName = (a: CatalogOperation, b: CatalogOperation) =>
  a.name.localeCompare(b.name);

export const NtosSurgeryLookup = (props) => {
  const { data } = useBackend<Data>();
  const surgeries = data.surgeries || [];
  const sections = data.sections || [];
  const [query, setQuery] = useState('');
  const [hideMechanic, setHideMechanic] = useState(false);
  const [tab, setTab] = useState(sections[0]?.id || '');

  const needle = query.trim().toLowerCase();
  const visible = surgeries.filter(
    (surgery) => !hideMechanic || !surgery.mechanic,
  );
  // w zakładce „Mechaniczne” przełącznik nic nie ukrywa
  const inSection = (sectionId: string) =>
    (sectionId === MECHANIC_SECTION ? surgeries : visible).filter((surgery) =>
      surgery.sections.includes(sectionId),
    );
  const sectionNames = Object.fromEntries(
    sections.map((section) => [section.id, section.name]),
  );
  const current = sections.find((section) => section.id === tab);

  return (
    <NtosWindow width={680} height={640}>
      <NtosWindow.Content scrollable>
        <Section>
          <Input
            fluid
            autoFocus
            placeholder="Szukaj operacji albo narzędzia we wszystkich częściach ciała…"
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
          <Box color="label" mt={1}>
            Operacje nie mają już kroków: każda jest jedną czynnością, a co da
            się zrobić, zależy od narzędzia w ręce, wybranej części ciała i jej
            stanu (nacięta skóra, zaciśnięte naczynia, przepiłowana kość…).
            Zacznij od położenia serwet albo prześcieradła na pacjencie. Procent
            przy narzędziu to jego sprawność; gdy operacja trwa ponad dwa i pół
            raza dłużej niż zwykle, pojawia się szansa porażki.
          </Box>
        </Section>
        {needle ? (
          <SearchResults
            surgeries={visible
              .filter(
                (surgery) =>
                  surgery.name.toLowerCase().includes(needle) ||
                  (surgery.desc || '').toLowerCase().includes(needle) ||
                  surgery.tools.some((tool) =>
                    tool.name.toLowerCase().includes(needle),
                  ),
              )
              .sort(byName)}
            sectionNames={sectionNames}
          />
        ) : (
          <Stack>
            <Stack.Item>
              <Tabs vertical>
                {sections.map((section) => (
                  <Tabs.Tab
                    key={section.id}
                    selected={section.id === tab}
                    onClick={() => setTab(section.id)}
                  >
                    {section.name} ({inSection(section.id).length})
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              {current && (
                <Section title={current.name}>
                  <Box color="label" mb={1}>
                    {current.hint}
                  </Box>
                  {inSection(current.id).length === 0 && (
                    <NoticeBox>Brak operacji w tej części.</NoticeBox>
                  )}
                  {inSection(current.id)
                    .sort(byName)
                    .map((surgery) => (
                      <SurgeryEntry key={surgery.id} surgery={surgery} />
                    ))}
                </Section>
              )}
            </Stack.Item>
          </Stack>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const SearchResults = (props: {
  surgeries: CatalogOperation[];
  sectionNames: Record<string, string>;
}) => {
  const { surgeries, sectionNames } = props;
  return (
    <Section title={`Wyniki (${surgeries.length})`}>
      {surgeries.length === 0 && <NoticeBox>Nie ma takiej operacji.</NoticeBox>}
      {surgeries.map((surgery) => (
        <SurgeryEntry
          key={surgery.id}
          surgery={surgery}
          where={surgery.sections
            .map((section) => sectionNames[section] || section)
            .join(', ')}
        />
      ))}
    </Section>
  );
};

const SurgeryEntry = (props: { surgery: CatalogOperation; where?: string }) => {
  const { surgery, where } = props;
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
        {!!where && (
          <Box italic color="label" mb={0.5}>
            {where}
          </Box>
        )}
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
