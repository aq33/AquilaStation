import { Button, Flex, LabeledList } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { pointName, useRemappedBackend } from './helpers';
import { useTechWebRoute } from './hooks';
import { TechwebRouter } from './Router';

export function TechwebContent(props) {
  const { act, data } = useRemappedBackend();
  const {
    compact,
    d_disk,
    linkedanalyzer,
    points_last_tick = {},
    points = {},
    sec_protocols,
    t_disk,
    tech_tier,
  } = data;
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  return (
    <Flex direction="column" className="Techweb__Viewport" height="100%">
      <Flex.Item className="Techweb__HeaderSection">
        <Flex className="Techweb__HeaderContent">
          <Flex.Item>
            <LabeledList>
              <LabeledList.Item label="Zabezpieczenia">
                <span
                  className={`Techweb__SecProtocol ${
                    !!sec_protocols && 'engaged'
                  }`}
                >
                  {sec_protocols ? 'Aktywne' : 'Wyłączone'}
                </span>
              </LabeledList.Item>
              {Object.keys(points).map((k) => (
                <LabeledList.Item key={k} label={pointName(k)}>
                  <b>{points[k]}</b>
                  {!!points_last_tick[k] &&
                    ` (+${toFixed(points_last_tick[k], 1)}/s)`}
                </LabeledList.Item>
              ))}
              {/* AQUILA: poziomy technologii (z NSV13) */}
              <LabeledList.Item label="Poziom technologii">
                {tech_tier}
              </LabeledList.Item>
            </LabeledList>
          </Flex.Item>
          <Flex.Item grow />
          <Flex.Item>
            <Button fluid onClick={() => act('toggleLock')} icon="lock">
              Zablokuj konsolę
            </Button>
            {/* AQUILA: tryb kompaktowy, łączenie maszyn i analizator (z NSV13) */}
            <Button.Checkbox
              fluid
              color="default"
              checked={!compact}
              tooltip="Ukrywa paski postępu i ikony projektów w węzłach"
              onClick={() => act('compactify')}
            >
              Tryb kompaktowy
            </Button.Checkbox>
            <Button fluid icon="link" onClick={() => act('linkmachines')}>
              Połącz maszyny
            </Button>
            <Button
              fluid
              icon="trash"
              disabled={!linkedanalyzer}
              selected={techwebRoute.route === 'analyzer'}
              onClick={() => setTechwebRoute({ route: 'analyzer' })}
            >
              Analizator destrukcyjny
            </Button>
            {d_disk && (
              <Button
                fluid
                icon="floppy-disk"
                onClick={() =>
                  setTechwebRoute({ route: 'disk', diskType: 'design' })
                }
              >
                Włożony dysk projektów
              </Button>
            )}
            {t_disk && (
              <Button
                fluid
                icon="floppy-disk"
                onClick={() =>
                  setTechwebRoute({ route: 'disk', diskType: 'tech' })
                }
              >
                Włożony dysk technologii
              </Button>
            )}
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className="Techweb__RouterContent" grow minHeight={0}>
        <TechwebRouter />
      </Flex.Item>
    </Flex>
  );
}
