package com.driverandrider.service;

import com.driverandrider.dto.DriverDto;
import com.driverandrider.exception.ResourceNotFoundException;
import com.driverandrider.model.Driver;
import com.driverandrider.model.Driver.DriverStatus;
import com.driverandrider.repository.DriverRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class DriverService {

    private final DriverRepository driverRepository;

    public List<Driver> findAll() {
        return driverRepository.findAll();
    }

    public Driver findById(Long id) {
        return driverRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Driver", id));
    }

    public List<Driver> findByStatus(DriverStatus status) {
        return driverRepository.findByStatus(status);
    }

    public Driver register(DriverDto dto) {
        if (driverRepository.existsByEmail(dto.getEmail())) {
            throw new IllegalStateException("Email already registered: " + dto.getEmail());
        }
        Driver driver = toEntity(dto);
        return driverRepository.save(driver);
    }

    public Driver update(Long id, DriverDto dto) {
        Driver driver = findById(id);
        driver.setName(dto.getName());
        driver.setPhone(dto.getPhone());
        driver.setVehicleType(dto.getVehicleType());
        driver.setVehiclePlate(dto.getVehiclePlate());
        if (dto.getRating() != null) driver.setRating(dto.getRating());
        return driverRepository.save(driver);
    }

    public Driver updateLocation(Long id, Double latitude, Double longitude) {
        Driver driver = findById(id);
        driver.setCurrentLatitude(latitude);
        driver.setCurrentLongitude(longitude);
        return driverRepository.save(driver);
    }

    public Driver updateStatus(Long id, DriverStatus status) {
        Driver driver = findById(id);
        driver.setStatus(status);
        return driverRepository.save(driver);
    }

    public void delete(Long id) {
        Driver driver = findById(id);
        driverRepository.delete(driver);
    }

    private Driver toEntity(DriverDto dto) {
        Driver driver = new Driver();
        driver.setName(dto.getName());
        driver.setEmail(dto.getEmail());
        driver.setPhone(dto.getPhone());
        driver.setLicenseNumber(dto.getLicenseNumber());
        driver.setVehicleType(dto.getVehicleType());
        driver.setVehiclePlate(dto.getVehiclePlate());
        return driver;
    }
}
