/**
 * @file
 * @author Original by ArcaneMusic (https://github.com/ArcaneMusic)
 * @author Changes Shadowh4nD/jlsnow301
 * @author Ported by itsmeow
 * @license MIT
 *
 * AQUILA: zostaje nasz port (aquila/code/game/machinery/newscaster) — ma
 * edycję kanałów, edycję listu gończego, tryb admina/pAI i override_bg,
 * których wersja z tg nie obsługuje. Teksty przetłumaczone.
 */

import { marked } from 'marked';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend, useLocalState } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Icon,
  Image,
  Input,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  TextArea,
} from '../components';
import { sanitizeText } from '../sanitize';
import { BountyBoardContent } from './BountyBoard';

const CENSOR_MESSAGE =
  'Ten kanał uznano za zagrożenie dla dobra stacji \
  i objęto go zakazem publikacji Nanotrasen (D-Notice).';

export const Newscaster = (props) => {
  const { override_bg } = props;
  const { data } = useBackend();
  const { user } = data;
  const NEWSCASTER_SCREEN = 1;
  const BOUNTYBOARD_SCREEN = 2;
  const [screenmode, setScreenmode] = useLocalState(
    'tab_main',
    NEWSCASTER_SCREEN,
  );
  return (
    <>
      <NewscasterChannelCreation override_bg={override_bg} />
      <NewscasterChannelEditing override_bg={override_bg} />
      <NewscasterCommentCreation override_bg={override_bg} />
      <NewscasterWantedScreen override_bg={override_bg} />
      <Stack fill vertical>
        {!user?.admin && !user?.pai && (
          <Stack.Item>
            <Tabs fluid textAlign="center">
              <Tabs.Tab
                color="Green"
                selected={screenmode === NEWSCASTER_SCREEN}
                onClick={() => setScreenmode(NEWSCASTER_SCREEN)}
              >
                Wiadomości
              </Tabs.Tab>
              <Tabs.Tab
                Color="Blue"
                selected={screenmode === BOUNTYBOARD_SCREEN}
                onClick={() => setScreenmode(BOUNTYBOARD_SCREEN)}
              >
                Tablica zleceń
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
        )}
        <Stack.Item grow>
          {screenmode === NEWSCASTER_SCREEN && <NewscasterContent />}
          {screenmode === BOUNTYBOARD_SCREEN && <BountyBoardContent />}
        </Stack.Item>
      </Stack>
    </>
  );
};

