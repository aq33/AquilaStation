import { useBackend } from 'tgui/backend';
import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import type { Data } from './types';

/** Informacje o włożonej zlewce */
export const BeakerDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_beaker, beaker, beaker_empty, has_blood } = data;
  const isEmpty = beaker ? !beaker.volume : !!beaker_empty;
  const cant_empty = !has_beaker || isEmpty;
  let content;
  if (!has_beaker) {
    content = <NoticeBox>Nie włożono zlewki.</NoticeBox>;
  } else if (isEmpty) {
    content = <NoticeBox>Zlewka jest pusta.</NoticeBox>;
  } else if (!has_blood) {
    content = <NoticeBox>Brak próbki krwi.</NoticeBox>;
  } else {
    content = (
      <Stack vertical>
        <Stack.Item>
          <Info />
        </Stack.Item>
        <Stack.Item>
          <Antibodies />
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Section
      title="Zlewka"
      buttons={
        <>
          <Button
            icon="times"
            color="bad"
            disabled={cant_empty}
            onClick={() => act('empty_eject_beaker')}
          >
            Opróżnij i wysuń
          </Button>
          <Button
            icon="trash"
            disabled={cant_empty}
            onClick={() => act('empty_beaker')}
          >
            Opróżnij
          </Button>
          <Button
            icon="eject"
            disabled={!has_beaker}
            onClick={() => act('eject_beaker')}
          >
            Wysuń
          </Button>
        </>
      }
    >
      {content}
    </Section>
  );
};

/** Grupa krwi, DNA i zapełnienie zlewki */
const Info = (props) => {
  const { data } = useBackend<Data>();
  const { beaker, blood } = data;
  if (!blood) {
    return <NoticeBox>Brak próbki krwi.</NoticeBox>;
  }

  return (
    <Stack>
      <Stack.Item grow={2}>
        <LabeledList>
          <LabeledList.Item label="DNA">
            {capitalizeFirst(blood.dna)}
          </LabeledList.Item>
          <LabeledList.Item label="Grupa">
            {capitalizeFirst(blood.type)}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      {!!beaker && (
        <Stack.Item grow={2}>
          <LabeledList>
            <LabeledList.Item label="Pojemnik">
              <ProgressBar
                color="darkred"
                value={beaker.volume}
                minValue={0}
                maxValue={beaker.capacity}
                ranges={{
                  good: [beaker.capacity * 0.85, beaker.capacity],
                  average: [beaker.capacity * 0.25, beaker.capacity * 0.85],
                  bad: [0, beaker.capacity * 0.25],
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      )}
    </Stack>
  );
};

/** Przyciski do robienia szczepionek z wykrytych przeciwciał */
const Antibodies = (props) => {
  const { act, data } = useBackend<Data>();
  const { is_ready, resistances = [] } = data;

  return (
    <LabeledList>
      <LabeledList.Item label="Przeciwciała">
        {!resistances.length
          ? 'Brak'
          : resistances.map((resistance) => {
              return (
                <Button
                  key={resistance.id}
                  icon="eye-dropper"
                  disabled={!is_ready}
                  tooltip="Tworzy fiolkę ze szczepionką."
                  onClick={() =>
                    act('create_vaccine_bottle', {
                      index: resistance.id,
                    })
                  }
                >
                  {`${resistance.name}`}
                </Button>
              );
            })}
      </LabeledList.Item>
    </LabeledList>
  );
};
