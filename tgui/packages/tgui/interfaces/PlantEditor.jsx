import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Flex,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

export const PlantEditor = (props) => {
  const { act, data } = useBackend();
  const {
    inserted_plant,
    plant_feature_data,
    current_feature,
    disk_feature_data,
    disk_trait_data,
    disk_inserted,
    saving_feature,
  } = data;
  return (
    <Window width={750} height={750}>
      <Window.Content>
        {saving_feature ? <Dimmer /> : ''}
        <Stack fill>
          <Stack.Item basis="45%">
            <Section title={inserted_plant || 'Nie włożono rośliny'}>
              {plant_feature_data.length
                ? plant_feature_data.map((feature_data) => (
                    <PlantFeaturePanel
                      feature={feature_data}
                      key={feature_data['key']}
                    />
                  ))
                : 'Włóż dojrzałą roślinę łopatką.'}
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
  return (
    <Flex direction={'row'}>
      <Button className="plant__dialogue" width={'100%'}>
        Pusty dysk
      </Button>
      <Button
        className="plant__button"
        icon={'eject'}
        tooltip={'Wysuń dysk'}
        onClick={() => act('remove_disk')}
      />
    </Flex>
  );
};

const DiskTraitTab = (props) => {
  const { act, data } = useBackend();
  const { data_set } = props;
  return (
    <Flex direction={'row'}>
      <Button className="plant__dialogue" width={'100%'}>
        <i>{data_set['trait_name']}</i>
        <br />
        {data_set['trait_desc']}
      </Button>
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'trash'}
        tooltip="Usuń cechę"
        onClick={() => act('remove_trait', { key: data_set['trait_ref'] })}
      />
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'eject'}
        tooltip={'Wysuń dysk'}
        onClick={() => act('remove_disk')}
      />
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
          <Button className="plant__dialogue--beacon" width={'100%'}>
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
                save_disabled={data_set['can_copy']}
              />
            ))
          ) : (
            <Button className="plant__dialogue--beacon">
              Nie znaleziono cech
            </Button>
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

const PlantTraitInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body, trait_key, save_disabled } = props;
  const { saving_feature, save_excluded_traits } = data;
  return (
    <Flex direction={'row'}>
      <Button className="plant__dialogue--beacon" width={'100%'}>
        <i>{title}</i>
        <br />
        {body}
      </Button>
      {!saving_feature ? (
        <Button
          className="plant__button"
          verticalAlignContent={'middle'}
          icon={'save'}
          onClick={() => act('save_trait', { key: trait_key })}
          disabled={!save_disabled}
        />
      ) : (
        <Button.Checkbox
          className="plant__button--beacon"
          verticalAlignContent={'middle'}
          checked={!save_excluded_traits.includes(trait_key)}
          onClick={() => act('toggle_trait', { key: trait_key })}
          disabled={!save_disabled}
        />
      )}
    </Flex>
  );
};

const PlantFeaturePanel = (props) => {
  const { act, data } = useBackend();
  const { feature } = props;
  const { current_feature, saving_feature } = data;
  return (
    <Flex>
      <Button
        className="plant__button"
        width={'100%'}
        onClick={
          saving_feature
            ? null
            : () => act('select_feature', { key: feature['key'] })
        }
        selected={feature['key'] === current_feature}
      >
        {`${feature['name']}`}
      </Button>
      <Button
        className={
          feature['key'] === current_feature
            ? 'plant__button--beacon'
            : 'plant__button'
        }
        verticalAlignContent={'middle'}
        icon={saving_feature ? 'save' : 'search'}
        tooltip="Zapisz część"
        disabled={!feature['can_copy']}
        onClick={() =>
          act('save_feature', {
            key: feature['key'],
            force: saving_feature ? 1 : 0,
          })
        }
      />
    </Flex>
  );
};
