package com.driverandrider.repository;

import com.driverandrider.model.Trip;
import com.driverandrider.model.Trip.TripStatus;
import com.driverandrider.model.Trip.TripType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripRepository extends JpaRepository<Trip, Long> {
    List<Trip> findByRiderId(Long riderId);
    List<Trip> findByDriverId(Long driverId);
    List<Trip> findByStatus(TripStatus status);
    List<Trip> findByTripType(TripType tripType);
    List<Trip> findByRiderIdAndTripType(Long riderId, TripType tripType);
    List<Trip> findByRiderIdAndStatus(Long riderId, TripStatus status);
    List<Trip> findByDriverIdAndStatus(Long driverId, TripStatus status);
}
