import { Box, Dropdown, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { sanitizeText } from '../sanitize';

type Data = {
  available_modes: string[] | null;
  last_record: string;
  set_mode: string | null;
};

// Nazwy trybów przychodzą z DM i wracają do niego w akcji selectMode
const MODE_NAMES: Record<string, string> = {
  Reagent: 'Substancje',
  Health: 'Zdrowie',
  Radiation: 'Promieniowanie',
  Gas: 'Gazy',
};

export const NtosPhysScanner = (props) => {
  const { act, data } = useBackend<Data>();
  const { set_mode, available_modes, last_record } = data;
  const textHtml = {
    __html: sanitizeText(last_record || ''),
  };
  return (
    <NtosWindow width={600} height={350}>
      <NtosWindow.Content scrollable>
        <Section>
          Dotknij czegoś tabletem (prawy przycisk), żeby użyć skanera.
        </Section>
        {/* AQUILA: wybór trybu skanera zależnie od włożonych dysków */}
        <Section title="Tryb skanera">
          <Dropdown
            options={(available_modes || []).map((mode) => ({
              displayText: MODE_NAMES[mode] || mode,
              value: mode,
            }))}
            selected={set_mode || ''}
            displayText={
              set_mode ? MODE_NAMES[set_mode] || set_mode : 'Wybierz tryb'
            }
            onSelected={(value) =>
              act('selectMode', {
                newMode: value,
              })
            }
          />
        </Section>
        <Section title="Ostatni zapisany wynik">
          {textHtml.__html.length ? (
            <Box
              style={{ whiteSpace: 'pre-line' }}
              dangerouslySetInnerHTML={textHtml}
            />
          ) : (
            <Box color="label">Brak wyników.</Box>
          )}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
