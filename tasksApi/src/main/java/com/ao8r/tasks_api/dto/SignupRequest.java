package com.ao8r.tasks_api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class SignupRequest {

    @NotBlank(message = "Display name is required")
    @Size(max = 50, message = "Display name must not exceed 50 characters")
    private String displayName;

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 20, message = "Username must be between 3 and 20 characters")
    private String username;

    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 40, message = "Password must be between 6 and 40 characters")
    private String password;

    @NotBlank(message = "Department is required")
    private String role;

    @NotBlank(message = "Department is required")
    private String department;
}
