// NSV13

import { Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  iff_theme: any;
  is_hackerman: any;
};

export const IFF = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme={data.iff_theme} width={600} height={800}>
      <Window.Content scrollable>
        {!data.is_hackerman && (
          <Section title="ODMOWA DOSTĘPU.">
            <img src="https://nsv.beestation13.com/mediawiki2/images/8/8f/SolGov.png" />
            <br />
            {'DOSTĘP DO PLIKU ZASZYFROWANY.'}
            <br />
            {
              'Przeprogramowywanie układów IFF narusza przepis SolGov o konfliktach nr A230385-C. Wobec statków z naruszonym IFF dopuszcza się użycie siły śmiertelnej.'
            }
          </Section>
        )}
        {!!data.is_hackerman && (
          <Section title="./iff_bustr.exe">
            {`
.####.########.########.........########..##.....##..######..########.########.\n
..##..##.......##...............##.....##.##.....##.##....##....##....##.....##\n
..##..##.......##...............##.....##.##.....##.##..........##....##.....##\n
..##..######...######...........########..##.....##..######.....##....########.\n
..##..##.......##...............##.....##.##.....##.......##....##....##...##..\n
..##..##.......##...............##.....##.##.....##.##....##....##....##....##.\n
.####.##.......##.......#######.########...#######...######.....##....##.....##\n
            `}
            <br />
            {'___________________________________'}
            <br />
            {'br34ch3r.dll: wczytano'}
            <br />
            {'5ysbr34k3r.dll: wczytano'}
            <br />
            {'bye_bye_iff.dll: wczytano'}
            <br />
            {'trwa wysyłanie pakietu'}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
