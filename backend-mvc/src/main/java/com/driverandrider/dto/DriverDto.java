package com.driverandrider.dto;

import com.driverandrider.model.Driver.DriverStatus;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class DriverDto {
    private Long id;

    @NotBlank
    private String name;

    @NotBlank
    private String email;

    @NotBlank
    private String phone;

    @NotBlank
    private String licenseNumber;

    private String vehicleType;
    private String vehiclePlate;
    private DriverStatus status;
    private Double currentLatitude;
    private Double currentLongitude;
    private Double rating;
}
