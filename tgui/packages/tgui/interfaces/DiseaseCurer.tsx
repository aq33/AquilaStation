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

type Antibody = {
  name: string;
  level: number;
};

type Data = {
  curing: BooleanLike;
  virusing: BooleanLike;
  container: string | null;
  has_blood: BooleanLike;
  antibodies: Antibody[];
};

export function DiseaseCurer(props) {
  const { act, data } = useBackend<Data>();
  const { curing, virusing, container, has_blood, antibodies = [] } = data;

  return (
    <Window width={450} height={400}>
      <Window.Content scrollable>
        <Section
          title="Cure Research Machine"
          buttons={
            <Button
              icon="eject"
              content="Eject container"
              disabled={!container || !!curing}
              tooltip={curing ? 'Production in progress.' : undefined}
              onClick={() => act('eject')}
            />
          }
        >
          {!!curing && <NoticeBox info>Antibody production in progress.</NoticeBox>}
          {!!virusing && (
            <NoticeBox>The pathogen materializer is recharging.</NoticeBox>
          )}
          {!container && (
            <NoticeBox>Please insert a container.</NoticeBox>
          )}
          {!!container && (
            <LabeledList>
              <LabeledList.Item label="Container">{container}</LabeledList.Item>
              <LabeledList.Item label="Sample">
                {has_blood ? 'Blood sample inserted' : 'No blood detected'}
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
        {!!container && !!has_blood && (
          <Section
            title="Antibodies"
            buttons={
              <Button
                icon="syringe"
                content="Begin antibody production"
                disabled={!!curing || !antibodies.length}
                tooltip={
                  !antibodies.length
                    ? 'No antibodies in this blood sample.'
                    : undefined
                }
                onClick={() => act('antibody')}
              />
            }
          >
            {!antibodies.length && (
              <NoticeBox>
                This donor carries no antibodies. A vaccine needs a sample from
                someone who fought the pathogen off.
              </NoticeBox>
            )}
            <LabeledList>
              {antibodies.map((antibody) => (
                <LabeledList.Item key={antibody.name} label={antibody.name}>
                  <ProgressBar
                    value={antibody.level}
                    minValue={0}
                    maxValue={100}
                  >
                    {antibody.level}%
                  </ProgressBar>
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
}
