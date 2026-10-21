// AQUILA - syntezator odczynników działka strzykawkowego mecha
// (code/game/mecha/equipment/tools/medical_tools.dm, /syringe_gun). Zastępuje
// stare okno HTML "msyringegun": zawartość, usuwanie i wybór produkcji.
import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Reagent = {
  name: string;
  volume: number;
  id: string;
};

type KnownReagent = {
  id: string;
  name: string;
  processing: BooleanLike;
};

type Data = {
  mode: BooleanLike;
  syringes: number;
  max_syringes: number;
  total_volume: number;
  maximum_volume: number;
  synth_speed: number;
  reagents: Reagent[];
  known_reagents: KnownReagent[];
};

export const MechaSyringeGun = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    mode,
    syringes,
    max_syringes,
    total_volume,
    maximum_volume,
    synth_speed,
  } = data;
  const reagents = data.reagents || [];
  const known = data.known_reagents || [];

  // Zaznaczenia jak w dawnym formularzu: zmiany idą do maszyny po „Zastosuj”
  const processingIds = known.filter((r) => r.processing).map((r) => r.id);
  const processingKey = processingIds.join(',');
  const [selected, setSelected] = useState<string[]>(processingIds);
  useEffect(() => {
    setSelected(processingIds);
  }, [processingKey]);

  const toggle = (id: string) =>
    setSelected((current) =>
      current.includes(id)
        ? current.filter((other) => other !== id)
        : [...current, id],
    );

  return (
    <Window width={420} height={520} title="Syntezator odczynników">
      <Window.Content scrollable>
        <Section
          title="Działko"
          buttons={
            <Button icon="exchange-alt" onClick={() => act('toggle_mode')}>
              {mode ? 'Tryb: analiza' : 'Tryb: strzał'}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Strzykawki">
              {syringes}/{max_syringes}
            </LabeledList.Item>
            <LabeledList.Item label="Odczynniki">
              <ProgressBar value={total_volume} maxValue={maximum_volume}>
                {total_volume}/{maximum_volume}u
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Obecne odczynniki"
          buttons={
            <Button
              icon="trash"
              color="bad"
              disabled={reagents.length === 0}
              onClick={() => act('purge_all')}
            >
              Usuń wszystko
            </Button>
          }
        >
          {reagents.length === 0 ? (
            <Box color="label">Brak.</Box>
          ) : (
            <Table>
              {reagents.map((reagent) => (
                <Table.Row key={reagent.id} className="candystripe">
                  <Table.Cell>
                    {reagent.name}: {reagent.volume}u
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon="trash"
                      color="bad"
                      onClick={() => act('purge_reagent', { id: reagent.id })}
                    >
                      Usuń
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
        <Section
          title="Produkcja odczynników"
          buttons={
            <Button
              icon="check"
              disabled={known.length === 0}
              onClick={() => act('select_reagents', { reagents: selected })}
            >
              Zastosuj
            </Button>
          }
        >
          {known.length === 0 ? (
            <NoticeBox>Brak znanych odczynników.</NoticeBox>
          ) : (
            <>
              {known.map((reagent) => (
                <Button.Checkbox
                  key={reagent.id}
                  fluid
                  checked={selected.includes(reagent.id)}
                  onClick={() => toggle(reagent.id)}
                >
                  {reagent.name}
                </Button.Checkbox>
              ))}
              <Box mt={1} color="label" fontSize={0.9}>
                Do produkcji trafi tylko pierwsze {synth_speed} zaznaczonych
                odczynników.
              </Box>
            </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
