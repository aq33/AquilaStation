import {
  Box,
  Button,
  Icon,
  Image,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type OutfitItem = {
  path: string;
  name: string;
  desc: string;
  sprite: string;
};

type Data = {
  // name + sloty (head, glasses, ...); slot to przedmiot albo null
  outfit: Record<string, OutfitItem | string | null>;
  saveable: boolean;
  dummy64: string;
};

export const OutfitEditor = (props) => {
  const { act, data } = useBackend<Data>();
  const { outfit, saveable, dummy64 } = data;
  return (
    <Window width={380} height={600} theme="admin">
      <Window.Content>
        <Image
          fillPositionedParent
          width="100%"
          height="100%"
          opacity={0.5}
          py={3}
          src={`data:image/png;base64,${dummy64}`}
        />
        <Section
          fill
          title={
            <Stack>
              <Stack.Item
                grow={1}
                style={{
                  overflow: 'hidden',
                  whiteSpace: 'nowrap',
                  textOverflow: 'ellipsis',
                }}
              >
                <Button
                  ml={0.5}
                  color="transparent"
                  icon="pencil-alt"
                  tooltip="Zmień nazwę stroju"
                  onClick={() => act('rename', {})}
                />
                {String(outfit.name ?? '')}
              </Stack.Item>
              <Stack.Item align="end" shrink={0}>
                <Button
                  color="transparent"
                  icon="info"
                  tooltip="Ctrl+klik na przycisku slotu pozwala wybrać dowolny przedmiot zamiast tych, które pewnie do niego pasują."
                  tooltipPosition="bottom-start"
                />
                <Button
                  icon="code"
                  tooltip="Edytuj strój w oknie VV"
                  tooltipPosition="bottom-start"
                  onClick={() => act('vv')}
                />
                <Button
                  color={saveable ? undefined : 'bad'}
                  icon={saveable ? 'save' : 'trash-alt'}
                  tooltip={
                    saveable
                      ? 'Zapisz strój na liście własnych strojów'
                      : 'Usuń strój z listy własnych strojów'
                  }
                  tooltipPosition="bottom-start"
                  onClick={() => act(saveable ? 'save' : 'delete')}
                />
              </Stack.Item>
            </Stack>
          }
        >
          <Box textAlign="center">
            <Stack mb={2}>
              <OutfitSlot name="Głowa" icon="hard-hat" slot="head" />
              <OutfitSlot name="Okulary" icon="glasses" slot="glasses" />
              <OutfitSlot name="Uszy" icon="headphones-alt" slot="ears" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Szyja" icon="stethoscope" slot="neck" />
              <OutfitSlot name="Maska" icon="theater-masks" slot="mask" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Uniform" icon="tshirt" slot="uniform" />
              <OutfitSlot name="Wierzchnie" icon="user-tie" slot="suit" />
              <OutfitSlot name="Rękawice" icon="mitten" slot="gloves" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot
                name="Schowek stroju"
                icon="briefcase-medical"
                slot="suit_store"
              />
              <OutfitSlot name="Plecy" icon="shopping-bag" slot="back" />
              <OutfitSlot name="ID" icon="id-card-o" slot="id" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Pas" icon="band-aid" slot="belt" />
              <OutfitSlot name="Lewa ręka" icon="hand-paper" slot="l_hand" />
              <OutfitSlot name="Prawa ręka" icon="hand-paper" slot="r_hand" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Buty" icon="socks" slot="shoes" />
              <OutfitSlot
                name="Lewa kieszeń"
                icon="envelope-open-o"
                iconRot={180}
                slot="l_pocket"
              />
              <OutfitSlot
                name="Prawa kieszeń"
                icon="envelope-open-o"
                iconRot={180}
                slot="r_pocket"
              />
            </Stack>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

type OutfitSlotProps = {
  name: string;
  icon: string;
  iconRot?: number;
  slot: string;
};

const OutfitSlot = (props: OutfitSlotProps) => {
  const { act, data } = useBackend<Data>();
  const { name, icon, iconRot, slot } = props;
  const { outfit } = data;
  const rawItem = outfit[slot];
  const currItem = rawItem && typeof rawItem === 'object' ? rawItem : null;
  return (
    <Stack.Item grow={1} basis={0}>
      <Button
        fluid
        height={2}
        bold
        // todo: intuitive way to clear items
        onClick={(e) => act(e.ctrlKey ? 'ctrlClick' : 'click', { slot })}
      >
        <Icon name={icon} rotation={iconRot} mr={0.5} />
        {name}
      </Button>
      <Box height="32px">
        {currItem?.sprite && (
          <>
            <Tooltip content={currItem.desc}>
              <Image src={`data:image/png;base64,${currItem.sprite}`} />
            </Tooltip>
            <Icon
              position="absolute"
              name="times"
              color="label"
              style={{ cursor: 'pointer' }}
              onClick={() => act('clear', { slot })}
            />
          </>
        )}
      </Box>
      <Tooltip content={currItem?.path}>
        <Box
          color="label"
          style={{
            overflow: 'hidden',
            whiteSpace: 'nowrap',
            textOverflow: 'ellipsis',
          }}
        >
          {currItem?.name || 'Pusto'}
        </Box>
      </Tooltip>
    </Stack.Item>
  );
};
