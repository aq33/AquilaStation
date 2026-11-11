import type { FC } from 'react';

import { TechwebAnalyzer } from './Analyzer';
import { TechwebDiskMenu } from './disks/DiskMenu';
import { useTechWebRoute } from './hooks';
import { TechwebTree } from './TechTree';

export function TechwebRouter(props) {
  const [techwebRoute] = useTechWebRoute();

  const route = techwebRoute.route;

  let RoutedComponent: FC<any>;
  if (route === 'disk') {
    RoutedComponent = TechwebDiskMenu;
  } else if (route === 'analyzer') {
    // AQUILA: analizator destrukcyjny obsługiwany z konsoli (z NSV13)
    RoutedComponent = TechwebAnalyzer;
  } else {
    // AQUILA: zamiast list zbadanych/dostępnych/przyszłych jest samo drzewko nauki
    RoutedComponent = TechwebTree;
  }

  return <RoutedComponent {...techwebRoute} />;
}
