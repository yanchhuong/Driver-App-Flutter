package com.driverandrider.repository;

import com.driverandrider.model.Driver;
import com.driverandrider.model.Driver.DriverStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DriverRepository extends JpaRepository<Driver, Long> {
    Optional<Driver> findByEmail(String email);
    List<Driver> findByStatus(DriverStatus status);
    boolean existsByEmail(String email);
    boolean existsByLicenseNumber(String licenseNumber);
}