const NewscasterChannelModal = ({ header, submit_content, override_bg }) => {
  const {
    act,
    data: {
      editor: { channelName, channelDesc, channelLocked },
    },
  } = useBackend();
  const modalStyle = { border: '1px solid #2c4461' };
  return (
    <Modal
      textAlign="center"
      mr={1.5}
      pt={0}
      style={modalStyle}
      backgroundColor={override_bg}
      width="350px"
    >
      <h2>{header}</h2>
      <Stack vertical fill>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Box inline color="label">
                Nazwa kanału:{' '}
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Input
                id="create_channel_name"
                width="100%"
                maxLength={42}
                onBlur={(name) =>
                  act('setChannelName', {
                    channeltext: name,
                  })
                }
                value={channelName}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Box inline color="label">
                Dostęp:{' '}
              </Box>
            </Stack.Item>
            <Stack.Item grow textAlign="left">
              <Button
                selected={!channelLocked}
                content="Publiczny"
                onClick={() =>
                  act('setChannelLocked', { channellocked: false })
                }
              />
              <Button
                selected={!!channelLocked}
                content="Prywatny"
                onClick={() => act('setChannelLocked', { channellocked: true })}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Box inline color="label">
                Opis kanału
              </Box>
            </Stack.Item>
            <Stack.Item grow basis="content">
              <TextArea
                id="create_channel_desc"
                height="150px"
                width="100%"
                maxLength={512}
                onBlur={(desc) =>
                  act('setChannelDesc', {
                    channeldesc: desc,
                  })
                }
                value={channelDesc}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              content={submit_content}
              onClick={() => act('createChannel')}
            />
            <Button
              content="Anuluj"
              color="red"
              onClick={() => act('cancelCreation')}
            />
          </Box>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

/** The modal menu that contains the prompts to making new channels. */
const NewscasterChannelCreation = (props) => {
  const { override_bg } = props;
  const {
    data: { creating_channel },
  } = useBackend();
  if (!creating_channel) {
    return null;
  }
  return (
    <NewscasterChannelModal
      override_bg={override_bg}
      header="Nowy kanał"
      submit_content="Utwórz kanał"
      default_locked
    />
  );
};

const NewscasterChannelEditing = (props) => {
  const { override_bg } = props;
  const {
    data: { creating_channel, editing_channel },
  } = useBackend();
  if (creating_channel || !editing_channel) {
    return null;
  }
  return (
    <NewscasterChannelModal
      override_bg={override_bg}
      header="Edycja kanału"
      submit_content="Zapisz zmiany"
    />
  );
};

/** The modal menu that contains the prompts to making new comments. */
const NewscasterCommentCreation = (props) => {
  const { override_bg } = props;
  const { act, data } = useBackend();
  const { creating_comment, viewing_message } = data;
  if (!creating_comment) {
    return null;
  }
  return (
    <Modal textAlign="center" backgroundColor={override_bg} mr={1.5}>
      <Stack vertical>
        <Stack.Item>
          <Box pb={1}>
            Wpisz komentarz:
            <Button
              icon="times"
              color="red"
              position="relative"
              top="20%"
              left="25%"
              onClick={() => act('cancelCreation')}
            />
          </Box>
          <TextArea
            fluid
            height="120px"
            width="240px"
            backgroundColor="black"
            textColor="white"
            maxLength={512}
            onBlur={(comment) =>
              act('setCommentBody', {
                commenttext: comment,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              content={'Dodaj komentarz'}
              onClick={() =>
                act('createComment', {
                  messageID: viewing_message,
                })
              }
            />
          </Box>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

const NewscasterWantedScreen = (props) => {
  const { override_bg } = props;
  const { act, data } = useBackend();
  const {
    viewing_wanted,
    editing_wanted,
    photo_data,
    security_mode,
    wanted = [],
    criminal_name,
    crime_description,
  } = data;
  if (!viewing_wanted && !editing_wanted) {
    return null;
  }
  return (
    <Modal textAlign="center" backgroundColor={override_bg} mr={1.5} width={25}>
      {!editing_wanted
        ? wanted
            .filter((wanted) => wanted.criminal)
            .map((activeWanted) => (
              <>
                <Stack vertical>
                  <Stack.Item>
                    <Box bold color="red" mb={1}>
                      {activeWanted.active
                        ? 'Aktywny list gończy'
                        : 'Odwołany list gończy'}
                    </Box>
                    <Section>
                      {activeWanted.has_image ? (
                        <Image src={activeWanted.image} />
                      ) : null}
                      <Box bold>{activeWanted.criminal}</Box>
                      <Box italic>{activeWanted.crime}</Box>
                    </Section>
                    <Box italic>
                      Opublikował(a){' '}
                      {activeWanted.author ? activeWanted.author : 'b.d.'}
                    </Box>
                  </Stack.Item>
                </Stack>
                <Divider />
                <Button
                  content="Zamknij"
                  color="red"
                  onClick={() => act('cancelCreation')}
                />
              </>
            ))
        : null}
      {security_mode && editing_wanted ? (
        <>
          <LabeledList>
            <LabeledList.Item label="Poszukiwany">
              <Button
                content={criminal_name ? criminal_name : ' b.d.'}
                disabled={!security_mode}
                icon="pen"
                onClick={() => act('setCriminalName')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Przestępstwa">
              <Button
                content={crime_description ? crime_description : ' b.d.'}
                nowrap={false}
                disabled={!security_mode}
                icon="pen"
                onClick={() => act('setCrimeData')}
              />
            </LabeledList.Item>
          </LabeledList>
          <Button
            mt={1}
            mb={1}
            icon="camera"
            selected={photo_data}
            disabled={!security_mode}
            content={photo_data ? 'Usuń zdjęcie' : 'Zeskanuj zdjęcie'}
            onClick={() => act('togglePhoto')}
          />
          <Section>
            <Button
              content="Opublikuj"
              disabled={!security_mode}
              color="green"
              icon="volume-up"
              onClick={() => act('submitWantedIssue')}
            />
            <Button
              content="Anuluj"
              disabled={!security_mode}
              icon="times"
              color="red"
              onClick={() => act('cancelCreation')}
            />
          </Section>
        </>
      ) : null}
    </Modal>
  );
};

export const UserDetails = (_) => {
  const { data } = useBackend();
  const { user } = data;

  if (!user.authenticated) {
    return (
      <NoticeBox>
        Nie wykryto karty ID! Skontaktuj się z kierownikiem kadr.
      </NoticeBox>
    );
  } else {
    return (
      <Section>
        <Stack>
          <Stack.Item>
            <Icon name="id-card" size={3} mr={1} />
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Użytkownik">
                {user.name}
              </LabeledList.Item>
              <LabeledList.Item label="Stanowisko">{user.job}</LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
};

const NewscasterContent = (_) => {
  const { data } = useBackend();
  const { current_channel = {} } = data;
  return (
    <>
      <Stack>
        <Stack.Item grow basis="content">
          <NewscasterChannelSelector />
        </Stack.Item>
        <Stack.Item grow basis="content" style={{ width: '100%' }}>
          <Stack fill vertical>
            <Stack.Item>
              <UserDetails />
            </Stack.Item>
            <Stack.Item grow basis="content">
              <NewscasterChannelBox
                channelName={current_channel.name}
                channelOwner={current_channel.owner}
                channelDesc={current_channel.desc}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      <NewscasterChannelMessages />
    </>
  );
};

/** The Channel Box is the basic channel information where buttons live.*/
const NewscasterChannelBox = (_) => {
  const { act, data } = useBackend();
  const {
    channelName,
    channelDesc,
    channelLocked,
    channelAuthor,
    channelCensored,
    viewing_channel,
    security_mode,
    photo_data,
    paper,
    user,
  } = data;
  return (
    <Section
      fill
      title={channelName}
      buttons={
        user.name === channelAuthor || user.admin ? (
          <Button
            icon="pen"
            content="Edytuj kanał"
            onClick={() =>
              act('startEditChannel', { current: viewing_channel })
            }
          />
        ) : null
      }
    >
      <Stack fill vertical>
        <Stack.Item grow basis="content">
          {channelCensored ? (
            <Section>
              <BlockQuote color="red">
                <b>UWAGA:</b> {CENSOR_MESSAGE}
              </BlockQuote>
            </Section>
          ) : (
            <Box width="100%" height="100%" style={{ overflowY: 'auto' }}>
              <BlockQuote italic fontSize={1.2}>
                {decodeHtmlEntities(channelDesc)}
              </BlockQuote>
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              icon="print"
              content="Dodaj artykuł"
              disabled={
                (channelLocked && channelAuthor !== user.name && !user.admin) ||
                channelCensored
              }
              onClick={() => act('createStory', { current: viewing_channel })}
              mt={1}
            />
            <Button
              icon="camera"
              selected={photo_data}
              content="Zeskanuj zdjęcie"
              disabled={
                (channelLocked && channelAuthor !== user.name && !user.admin) ||
                channelCensored
              }
              onClick={() => act('togglePhoto')}
            />
            {!!security_mode && (
              <Button
                icon="ban"
                content={channelCensored ? 'Zdejmij D-Notice' : 'D-Notice'}
                color={channelCensored ? 'red' : null}
                tooltip="Ocenzuruj cały kanał i jego \
                  treść jako groźne dla stacji."
                disabled={!security_mode || !viewing_channel}
                onClick={() =>
                  act('channelDNotice', {
                    secure: security_mode,
                    channel: viewing_channel,
                  })
                }
              />
            )}
          </Box>
          <Box>
            <Button
              icon="newspaper"
              content="Drukuj gazetę"
              disabled={user.silicon || paper <= 0}
              tooltip={paper <= 0 ? 'Włóż papier.' : null}
              onClick={() => act('printNewspaper')}
            />
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Channel select is the left-hand menu where all the channels are listed. */
const NewscasterChannelSelector = (_) => {
  const { act, data } = useBackend();
  const {
    channels = [],
    viewing_channel,
    wanted = [],
    user,
    security_mode,
  } = data;
  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item grow basis="content">
          <Tabs vertical>
            {wanted
              .filter((wanted) => wanted.criminal)
              .map((activeWanted) => (
                <Tabs.Tab
                  pt={0.75}
                  pb={0.75}
                  mr={1}
                  key={activeWanted.index}
                  icon={activeWanted.active ? 'skull-crossbones' : null}
                  textColor={activeWanted.active ? 'red' : 'grey'}
                  onClick={() => act('showWanted')}
                >
                  List gończy
                </Tabs.Tab>
              ))}
            {channels.map((channel) => (
              <Tabs.Tab
                key={channel.index}
                pt={0.75}
                pb={0.75}
                mr={1}
                selected={viewing_channel === channel.ID}
                icon={channel.censored ? 'ban' : null}
                textColor={channel.censored ? 'red' : 'white'}
                onClick={() =>
                  act('setChannel', {
                    channel: channel.ID,
                  })
                }
              >
                {channel.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Item>
          <Button
            fill
            width="100%"
            color="green"
            onClick={() => act('startCreateChannel')}
            content="Nowy kanał"
            icon="plus-square"
            disabled={!user.authenticated}
          />
        </Stack.Item>
        {!!security_mode && (
          <>
            <Stack.Item>
              <Button
                fill
                width="100%"
                color="red"
                onClick={() => act('editWanted')}
                content="Edytuj list gończy"
                icon="pen"
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fill
                width="100%"
                color="red"
                content="Usuń list gończy"
                icon="times"
                onClick={() => act('clearWantedIssue')}
              />
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};

const processedText = (value) => {
  const textHtml = {
    __html: sanitizeText(
      // marked 15 dropped smartypants/smartLists/baseUrl options
      marked.parse(value, { breaks: true, async: false }),
    ),
  };
  return textHtml;
};

/** This is where the channels comments get spangled out (tm) */
const NewscasterChannelMessages = (_) => {
  const { act, data } = useBackend();
  const {
    messages = [],
    viewing_channel,
    security_mode,
    channelCensored,
    channelLocked,
    channelAuthor,
    user,
  } = data;
  if (channelCensored) {
    return (
      <Section style={{ marginTop: '0.5em' }} color="red">
        <b>UWAGA:</b> Komentarzy nie można teraz przeczytać.
        <br />
        Dziękujemy za wyrozumiałość i życzymy bezpiecznego dnia.
      </Section>
    );
  }
  const visibleMessages = messages.filter(
    (message) => message.ID !== viewing_channel,
  );

  return (
    <Box style={{ marginTop: '0.5em' }}>
      {visibleMessages.map((message) => {
        return (
          <Section
            key={message.index}
            textColor="white"
            style={{ marginTop: '0.5em' }}
            title={
              <i>
                {message.censored_author ? (
                  <Box inline color="red" style={{ display: 'inline' }}>
                    Autor: [UTAJNIONO] (D-Notice)
                  </Box>
                ) : (
                  <>
                    Autor: {message.auth}, {message.time}
                  </>
                )}
              </i>
            }
            buttons={
              <>
                {!!security_mode && (
                  <Button
                    icon="comment-slash"
                    tooltip="Ocenzuruj artykuł"
                    disabled={!security_mode}
                    onClick={() =>
                      act('storyCensor', {
                        messageID: message.ID,
                      })
                    }
                  />
                )}
                {!!security_mode && (
                  <Button
                    icon="user-slash"
                    tooltip="Ocenzuruj autora"
                    disabled={!security_mode}
                    onClick={() =>
                      act('authorCensor', {
                        messageID: message.ID,
                      })
                    }
                  />
                )}
                <Button
                  icon="comment"
                  tooltip="Skomentuj"
                  disabled={
                    message.censored_author ||
                    message.censored_message ||
                    !user?.authenticated ||
                    (!!channelLocked &&
                      channelAuthor !== user?.name &&
                      !user?.admin)
                  }
                  onClick={() =>
                    act('startComment', {
                      messageID: message.ID,
                    })
                  }
                />
              </>
            }
          >
            <BlockQuote>
              {message.censored_message ? (
                <Section textColor="red">
                  Tę wiadomość uznano za groźną dla dobra stacji i objęto
                  zakazem publikacji <b>D-Notice</b>.
                </Section>
              ) : (
                <Section pl={1}>
                  <Box dangerouslySetInnerHTML={processedText(message.body)} />
                </Section>
              )}
              {message.photo !== null && !message.censored_message && (
                <>
                  <Image src={message.photo} />
                  {message.photo_caption && (
                    <Section
                      dangerouslySetInnerHTML={processedText(
                        message.photo_caption,
                      )}
                      pl={1}
                    />
                  )}
                </>
              )}
              {!!message.comments && (
                <Box>
                  {message.comments.map((comment) => (
                    <BlockQuote key={comment.index}>
                      <Box italic textColor="white">
                        Autor: {comment.auth}, {comment.time}
                      </Box>
                      <Section ml={2.5}>
                        <Box
                          dangerouslySetInnerHTML={processedText(comment.body)}
                        />
                      </Section>
                    </BlockQuote>
                  ))}
                </Box>
              )}
            </BlockQuote>
            <Divider />
          </Section>
        );
      })}
    </Box>
  );
};
