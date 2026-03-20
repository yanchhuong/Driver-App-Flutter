package com.driverandrider.dto;

import com.driverandrider.model.Trip.DeliveryType;
import com.driverandrider.model.Trip.TripStatus;
import com.driverandrider.model.Trip.TripType;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class TripDto {
    private Long id;

    @NotNull
    private Long riderId;

    private Long driverId;

    @NotNull
    private TripType tripType;

    // Required only when tripType = DELIVERY
    private DeliveryType deliveryType;
    private String packageDescription;
    private String recipientName;
    private String recipientPhone;

    @NotNull
    private Double pickupLatitude;

    @NotNull
    private Double pickupLongitude;

    private String pickupAddress;

    @NotNull
    private Double dropoffLatitude;

    @NotNull
    private Double dropoffLongitude;

    private String dropoffAddress;

    private TripStatus status;
    private LocalDateTime requestedAt;
    private LocalDateTime completedAt;
    private Double fareAmount;
    private Double distanceKm;
}
