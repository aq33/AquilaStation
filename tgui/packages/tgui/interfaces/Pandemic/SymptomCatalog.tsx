// AQUILA - lista wszystkich symptomów z wyszukiwarką i chemikaliami, które je losują
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Collapsible,
  Input,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { SymptomInfo } from './Symptom';
import type { Data } from './types';

export const SymptomCatalog = (props) => {
  const { data } = useBackend<Data>();
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState('');
  const [level, setLevel] = useState<number | null>(null);
  const symptoms = data.symptom_catalog || [];
  const levels = Array.from(new Set(symptoms.map((s) => s.level))).sort(
    (a, b) => a - b,
  );
  const needle = query.trim().toLowerCase();
  const shown = symptoms
    .filter((s) => level === null || s.level === level)
    .filter(
      (s) =>
        !needle ||
        s.name.toLowerCase().includes(needle) ||
        (s.desc || '').toLowerCase().includes(needle),
    )
    .sort((a, b) => a.level - b.level || a.name.localeCompare(b.name));

  return (
    <Section
      title="Lista symptomów"
      buttons={
        <Button
          icon={open ? 'chevron-up' : 'search'}
          onClick={() => setOpen(!open)}
        >
          {open ? 'Schowaj' : 'Pokaż'}
        </Button>
      }
    >
      {open && (
        <>
          <Input
            fluid
            autoFocus
            placeholder="Szukaj symptomu…"
            value={query}
            onChange={(value) => setQuery(value)}
          />
          <Box mt={1} mb={1}>
            Poziom:{' '}
            <Button
              compact
              selected={level === null}
              onClick={() => setLevel(null)}
            >
              Wszystkie
            </Button>
            {levels.map((l) => (
              <Button
                compact
                key={l}
                selected={level === l}
                onClick={() => setLevel(level === l ? null : l)}
              >
                {l}
              </Button>
            ))}
          </Box>
          {shown.length === 0 && (
            <NoticeBox>Nie ma takiego symptomu.</NoticeBox>
          )}
          {shown.map((symptom) => (
            <Collapsible
              key={symptom.id}
              title={`${symptom.name} (poziom ${symptom.level})`}
            >
              <Box color="label" mb={1}>
                {symptom.natural
                  ? symptom.sources.length > 0
                    ? `Wylosujesz go, dodając do krwi z wirusem: ${symptom.sources.join(', ')}.`
                    : 'Żaden odczynnik nie losuje tego poziomu.'
                  : 'Nie losuje się chemikaliami.'}
              </Box>
              <SymptomInfo symptom={symptom} />
            </Collapsible>
          ))}
        </>
      )}
    </Section>
  );
};
