// AQUILA - ankiety graczy z bazy (code/modules/mob/dead/new_player/poll.dm), zamiast dawnych okien HTML
import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const POLLTYPE_OPTION = 'OPTION';
const POLLTYPE_TEXT = 'TEXT';
const POLLTYPE_RATING = 'NUMVAL';
const POLLTYPE_MULTI = 'MULTICHOICE';
const POLLTYPE_IRV = 'IRV';

const TYPE_NAMES: Record<string, string> = {
  [POLLTYPE_OPTION]: 'Jednokrotny wybór',
  [POLLTYPE_TEXT]: 'Odpowiedź tekstowa',
  [POLLTYPE_RATING]: 'Ocena',
  [POLLTYPE_MULTI]: 'Wielokrotny wybór',
  [POLLTYPE_IRV]: 'Ranking',
};

const MAX_REPLY_LENGTH = 2048;

type PollEntry = {
  ref: string;
  question: string;
  type: string;
};

type PollOption = {
  ref: string;
  text: string;
  min_val: number;
  max_val: number;
  desc_min: string;
  desc_mid: string;
  desc_max: string;
};

type SelectedPoll = {
  ref: string;
  question: string;
  subtitle: string | null;
  type: string;
  start: string;
  end: string;
  allow_revoting: boolean;
  options_allowed: number;
  minimum_playtime: number;
  options: PollOption[];
  has_voted: boolean;
  vote: any;
};

type Data = {
  polls: PollEntry[];
  selected: SelectedPoll | null;
};

export const PlayerPolls = (_) => {
  const { data } = useBackend<Data>();
  const { selected } = data;
  return (
    <Window width={520} height={600}>
      <Window.Content scrollable>
        {selected ? (
          <PollView key={selected.ref} poll={selected} />
        ) : (
          <PollList />
        )}
      </Window.Content>
    </Window>
  );
};

