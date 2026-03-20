package com.driverandrider.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RiderDto {
    private Long id;

    @NotBlank
    private String name;

    @NotBlank
    private String email;

    @NotBlank
    private String phone;

    private Double rating;
}
