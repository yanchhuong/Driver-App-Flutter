package com.driverandrider.controller;

import com.driverandrider.dto.RiderDto;
import com.driverandrider.model.Payment;
import com.driverandrider.model.Rider;
import com.driverandrider.model.Trip;
import com.driverandrider.model.Trip.TripType;
import com.driverandrider.service.PaymentService;
import com.driverandrider.service.RiderService;
import com.driverandrider.service.TripService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/riders")
@RequiredArgsConstructor
public class RiderController {

    private final RiderService riderService;
    private final TripService tripService;
    private final PaymentService paymentService;

    @GetMapping
    public ResponseEntity<List<Rider>> getAll() {
        return ResponseEntity.ok(riderService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Rider> getById(@PathVariable Long id) {
        return ResponseEntity.ok(riderService.findById(id));
    }

    @PostMapping
    public ResponseEntity<Rider> register(@Valid @RequestBody RiderDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(riderService.register(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Rider> update(@PathVariable Long id, @Valid @RequestBody RiderDto dto) {
        return ResponseEntity.ok(riderService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        riderService.delete(id);
        return ResponseEntity.noContent().build();
    }

    // All trips (RIDE + DELIVERY) that belong to this rider, with optional type filter
    @GetMapping("/{id}/trips")
    public ResponseEntity<List<Trip>> getTrips(
            @PathVariable Long id,
            @RequestParam(required = false) TripType tripType) {
        List<Trip> trips = tripType != null
                ? tripService.findByRiderAndTripType(id, tripType)
                : tripService.findByRider(id);
        return ResponseEntity.ok(trips);
    }

    @GetMapping("/{id}/payments")
    public ResponseEntity<List<Payment>> getPayments(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.findByRider(id));
    }
}
