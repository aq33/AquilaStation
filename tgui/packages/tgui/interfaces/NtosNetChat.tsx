import {
  Box,
  Button,
  Dimmer,
  Icon,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Channel = {
  chan: string;
  id: number;
};

type Client = {
  name: string;
  status: number;
  muted: BooleanLike;
  operator: BooleanLike;
  ref: string;
};

type Data = {
  PC_device_theme: string;
  active_channel: number | null;
  adminmode: BooleanLike;
  all_channels: Channel[];
  authed: BooleanLike;
  can_admin: BooleanLike;
  clients: Client[];
  is_operator: BooleanLike;
  messages: { msg: string }[];
  selfref: string;
  strong: BooleanLike;
  title: string;
  username: string;
};

// stany programu z DM (program_state)
const CLIENT_ONLINE = 2;
const CLIENT_AWAY = 1;

const NoChannelDimmer = (props) => {
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item>
          <Stack ml={-2}>
            <Stack.Item>
              <Icon color="green" name="grin-beam" size={10} />
            </Stack.Item>
            <Stack.Item mt={-8}>
              <Icon name="comment-dots" size={10} />
            </Stack.Item>
            <Stack.Item ml={-1}>
              <Icon color="green" name="smile" size={10} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item fontSize="18px">
          Kliknij kanał, żeby zacząć rozmowę!
        </Stack.Item>
        <Stack.Item fontSize="15px">
          (Jeśli jesteś tu nowy, ustaw swoją nazwę w lewym dolnym rogu!)
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

export const NtosNetChat = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    title,
    can_admin,
    adminmode,
    authed,
    username,
    active_channel,
    is_operator,
    strong,
    selfref,
    all_channels = [],
    clients = [],
    messages = [],
    PC_device_theme,
  } = data;
  const in_channel = active_channel !== null && active_channel !== undefined;
  const authorized = authed || adminmode;
  // Kolejność: operator > status > alfabetycznie
  const displayed_clients = [...clients].sort(
    (clientA, clientB) =>
      Number(!!clientB.operator) - Number(!!clientA.operator) ||
      clientB.status - clientA.status ||
      clientA.name.localeCompare(clientB.name),
  );
  const client_color = (client: Client) => {
    if (client.operator) {
      return 'green';
    }
    switch (client.status) {
      case CLIENT_ONLINE:
        return 'white';
      case CLIENT_AWAY:
        return 'yellow';
      default:
        return 'label';
    }
  };
  // klient z tego komputera
  const this_client = clients.find((client) => client.ref === selfref);

  return (
    <NtosWindow width={1000} height={675}>
      <NtosWindow.Content>
        <Stack fill>
          <Stack.Item>
            <Section fill>
              <Stack vertical fill>
                <Stack.Item grow>
                  <Button.Input
                    fluid
                    buttonText="Nowy kanał..."
                    onCommit={(value) =>
                      act('PRG_newchannel', {
                        new_channel_name: value,
                      })
                    }
                  />
                  {all_channels.map((channel) => (
                    <Button
                      fluid
                      key={channel.id}
                      selected={channel.id === active_channel}
                      color="transparent"
                      onClick={() =>
                        act('PRG_joinchannel', {
                          id: channel.id,
                        })
                      }
                    >
                      {channel.chan}
                    </Button>
                  ))}
                </Stack.Item>
                <Stack.Item>
                  <Box>Nazwa użytkownika:</Box>
                  <Button.Input
                    fluid
                    mt={1}
                    buttonText={`${username}...`}
                    value={username}
                    onCommit={(value) =>
                      act('PRG_changename', {
                        new_name: value,
                      })
                    }
                  />
                  {!!can_admin && (
                    <Button
                      fluid
                      bold
                      color={adminmode ? 'bad' : 'good'}
                      onClick={() => act('PRG_toggleadmin')}
                    >
                      {`TRYB ADMINA: ${adminmode ? 'WŁ.' : 'WYŁ.'}`}
                    </Button>
                  )}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow={4}>
            <Stack fill vertical g={0}>
              <Stack.Item grow>
                <Section scrollable fill>
                  {(in_channel &&
                    (authorized ? (
                      messages.map((message, i) => (
                        <Box key={i}>{message.msg}</Box>
                      ))
                    ) : (
                      <Box textAlign="center">
                        <Icon
                          name="exclamation-triangle"
                          mt={4}
                          fontSize="40px"
                        />
                        <Box mt={1} bold fontSize="18px">
                          TEN KANAŁ JEST CHRONIONY HASŁEM
                        </Box>
                        <Box mt={1}>PODAJ HASŁO, ABY WEJŚĆ</Box>
                      </Box>
                    ))) ||
                    // AQUILA: klasyczny motyw Thinktronic nie ma miejsca na wygaszacz
                    (PC_device_theme !== 'thinktronic-classic' && (
                      <NoChannelDimmer />
                    ))}
                </Section>
              </Stack.Item>
              {!!in_channel && (
                <Input
                  backgroundColor={this_client?.muted ? 'red' : undefined}
                  height="22px"
                  placeholder={
                    this_client?.muted
                      ? 'Jesteś wyciszony!'
                      : `Wiadomość na ${title}`
                  }
                  fluid
                  selfClear
                  mt={1}
                  disabled={!!this_client?.muted}
                  onEnter={(value) =>
                    act('PRG_speak', {
                      message: value,
                    })
                  }
                />
              )}
            </Stack>
          </Stack.Item>
          {!!in_channel && (
            <>
              <Stack.Divider />
              <Stack.Item grow={2}>
                <Stack vertical fill>
                  <Stack.Item grow>
                    <Section scrollable fill>
                      <Stack vertical>
                        {displayed_clients.map((client) => (
                          <Stack height="18px" fill key={client.ref}>
                            <Stack.Item
                              basis={0}
                              grow
                              color={client_color(client)}
                            >
                              {client.name}
                            </Stack.Item>
                            {client !== this_client && (
                              <>
                                <Stack.Item>
                                  <Button
                                    disabled={!!this_client?.muted}
                                    compact
                                    icon="bullhorn"
                                    tooltip={
                                      this_client?.muted
                                        ? 'Jesteś wyciszony!'
                                        : 'Zaczep'
                                    }
                                    tooltipPosition="left"
                                    onClick={() =>
                                      act('PRG_ping_user', {
                                        ref: client.ref,
                                      })
                                    }
                                  />
                                </Stack.Item>
                                {!!is_operator && (
                                  <Stack.Item>
                                    <Button
                                      compact
                                      icon={
                                        client.muted
                                          ? 'volume-mute'
                                          : 'volume-up'
                                      }
                                      color={client.muted ? 'red' : 'green'}
                                      tooltip={
                                        client.muted
                                          ? 'Cofnij wyciszenie'
                                          : 'Wycisz użytkownika'
                                      }
                                      tooltipPosition="left"
                                      onClick={() =>
                                        act('PRG_mute_user', {
                                          ref: client.ref,
                                        })
                                      }
                                    />
                                  </Stack.Item>
                                )}
                              </>
                            )}
                          </Stack>
                        ))}
                      </Stack>
                    </Section>
                  </Stack.Item>
                  <Section>
                    <Stack vertical g={0.5}>
                      <Stack.Item>Ustawienia kanału {title}:</Stack.Item>
                      {!!(in_channel && authorized) && (
                        <>
                          <Button.Input
                            fluid
                            buttonText="Zapisz log jako..."
                            onCommit={(value) =>
                              act('PRG_savelog', {
                                log_name: value,
                              })
                            }
                          />
                          <Button.Confirm
                            fluid
                            confirmContent="Na pewno?"
                            onClick={() => act('PRG_leavechannel')}
                          >
                            Opuść kanał
                          </Button.Confirm>
                        </>
                      )}
                      {!!(is_operator && authed) && (
                        <>
                          <Button.Confirm
                            fluid
                            disabled={!!strong}
                            confirmContent="Na pewno?"
                            onClick={() => act('PRG_deletechannel')}
                          >
                            Usuń kanał
                          </Button.Confirm>
                          <Button.Input
                            fluid
                            disabled={!!strong}
                            buttonText="Zmień nazwę kanału..."
                            onCommit={(value) =>
                              act('PRG_renamechannel', {
                                new_name: value,
                              })
                            }
                          />
                          <Button.Input
                            fluid
                            buttonText="Ustaw hasło..."
                            onCommit={(value) =>
                              act('PRG_setpassword', {
                                new_password: value,
                              })
                            }
                          />
                        </>
                      )}
                    </Stack>
                  </Section>
                </Stack>
              </Stack.Item>
            </>
          )}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
