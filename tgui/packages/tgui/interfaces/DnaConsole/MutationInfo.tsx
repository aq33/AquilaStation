import { uniqBy } from 'es-toolkit';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  LabeledList,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  CHROMOSOME_NEVER,
  CHROMOSOME_NONE,
  CHROMOSOME_USED,
  CONSOLE_MODE_STORAGE,
  type Data,
  MUT_COLORS,
  MUT_EXTRA,
  type Mutation,
  SOURCE_NAMES,
  SUBJECT_TRANSFORMING,
} from './constants';

/**
 * The following predicate tests if two mutations are functionally
 * the same on the basis of their metadata. Useful if your intent is
 * to prevent "true" duplicates - i.e. mutations with identical metadata.
 */
const isSameMutation = (a: Mutation, b: Mutation) => {
  return a.Alias === b.Alias && a.AppliedChromo === b.AppliedChromo;
};

const ChromosomeInfo = (props: { mutation: Mutation; disabled: boolean }) => {
  const { mutation, disabled } = props;
  const { act } = useBackend<Data>();
  if (mutation.CanChromo === CHROMOSOME_NEVER) {
    return <Box color="label">Brak zgodnych chromosomów.</Box>;
  }
  if (mutation.CanChromo === CHROMOSOME_NONE) {
    if (disabled) {
      return <Box color="label">Nie zastosowano chromosomu.</Box>;
    }
    const validChromos = mutation.ValidStoredChromos ?? [];
    return (
      <>
        <Dropdown
          width="240px"
          options={validChromos}
          disabled={validChromos.length === 0}
          selected={
            validChromos.length === 0
              ? 'Brak pasujących chromosomów'
              : 'Wybierz chromosom'
          }
          onSelected={(e) =>
            act('apply_chromo', {
              chromo: e,
              mutref: mutation.ByondRef,
            })
          }
        />
        <Box color="label" mt={1}>
          Zgodne z: {mutation.ValidChromos}
        </Box>
      </>
    );
  }
  if (mutation.CanChromo === CHROMOSOME_USED) {
    return (
      <Box color="label">Zastosowany chromosom: {mutation.AppliedChromo}</Box>
    );
  }
  return null;
};

type CombinerProps = {
  mutations: Mutation[];
  source: Mutation;
  disabled?: boolean;
};

const MutationCombiner = (props: CombinerProps) => {
  const { mutations = [], source, disabled } = props;
  const { act } = useBackend<Data>();

  const brefFromName = (name) => {
    return mutations.find((mutation) => mutation.Name === name)?.ByondRef;
  };

  return (
    <Dropdown
      key={source.ByondRef}
      width="240px"
      options={mutations.map((mutation) => mutation.Name)}
      disabled={disabled || mutations.length === 0}
      selected="Połącz mutacje"
      onSelected={(value) =>
        act(`combine_${source.Source}`, {
          firstref: brefFromName(value),
          secondref: source.ByondRef,
        })
      }
    />
  );
};

