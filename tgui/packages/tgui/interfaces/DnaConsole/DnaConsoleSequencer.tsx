import type { ReactNode } from 'react';
import { Box, Button, Image, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import {
  type Data,
  GENE_COLORS,
  GENES,
  MUT_NORMAL,
  type Mutation,
  SUBJECT_DEAD,
  SUBJECT_TRANSFORMING,
} from './constants';
import { MutationInfo } from './MutationInfo';

const GenomeImage = (props) => {
  const { url, selected, onClick } = props;
  let outline;
  if (selected) {
    outline = '2px solid #22aa00';
  }
  return (
    <Box
      inline
      position="relative"
      style={{ margin: '2px', marginLeft: '4px' }}
    >
      <Image
        src={url}
        style={{
          width: '64px',
          display: 'block',
          outline,
        }}
        onClick={onClick}
      />
    </Box>
  );
};

/**
 * Nasz DM przyjmuje w pulse_gene docelową literę (`gene`), a nie
 * `pulseAction` jak w tg, więc kolejną literę liczymy tutaj.
 */
const GeneCycler = (props) => {
  const { gene, onChange, disabled, ...rest } = props;
  const length = GENES.length;
  const index = GENES.indexOf(gene);
  const color = (disabled && GENE_COLORS.X) || GENE_COLORS[gene];
  return (
    <Button
      {...rest}
      color={color}
      onClick={(e) => {
        e.preventDefault();
        if (!onChange) {
          return;
        }
        if (index === -1) {
          onChange(e, GENES[0]);
          return;
        }
        const nextGene = GENES[(index + 1) % length];
        onChange(e, nextGene);
      }}
      onContextMenu={(e) => {
        e.preventDefault();
        if (!onChange) {
          return;
        }
        if (index === -1) {
          onChange(e, GENES[length - 1]);
          return;
        }
        const prevGene = GENES[(index - 1 + length) % length];
        onChange(e, prevGene);
      }}
    >
      {gene}
    </Button>
  );
};

function isPairMatched(sequence: string, index: number) {
  const gene1 = sequence.charAt(index);
  const gene2 = sequence.charAt(index + 1);
  return (
    (gene1 === 'A' && gene2 === 'T') ||
    (gene1 === 'T' && gene2 === 'A') ||
    (gene1 === 'G' && gene2 === 'C') ||
    (gene1 === 'C' && gene2 === 'G')
  );
}

function buildGenomePairs(
  sequence: string,
  renderGene: (i: number) => ReactNode,
) {
  const pairs: ReactNode[] = [];
  for (let i = 0; i < sequence.length; i += 2) {
    const pair = (
      <Box key={i} inline m={0.5}>
        {renderGene(i)}
        <Box
          mt="-2px"
          ml="10px"
          width="3px"
          height="8px"
          backgroundColor={isPairMatched(sequence, i) ? 'label' : 'red'}
        />
        {renderGene(i + 1)}
      </Box>
    );

    if (i % 8 === 0 && i !== 0) {
      pairs.push(
        <Box
          key={`${i}_divider`}
          inline
          position="relative"
          top="-17px"
          left="-1px"
          width="8px"
          height="2px"
          backgroundColor="label"
        />,
      );
    }

    pairs.push(pair);
  }
  return pairs;
}

const GenomeSequencer = (props: { mutation: Mutation | undefined }) => {
  const { mutation } = props;
  const { data, act } = useBackend<Data>();
  const { jokerActive } = data.view;
  if (!mutation) {
    return <Box color="average">Nie wybrano genomu do sekwencjonowania.</Box>;
  }
  if (mutation.Scrambled) {
    return (
      <Box color="average">
        Sekwencja nieczytelna z powodu nieprzewidywalnej mutacji.
      </Box>
    );
  }
  const sequence = mutation.Sequence;
  const defaultSeq = mutation.DefaultSeq;
  const pairs = buildGenomePairs(sequence, (i) => (
    <GeneCycler
      width="22px"
      textAlign="center"
      disabled={!!mutation.Scrambled || mutation.Class !== MUT_NORMAL}
      className={
        defaultSeq?.charAt(i) === 'X' && !mutation.Active
          ? classes(['outline-solid', 'outline-color-orange'])
          : undefined
      }
      gene={sequence.charAt(i)}
      onChange={(e, nextGene) => {
        if (e.ctrlKey) {
          act('pulse_gene', {
            pos: i + 1,
            gene: 'X',
            alias: mutation.Alias,
          });
          return;
        }
        if (jokerActive) {
          act('pulse_gene', {
            pos: i + 1,
            gene: 'J',
            alias: mutation.Alias,
          });
          act('set_view', {
            jokerActive: '',
          });
          return;
        }
        act('pulse_gene', {
          pos: i + 1,
          gene: nextGene,
          alias: mutation.Alias,
        });
      }}
    />
  ));
  return (
    <>
      <Box m={-0.5}>{pairs}</Box>
      <Box color="label" mt={1}>
        <b>Wskazówka:</b> Ctrl+klik ustawia gen na X. Prawy przycisk zmienia gen
        w odwrotnej kolejności.
      </Box>
    </>
  );
};

export const DnaConsoleSequencer = (props) => {
  const { data, act } = useBackend<Data>();
  const mutations = data.storage?.occupant ?? [];
  const { isJokerReady, jokerSeconds, subjectStatus } = data;
  const { sequencerMutation, jokerActive } = data.view;
  const mutation = mutations.find(
    (mutation) => mutation.Alias === sequencerMutation,
  );
  return (
    <>
      <Stack mb={1}>
        <Stack.Item width={(mutations.length <= 8 && '154px') || '174px'}>
          <Section
            title="Sekwencje"
            height="214px"
            scrollable={mutations.length > 8}
          >
            {mutations.map((mutation) => (
              <GenomeImage
                key={mutation.Alias}
                url={resolveAsset(mutation.Image)}
                selected={mutation.Alias === sequencerMutation}
                onClick={() => {
                  act('set_view', {
                    sequencerMutation: mutation.Alias,
                  });
                  act('check_discovery', {
                    alias: mutation.Alias,
                  });
                }}
              />
            ))}
          </Section>
        </Stack.Item>
        <Stack.Item grow={1} basis={0}>
          <Section title="Informacje o sekwencji" minHeight="100%">
            <MutationInfo mutation={mutation} />
          </Section>
        </Stack.Item>
      </Stack>
      {(subjectStatus === SUBJECT_DEAD && (
        <Section color="bad">
          Sekwencja genetyczna uszkodzona. Raport diagnostyczny obiektu: ZGON.
        </Section>
      )) ||
        (subjectStatus === SUBJECT_TRANSFORMING && (
          <Section color="bad">
            Sekwencja genetyczna uszkodzona. Raport diagnostyczny obiektu:
            TRANSFORMACJA.
          </Section>
        )) || (
          <Section
            title="Sekwenser genomu™"
            buttons={
              (!isJokerReady && (
                <Box lineHeight="20px" color="label">
                  Joker się ładuje ({jokerSeconds}s)
                </Box>
              )) ||
              (jokerActive && (
                <>
                  <Box mr={1} inline color="label">
                    Kliknij gen, aby go odkryć.
                  </Box>
                  <Button
                    onClick={() =>
                      act('set_view', {
                        jokerActive: '',
                      })
                    }
                  >
                    Anuluj jokera
                  </Button>
                </>
              )) || (
                <Button
                  icon="crown"
                  color="purple"
                  onClick={() =>
                    act('set_view', {
                      jokerActive: '1',
                    })
                  }
                >
                  Użyj jokera
                </Button>
              )
            }
          >
            <GenomeSequencer mutation={mutation} />
          </Section>
        )}
    </>
  );
};
