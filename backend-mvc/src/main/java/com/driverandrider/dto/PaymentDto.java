package com.driverandrider.dto;

import com.driverandrider.model.Payment.PaymentMethod;
import com.driverandrider.model.Payment.PaymentStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class PaymentDto {
    private Long id;

    @NotNull
    private Long tripId;

    private Double amount;
    private String currency;
    private PaymentStatus status;

    @NotNull
    private PaymentMethod method;

    private String transactionReference;
    private LocalDateTime processedAt;
}
