package com.driverandrider.repository;

import com.driverandrider.model.Payment;
import com.driverandrider.model.Payment.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    Optional<Payment> findByTripId(Long tripId);
    List<Payment> findByStatus(PaymentStatus status);
    Optional<Payment> findByTransactionReference(String transactionReference);
    List<Payment> findByTrip_Rider_Id(Long riderId);
}
