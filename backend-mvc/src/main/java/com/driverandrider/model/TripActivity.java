package com.driverandrider.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Immutable record of a single event in a trip's lifecycle.
 * <p>
 * activity_type values: TRIP_REQUESTED, TRIP_ACCEPTED, DRIVER_ARRIVED,
 *                       TRIP_STARTED, TRIP_COMPLETED, TRIP_CANCELLED
 * performed_by_role:    RIDER, DRIVER, SYSTEM
 */
@Entity
@Table(name = "trip_activities")
@Data
@NoArgsConstructor
public class TripActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Parent trip — excluded from JSON to avoid circular serialization. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id", nullable = false)
    @JsonIgnore
    private Trip trip;

    /** Convenience field — included in JSON responses. */
    @Transient
    private Long tripId;

    @PostLoad
    @PostPersist
    private void populateTripId() {
        if (trip != null) tripId = trip.getId();
    }

    /** One of: TRIP_REQUESTED, TRIP_ACCEPTED, DRIVER_ARRIVED,
     *          TRIP_STARTED, TRIP_COMPLETED, TRIP_CANCELLED */
    @Column(nullable = false, length = 50)
    private String activityType;

    /** Nullable — SYSTEM events have no actor. */
    private Long performedById;

    /** RIDER | DRIVER | SYSTEM */
    @Column(nullable = false, length = 20)
    private String performedByRole = "SYSTEM";

    private String performedByName;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    // ── Factory helpers ─────────────────────────────────────────

    public static TripActivity of(Trip trip, String type, String role,
                                   Long actorId, String actorName) {
        TripActivity a = new TripActivity();
        a.trip = trip;
        a.tripId = trip.getId();
        a.activityType = type;
        a.performedByRole = role;
        a.performedById = actorId;
        a.performedByName = actorName;
        a.createdAt = LocalDateTime.now();
        return a;
    }

    public static TripActivity system(Trip trip, String type, String note) {
        TripActivity a = of(trip, type, "SYSTEM", null, "System");
        a.note = note;
        return a;
    }
}
