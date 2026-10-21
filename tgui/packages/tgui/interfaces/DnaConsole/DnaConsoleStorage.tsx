import { uniqBy } from 'es-toolkit';
import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  type Data,
  type Mutation,
  STORAGE_CONS_SUBMODE_CHROMOSOMES,
  STORAGE_CONS_SUBMODE_MUTATIONS,
  STORAGE_DISK_SUBMODE_ENZYMES,
  STORAGE_DISK_SUBMODE_MUTATIONS,
  STORAGE_MODE_ADVINJ,
  STORAGE_MODE_CONSOLE,
  STORAGE_MODE_DISK,
} from './constants';
import { GeneticMakeupInfo } from './GeneticMakeupInfo';
import { MutationInfo } from './MutationInfo';

export const DnaConsoleStorage = (props) => {
  const { data, act } = useBackend<Data>();
  const { storageMode, storageConsSubMode, storageDiskSubMode } = data.view;
  const { diskMakeupBuffer, diskHasMakeup } = data;
  const mutations = data.storage[storageMode];

  return (
    <Section fill title="Magazyn" buttons={<StorageButtons />}>
      {storageMode === STORAGE_MODE_CONSOLE &&
        storageConsSubMode === STORAGE_CONS_SUBMODE_MUTATIONS && (
          <StorageMutations mutations={mutations} />
        )}
      {storageMode === STORAGE_MODE_CONSOLE &&
        storageConsSubMode === STORAGE_CONS_SUBMODE_CHROMOSOMES && (
          <StorageChromosomes />
        )}
      {storageMode === STORAGE_MODE_DISK &&
        storageDiskSubMode === STORAGE_DISK_SUBMODE_MUTATIONS && (
          <StorageMutations mutations={mutations} />
        )}
      {storageMode === STORAGE_MODE_DISK &&
        storageDiskSubMode === STORAGE_DISK_SUBMODE_ENZYMES && (
          <>
            <GeneticMakeupInfo makeup={diskMakeupBuffer} />
            <Button
              icon="times"
              color="red"
              disabled={!diskHasMakeup}
              onClick={() => act('del_makeup_disk')}
            >
              Usuń
            </Button>
          </>
        )}
      {storageMode === STORAGE_MODE_ADVINJ && <DnaConsoleAdvancedInjectors />}
    </Section>
  );
};

const DnaConsoleAdvancedInjectors = (props) => {
  const { act, data } = useBackend<Data>();
  const { maxAdvInjectors, isInjectorReady } = data;
  const advInjectors = data.storage.injector ?? [];

  return (
    <Section fill title="Zaawansowane iniektory">
      {advInjectors.map((injector, index) => (
        <Collapsible
          key={injector.name}
          title={injector.name}
          buttons={
            <>
              <Button
                icon="syringe"
                disabled={!isInjectorReady}
                onClick={() =>
                  act('print_adv_inj', {
                    name: injector.name,
                  })
                }
              >
                Drukuj
              </Button>
              <Button
                ml={1}
                color="red"
                icon="times"
                tooltip="Usuń iniektor"
                onClick={() =>
                  act('del_adv_inj', {
                    name: injector.name,
                  })
                }
              />
            </>
          }
        >
          <StorageMutations
            mutations={injector.mutations}
            customMode={`advinj${index}`}
          />
        </Collapsible>
      ))}
      <Box mt={2}>
        <Button.Input
          minWidth="200px"
          buttonText="Utwórz nowy iniektor"
          disabled={advInjectors.length >= maxAdvInjectors}
          onCommit={(value) =>
            act('new_adv_inj', {
              name: value,
            })
          }
        />
      </Box>
    </Section>
  );
};

