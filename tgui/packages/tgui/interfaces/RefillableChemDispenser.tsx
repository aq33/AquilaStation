import { toFixed } from 'common/math';
import { toTitleCase } from 'common/string';
import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  amount: any;
  beakerContents: any;
  beakerCurrentVolume: any;
  beakerMaxVolume: any;
  beakerTransferAmounts: any;
  chemicals: any;
  isBeakerLoaded: any;
  maxVolume: any;
  mode: any;
  recipes: any;
  recordingRecipe: any;
  volume: any;
};

export const RefillableChemDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const isBeakerLoaded = data.isBeakerLoaded || 0;
  const recording = !!data.recordingRecipe;
  // TODO: Change how this piece of shit is built on server side
  // It has to be a list, not a fucking OBJECT!
  const recipes = Object.keys(data.recipes).map((name) => ({
    name,
    contents: data.recipes[name],
  }));
  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const beakerContents =
    (recording &&
      Object.keys(data.recordingRecipe).map((id) => ({
        id,
        name: toTitleCase(id.replace(/_/, ' ')),
        volume: data.recordingRecipe[id],
      }))) ||
    data.beakerContents ||
    [];
  return (
    <Window width={635} height={620}>
      <Window.Content scrollable>
        <Section
          title="Stan"
          buttons={
            recording && (
              <Box inline mx={1} color="red">
                <Icon name="circle" mr={1} />
                Nagrywanie
              </Box>
            )
          }
        >
          <LabeledList>
            <LabeledList.Item label="Pojemność">
              <ProgressBar value={data.volume / data.maxVolume}>
                {toFixed(data.volume) + ' j.'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Receptury"
          buttons={
            <>
              {!recording && (
                <Box inline mx={1}>
                  <Button
                    color="transparent"
                    content="Wyczyść receptury"
                    onClick={() => act('clear_recipes')}
                  />
                </Box>
              )}
              {!recording && (
                <Button
                  icon="circle"
                  // disabled={!data.isBeakerLoaded}
                  content="Nagraj"
                  onClick={() => act('record_recipe')}
                />
              )}
              {recording && (
                <Button
                  icon="ban"
                  color="transparent"
                  content="Odrzuć"
                  onClick={() => act('cancel_recording')}
                />
              )}
              {recording && (
                <Button
                  icon="save"
                  color="green"
                  content="Zapisz"
                  onClick={() => act('save_recording')}
                />
              )}
            </>
          }
        >
          <Box mr={-1}>
            {recipes.map((recipe) => (
              <Button
                key={recipe.name}
                icon="tint"
                width="147px"
                lineHeight="21px"
                content={recipe.name}
                onClick={() =>
                  act('dispense_recipe', {
                    recipe: recipe.name,
                  })
                }
              />
            ))}
            {recipes.length === 0 && (
              <Box color="light-gray">Brak receptur.</Box>
            )}
          </Box>
        </Section>
        <Section
          title="Dozuj"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="plus"
              selected={amount === data.amount}
              content={amount}
              onClick={() =>
                act('amount', {
                  target: amount,
                })
              }
            />
          ))}
        >
          <Box mr={-1}>
            {data.chemicals.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                width="147px"
                lineHeight="21px"
                content={chemical.title + ' (' + chemical.volume + ')'}
                disabled={chemical.volume === 0 && !recording}
                onClick={() =>
                  act('dispense', {
                    reagent: chemical.id,
                  })
                }
              />
            ))}
          </Box>
        </Section>
        <Section
          title="Zlewka"
          buttons={
            !!isBeakerLoaded && (
              <>
                <Box inline color="label" mr={2}>
                  <AnimatedNumber
                    value={data.beakerCurrentVolume}
                    initial={0}
                  />
                  {` / ${data.beakerMaxVolume} j.`}
                </Box>
                <Box inline color="label" mr={1}>
                  Tryb:
                </Box>
                <Button
                  color={data.mode ? 'good' : 'bad'}
                  icon={data.mode ? 'exchange-alt' : 'times'}
                  content={data.mode ? 'Przelewanie' : 'Usuwanie'}
                  onClick={() => act('toggleMode')}
                />
                <Button
                  icon="eject"
                  content="Wysuń"
                  onClick={() => act('eject')}
                />
              </>
            )
          }
        >
          {!isBeakerLoaded && !recording && (
            <Box color="label" mt="3px" mb="5px">
              Nie włożono zlewki.
            </Box>
          )}
          {!!isBeakerLoaded && beakerContents.length === 0 && (
            <Box color="label" mt="3px" mb="5px">
              Zlewka jest pusta.
            </Box>
          )}
          <ChemicalBuffer>
            {beakerContents.map((chemical) => (
              <ChemicalBufferEntry key={chemical.id} chemical={chemical} />
            ))}
          </ChemicalBuffer>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ChemicalBuffer = Table;

const ChemicalBufferEntry = (props) => {
  const { act, data } = useBackend<Data>();
  const recording = !!data.recordingRecipe;
  const { chemical } = props;
  return (
    <Table.Row key={chemical.name}>
      <Table.Cell color="label">
        <AnimatedNumber value={chemical.volume} initial={0} />
        {` j. ${chemical.name}`}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          content="1"
          disabled={recording}
          onClick={() =>
            act('transfer', {
              id: chemical.id,
              amount: 1,
            })
          }
        />
        <Button
          content="5"
          disabled={recording}
          onClick={() =>
            act('transfer', {
              id: chemical.id,
              amount: 5,
            })
          }
        />
        <Button
          content="10"
          disabled={recording}
          onClick={() =>
            act('transfer', {
              id: chemical.id,
              amount: 10,
            })
          }
        />
        <Button
          content="Wszystko"
          disabled={recording}
          onClick={() =>
            act('transfer', {
              id: chemical.id,
              amount: 1000,
            })
          }
        />
        <Button
          icon="ellipsis-h"
          tooltip="Własna ilość"
          disabled={recording}
          onClick={() =>
            act('transfer', {
              id: chemical.id,
              amount: -1,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  );
};
