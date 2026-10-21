// AQUILA: analizator destrukcyjny obsługiwany z konsoli R&D (z NSV13, nie ma go w tg)
import {
  Button,
  Divider,
  Flex,
  NoticeBox,
  Section,
  VirtualList,
} from 'tgui-core/components';

import { useRemappedBackend } from './helpers';
import { useTechWebRoute } from './hooks';
import { TechNode } from './nodes/TechNode';
import type { TechwebNode } from './types';

export function TechwebAnalyzer(props) {
  const { act, data } = useRemappedBackend();
  const { linkedanalyzer, analyzertechs, analyzeritem, itemmats, itempoints } =
    data;
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Analizator destrukcyjny
          </Flex.Item>
          <Flex.Item align="center" grow>
            {analyzeritem || ''}
          </Flex.Item>
          <Flex.Item align="center">
            <Button.Confirm
              icon="trash"
              color="bad"
              disabled={!analyzeritem}
              confirmContent="Na pewno?"
              onClick={() => act('destroyitem')}
            >
              Zniszcz (odzysk materiałów)
            </Button.Confirm>
            <Button
              icon="eject"
              disabled={!analyzeritem}
              onClick={() => act('ejectitem')}
            >
              Wysuń
            </Button>
            <Button icon="home" onClick={() => setTechwebRoute({ route: '' })}>
              Start
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      {!linkedanalyzer && (
        <Flex.Item mt={1}>
          <NoticeBox>Brak połączonego analizatora destrukcyjnego.</NoticeBox>
        </Flex.Item>
      )}
      {!!linkedanalyzer && !analyzeritem && (
        <Flex.Item mt={1}>
          <NoticeBox info>Analizator jest pusty.</NoticeBox>
        </Flex.Item>
      )}
      {!!linkedanalyzer && !!analyzeritem && (
        <>
          {!!(itempoints?.length || itemmats?.length) && (
            <Flex.Item>
              <Section mt={1} className="Techweb__NodeContainer">
                {!!itempoints?.length && (
                  <>
                    {itempoints.map((line) => (
                      <div key={line}>{line}</div>
                    ))}
                    {!!itemmats?.length && <Divider />}
                  </>
                )}
                {!!itemmats?.length && (
                  <>
                    Materiały do odzyskania:
                    {itemmats.map((line) => (
                      <div key={line}>{line}</div>
                    ))}
                  </>
                )}
              </Section>
            </Flex.Item>
          )}
          <Flex.Item grow minHeight={0} className="Techweb__OverviewNodes">
            {analyzertechs ? (
              <Section fill scrollable>
                <VirtualList>
                  {Object.keys(analyzertechs)
                    .map((x) => ({ id: x }) as TechwebNode)
                    .map((n) => (
                      <TechNode key={n.id} nodetails destructive node={n} />
                    ))}
                </VirtualList>
              </Section>
            ) : (
              <NoticeBox>
                Ten przedmiot nie odblokuje żadnych nowych węzłów.
              </NoticeBox>
            )}
          </Flex.Item>
        </>
      )}
    </Flex>
  );
}
