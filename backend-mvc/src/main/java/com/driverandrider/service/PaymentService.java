package com.driverandrider.service;

import com.driverandrider.dto.PaymentDto;
import com.driverandrider.exception.ResourceNotFoundException;
import com.driverandrider.model.Payment;
import com.driverandrider.model.Payment.PaymentStatus;
import com.driverandrider.model.Trip;
import com.driverandrider.model.Trip.TripStatus;
import com.driverandrider.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final TripService tripService;

    public List<Payment> findAll() {
        return paymentRepository.findAll();
    }

    public Payment findById(Long id) {
        return paymentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Payment", id));
    }

    public Payment findByTrip(Long tripId) {
        return paymentRepository.findByTripId(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment for trip " + tripId + " not found"));
    }

    public List<Payment> findByStatus(PaymentStatus status) {
        return paymentRepository.findByStatus(status);
    }

    public Payment initiatePayment(PaymentDto dto) {
        Trip trip = tripService.findById(dto.getTripId());

        if (trip.getStatus() != TripStatus.COMPLETED) {
            throw new IllegalStateException("Payment can only be initiated for COMPLETED trips");
        }

        if (paymentRepository.findByTripId(dto.getTripId()).isPresent()) {
            throw new IllegalStateException("Payment already initiated for this trip");
        }

        Payment payment = new Payment();
        payment.setTrip(trip);
        payment.setAmount(trip.getFareAmount());
        payment.setMethod(dto.getMethod());
        payment.setStatus(PaymentStatus.PENDING);
        payment.setTransactionReference(UUID.randomUUID().toString());

        return paymentRepository.save(payment);
    }

    public Payment confirmPayment(Long id) {
        Payment payment = findById(id);
        if (payment.getStatus() != PaymentStatus.PENDING) {
            throw new IllegalStateException("Payment is not PENDING");
        }
        payment.setStatus(PaymentStatus.COMPLETED);
        payment.setProcessedAt(LocalDateTime.now());
        return paymentRepository.save(payment);
    }

    public Payment refundPayment(Long id) {
        Payment payment = findById(id);
        if (payment.getStatus() != PaymentStatus.COMPLETED) {
            throw new IllegalStateException("Only COMPLETED payments can be refunded");
        }
        payment.setStatus(PaymentStatus.REFUNDED);
        return paymentRepository.save(payment);
    }

    public List<Payment> findByRider(Long riderId) {
        return paymentRepository.findByTrip_Rider_Id(riderId);
    }
}
