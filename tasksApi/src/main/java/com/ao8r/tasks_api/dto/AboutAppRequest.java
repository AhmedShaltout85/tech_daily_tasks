package com.ao8r.tasks_api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AboutAppRequest {

    @NotBlank(message = "App name is required")
    @Size(max = 255, message = "App name must not exceed 255 characters")
    private String appName;

    @NotBlank(message = "Recommended is required")
    @Size(max = 255, message = "Recommended must not exceed 255 characters")
    private String recommended;
}