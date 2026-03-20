package com.driverandrider.controller;

import com.driverandrider.dto.DriverDto;
import com.driverandrider.model.Driver;
import com.driverandrider.model.Driver.DriverStatus;
import com.driverandrider.service.DriverService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/drivers")
@RequiredArgsConstructor
public class DriverController {

    private final DriverService driverService;

    @GetMapping
    public ResponseEntity<List<Driver>> getAll(
            @RequestParam(required = false) DriverStatus status) {
        List<Driver> drivers = status != null
                ? driverService.findByStatus(status)
                : driverService.findAll();
        return ResponseEntity.ok(drivers);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Driver> getById(@PathVariable Long id) {
        return ResponseEntity.ok(driverService.findById(id));
    }

    @PostMapping
    public ResponseEntity<Driver> register(@Valid @RequestBody DriverDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(driverService.register(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Driver> update(@PathVariable Long id, @Valid @RequestBody DriverDto dto) {
        return ResponseEntity.ok(driverService.update(id, dto));
    }

    @PatchMapping("/{id}/location")
    public ResponseEntity<Driver> updateLocation(
            @PathVariable Long id,
            @RequestBody Map<String, Double> location) {
        return ResponseEntity.ok(
                driverService.updateLocation(id, location.get("latitude"), location.get("longitude")));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Driver> updateStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        DriverStatus status = DriverStatus.valueOf(body.get("status"));
        return ResponseEntity.ok(driverService.updateStatus(id, status));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        driverService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
