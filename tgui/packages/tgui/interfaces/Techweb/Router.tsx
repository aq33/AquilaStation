import type { FC } from 'react';

import { TechwebAnalyzer } from './Analyzer';
import { TechwebDiskMenu } from './disks/DiskMenu';
import { useTechWebRoute } from './hooks';
import { TechwebNodeDetail } from './nodes/detail';
import { TechwebOverview } from './Overview';

export function TechwebRouter(props) {
  const [techwebRoute] = useTechWebRoute();

  const route = techwebRoute.route;

  let RoutedComponent: FC<any>;
  if (route === 'disk') {
    RoutedComponent = TechwebDiskMenu;
  } else if (route === 'details') {
    RoutedComponent = TechwebNodeDetail;
  } else if (route === 'analyzer') {
    // AQUILA: analizator destrukcyjny obsługiwany z konsoli (z NSV13)
    RoutedComponent = TechwebAnalyzer;
  } else {
    RoutedComponent = TechwebOverview;
  }

  return <RoutedComponent {...techwebRoute} />;
}
