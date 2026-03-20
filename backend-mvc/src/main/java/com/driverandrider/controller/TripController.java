package com.driverandrider.controller;

import com.driverandrider.dto.TripDto;
import com.driverandrider.model.Trip;
import com.driverandrider.model.Trip.TripStatus;
import com.driverandrider.model.Trip.TripType;
import com.driverandrider.model.TripActivity;
import com.driverandrider.service.TripService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/trips")
@RequiredArgsConstructor
public class TripController {

    private final TripService tripService;

    @GetMapping
    public ResponseEntity<List<Trip>> getAll(
            @RequestParam(required = false) TripStatus status,
            @RequestParam(required = false) TripType tripType,
            @RequestParam(required = false) Long riderId,
            @RequestParam(required = false) Long driverId) {
        if (riderId != null) return ResponseEntity.ok(tripService.findByRider(riderId));
        if (driverId != null) return ResponseEntity.ok(tripService.findByDriver(driverId));
        if (status != null) return ResponseEntity.ok(tripService.findByStatus(status));
        if (tripType != null) return ResponseEntity.ok(tripService.findByTripType(tripType));
        return ResponseEntity.ok(tripService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Trip> getById(@PathVariable Long id) {
        return ResponseEntity.ok(tripService.findById(id));
    }

    @PostMapping
    public ResponseEntity<Trip> requestTrip(@Valid @RequestBody TripDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tripService.requestTrip(dto));
    }

    @PatchMapping("/{id}/accept")
    public ResponseEntity<Trip> acceptTrip(
            @PathVariable Long id,
            @RequestBody Map<String, Long> body) {
        return ResponseEntity.ok(tripService.acceptTrip(id, body.get("driverId")));
    }

    @PatchMapping("/{id}/start")
    public ResponseEntity<Trip> startTrip(@PathVariable Long id) {
        return ResponseEntity.ok(tripService.startTrip(id));
    }

    @PatchMapping("/{id}/complete")
    public ResponseEntity<Trip> completeTrip(
            @PathVariable Long id,
            @RequestBody Map<String, Double> body) {
        return ResponseEntity.ok(
                tripService.completeTrip(id, body.get("distanceKm"), body.get("fareAmount")));
    }

    @PatchMapping("/{id}/arrive")
    public ResponseEntity<Trip> arriveAtPickup(
            @PathVariable Long id,
            @RequestBody Map<String, Long> body) {
        return ResponseEntity.ok(tripService.arriveAtPickup(id, body.get("driverId")));
    }

    @PatchMapping("/{id}/cancel")
    public ResponseEntity<Trip> cancelTrip(@PathVariable Long id) {
        return ResponseEntity.ok(tripService.cancelTrip(id));
    }

    @GetMapping("/{id}/activities")
    public ResponseEntity<List<TripActivity>> getActivities(@PathVariable Long id) {
        return ResponseEntity.ok(tripService.findActivities(id));
    }
}