const StorageButtons = (props) => {
  const { data, act } = useBackend<Data>();
  const { hasDisk } = data;
  const { storageMode, storageConsSubMode, storageDiskSubMode } = data.view;

  return (
    <>
      {storageMode === STORAGE_MODE_CONSOLE && (
        <>
          <Button
            selected={storageConsSubMode === STORAGE_CONS_SUBMODE_MUTATIONS}
            onClick={() =>
              act('set_view', {
                storageConsSubMode: STORAGE_CONS_SUBMODE_MUTATIONS,
              })
            }
          >
            Mutacje
          </Button>
          <Button
            selected={storageConsSubMode === STORAGE_CONS_SUBMODE_CHROMOSOMES}
            onClick={() =>
              act('set_view', {
                storageConsSubMode: STORAGE_CONS_SUBMODE_CHROMOSOMES,
              })
            }
          >
            Chromosomy
          </Button>
        </>
      )}
      {storageMode === STORAGE_MODE_DISK && (
        <>
          <Button
            selected={storageDiskSubMode === STORAGE_DISK_SUBMODE_MUTATIONS}
            onClick={() =>
              act('set_view', {
                storageDiskSubMode: STORAGE_DISK_SUBMODE_MUTATIONS,
              })
            }
          >
            Mutacje
          </Button>
          <Button
            selected={storageDiskSubMode === STORAGE_DISK_SUBMODE_ENZYMES}
            onClick={() =>
              act('set_view', {
                storageDiskSubMode: STORAGE_DISK_SUBMODE_ENZYMES,
              })
            }
          >
            Enzymy
          </Button>
        </>
      )}
      <Box inline mr={1} />
      <Button
        selected={storageMode === STORAGE_MODE_CONSOLE}
        onClick={() =>
          act('set_view', {
            storageMode: STORAGE_MODE_CONSOLE,
            storageConsSubMode: STORAGE_CONS_SUBMODE_MUTATIONS,
          })
        }
      >
        Konsola
      </Button>
      <Button
        disabled={!hasDisk}
        selected={storageMode === STORAGE_MODE_DISK}
        onClick={() =>
          act('set_view', {
            storageMode: STORAGE_MODE_DISK,
            storageDiskSubMode: STORAGE_DISK_SUBMODE_MUTATIONS,
          })
        }
      >
        Dysk
      </Button>
      <Button
        selected={storageMode === STORAGE_MODE_ADVINJ}
        onClick={() =>
          act('set_view', {
            storageMode: STORAGE_MODE_ADVINJ,
          })
        }
      >
        Zaaw. iniektor
      </Button>
    </>
  );
};

const StorageChromosomes = (props) => {
  const { data, act } = useBackend<Data>();
  const chromos = data.chromoStorage ?? [];
  const uniqueChromos = uniqBy(chromos, (chromo) => chromo.Name);
  const chromoName = data.view.storageChromoName;
  const chromo = chromos.find((chromo) => chromo.Name === chromoName);

  return (
    <Stack fill>
      <Stack.Item width="140px">
        <Section fill scrollable>
          {uniqueChromos.length === 0 && <Box color="label">Brak danych.</Box>}
          <Tabs vertical>
            {uniqueChromos.map((chromo) => (
              <Tabs.Tab
                className="candystripe"
                key={chromo.Index}
                selected={chromo.Name === chromoName}
                onClick={() =>
                  act('set_view', {
                    storageChromoName: chromo.Name,
                  })
                }
              >
                {chromo.Name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack.Divider />
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Informacje o chromosomie">
          {(!chromo && <Box color="label">Brak danych.</Box>) || (
            <>
              <LabeledList>
                <LabeledList.Item label="Nazwa">
                  {chromo!.Name}
                </LabeledList.Item>
                <LabeledList.Item label="Opis">
                  {chromo!.Description}
                </LabeledList.Item>
                <LabeledList.Item label="Ilość">
                  {chromos.filter((x) => x.Name === chromo!.Name).length}
                </LabeledList.Item>
              </LabeledList>
              <Button
                mt={2}
                icon="eject"
                onClick={() =>
                  act('eject_chromo', {
                    chromo: chromo!.Name,
                  })
                }
              >
                Wysuń chromosom
              </Button>
            </>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

type StorageMutationsProps = {
  mutations: Mutation[] | undefined;
  customMode?: string;
};

const StorageMutations = (props: StorageMutationsProps) => {
  const { customMode = '' } = props;
  const { data, act } = useBackend<Data>();
  const mutations = props.mutations || [];
  const mode = data.view.storageMode + customMode;
  let mutationRef = data.view[`storage${mode}MutationRef`];
  let mutation = mutations.find(
    (mutation) => mutation.ByondRef === mutationRef,
  );
  // If no mutation is selected but there are stored mutations, pick the first
  // mutation and set that as the currently showed one.
  if (!mutation && mutations.length > 0) {
    mutation = mutations[0];
    mutationRef = mutation.ByondRef;
  }

  return (
    <Stack fill>
      <Stack.Item width="140px">
        <Section fill scrollable>
          {mutations.length === 0 && <Box color="label">Brak danych.</Box>}
          <Tabs vertical>
            {mutations.map((mutation) => (
              <Tabs.Tab
                className="candystripe"
                key={mutation.ByondRef}
                selected={mutation.ByondRef === mutationRef}
                onClick={() =>
                  act('set_view', {
                    [`storage${mode}MutationRef`]: mutation.ByondRef,
                  })
                }
              >
                {mutation.Name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack.Divider />
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Informacje o mutacji">
          <MutationInfo mutation={mutation} />
        </Section>
      </Stack.Item>
    </Stack>
  );
};
