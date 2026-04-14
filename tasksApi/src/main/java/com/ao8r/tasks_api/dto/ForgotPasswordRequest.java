package com.ao8r.tasks_api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ForgotPasswordRequest {

    @NotBlank
    private String username;

    @NotBlank
    @Size(min = 6, max = 40)
    private String newPassword;
}
