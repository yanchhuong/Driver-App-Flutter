package com.driverandrider.controller;

import com.driverandrider.dto.PaymentDto;
import com.driverandrider.model.Payment;
import com.driverandrider.model.Payment.PaymentStatus;
import com.driverandrider.service.PaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @GetMapping
    public ResponseEntity<List<Payment>> getAll(
            @RequestParam(required = false) PaymentStatus status) {
        List<Payment> payments = status != null
                ? paymentService.findByStatus(status)
                : paymentService.findAll();
        return ResponseEntity.ok(payments);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Payment> getById(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.findById(id));
    }

    @GetMapping("/trip/{tripId}")
    public ResponseEntity<Payment> getByTrip(@PathVariable Long tripId) {
        return ResponseEntity.ok(paymentService.findByTrip(tripId));
    }

    @PostMapping
    public ResponseEntity<Payment> initiatePayment(@Valid @RequestBody PaymentDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(paymentService.initiatePayment(dto));
    }

    @PatchMapping("/{id}/confirm")
    public ResponseEntity<Payment> confirmPayment(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.confirmPayment(id));
    }

    @PatchMapping("/{id}/refund")
    public ResponseEntity<Payment> refundPayment(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.refundPayment(id));
    }
}
