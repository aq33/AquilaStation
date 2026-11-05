import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Flex,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

export const PlantMutator = (props) => {
  const { act, data } = useBackend();
  const {
    inserted_plant,
    inserted_seeds,
    plant_feature_data,
    catalyst,
    catalyst_desc,
    catalyst_strength,
    current_feature,
    confirm_radiation,
    working,
    port_traits,
  } = data;
  return (
    <Window width={750} height={750}>
      <Window.Content>
        {working ? (
          <Dimmer className={'plant__dimmer'}>
            <Icon size={3} name={'radiation'} className={'plant__spinner'} />
          </Dimmer>
        ) : (
          ''
        )}
        {confirm_radiation ? <Dimmer /> : ''}
        <Stack fill>
          <Stack.Item basis="45%">
            <Section
              title={inserted_plant || 'Nie włożono rośliny'}
              buttons={
                !!inserted_seeds && (
                  <Button
                    icon="eject"
                    disabled={working}
                    onClick={() => act('eject_seeds')}
                  >
                    Wyjmij nasiona
                  </Button>
                )
              }
            >
              {plant_feature_data.length
                ? plant_feature_data.map((feature_data) => (
                    <PlantFeaturePanel
                      feature={feature_data}
                      key={feature_data['key']}
                    />
                  ))
                : 'Włóż nasiona albo roślinę na łopatce.'}
            </Section>
            <Section title={catalyst || 'Nie włożono butli'}>
              <Box mb={1}>{catalyst_desc || 'Włóż butlę z plazmą.'}</Box>
              <LabeledList>
                <LabeledList.Item label="Plazma">
                  <ProgressBar
                    value={Math.min((catalyst_strength || 0) * 0.01, 1)}
                    ranges={{
                      good: [0.5, Infinity],
                      average: [0.1, 0.5],
                      bad: [-Infinity, 0.1],
                    }}
                  >
                    {`${catalyst_strength || 0} mol`}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Wybrana część"
              buttons={
                <Button.Checkbox
                  checked={port_traits}
                  tooltip="Przenieś cechy z pierwotnej części na zmutowany wynik, jeśli to możliwe"
                  onClick={() =>
                    act('toggle_port', { port_state: !port_traits })
                  }
                >
                  Zachowaj cechy
                </Button.Checkbox>
              }
            >
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
  const { title, body } = props;
  return (
    <Flex direction={'row'}>
      <Button className="plant__dialogue--beacon" width={'100%'}>
        <i>{title}</i>
        <br />
        {body}
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

const PlantFeaturePanel = (props) => {
  const { act, data } = useBackend();
  const { feature } = props;
  const { current_feature, confirm_radiation } = data;
  return (
    <Flex>
      <Button
        className="plant__button"
        width={'100%'}
        onClick={() =>
          confirm_radiation
            ? act('cancel')
            : act('select_feature', { key: feature['key'] })
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
        icon={confirm_radiation ? 'check' : 'radiation'}
        tooltip={`Mutuj część - ${feature['mutation_cost']}`}
        onClick={() => act('mutate', { key: feature['key'] })}
      />
    </Flex>
  );
};
