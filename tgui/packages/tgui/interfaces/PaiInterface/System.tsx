import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import type { PaiData } from './types';

export function SystemDisplay(props) {
  return (
    <Stack fill vertical>
      <Stack.Item grow={3}>
        <SystemWallpaper />
      </Stack.Item>
      <Stack.Item grow>
        <SystemInfo />
      </Stack.Item>
    </Stack>
  );
}

/** Renders some ASCII art. Changes to red on emag. */
function SystemWallpaper(props) {
  // AQUILA: nasze pAI nie ma stanu emagu, tapeta zawsze w barwach Nanotrasen
  const emagged = false;

  const owner = !emagged ? 'NANOTRASEN' : ' SYNDICATE';
  const eyebrows = !emagged ? "/\\ ' /\\" : ' \\\\ // ';

  const paiAscii = [
    ' ________  ________  ___',
    ' |\\   __  \\|\\   __  \\|\\  \\',
    ' \\ \\  \\|\\  \\ \\  \\|\\  \\ \\  \\     Interfejs',
    '  \\ \\   ____\\ \\   __  \\ \\  \\     Wersja 2.5',
    '   \\ \\  \\___|\\ \\  \\ \\  \\ \\  \\',
    '    \\ \\__\\    \\ \\__\\ \\__\\ \\__\\     Własność',
    `     \\|__|     \\|__|\\|__|\\|__|      ${owner}`,
    '',
  ].join('\n');

  const floofAscii = [
    '                              .--.       .-.',
    "        ,;;``;;-;,,..___.,,.-/   `;_//,.'   )",
    "      .' ;;  `;  :; `;;  ;;  `.       '/   .'",
    `     ,;  ';   ;   '  ';  ';   ,'    ${eyebrows}';`, // lol
    "    /'     `      \\   `     ;','   ( d\\__b_),",
    "   /   /       .,;;)       ', (    .'     __\\",
    "  ;:.  \\     ,_   /         ', ' .'_      \\/;",
    " ,   ,;'      `;;/       /    ';,\\ `-..__._,'",
    " ;:.  /____  ..-'--.    /-'    ..---. ._._/ ---.",
    " |    ;' ;'|        \\--/;' ,' /      \\   ,      \\",
    " `.fL__;,__/-..__)_)/  `--'--'`-._)_)/ --\\.._)_)/",
  ].join('\n');

  return (
    <Section fill nowrap overflow="hidden">
      <pre>
        <Box color={!emagged ? 'blue' : 'crimson'}>{paiAscii}</Box>
        <Box color={!emagged ? 'gold' : 'limegreen'}>{floofAscii}</Box>
      </pre>
    </Section>
  );
}

/** Displays master info.
 * You can check their DNA and change your image here.
 */
function SystemInfo(props) {
  const { act, data } = useBackend<PaiData>();
  const { master_dna, master_name } = data;

  return (
    <Section
      buttons={
        <>
          <Button
            disabled={!master_dna}
            icon="dna"
            onClick={() => act('check_dna')}
            tooltip="Weryfikuje DNA właściciela. Musisz być trzymany w ręku."
          >
            Weryfikuj
          </Button>
          <Button
            icon="image"
            onClick={() => act('change_image')}
            tooltip="Zmień obraz na wyświetlaczu karty."
          >
            Wyświetlacz
          </Button>
          <Button
            icon="broadcast-tower"
            onClick={() => act('radio')}
            tooltip="Konfiguracja wbudowanego radia."
          >
            Radio
          </Button>
        </>
      }
      fill
      title="Informacje o systemie"
    >
      <LabeledList>
        <LabeledList.Item label="Właściciel">
          {master_name || 'Brak.'}
        </LabeledList.Item>
        <LabeledList.Item color={master_dna ? 'red' : ''} label="DNA">
          {master_dna || 'Brak.'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}
