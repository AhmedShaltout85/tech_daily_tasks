package com.ao8r.tasks_api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AboutAppRequest {

    @NotBlank(message = "App name is required")
    @Size(max = 255, message = "App name must not exceed 255 characters")
    private String appName;

    @NotBlank(message = "Department is required")
    @Size(max = 255, message = "Department must not exceed 255 characters")
    private String department;

    private List<String> recommended;
}