const PollList = () => {
  const { act, data } = useBackend<Data>();
  const { polls = [] } = data;
  return (
    <Section title="Ankiety graczy">
      {polls.length === 0 ? (
        <NoticeBox>Nie ma teraz żadnych ankiet.</NoticeBox>
      ) : (
        <Stack vertical>
          {polls.map((poll) => (
            <Stack.Item key={poll.ref}>
              <Button
                fluid
                icon="poll"
                tooltip={TYPE_NAMES[poll.type]}
                onClick={() => act('select', { ref: poll.ref })}
              >
                {poll.question}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

type PollProps = {
  poll: SelectedPoll;
};

const PollView = (props: PollProps) => {
  const { act } = useBackend<Data>();
  const { poll } = props;
  const locked = poll.has_voted && !poll.allow_revoting;
  return (
    <>
      <Section
        title="Ankieta"
        buttons={
          <Button icon="arrow-left" onClick={() => act('back')}>
            Wróć do listy
          </Button>
        }
      >
        <Box bold fontSize="1.1em" mb={1}>
          {poll.question}
        </Box>
        {!!poll.subtitle && <Box mb={1}>{poll.subtitle}</Box>}
        <LabeledList>
          <LabeledList.Item label="Rodzaj">
            {TYPE_NAMES[poll.type] || poll.type}
          </LabeledList.Item>
          <LabeledList.Item label="Trwa">
            od {poll.start} do {poll.end}
          </LabeledList.Item>
          {poll.minimum_playtime > 0 && (
            <LabeledList.Item label="Wymagany czas gry">
              {poll.minimum_playtime} godz.
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Zmiana głosu">
            {poll.allow_revoting ? 'dozwolona' : 'niedozwolona'}
          </LabeledList.Item>
        </LabeledList>
        {!!poll.has_voted && (
          <NoticeBox info mt={1} mb={0}>
            {locked
              ? 'Już głosowałeś w tej ankiecie. Poniżej twój głos.'
              : 'Już głosowałeś w tej ankiecie. Możesz zmienić głos.'}
          </NoticeBox>
        )}
      </Section>
      {poll.type === POLLTYPE_OPTION && (
        <OptionVote poll={poll} locked={locked} />
      )}
      {poll.type === POLLTYPE_TEXT && <TextVote poll={poll} locked={locked} />}
      {poll.type === POLLTYPE_RATING && (
        <RatingVote poll={poll} locked={locked} />
      )}
      {poll.type === POLLTYPE_MULTI && (
        <MultiVote poll={poll} locked={locked} />
      )}
      {poll.type === POLLTYPE_IRV && <IrvVote poll={poll} locked={locked} />}
    </>
  );
};

type VoteProps = PollProps & {
  locked: boolean;
};

const VoteButton = (props: {
  disabled: boolean;
  locked: boolean;
  label?: string;
  onClick: () => void;
}) => {
  const { disabled, locked, label = 'Głosuj', onClick } = props;
  if (locked) {
    return null;
  }
  return (
    <Button icon="check" color="good" disabled={disabled} onClick={onClick}>
      {label}
    </Button>
  );
};

const OptionVote = (props: VoteProps) => {
  const { act } = useBackend<Data>();
  const { poll, locked } = props;
  const [choice, setChoice] = useState<string | null>(poll.vote || null);
  return (
    <Section
      title="Wybierz jedną odpowiedź"
      buttons={
        <VoteButton
          locked={locked}
          disabled={!choice}
          onClick={() => act('vote', { ref: poll.ref, option: choice })}
        />
      }
    >
      <Stack vertical>
        {poll.options.map((option) => (
          <Stack.Item key={option.ref}>
            <Button.Checkbox
              fluid
              checked={choice === option.ref}
              disabled={locked}
              onClick={() => setChoice(option.ref)}
            >
              {option.text}
            </Button.Checkbox>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const TextVote = (props: VoteProps) => {
  const { act } = useBackend<Data>();
  const { poll, locked } = props;
  const [text, setText] = useState<string>(poll.vote || '');
  const trimmed = text.trim();
  return (
    <Section
      title="Twoja odpowiedź"
      buttons={
        <VoteButton
          locked={locked}
          label="Wyślij"
          disabled={!trimmed || trimmed.length > MAX_REPLY_LENGTH}
          onClick={() => act('vote', { ref: poll.ref, text: trimmed })}
        />
      }
    >
      {locked ? (
        <Box preserveWhitespace>{poll.vote}</Box>
      ) : (
        <>
          <TextArea
            fluid
            height="220px"
            maxLength={MAX_REPLY_LENGTH}
            value={text}
            placeholder="Napisz tutaj swoją opinię..."
            onChange={setText}
          />
          <Box
            mt={0.5}
            textAlign="right"
            color={text.length > MAX_REPLY_LENGTH ? 'bad' : 'label'}
          >
            {text.length} / {MAX_REPLY_LENGTH}
          </Box>
        </>
      )}
    </Section>
  );
};

const ratingRange = (option: PollOption) => {
  const values: number[] = [];
  for (let rating = option.min_val; rating <= option.max_val; rating++) {
    values.push(rating);
  }
  return values;
};

const ratingDescription = (option: PollOption, rating: number) => {
  const mid = Math.floor((option.max_val + option.min_val) / 2);
  if (option.desc_min && rating === option.min_val) {
    return option.desc_min;
  }
  if (option.desc_mid && rating === mid) {
    return option.desc_mid;
  }
  if (option.desc_max && rating === option.max_val) {
    return option.desc_max;
  }
  return undefined;
};

const RatingVote = (props: VoteProps) => {
  const { act } = useBackend<Data>();
  const { poll, locked } = props;
  const [ratings, setRatings] = useState<Record<string, number>>(() => {
    const saved = poll.vote && !Array.isArray(poll.vote) ? poll.vote : {};
    const initial: Record<string, number> = {};
    for (const option of poll.options) {
      initial[option.ref] = saved[option.ref] ?? option.min_val;
    }
    return initial;
  });
  return (
    <Section
      title="Oceń każdą pozycję"
      buttons={
        <VoteButton
          locked={locked}
          disabled={poll.options.length === 0}
          onClick={() => act('vote', { ref: poll.ref, ratings })}
        />
      }
    >
      <Stack vertical>
        {poll.options.map((option) => (
          <Stack.Item key={option.ref} mb={1}>
            <Box bold mb={0.5}>
              {option.text}
            </Box>
            <Box>
              {ratingRange(option).map((rating) => {
                const description = ratingDescription(option, rating);
                return (
                  <Button
                    key={rating}
                    minWidth="2em"
                    textAlign="center"
                    selected={ratings[option.ref] === rating}
                    disabled={locked && ratings[option.ref] !== rating}
                    tooltip={description}
                    onClick={() =>
                      !locked &&
                      setRatings({ ...ratings, [option.ref]: rating })
                    }
                  >
                    {rating}
                  </Button>
                );
              })}
            </Box>
            {!!(option.desc_min || option.desc_max) && (
              <Box color="label" fontSize="0.9em" mt={0.25}>
                {option.desc_min && `${option.min_val} – ${option.desc_min}`}
                {option.desc_min && option.desc_max && ', '}
                {option.desc_max && `${option.max_val} – ${option.desc_max}`}
              </Box>
            )}
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const MultiVote = (props: VoteProps) => {
  const { act } = useBackend<Data>();
  const { poll, locked } = props;
  const [chosen, setChosen] = useState<string[]>(
    Array.isArray(poll.vote) ? poll.vote : [],
  );
  const limit = poll.options_allowed > 0 ? poll.options_allowed : 0;
  const atLimit = limit > 0 && chosen.length >= limit;
  const toggle = (ref: string) => {
    if (chosen.includes(ref)) {
      setChosen(chosen.filter((entry) => entry !== ref));
    } else if (!atLimit) {
      setChosen([...chosen, ref]);
    }
  };
  return (
    <Section
      title={
        limit > 0 ? `Wybierz do ${limit} odpowiedzi` : 'Wybierz odpowiedzi'
      }
      buttons={
        <VoteButton
          locked={locked}
          disabled={chosen.length === 0}
          onClick={() => act('vote', { ref: poll.ref, options: chosen })}
        />
      }
    >
      <Stack vertical>
        {poll.options.map((option) => {
          const checked = chosen.includes(option.ref);
          return (
            <Stack.Item key={option.ref}>
              <Button.Checkbox
                fluid
                checked={checked}
                disabled={locked || (!checked && atLimit)}
                onClick={() => toggle(option.ref)}
              >
                {option.text}
              </Button.Checkbox>
            </Stack.Item>
          );
        })}
      </Stack>
    </Section>
  );
};

const IrvVote = (props: VoteProps) => {
  const { act } = useBackend<Data>();
  const { poll, locked } = props;
  const [order, setOrder] = useState<string[]>(() => {
    const saved: string[] = Array.isArray(poll.vote) ? poll.vote : [];
    const known = saved.filter((ref) =>
      poll.options.some((option) => option.ref === ref),
    );
    const rest = poll.options
      .map((option) => option.ref)
      .filter((ref) => !known.includes(ref));
    return [...known, ...rest];
  });
  const move = (index: number, offset: number) => {
    const target = index + offset;
    if (target < 0 || target >= order.length) {
      return;
    }
    const next = [...order];
    [next[index], next[target]] = [next[target], next[index]];
    setOrder(next);
  };
  const textOf = (ref: string) =>
    poll.options.find((option) => option.ref === ref)?.text || '';
  return (
    <Section
      title="Ułóż odpowiedzi od najbardziej do najmniej preferowanej"
      buttons={
        <VoteButton
          locked={locked}
          disabled={order.length === 0}
          onClick={() => act('vote', { ref: poll.ref, order })}
        />
      }
    >
      <Box color="label" textAlign="center" mb={0.5}>
        Najbardziej preferowane
      </Box>
      <Stack vertical>
        {order.map((ref, index) => (
          <Stack.Item key={ref}>
            <Stack align="center">
              <Stack.Item width="2em" textAlign="right" color="label">
                {index + 1}.
              </Stack.Item>
              <Stack.Item grow>{textOf(ref)}</Stack.Item>
              {!locked && (
                <Stack.Item>
                  <Button
                    icon="arrow-up"
                    tooltip="Wyżej"
                    disabled={index === 0}
                    onClick={() => move(index, -1)}
                  />
                  <Button
                    icon="arrow-down"
                    tooltip="Niżej"
                    disabled={index === order.length - 1}
                    onClick={() => move(index, 1)}
                  />
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
      <Box color="label" textAlign="center" mt={0.5}>
        Najmniej preferowane
      </Box>
    </Section>
  );
};
