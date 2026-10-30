import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

type Tube = {
  slot: number;
  inserted: BooleanLike;
  name: string;
  volume: number;
  has_blood: BooleanLike;
  has_pathogen: BooleanLike;
  has_antibodies: BooleanLike;
  vaccine: string | null;
  task: string | null;
  target: string | null;
  progress: number;
};

type Data = {
  on: BooleanLike;
  efficiency: number;
  tubes: Tube[];
};

/** What the centrifuge sees inside a tube. */
const contentsLabel = (tube: Tube) => {
  if (tube.vaccine) {
    return `Vaccine (${tube.vaccine})`;
  }
  if (!tube.has_blood) {
    return 'No blood detected';
  }
  return tube.has_pathogen
    ? 'Blood, pathogen detected'
    : 'Blood, no pathogen detected';
};

const taskLabel = (tube: Tube) => {
  if (tube.task === 'dish') {
    return `Isolating ${tube.target}`;
  }
  if (tube.task === 'vaccine') {
    return `Synthesizing vaccine (${tube.target})`;
  }
  return 'Working';
};

const TubeSlot = (props: { tube: Tube }) => {
  const { act, data } = useBackend<Data>();
  const { on } = data;
  const { tube } = props;

  if (!tube.inserted) {
    return (
      <Section title={`Slot ${tube.slot}`}>
        <Button
          icon="flask"
          content="Insert tube from hand"
          disabled={!!on}
          onClick={() => act('insert_tube', { slot: tube.slot })}
        />
      </Section>
    );
  }

  return (
    <Section
      title={`Slot ${tube.slot}: ${tube.name}`}
      buttons={
        <Button
          icon="eject"
          content="Eject"
          disabled={!!on}
          tooltip={on ? 'Turn the centrifuge off first.' : undefined}
          onClick={() => act('eject_tube', { slot: tube.slot })}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Contents">
          {contentsLabel(tube)}
        </LabeledList.Item>
        <LabeledList.Item label="Volume">{tube.volume}u</LabeledList.Item>
        {!!tube.task && (
          <LabeledList.Item
            label={taskLabel(tube)}
            buttons={
              <Button
                icon="times"
                color="red"
                content="Abort"
                onClick={() => act('interrupt', { slot: tube.slot })}
              />
            }
          >
            <ProgressBar value={tube.progress} minValue={0} maxValue={100}>
              {Math.round(tube.progress)}%
            </ProgressBar>
          </LabeledList.Item>
        )}
      </LabeledList>
      {!tube.task && (
        <>
          <Button
            icon="viruses"
            content="Isolate to dish"
            disabled={!tube.has_pathogen}
            tooltip={
              !tube.has_pathogen ? 'No pathogen in this sample.' : undefined
            }
            onClick={() => act('isolate', { slot: tube.slot })}
          />
          <Button
            icon="syringe"
            content="Synthesize vaccine"
            disabled={!tube.has_antibodies}
            tooltip={
              !tube.has_antibodies
                ? 'Antibody level too low for a vaccine (minimum 30%).'
                : undefined
            }
            onClick={() => act('synthvaccine', { slot: tube.slot })}
          />
        </>
      )}
    </Section>
  );
};

export function DiseaseCentrifuge(props) {
  const { act, data } = useBackend<Data>();
  const { on, efficiency, tubes = [] } = data;

  const queued = tubes.some((tube) => !!tube.task);

  return (
    <Window width={520} height={520}>
      <Window.Content scrollable>
        <Section
          title="Isolation Centrifuge"
          buttons={
            <Button
              icon="power-off"
              content={on ? 'On' : 'Off'}
              color={on ? 'green' : 'red'}
              onClick={() => act('power')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Efficiency">
              {efficiency}x
            </LabeledList.Item>
          </LabeledList>
          {!on && queued && (
            <NoticeBox>
              Turn the centrifuge on to work through the queued samples.
            </NoticeBox>
          )}
          {!!on && (
            <NoticeBox info>
              Keep opposite slots evenly filled for the best efficiency.
            </NoticeBox>
          )}
        </Section>
        {tubes.map((tube) => (
          <TubeSlot key={tube.slot} tube={tube} />
        ))}
      </Window.Content>
    </Window>
  );
}