export const MutationInfo = (props: { mutation: Mutation | undefined }) => {
  const { mutation } = props;
  const { data, act } = useBackend<Data>();
  const {
    diskCapacity,
    diskReadOnly,
    hasDisk,
    isInjectorReady,
    isViableSubject,
    subjectStatus,
  } = data;
  const { consoleMode } = data.view;
  const diskMutations = data.storage.disk ?? [];
  const mutationStorage = data.storage.console ?? [];
  const advInjectors = data.storage.injector ?? [];
  if (!mutation) {
    return <Box color="label">Brak danych.</Box>;
  }
  if (mutation.Source === 'occupant' && !mutation.Discovered) {
    return (
      <LabeledList>
        <LabeledList.Item label="Nazwa">{mutation.Alias}</LabeledList.Item>
      </LabeledList>
    );
  }
  const savedToConsole = mutationStorage.find((x) =>
    isSameMutation(x, mutation),
  );
  const savedToDisk = diskMutations.find((x) => isSameMutation(x, mutation));
  const combinedMutations = uniqBy(
    [...diskMutations, ...mutationStorage],
    (mutation) => mutation.Name,
  ).filter((x) => x.Name !== mutation.Name);
  return (
    <>
      <LabeledList>
        <LabeledList.Item label="Nazwa">
          <Box inline color={MUT_COLORS[mutation.Quality]}>
            {mutation.Name}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Opis">{mutation.Description}</LabeledList.Item>
        <LabeledList.Item label="Niestabilność">
          {mutation.Instability}
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Stack vertical>
        <Stack.Item>
          {mutation.Source === 'disk' && (
            <MutationCombiner
              disabled={!hasDisk || diskCapacity <= 0 || diskReadOnly}
              mutations={combinedMutations}
              source={mutation}
            />
          )}
          {mutation.Source === 'console' && (
            <MutationCombiner mutations={combinedMutations} source={mutation} />
          )}
        </Stack.Item>
        {['occupant', 'disk', 'console'].includes(mutation.Source) && (
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                <Dropdown
                  width="240px"
                  options={advInjectors.map((injector) => injector.name)}
                  disabled={advInjectors.length === 0 || !mutation.Active}
                  selected="Dodaj do zaaw. iniektora"
                  onSelected={(value) =>
                    act('add_advinj_mut', {
                      mutref: mutation.ByondRef,
                      advinj: value,
                      source: mutation.Source,
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item>
                <Stack wrap>
                  <Stack.Item>
                    {(consoleMode === CONSOLE_MODE_STORAGE && (
                      <Button
                        icon="exchange-alt"
                        disabled={!isViableSubject || !isInjectorReady}
                        onClick={() =>
                          act('add_mutation', {
                            mutref: mutation.ByondRef,
                            source: mutation.Source,
                          })
                        }
                      >
                        Zmutuj
                      </Button>
                    )) || (
                      <Button
                        icon="exchange-alt"
                        disabled={
                          subjectStatus === SUBJECT_TRANSFORMING ||
                          mutation.Active ||
                          !mutation.Discovered ||
                          !isInjectorReady
                        }
                        onClick={() =>
                          act('activate_mutation', {
                            alias: mutation.Alias,
                          })
                        }
                      >
                        Aktywuj
                      </Button>
                    )}
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="syringe"
                      disabled={!isInjectorReady || !mutation.Active}
                      onClick={() =>
                        act('print_injector', {
                          mutref: mutation.ByondRef,
                          is_activator: 1,
                          source: mutation.Source,
                        })
                      }
                    >
                      Drukuj aktywator
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="syringe"
                      disabled={!isInjectorReady || !mutation.Active}
                      onClick={() =>
                        act('print_injector', {
                          mutref: mutation.ByondRef,
                          is_activator: 0,
                          source: mutation.Source,
                        })
                      }
                    >
                      Drukuj mutator
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="syringe"
                      disabled={!isInjectorReady || !mutation.Active}
                      onClick={() =>
                        act('print_injector', {
                          mutref: mutation.ByondRef,
                          is_nullifier: 1,
                          source: mutation.Source,
                        })
                      }
                    >
                      Drukuj neutralizator
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          <Stack wrap>
            {['disk', 'occupant'].includes(mutation.Source) && (
              <Stack.Item>
                <Button
                  icon="save"
                  disabled={!!savedToConsole || !mutation.Active}
                  onClick={() =>
                    act('save_console', {
                      mutref: mutation.ByondRef,
                      source: mutation.Source,
                    })
                  }
                >
                  Zapisz w konsoli
                </Button>
              </Stack.Item>
            )}
            {['console', 'occupant'].includes(mutation.Source) && (
              <Stack.Item>
                <Button
                  icon="save"
                  disabled={
                    !!savedToDisk ||
                    !hasDisk ||
                    diskCapacity <= 0 ||
                    diskReadOnly ||
                    !mutation.Active
                  }
                  onClick={() =>
                    act('save_disk', {
                      mutref: mutation.ByondRef,
                      source: mutation.Source,
                    })
                  }
                >
                  Zapisz na dysku
                </Button>
              </Stack.Item>
            )}
            {['console', 'disk', 'injector'].includes(mutation.Source) && (
              <Stack.Item>
                <Button
                  icon="times"
                  color="red"
                  onClick={() =>
                    act(`delete_${mutation.Source}_mut`, {
                      mutref: mutation.ByondRef,
                    })
                  }
                >
                  Usuń z {SOURCE_NAMES[mutation.Source] ?? mutation.Source}
                </Button>
              </Stack.Item>
            )}
            {(mutation.Class === MUT_EXTRA ||
              (!!mutation.Scrambled && mutation.Source === 'occupant')) && (
              <Stack.Item>
                <Button
                  onClick={() =>
                    act('nullify', {
                      mutref: mutation.ByondRef,
                    })
                  }
                >
                  Zneutralizuj
                </Button>
              </Stack.Item>
            )}
          </Stack>
          <Divider />
          <ChromosomeInfo
            disabled={mutation.Source !== 'occupant'}
            mutation={mutation}
          />
        </Stack.Item>
      </Stack>
    </>
  );
};
