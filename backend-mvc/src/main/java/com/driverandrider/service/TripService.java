package com.driverandrider.service;

import com.driverandrider.dto.TripDto;
import com.driverandrider.exception.ResourceNotFoundException;
import com.driverandrider.model.Driver;
import com.driverandrider.model.Driver.DriverStatus;
import com.driverandrider.model.Rider;
import com.driverandrider.model.Trip;
import com.driverandrider.model.Trip.DeliveryType;
import com.driverandrider.model.Trip.TripStatus;
import com.driverandrider.model.Trip.TripType;
import com.driverandrider.model.TripActivity;
import com.driverandrider.repository.TripActivityRepository;
import com.driverandrider.repository.TripRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class TripService {

    private final TripRepository         tripRepository;
    private final TripActivityRepository activityRepository;
    private final RiderService           riderService;
    private final DriverService          driverService;
    private final PusherBeamsService     pusherBeamsService;
    private final PusherChannelsService  pusherChannelsService;

    // ── Queries ─────────────────────────────────────────────────

    public List<Trip> findAll()                          { return tripRepository.findAll(); }
    public Trip       findById(Long id)                  { return tripRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Trip", id)); }
    public List<Trip> findByRider(Long riderId)          { riderService.findById(riderId); return tripRepository.findByRiderId(riderId); }
    public List<Trip> findByDriver(Long driverId)        { return tripRepository.findByDriverId(driverId); }
    public List<Trip> findByStatus(TripStatus status)    { return tripRepository.findByStatus(status); }
    public List<Trip> findByTripType(TripType tripType)  { return tripRepository.findByTripType(tripType); }

    public List<Trip> findByRiderAndTripType(Long riderId, TripType tripType) {
        riderService.findById(riderId);
        return tripRepository.findByRiderIdAndTripType(riderId, tripType);
    }

    public List<TripActivity> findActivities(Long tripId) {
        findById(tripId); // verify exists
        return activityRepository.findByTrip_IdOrderByCreatedAtAsc(tripId);
    }

    // ── Commands ────────────────────────────────────────────────

    public Trip requestTrip(TripDto dto) {
        if (dto.getTripType() == null)
            throw new IllegalStateException("tripType is required (RIDE or DELIVERY)");
        if (dto.getTripType() == TripType.DELIVERY && dto.getDeliveryType() == null)
            throw new IllegalStateException("deliveryType is required for DELIVERY trips");

        Rider rider = riderService.findById(dto.getRiderId());

        Trip trip = new Trip();
        trip.setRider(rider);
        trip.setTripType(dto.getTripType());
        trip.setDeliveryType(dto.getDeliveryType());
        trip.setPackageDescription(dto.getPackageDescription());
        trip.setRecipientName(dto.getRecipientName());
        trip.setRecipientPhone(dto.getRecipientPhone());
        trip.setPickupLatitude(dto.getPickupLatitude());
        trip.setPickupLongitude(dto.getPickupLongitude());
        trip.setPickupAddress(dto.getPickupAddress());
        trip.setDropoffLatitude(dto.getDropoffLatitude());
        trip.setDropoffLongitude(dto.getDropoffLongitude());
        trip.setDropoffAddress(dto.getDropoffAddress());
        trip.setStatus(TripStatus.REQUESTED);
        trip.setRequestedAt(LocalDateTime.now());

        Trip saved = tripRepository.save(trip);

        // Record activity
        record(saved, "TRIP_REQUESTED", "RIDER", rider.getId(), rider.getName(), null);

        // Real-time & push notifications
        pusherChannelsService.broadcastTripRequested(saved);
        pusherBeamsService.notifyNewTripRequest(saved.getId(), saved.getPickupAddress());
        return saved;
    }

    public Trip acceptTrip(Long tripId, Long driverId) {
        Trip trip = findById(tripId);
        if (trip.getStatus() != TripStatus.REQUESTED)
            throw new IllegalStateException("Trip is not in REQUESTED state");

        Driver driver = driverService.findById(driverId);
        trip.setDriver(driver);
        trip.setStatus(TripStatus.ACCEPTED);
        trip.setAcceptedAt(LocalDateTime.now());

        driverService.updateStatus(driverId, DriverStatus.ON_TRIP);
        Trip saved = tripRepository.save(trip);

        record(saved, "TRIP_ACCEPTED", "DRIVER", driver.getId(), driver.getName(), null);

        pusherChannelsService.broadcastTripAccepted(saved.getId());
        pusherChannelsService.notifyRiderTripAccepted(
                saved.getRider().getId(), saved.getId(),
                driver.getName(), driver.getPhone(),
                driver.getVehicleType(), driver.getVehiclePlate());
        pusherBeamsService.notifyTripAccepted(saved.getRider().getId(), driver.getName());
        return saved;
    }

    /** Driver has physically arrived at the pickup location. */
    public Trip arriveAtPickup(Long tripId, Long driverId) {
        Trip trip = findById(tripId);
        if (trip.getStatus() != TripStatus.ACCEPTED)
            throw new IllegalStateException("Trip is not in ACCEPTED state");
        if (trip.getDriver() == null || !trip.getDriver().getId().equals(driverId))
            throw new IllegalStateException("Only the assigned driver can mark arrival");

        trip.setArrivedAt(LocalDateTime.now());
        Trip saved = tripRepository.save(trip);

        Driver driver = trip.getDriver();
        record(saved, "DRIVER_ARRIVED", "DRIVER", driver.getId(), driver.getName(),
               "Driver arrived at pickup");

        // Notify rider in real-time
        Long riderId = saved.getRider() != null ? saved.getRider().getId() : null;
        pusherChannelsService.broadcastTripActivity(saved.getId(), riderId, "DRIVER_ARRIVED");
        return saved;
    }

    public Trip startTrip(Long tripId) {
        Trip trip = findById(tripId);
        if (trip.getStatus() != TripStatus.ACCEPTED)
            throw new IllegalStateException("Trip is not in ACCEPTED state");

        trip.setStatus(TripStatus.IN_PROGRESS);
        trip.setStartedAt(LocalDateTime.now());
        Trip saved = tripRepository.save(trip);

        Driver driver = saved.getDriver();
        String name = driver != null ? driver.getName() : "Driver";
        Long  did   = driver != null ? driver.getId()   : null;
        record(saved, "TRIP_STARTED", "DRIVER", did, name, null);

        Long riderId2 = saved.getRider() != null ? saved.getRider().getId() : null;
        pusherBeamsService.notifyTripStarted(riderId2);
        pusherChannelsService.broadcastTripActivity(saved.getId(), riderId2, "TRIP_STARTED");
        return saved;
    }

    public Trip completeTrip(Long tripId, Double distanceKm, Double fareAmount) {
        Trip trip = findById(tripId);
        if (trip.getStatus() != TripStatus.IN_PROGRESS)
            throw new IllegalStateException("Trip is not IN_PROGRESS");

        trip.setStatus(TripStatus.COMPLETED);
        trip.setCompletedAt(LocalDateTime.now());
        trip.setDistanceKm(distanceKm);
        trip.setFareAmount(fareAmount);

        driverService.updateStatus(trip.getDriver().getId(), DriverStatus.ONLINE);
        Trip saved = tripRepository.save(trip);

        Driver driver = saved.getDriver();
        record(saved, "TRIP_COMPLETED", "DRIVER",
               driver != null ? driver.getId() : null,
               driver != null ? driver.getName() : "Driver",
               String.format("Distance: %.1f km, Fare: $%.2f", distanceKm, fareAmount));

        Long riderId3 = saved.getRider() != null ? saved.getRider().getId() : null;
        pusherBeamsService.notifyTripCompleted(riderId3, saved.getFareAmount());
        pusherChannelsService.broadcastTripActivity(saved.getId(), riderId3, "TRIP_COMPLETED");
        return saved;
    }

    public Trip cancelTrip(Long tripId) {
        Trip trip = findById(tripId);
        if (trip.getStatus() == TripStatus.COMPLETED || trip.getStatus() == TripStatus.CANCELLED)
            throw new IllegalStateException("Cannot cancel a " + trip.getStatus() + " trip");

        String cancelledBy = "SYSTEM";
        Long actorId = null;
        String actorName = "System";

        trip.setStatus(TripStatus.CANCELLED);
        if (trip.getDriver() != null) {
            driverService.updateStatus(trip.getDriver().getId(), DriverStatus.ONLINE);
        }
        Trip saved = tripRepository.save(trip);

        record(saved, "TRIP_CANCELLED", cancelledBy, actorId, actorName, null);

        Long riderId4 = saved.getRider() != null ? saved.getRider().getId() : null;
        pusherChannelsService.broadcastTripCancelled(saved.getId());
        pusherBeamsService.notifyTripCancelled(riderId4);
        return saved;
    }

    // ── Private helpers ─────────────────────────────────────────

    private void record(Trip trip, String type, String role,
                        Long actorId, String actorName, String note) {
        TripActivity a = TripActivity.of(trip, type, role, actorId, actorName);
        if (note != null) a.setNote(note);
        activityRepository.save(a);
    }
}
