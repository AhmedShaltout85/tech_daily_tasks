package com.a08r.tasks_emp_complaint.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RetrieveEmpDataRequest {

    @NotNull(message = "Employee ID is required")
    private Integer empId;

    @NotBlank(message = "Employee name is required")
    @Size(max = 255, message = "Employee name must not exceed 255 characters")
    private String empName;

    @Size(max = 255, message = "Employee type must not exceed 255 characters")
    private String empType;

    @NotBlank(message = "Employee job is required")
    @Size(max = 255, message = "Employee job must not exceed 255 characters")
    private String empJob;

    @Size(max = 255, message = "Employee degree must not exceed 255 characters")
    private String empDegree;

    @NotBlank(message = "Employee location is required")
    @Size(max = 255, message = "Employee location must not exceed 255 characters")
    private String empLocation;

    @Size(max = 255, message = "Employee department must not exceed 255 characters")
    private String empDept;

    @Size(max = 255, message = "Employee admin must not exceed 255 characters")
    private String empAdmin;

    @Size(max = 255, message = "Employee sector must not exceed 255 characters")
    private String empSector;
}
