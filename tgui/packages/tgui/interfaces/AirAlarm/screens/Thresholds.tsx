import { Button, Table } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { ENV_NAMES } from '../AlarmStatus';
import type { AirAlarmData, ThresholdVar } from '../types';
import { useAlarmModal } from '../useModal';

const COLUMNS: { typeVar: ThresholdVar; typeName: string }[] = [
  { typeVar: 'min2', typeName: 'Zagrożenie poniżej' },
  { typeVar: 'min1', typeName: 'Ostrzeżenie poniżej' },
  { typeVar: 'max1', typeName: 'Ostrzeżenie powyżej' },
  { typeVar: 'max2', typeName: 'Zagrożenie powyżej' },
];

// AQUILA: progi gazów w naszym DM liczone są z ciśnienia cząstkowego.
const getUnit = (name: string) => {
  if (name === 'Temperature') return 'K';
  return 'kPa';
};

export function AirAlarmControlThresholds(props) {
  const { act, data } = useBackend<AirAlarmData>();
  const [, setActiveModal] = useAlarmModal();
  const { thresholds = [] } = data;

  return (
    <Table>
      <Table.Row>
        <Table.Cell bold>Próg</Table.Cell>
        <Table.Cell bold color="bad">
          Zagrożenie poniżej
        </Table.Cell>
        <Table.Cell bold color="average">
          Ostrzeżenie poniżej
        </Table.Cell>
        <Table.Cell bold color="average">
          Ostrzeżenie powyżej
        </Table.Cell>
        <Table.Cell bold color="bad">
          Zagrożenie powyżej
        </Table.Cell>
      </Table.Row>
      {thresholds.map((threshold) => {
        const unit = getUnit(threshold.name);
        const name = ENV_NAMES[threshold.name] || threshold.name;
        return (
          <Table.Row key={threshold.name} className="candystripe">
            <Table.Cell>{name}</Table.Cell>
            {COLUMNS.map((column) => {
              const setting = threshold.settings.find(
                (s) => s.val === column.typeVar,
              );
              if (!setting) {
                return <Table.Cell key={column.typeVar} />;
              }
              return (
                <Table.Cell key={column.typeVar}>
                  <Button
                    fluid
                    onClick={() =>
                      setActiveModal({
                        env: setting.env,
                        name,
                        typeVar: column.typeVar,
                        typeName: column.typeName,
                        unit,
                        finish: () => setActiveModal(undefined),
                      })
                    }
                  >
                    {setting.selected === -1
                      ? 'Wył.'
                      : `${setting.selected} ${unit}`}
                  </Button>
                </Table.Cell>
              );
            })}
          </Table.Row>
        );
      })}
    </Table>
  );
}
