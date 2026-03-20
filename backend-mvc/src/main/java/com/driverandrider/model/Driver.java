package com.driverandrider.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "drivers")
@Data
@NoArgsConstructor
public class Driver {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String name;

    @NotBlank
    @Column(unique = true)
    private String email;

    @NotBlank
    private String phone;

    @NotBlank
    private String licenseNumber;

    private String vehicleType;
    private String vehiclePlate;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(columnDefinition = "driver_status")
    private DriverStatus status = DriverStatus.OFFLINE;

    private Double currentLatitude;
    private Double currentLongitude;
    private Double rating = 5.0;

    public enum DriverStatus {
        ONLINE, OFFLINE, ON_TRIP
    }
}
