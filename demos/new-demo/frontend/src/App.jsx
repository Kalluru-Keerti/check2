import { Suspense, lazy } from 'react';
import { Link as RouterLink, Route, Routes, useLocation } from 'react-router-dom';
import {
  Content,
  Header,
  HeaderMenuItem,
  HeaderName,
  HeaderNavigation,
  Loading,
  SkipToContent,
} from '@carbon/react';
import DemoBanner from './components/DemoBanner.jsx';
import './App.scss';

const AnalyzerPage = lazy(() => import('./pages/AnalyzerPage.jsx'));
const RolesPage = lazy(() => import('./pages/RolesPage.jsx'));
const ArchitecturePage = lazy(() => import('./pages/ArchitecturePage.jsx'));

const NAV = [
  { to: '/', label: 'Role-fit analyser' },
  { to: '/roles', label: 'Role catalog' },
  { to: '/architecture', label: 'Architecture' },
];

export default function App() {
  const { pathname } = useLocation();
  return (
    <>
      <Header aria-label="IBM Role-Fit Resume Analyser">
        <SkipToContent />
        <HeaderName as={RouterLink} to="/" prefix="IBM">
          Role-Fit Resume Analyser
        </HeaderName>
        <HeaderNavigation aria-label="Main navigation">
          {NAV.map((item) => (
            <HeaderMenuItem key={item.to} as={RouterLink} to={item.to} isCurrentPage={pathname === item.to}>
              {item.label}
            </HeaderMenuItem>
          ))}
        </HeaderNavigation>
      </Header>
      <Content id="main-content" className="app-content">
        <DemoBanner />
        <Suspense fallback={<Loading withOverlay={false} description="Loading page" />}>
          <Routes>
            <Route path="/" element={<AnalyzerPage />} />
            <Route path="/roles" element={<RolesPage />} />
            <Route path="/architecture" element={<ArchitecturePage />} />
          </Routes>
        </Suspense>
        <footer className="app-footer">Built with IBM watsonx</footer>
      </Content>
    </>
  );
}
