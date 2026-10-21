import {
  Box,
  Button,
  ColorBox,
  Divider,
  Flex,
  Icon,
  Image,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ColorEntry = {
  index: number;
  value: string;
};

type SpriteData = {
  icon_states: string[];
  finished: string;
  steps: SpriteEntry[];
  time_spent: number;
};

type SpriteEntry = {
  layer: string;
  result: string;
  config_name: string;
};

type GreyscaleMenuData = {
  greyscale_config: string;
  colors: ColorEntry[];
  sprites: SpriteData;
  generate_full_preview: boolean;
  unlocked: boolean;
  monitoring_files: boolean;
  sprites_dir: string;
  icon_state: string;
  refreshing: boolean;
};

enum Direction {
  North = 'north',
  NorthEast = 'northeast',
  East = 'east',
  SouthEast = 'southeast',
  South = 'south',
  SouthWest = 'southwest',
  West = 'west',
  NorthWest = 'northwest',
}

const DirectionAbbreviation: Record<Direction, string> = {
  [Direction.North]: 'N',
  [Direction.NorthEast]: 'NE',
  [Direction.East]: 'E',
  [Direction.SouthEast]: 'SE',
  [Direction.South]: 'S',
  [Direction.SouthWest]: 'SW',
  [Direction.West]: 'W',
  [Direction.NorthWest]: 'NW',
};

const ConfigDisplay = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  return (
    <Section title="Wzory">
      <LabeledList>
        <LabeledList.Item label="Rodzaj wzoru">
          <Button icon="cogs" onClick={() => act('select_config')} />
          <Input
            value={data.greyscale_config}
            onBlur={(value) =>
              act('load_config_from_string', { config_string: value })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ColorDisplay = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  const colors = data.colors || [];
  return (
    <Section title="Kolory">
      <LabeledList>
        <LabeledList.Item label="Pełny ciąg kolorów">
          <Button
            icon="dice"
            onClick={() => act('random_all_colors')}
            tooltip="Losuje wszystkie grupy kolorów."
          />
          <Input
            value={colors.map((item) => item.value).join('')}
            onBlur={(value) =>
              act('recolor_from_string', { color_string: value })
            }
          />
        </LabeledList.Item>
        {colors.map((item) => (
          <LabeledList.Item
            key={`colorgroup${item.index}${item.value}`}
            label={`Grupa kolorów ${item.index}`}
            color={item.value}
          >
            <ColorBox color={item.value} />{' '}
            <Button
              icon="palette"
              onClick={() => act('pick_color', { color_index: item.index })}
              tooltip="Otwiera okno wyboru koloru dla tej grupy."
            />
            <Button
              icon="dice"
              onClick={() => act('random_color', { color_index: item.index })}
              tooltip="Losuje kolor tej grupy."
            />
            <Input
              value={item.value}
              width={7}
              onBlur={(value) =>
                act('recolor', { color_index: item.index, new_color: value })
              }
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const PreviewCompassSelect = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  return (
    <Box>
      <Stack vertical>
        <Flex>
          <SingleDirection dir={Direction.NorthWest} />
          <SingleDirection dir={Direction.North} />
          <SingleDirection dir={Direction.NorthEast} />
        </Flex>
        <Flex>
          <SingleDirection dir={Direction.West} />
          <Flex.Item grow={1} basis={0}>
            <Button lineHeight={3} m={-0.2} fluid>
              <Icon name="arrows-alt" size={1.5} m="20%" />
            </Button>
          </Flex.Item>
          <SingleDirection dir={Direction.East} />
        </Flex>
        <Flex>
          <SingleDirection dir={Direction.SouthWest} />
          <SingleDirection dir={Direction.South} />
          <SingleDirection dir={Direction.SouthEast} />
        </Flex>
      </Stack>
    </Box>
  );
};

const SingleDirection = (props) => {
  const { dir } = props;
  const { data, act } = useBackend<GreyscaleMenuData>();
  return (
    <Flex.Item grow={1} basis={0}>
      <Button
        content={DirectionAbbreviation[dir]}
        tooltip={`Ustawia kierunek podglądu na ${dir}`}
        disabled={`${dir}` === data.sprites_dir ? true : false}
        textAlign="center"
        onClick={() => act('change_dir', { new_sprite_dir: dir })}
        lineHeight={3}
        m={-0.2}
        fluid
      />
    </Flex.Item>
  );
};

const IconStatesDisplay = (props) => {
  const { data, act } = useBackend<GreyscaleMenuData>();
  return (
    <Section title="Stany ikony">
      <Flex>
        {data.sprites.icon_states.map((item) => (
          <Flex.Item key={item}>
            <Button
              mx={0.5}
              content={item ? item : 'Pusty stan'}
              disabled={item === data.icon_state}
              onClick={() => act('select_icon_state', { new_icon_state: item })}
            />
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const PreviewDisplay = (props) => {
  const { data } = useBackend<GreyscaleMenuData>();
  return (
    <Section title={`Podgląd (${data.sprites_dir})`}>
      <Table>
        <Table.Row>
          <Table.Cell width="50%">
            <PreviewCompassSelect />
          </Table.Cell>
          {data.sprites?.finished ? (
            <Table.Cell>
              <Image
                src={data.sprites.finished}
                m={0}
                width="75%"
                mx="10%"
                style={{ imageRendering: 'pixelated' }}
              />
            </Table.Cell>
          ) : (
            <Table.Cell>
              <Box>
                <Icon
                  name="image"
                  ml="25%"
                  size={5}
                  style={{ imageRendering: 'pixelated' }}
                />
              </Box>
            </Table.Cell>
          )}
        </Table.Row>
      </Table>
      {!!data.generate_full_preview && `Czas: ${data.sprites.time_spent}ms`}
      <Divider />
      {!data.refreshing && (
        <Table>
          {!!data.generate_full_preview && data.sprites.steps !== null && (
            <Table.Row header>
              <Table.Cell width="50%" textAlign="center">
                Źródło warstwy
              </Table.Cell>
              <Table.Cell width="25%" textAlign="center">
                Warstwa kroku
              </Table.Cell>
              <Table.Cell width="25%" textAlign="center">
                Wynik kroku
              </Table.Cell>
            </Table.Row>
          )}
          {!!data.generate_full_preview &&
            data.sprites.steps !== null &&
            data.sprites.steps.map((item) => (
              <Table.Row key={`${item.result}|${item.layer}`}>
                <Table.Cell verticalAlign="middle">
                  {item.config_name}
                </Table.Cell>
                <Table.Cell>
                  <SingleSprite source={item.layer} />
                </Table.Cell>
                <Table.Cell>
                  <SingleSprite source={item.result} />
                </Table.Cell>
              </Table.Row>
            ))}
        </Table>
      )}
    </Section>
  );
};

const SingleSprite = (props) => {
  const { source } = props;
  return (
    <Image src={source} width="100%" style={{ imageRendering: 'pixelated' }} />
  );
};

const LoadingAnimation = () => {
  return (
    <Box height={0} mt="-100%">
      <Icon name="cog" height={22.7} opacity={0.5} size={25} spin />
    </Box>
  );
};

export const GreyscaleModifyMenu = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  return (
    <Window title="Konfiguracja kolorów" width={325} height={800}>
      <Window.Content scrollable>
        <ConfigDisplay />
        <ColorDisplay />
        <IconStatesDisplay />
        <Flex direction="column">
          {!!data.unlocked && (
            <Flex.Item justify="flex-start">
              <Button
                content={
                  <Icon name="file-image-o" spin={data.monitoring_files} />
                }
                tooltip="Stale sprawdza pliki i przeładowuje je po zmianach. UWAGA: bardzo kosztowne"
                selected={data.monitoring_files}
                onClick={() => act('toggle_mass_refresh')}
                width={1.9}
                mr={-0.2}
              />
              <Button
                content="Odśwież plik ikon"
                tooltip="Wczytuje od nowa z dysku konfigurację json i plik ikon, żeby zobaczyć zmiany bez restartu serwera. UWAGA: kosztowne"
                onClick={() => act('refresh_file')}
              />
              <Button
                content="Zapisz plik ikon"
                tooltip="Zapisuje ikonę do pliku tymczasowego w tmp/. Przydaje się, gdy chcesz użyć wygenerowanej ikony gdzie indziej albo obejrzeć ją dokładniej"
                onClick={() => act('save_dmi')}
              />
            </Flex.Item>
          )}
          <Flex.Item>
            <Button
              content="Zastosuj"
              tooltip="Zapisuje zmiany w obiekcie, z którego otwarto to menu."
              color="red"
              onClick={() => act('apply')}
            />
            <Button.Checkbox
              content="Pełny podgląd"
              tooltip="Pokazuje cały proces generowania sprite'a zamiast samego wyniku."
              disabled={!data.generate_full_preview && !data.unlocked}
              checked={data.generate_full_preview}
              onClick={() => act('toggle_full_preview')}
            />
          </Flex.Item>
        </Flex>
        <PreviewDisplay />
        {!!data.refreshing && <LoadingAnimation />}
      </Window.Content>
    </Window>
  );
};
