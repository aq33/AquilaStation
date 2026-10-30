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

type Pathogen = {
  id: number;
  name: string;
};

type Data = {
  isolating: BooleanLike;
  progress: number;
  beaker: string | null;
  empty: BooleanLike;
  pathogens: Pathogen[];
};

export function DiseaseIsolator(props) {
  const { act, data } = useBackend<Data>();
  const { isolating, progress, beaker, empty, pathogens = [] } = data;

  return (
    <Window width={450} height={330}>
      <Window.Content scrollable>
        <Section
          title="Pathogenic Isolator"
          buttons={
            <Button
              icon="eject"
              content="Eject syringe"
              disabled={!beaker || !!isolating}
              tooltip={isolating ? 'Isolation in progress.' : undefined}
              onClick={() => act('eject')}
            />
          }
        >
          {!beaker && (
            <NoticeBox>Please insert a syringe into the isolator.</NoticeBox>
          )}
          {!!beaker && (
            <LabeledList>
              <LabeledList.Item label="Sample">{beaker}</LabeledList.Item>
              {!!isolating && (
                <LabeledList.Item label="Isolating">
                  <ProgressBar value={progress} minValue={0} maxValue={100}>
                    {Math.round(progress)}%
                  </ProgressBar>
                </LabeledList.Item>
              )}
            </LabeledList>
          )}
        </Section>
        {!!beaker && !isolating && (
          <Section title="Detected pathogens">
            {!!empty && <NoticeBox>The syringe is empty.</NoticeBox>}
            {!empty && !pathogens.length && (
              <NoticeBox>No pathogen found in this sample.</NoticeBox>
            )}
            {pathogens.map((pathogen) => (
              <Button
                key={pathogen.id}
                fluid
                icon="viruses"
                content={pathogen.name}
                onClick={() => act('isolate', { id: pathogen.id })}
              />
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
}
