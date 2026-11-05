import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

export const SeedEditor = (props) => {
  const { act, data } = useBackend();
  const {
    seeds_feature_data,
    current_feature,
    inserted_plant,
    disk_feature_data,
    disk_trait_data,
    disk_inserted,
    current_feature_genetic_budget,
    current_feature_remaining_genetic_budget,
  } = data;
  return (
    <Window width={750} height={750}>
      <Window.Content>
        <Stack fill>
          <Stack.Item basis="45%">
            <Section
              title={inserted_plant || 'Nie włożono nasion'}
              buttons={
                !!inserted_plant && (
                  <Button icon="eject" onClick={() => act('remove_seeds')}>
                    Wysuń
                  </Button>
                )
              }
            >
              {seeds_feature_data.length
                ? seeds_feature_data.map((feature_data) => (
                    <PlantFeaturePanel
                      feature={feature_data}
                      key={feature_data['key']}
                    />
                  ))
                : 'Włóż nasiona.'}
            </Section>
            <Section title="Stabilność genetyczna">
              <LabeledList>
                <LabeledList.Item label="Wolny budżet">
                  <ProgressBar
                    maxValue={current_feature_genetic_budget || 1}
                    value={current_feature_remaining_genetic_budget || 0}
                    ranges={{
                      good: [1, Infinity],
                      average: [0, 1],
                      bad: [-Infinity, 0],
                    }}
                  >
                    {`${current_feature_remaining_genetic_budget || 0} / ${
                      current_feature_genetic_budget || 0
                    }`}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section title="Dysk danych">
              {disk_feature_data ? (
                <DiskFeatureTab feature={disk_feature_data} />
              ) : disk_trait_data ? (
                <DiskTraitTab data_set={disk_trait_data} />
              ) : disk_inserted ? (
                <DiskEmptyTab />
              ) : (
                'Nie włożono dysku.'
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Wybrana część">
              {current_feature ? (
                <InspectionPanel />
              ) : (
                'Wybierz część rośliny z listy po lewej.'
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const DiskEmptyTab = (props) => {
  const { act, data } = useBackend();
  const { data_set } = props;
  return (
    <Flex direction={'row'}>
      <Button
        className="plant__button"
        icon={'eject'}
        tooltip={'Wysuń dysk'}
        onClick={() => act('remove_disk')}
      />
      <Button className="plant__dialogue" width={'100%'}>
        Pusty dysk
      </Button>
    </Flex>
  );
};

const DiskTraitTab = (props) => {
  const { act, data } = useBackend();
  const { data_set } = props;
  return (
    <Flex direction={'row'}>
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'eject'}
        tooltip={'Wysuń dysk'}
        onClick={() => act('remove_disk')}
      />
      <PlantTraitInstance
        title={data_set['trait_name']}
        body={data_set['trait_desc']}
        trait_key={data_set['trait_ref']}
        key={data_set}
      />
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        onClick={() => act('add_trait', { key: data_set['trait_ref'] })}
      >
        +
      </Button>
    </Flex>
  );
};

const DiskFeatureTab = (props) => {
  const { act, data } = useBackend();
  const { feature } = props;
  const { current_feature } = data;
  return (
    <Flex direction={'row'}>
      <Button
        className="plant__button"
        icon={'trash'}
        tooltip="Usuń część"
        onClick={() => act('remove_feature', { key: feature['key'] })}
      />
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'eject'}
        tooltip={'Wysuń dysk'}
        onClick={() => act('remove_disk')}
      />
      <Button
        className="plant__button"
        width={'100%'}
        onClick={() => act('select_feature', { key: feature['key'] })}
        selected={feature['key'] === current_feature}
      >
        {`${feature['name']}`}
      </Button>
      <Button
        className="plant__button"
        icon={'plus'}
        tooltip="Dodaj część"
        onClick={() => act('add_feature', { key: feature['key'] })}
      />
    </Flex>
  );
};

const PlantTraitInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body, trait_key, remove_disabled } = props;
  return (
    <Flex direction={'row'}>
      <Flex.Item grow={1}>
        <Button className="plant__dialogue" width={'100%'}>
          <i>{title}</i>
          <br />
          {body}
        </Button>
      </Flex.Item>
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'trash'}
        tooltip="Usuń cechę"
        disabled={!remove_disabled}
        onClick={() => act('remove_trait', { key: trait_key })}
      />
    </Flex>
  );
};

const InspectionPanel = (props) => {
  const { act, data } = useBackend();
  const { current_feature_data, current_feature_traits } = data;
  return (
    <Flex direction="column">
      <Box>
        {/* base feature information, stats */}
        <Flex.Item>
          <Button className="plant__dialogue" width={'100%'}>
            {current_feature_data.map((data_set) =>
              data_set['data_title'] ? (
                <PlantDataInstance
                  title={data_set['data_title']}
                  body={data_set['data_field']}
                  key={data_set}
                />
              ) : (
                <Divider key={data_set} />
              ),
            )}
          </Button>
        </Flex.Item>
        <Divider />
        {/* traits */}
        <Flex.Item>
          {current_feature_traits ? (
            current_feature_traits.map((data_set) => (
              <PlantTraitInstance
                title={data_set['trait_name']}
                body={data_set['trait_desc']}
                trait_key={data_set['trait_ref']}
                key={data_set}
                remove_disabled={data_set['can_remove']}
              />
            ))
          ) : (
            <Button className="plant__dialogue">Nie znaleziono cech</Button>
          )}
        </Flex.Item>
      </Box>
    </Flex>
  );
};

const PlantDataInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body } = props;
  return (
    <Flex.Item>
      <b>{title}</b>: {body}
    </Flex.Item>
  );
};

const PlantFeaturePanel = (props) => {
  const { act, data } = useBackend();
  const { feature } = props;
  const { current_feature } = data;
  return (
    <Flex>
      <Button
        className="plant__button"
        width={'100%'}
        onClick={() => act('select_feature', { key: feature['key'] })}
        selected={feature['key'] === current_feature}
      >
        {`${feature['name']}`}
      </Button>
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'trash'}
        tooltip="Usuń część"
        disabled={!feature['can_remove']}
        onClick={() => act('remove_feature', { key: feature['key'] })}
      />
    </Flex>
  );
};
