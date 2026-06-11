package com.a08r.tasks_emp_complaint.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TaskEmpComplaintRequest {

    @NotBlank(message = "App name is required")
    @Size(max = 255, message = "App name must not exceed 255 characters")
    private String appName;

    @NotBlank(message = "Complaint name is required")
    @Size(max = 255, message = "Complaint name must not exceed 255 characters")
    private String complaintName;

    @NotBlank(message = "Place name is required")
    @Size(max = 255, message = "Place name must not exceed 255 characters")
    private String placeName;

    @NotBlank(message = "Department is required")
    @Size(max = 255, message = "Department must not exceed 255 characters")
    private String department;

    @Size(max = 255, message = "Sub place must not exceed 255 characters")
    private String subPlace;

    @NotBlank(message = "Employee name is required")
    @Size(max = 255, message = "Employee name must not exceed 255 characters")
    private String empName;

    @NotNull(message = "Employee number is required")
    private String empNumber;

    @NotNull(message = "Employee mobile is required")
    private String empMobile;

    @Builder.Default
    private Boolean isEnable = true;
}
