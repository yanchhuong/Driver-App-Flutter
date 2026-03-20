package com.driverandrider.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

@Entity
@Table(name = "trips")
@Data
@NoArgsConstructor
public class Trip {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "rider_id", nullable = false)
    private Rider rider;

    @ManyToOne
    @JoinColumn(name = "driver_id")
    private Driver driver;

    private Double pickupLatitude;
    private Double pickupLongitude;
    private String pickupAddress;

    private Double dropoffLatitude;
    private Double dropoffLongitude;
    private String dropoffAddress;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false, columnDefinition = "trip_type")
    private TripType tripType;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(columnDefinition = "delivery_type")
    private DeliveryType deliveryType; // only when tripType = DELIVERY

    // Delivery-specific fields
    private String packageDescription;
    private String recipientName;
    private String recipientPhone;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(columnDefinition = "trip_status")
    private TripStatus status = TripStatus.REQUESTED;

    private LocalDateTime requestedAt = LocalDateTime.now();
    private LocalDateTime acceptedAt;
    /** Set when the driver physically arrives at the pickup point. */
    private LocalDateTime arrivedAt;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;

    private Double fareAmount;
    private Double distanceKm;

    public enum TripType {
        RIDE,       // Passenger calls driver to a destination
        DELIVERY    // Package delivery (Express or Normal)
    }

    public enum DeliveryType {
        EXPRESS,    // Fast / priority delivery
        NORMAL      // Standard delivery
    }

    public enum TripStatus {
        REQUESTED, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED
    }
}
