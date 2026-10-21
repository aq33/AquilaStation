import { useEffect, useState } from 'react';
import { Icon, Input, Tabs } from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

// AQUILA EDIT - wygląd z tg; u nas lokalizator nadal namierza też
// radiolatarnie teleportera, więc zostaje przełącznik implanty/radiolatarnie.
type Data = {
  trackimplants: Trackable[];
  telebeacons: Trackable[];
  trackingrange: number;
};

type Trackable = {
  name: string;
  distance: number;
  direction: string;
};

type Mode = 'implant' | 'beacon';

const DIRECTION_TO_ICON = {
  north: 0,
  northeast: 45,
  east: 90,
  southeast: 135,
  south: 180,
  southwest: 225,
  west: 270,
  northwest: 315,
} as const;

export const BluespaceLocator = (props) => {
  const { data } = useBackend<Data>();
  const { trackimplants = [], telebeacons = [], trackingrange } = data;
  const [mode, setMode] = useSharedState<Mode>('mode', 'implant');
  const targets = mode === 'beacon' ? telebeacons : trackimplants;
  const targetIcon = mode === 'beacon' ? 'broadcast-tower' : 'user';

  const [selectedName, setSelectedName] = useState<string | null>(
    targets.length > 0 ? targets[0].name : null,
  );
  const [searchQuery, setSearchQuery] = useState('');
  const [currentRotation, setCurrentRotation] = useState(0);

  const filteredTargets = targets.filter((target) =>
    target.name.toLowerCase().includes(searchQuery.toLowerCase()),
  );

  useEffect(() => {
    if (filteredTargets.length > 0) {
      if (
        !selectedName ||
        !filteredTargets.some((target) => target.name === selectedName)
      ) {
        setSelectedName(filteredTargets[0].name);
      }
    } else {
      setSelectedName(null);
    }
  }, [filteredTargets, selectedName]);

  const selectedTarget =
    filteredTargets.find((target) => target.name === selectedName) ||
    (filteredTargets.length > 0 ? filteredTargets[0] : null);

  useEffect(() => {
    if (selectedTarget) {
      if (selectedTarget.distance === 0) {
        setCurrentRotation(0);
      } else {
        const targetRotation = DIRECTION_TO_ICON[selectedTarget.direction];

        let shortestRotation = targetRotation - currentRotation;
        if (shortestRotation > 180) shortestRotation -= 360;
        if (shortestRotation < -180) shortestRotation += 360;

        setCurrentRotation(currentRotation + shortestRotation);
      }
    }
  }, [selectedTarget?.direction, selectedTarget?.distance]);

  const getArrowColor = (distance: number) => {
    if (distance === 0) return 'green';
    if (distance > (trackingrange * 2) / 3) return 'red';
    if (distance > (trackingrange * 1) / 3) return 'orange';
    return 'green';
  };

  const modeTabs = (
    <Tabs fluid>
      <Tabs.Tab
        icon="user"
        selected={mode === 'implant'}
        onClick={() => setMode('implant')}
      >
        Implanty
      </Tabs.Tab>
      <Tabs.Tab
        icon="broadcast-tower"
        selected={mode === 'beacon'}
        onClick={() => setMode('beacon')}
      >
        Radiolatarnie
      </Tabs.Tab>
    </Tabs>
  );

  if (targets.length === 0) {
    return (
      <Window width={550} height={500}>
        <Window.Content>
          {modeTabs}
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              height: '85%',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '1.2rem',
              opacity: 0.7,
              textAlign: 'center',
              gap: '1rem',
            }}
          >
            <Icon
              name="satellite-dish"
              size={4}
              color="rgba(100, 150, 255, 0.5)"
              style={{ filter: 'blur(1px)' }}
            />
            <div>Nie wykryto sygnatur bluespace</div>
            <div
              style={{
                fontSize: '0.9rem',
                opacity: 0.5,
                maxWidth: '80%',
              }}
            >
              {mode === 'beacon'
                ? 'W zasięgu nie ma żadnej radiolatarni teleportera'
                : 'W zasięgu nie ma żadnych aktywnych implantów śledzących'}
            </div>
          </div>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={550} height={500}>
      <Window.Content>
        <div
          style={{ display: 'flex', flexDirection: 'column', height: '100%' }}
        >
          {modeTabs}
          <div style={{ display: 'flex', flex: 1, minHeight: 0 }}>
            <div
              style={{
                flex: '0 0 170px',
                display: 'flex',
                flexDirection: 'column',
                paddingRight: '2px',
                backgroundColor: 'rgba(10, 15, 25, 0.9)',
              }}
            >
              <div
                style={{
                  padding: '0.5rem',
                  position: 'relative',
                }}
              >
                {!searchQuery && (
                  <Icon
                    name="search"
                    style={{
                      position: 'absolute',
                      left: '1rem',
                      top: '50%',
                      transform: 'translateY(-50%)',
                      zIndex: 1,
                      opacity: 0.6,
                    }}
                  />
                )}
                <Input
                  placeholder="Szukaj celów..."
                  value={searchQuery}
                  onChange={(value) => setSearchQuery(value)}
                  width="100%"
                  style={{
                    paddingLeft: searchQuery ? '0.5rem' : '2rem',
                  }}
                />
              </div>
              <div
                style={{
                  overflowY: 'auto',
                  flex: 1,
                  padding: '0.25rem',
                }}
              >
                {filteredTargets.map((target) => (
                  <div
                    key={target.name}
                    style={{
                      padding: '0.75rem 0.5rem',
                      cursor: 'pointer',
                      backgroundColor:
                        selectedName === target.name
                          ? 'rgba(100, 150, 255, 0.2)'
                          : 'rgba(30, 35, 50, 0.5)',
                      border:
                        selectedName === target.name
                          ? '1px solid rgba(100, 150, 255, 0.5)'
                          : '1px solid rgba(60, 65, 80, 0.5)',
                      borderRadius: '6px',
                      marginBottom: '0.5rem',
                      minHeight: '2.5rem',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.5rem',
                      boxShadow:
                        selectedName === target.name
                          ? '0 0 8px rgba(100, 150, 255, 0.3)'
                          : '0 2px 4px rgba(0, 0, 0, 0.2)',
                      transition: 'all 0.15s ease',
                      position: 'relative',
                      overflow: 'hidden',
                    }}
                    onClick={() => setSelectedName(target.name)}
                  >
                    <Icon
                      name={targetIcon}
                      style={{
                        marginLeft: '8px',
                        opacity: 0.8,
                        color:
                          selectedName === target.name ? '#88ccff' : '#aaa',
                        transition: 'color 0.15s ease',
                      }}
                    />

                    <div
                      style={{
                        fontWeight: 'bold',
                        fontSize: '1rem',
                        color: selectedName === target.name ? '#fff' : '#ccc',
                        transition: 'color 0.15s ease',
                      }}
                    >
                      {target.name}
                    </div>

                    <div
                      style={{
                        marginLeft: 'auto',
                        display: 'flex',
                        gap: '2px',
                      }}
                    >
                      {[1, 2, 3].map((dot) => (
                        <div
                          key={dot}
                          style={{
                            width: '4px',
                            height: '4px',
                            borderRadius: '50%',
                            backgroundColor:
                              target.distance <= (trackingrange / 3) * dot
                                ? getArrowColor(target.distance)
                                : 'rgba(100, 100, 100, 0.3)',
                            transition: 'background-color 0.2s ease',
                          }}
                        />
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div
              style={{
                flex: 1,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                padding: '2rem',
                borderLeft: '1px solid #555',
                backgroundColor: 'rgba(20, 25, 35, 0.7)',
              }}
            >
              {filteredTargets.length === 0 ? (
                <div
                  style={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    textAlign: 'center',
                    opacity: 0.7,
                    fontSize: '1.2rem',
                    gap: '1rem',
                  }}
                >
                  <Icon
                    name="search"
                    size={3}
                    color="rgba(200, 200, 200, 0.5)"
                  />
                  <div>Brak celów pasujących do wyszukiwania</div>
                </div>
              ) : selectedTarget ? (
                <>
                  <Icon
                    name={
                      selectedTarget.distance === 0 ? 'dot-circle' : 'arrow-up'
                    }
                    size={12}
                    rotation={
                      selectedTarget.distance === 0 ? 0 : currentRotation
                    }
                    color={getArrowColor(selectedTarget.distance)}
                    style={{
                      marginBottom: '2rem',
                      transition: 'transform 0.3s ease, color 0.2s ease',
                    }}
                  />
                  <div style={{ textAlign: 'center' }}>
                    <div
                      style={{
                        fontWeight: 'bold',
                        fontSize: '1.3rem',
                      }}
                    >
                      {selectedTarget.name}
                    </div>
                    <div
                      style={{
                        marginTop: '0.75rem',
                        fontSize: '1.1rem',
                      }}
                    >
                      Odległość: {selectedTarget.distance}
                    </div>
                  </div>
                </>
              ) : null}
            </div>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
