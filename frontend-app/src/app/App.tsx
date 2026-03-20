import { useState } from 'react';
import { LandingPage } from '@/app/components/LandingPage';
import { LoginPage } from '@/app/components/LoginPage';
import { DriverMain } from '@/app/components/driver/DriverMain';
import { RiderMain } from '@/app/components/rider/RiderMain';

type Page = 'landing' | 'login' | 'driver-main' | 'rider-main';

export default function App() {
  const [currentPage, setCurrentPage] = useState<Page>('landing');

  const handleLoginSuccess = (userType: 'rider' | 'driver') => {
    if (userType === 'driver') {
      setCurrentPage('driver-main');
    } else {
      setCurrentPage('rider-main');
    }
  };

  const handleLogout = () => {
    setCurrentPage('landing');
  };

  if (currentPage === 'login') {
    return (
      <LoginPage
        onBack={() => setCurrentPage('landing')}
        onLoginSuccess={handleLoginSuccess}
      />
    );
  }

  if (currentPage === 'driver-main') {
    return <DriverMain onLogout={handleLogout} />;
  }

  if (currentPage === 'rider-main') {
    return <RiderMain onLogout={handleLogout} />;
  }

  // Landing page
  return (
    <LandingPage
      onGetStarted={() => setCurrentPage('login')}
      onSignIn={() => setCurrentPage('login')}
    />
  );
}